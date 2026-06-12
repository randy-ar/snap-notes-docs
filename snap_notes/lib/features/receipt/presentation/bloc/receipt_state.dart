import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/receipt/domain/entities/receipt_entity.dart';
import 'package:snap_notes/features/receipt/domain/entities/recognized_text_entity.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  @override
  List<Object> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptCameraPreview extends ReceiptState {}

class ReceiptImageSelected extends ReceiptState {
  final File image;

  const ReceiptImageSelected({required this.image});

  @override
  List<Object> get props => [image];
}

class ReceiptTextRecognizedPreview extends ReceiptState {
  final File image;
  final RecognizedTextEntity recognizedText;

  const ReceiptTextRecognizedPreview({
    required this.image,
    required this.recognizedText,
  });

  @override
  List<Object> get props => [image, recognizedText];
}

class ReceiptPayloadPreview extends ReceiptState {
  final File image;
  final String rawText;
  final Map<String, dynamic> payload;
  final List<TextLineEntity> lines;
  final double imageWidth;
  final double imageHeight;

  const ReceiptPayloadPreview({
    required this.image,
    required this.rawText,
    required this.payload,
    required this.lines,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  List<Object> get props => [image, rawText, payload, lines];
}

class ReceiptResponsePreview extends ReceiptState {
  final File image;
  final Map<String, dynamic> response;
  final ReceiptEntity receipt;

  const ReceiptResponsePreview({
    required this.image,
    required this.response,
    required this.receipt,
  });

  @override
  List<Object> get props => [image, response, receipt];
}

class ReceiptLoading extends ReceiptState {
  final File? image;
  final List<TextLineEntity>? lines;
  final double? imageWidth;
  final double? imageHeight;

  const ReceiptLoading({
    this.image,
    this.lines,
    this.imageWidth,
    this.imageHeight,
  });

  @override
  List<Object> get props => [image ?? Object(), lines ?? [], imageWidth ?? 0, imageHeight ?? 0];
}

class ReceiptParsed extends ReceiptState {
  final ReceiptEntity receipt;
  final File image;

  const ReceiptParsed({required this.receipt, required this.image});

  @override
  List<Object> get props => [receipt, image];
}

class ReceiptConfirmed extends ReceiptState {
  final ReceiptEntity receipt;
  final File? image;

  const ReceiptConfirmed({
    required this.receipt,
    this.image,
  });

  @override
  List<Object> get props => [receipt, image ?? Object()];
}

class ReceiptError extends ReceiptState {
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? serverResponse;
  final int? statusCode;

  const ReceiptError({
    required this.message,
    this.stackTrace,
    this.serverResponse,
    this.statusCode,
  });

  @override
  List<Object> get props => [message, stackTrace ?? '', serverResponse ?? {}, statusCode ?? 0];
}
