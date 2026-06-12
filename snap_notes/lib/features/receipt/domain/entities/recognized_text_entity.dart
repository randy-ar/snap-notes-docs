import 'dart:ui';
import 'package:equatable/equatable.dart';

class RecognizedTextEntity extends Equatable {
  final String text;
  final List<TextLineEntity> lines;
  final double imageWidth;
  final double imageHeight;

  const RecognizedTextEntity({
    required this.text,
    required this.lines,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  List<Object?> get props => [text, lines, imageWidth, imageHeight];
}

class TextLineEntity extends Equatable {
  final int lineIndex;
  final String text;
  final Rect boundingBox;

  const TextLineEntity({
    required this.lineIndex,
    required this.text,
    required this.boundingBox,
  });

  @override
  List<Object?> get props => [lineIndex, text, boundingBox];
}
