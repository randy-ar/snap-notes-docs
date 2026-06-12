import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/features/receipt/data/datasources/receipt_local_datasource.dart';
import 'package:snap_notes/features/receipt/data/datasources/receipt_remote_datasource.dart';
import 'package:snap_notes/features/receipt/domain/usecases/scan_receipt.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_event.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final ScanReceiptUseCase scanReceipt;
  final ReceiptLocalDataSource localDataSource;
  final ReceiptRemoteDataSource remoteDataSource;

  ReceiptBloc({
    required this.scanReceipt,
    required this.localDataSource,
    required this.remoteDataSource,
  }) : super(ReceiptCameraPreview()) {
    on<StartCameraEvent>((event, emit) {
      emit(ReceiptCameraPreview());
    });

    // New flow: Image selected from gallery
    on<ImageSelectedEvent>((event, emit) {
      emit(ReceiptImageSelected(image: event.image));
    });

    // New flow: Crop image and return to image selected state
    on<CropImageEvent>((event, emit) async {
      emit(ReceiptImageSelected(image: event.image));
    });

    // New flow: Proceed to scan (ML Kit text recognition preview)
    on<ProceedToScanEvent>((event, emit) async {
      emit(ReceiptLoading(image: event.image));
      try {
        final recognizedText = await localDataSource.extractTextFromImage(event.image);
        emit(ReceiptTextRecognizedPreview(
          image: event.image,
          recognizedText: recognizedText,
        ));
      } catch (e, stackTrace) {
        debugPrint('Error in ProceedToScanEvent: $e\n$stackTrace');
        emit(ReceiptError(message: 'Failed to recognize text: $e'));
      }
    });

    // New flow: Proceed to payload preview
    on<ProceedToPayloadEvent>((event, emit) async {
      emit(ReceiptLoading(image: event.image));
      try {
        final payload = {
          'rawText': event.recognizedText.text,
          'imagePath': event.image.path,
          'imageSize': {
            'width': event.recognizedText.imageWidth,
            'height': event.recognizedText.imageHeight,
          },
          'linesCount': event.recognizedText.lines.length,
          'lines': event.recognizedText.lines.map((line) => {
            'lineIndex': line.lineIndex,
            'text': line.text,
            'boundingBox': {
              'left': line.boundingBox.left,
              'top': line.boundingBox.top,
              'right': line.boundingBox.right,
              'bottom': line.boundingBox.bottom,
            },
          }).toList(),
        };
        emit(ReceiptPayloadPreview(
          image: event.image,
          rawText: event.recognizedText.text,
          payload: payload,
          lines: event.recognizedText.lines,
          imageWidth: event.recognizedText.imageWidth,
          imageHeight: event.recognizedText.imageHeight,
        ));
      } catch (e, stackTrace) {
        debugPrint('Error in ProceedToPayloadEvent: $e\n$stackTrace');
        emit(ReceiptError(message: 'Failed to prepare payload: $e'));
      }
    });

    // New flow: Upload to server and show response preview
    on<UploadToServerEvent>((event, emit) async {
      emit(ReceiptLoading(
        image: event.image,
        lines: event.lines,
        imageWidth: event.imageWidth,
        imageHeight: event.imageHeight,
      ));
      try {
        final receiptModel = await remoteDataSource.parseReceiptData(
          event.rawText,
          event.image,
          event.lines,
          event.imageWidth,
          event.imageHeight,
        );
        final response = receiptModel.toJson();
        emit(ReceiptResponsePreview(
          image: event.image,
          response: response,
          receipt: receiptModel,
        ));
      } catch (e, stackTrace) {
        debugPrint('Error in UploadToServerEvent: $e\n$stackTrace');
        String errorMessage = 'Failed to upload: $e';
        String? stackTraceStr = stackTrace.toString();
        Map<String, dynamic>? serverResponse;
        int? statusCode;

        if (e is ServerException) {
          errorMessage = e.message;
          serverResponse = e.serverResponse;
          statusCode = e.statusCode;
          stackTraceStr = e.stackTrace?.toString() ?? stackTraceStr;
        }

        emit(ReceiptError(
          message: errorMessage,
          stackTrace: stackTraceStr,
          serverResponse: serverResponse,
          statusCode: statusCode,
        ));
      }
    });

    // Legacy flow - still supported
    on<ScanReceiptEvent>((event, emit) async {
      emit(ReceiptLoading(image: event.image));
      final result = await scanReceipt(ScanReceiptParams(image: event.image));
      result.fold(
        (failure) {
          debugPrint('Error in ScanReceiptEvent: ${failure.message}');
          emit(ReceiptError(message: failure.message));
        },
        (receipt) => emit(ReceiptParsed(receipt: receipt, image: event.image)),
      );
    });

    on<ConfirmReceiptEvent>((event, emit) {
      if (state is ReceiptParsed) {
        emit(ReceiptConfirmed(
          receipt: (state as ReceiptParsed).receipt,
          image: (state as ReceiptParsed).image,
        ));
      } else if (state is ReceiptResponsePreview) {
        emit(ReceiptConfirmed(
          receipt: (state as ReceiptResponsePreview).receipt,
          image: (state as ReceiptResponsePreview).image,
        ));
      }
    });

    on<CancelReceiptEvent>((event, emit) {
      emit(ReceiptCameraPreview());
    });
  }
}
