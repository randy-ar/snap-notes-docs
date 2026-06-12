import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/receipt/domain/entities/recognized_text_entity.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object> get props => [];
}

class StartCameraEvent extends ReceiptEvent {}

class ImageSelectedEvent extends ReceiptEvent {
  final File image;

  const ImageSelectedEvent(this.image);

  @override
  List<Object> get props => [image];
}

class CropImageEvent extends ReceiptEvent {
  final File image;

  const CropImageEvent(this.image);

  @override
  List<Object> get props => [image];
}

class ProceedToScanEvent extends ReceiptEvent {
  final File image;

  const ProceedToScanEvent(this.image);

  @override
  List<Object> get props => [image];
}

class ProceedToPayloadEvent extends ReceiptEvent {
  final File image;
  final RecognizedTextEntity recognizedText;

  const ProceedToPayloadEvent({
    required this.image,
    required this.recognizedText,
  });

  @override
  List<Object> get props => [image, recognizedText];
}

class UploadToServerEvent extends ReceiptEvent {
  final File image;
  final String rawText;
  final List<TextLineEntity> lines;
  final double imageWidth;
  final double imageHeight;

  const UploadToServerEvent({
    required this.image,
    required this.rawText,
    required this.lines,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  List<Object> get props => [image, rawText, lines];
}

class ConfirmReceiptEvent extends ReceiptEvent {}

class CancelReceiptEvent extends ReceiptEvent {}

class ScanReceiptEvent extends ReceiptEvent {
  final File image;

  const ScanReceiptEvent(this.image);

  @override
  List<Object> get props => [image];
}
