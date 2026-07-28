import 'package:flutter/material.dart';
import 'package:foodfo/utils/constant.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    // Should each log print contain a timestamp
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

Color getConfidenceColor(double confidence, ColorScheme colorScheme) {
  return switch (confidence) {
    < confidenceThreshold => colorScheme.primaryContainer,
    < 0.5 => Colors.yellow.shade200,
    < 0.7 => Colors.lightGreen.shade100,
    < 0.9 => Colors.lightGreen.shade200,
    _ => Colors.lightGreen.shade300,
  };
}
