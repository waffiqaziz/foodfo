import 'package:flutter/material.dart';

class CropImageTheme {
  final Color toolbarColor;
  final Color toolbarWidgetColor;
  final Color backgroundColor;
  final Color activeControlsColor;
  final Color cropFrameColor;
  final Color cropGridColor;
  final Color dimmedLayerColor;
  final bool statusBarLight;

  const CropImageTheme({
    required this.toolbarColor,
    required this.toolbarWidgetColor,
    required this.backgroundColor,
    required this.activeControlsColor,
    required this.cropFrameColor,
    required this.cropGridColor,
    required this.dimmedLayerColor,
    required this.statusBarLight,
  });

  factory CropImageTheme.fromColorScheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return CropImageTheme(
      toolbarColor: colorScheme.primary,
      toolbarWidgetColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.surface,
      activeControlsColor: colorScheme.primary,
      cropFrameColor: colorScheme.primary,
      cropGridColor: colorScheme.onSurface.withValues(alpha: 0.3),
      dimmedLayerColor: colorScheme.surface.withValues(alpha: 0.8),
      statusBarLight: brightness == Brightness.dark,
    );
  }
}
