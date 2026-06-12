import 'dart:ui';
import 'package:equatable/equatable.dart';

class RecognizedText extends Equatable {
  final String text;
  final List<TextLine> lines;
  final double imageWidth;
  final double imageHeight;

  const RecognizedText({
    required this.text,
    required this.lines,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  List<Object?> get props => [text, lines, imageWidth, imageHeight];
}

class TextLine extends Equatable {
  final int lineIndex;
  final String text;
  final Rect boundingBox;

  const TextLine({
    required this.lineIndex,
    required this.text,
    required this.boundingBox,
  });

  @override
  List<Object?> get props => [lineIndex, text, boundingBox];
}
