import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:snap_notes/features/receipt/domain/entities/recognized_text_entity.dart';

abstract class ReceiptLocalDataSource {
  Future<RecognizedTextEntity> extractTextFromImage(File image);
}

class ReceiptLocalDataSourceImpl implements ReceiptLocalDataSource {
  @override
  Future<RecognizedTextEntity> extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    
    // Get image dimensions
    final decodedImage = await decodeImageFromList(await image.readAsBytes());
    final imageWidth = decodedImage.width.toDouble();
    final imageHeight = decodedImage.height.toDouble();

    int lineIndex = 0;
    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => TextLineEntity(
              lineIndex: lineIndex++,
              text: line.text,
              boundingBox: line.boundingBox,
            ))
        .toList();

    return RecognizedTextEntity(
      text: recognizedText.text,
      lines: lines,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }
}
