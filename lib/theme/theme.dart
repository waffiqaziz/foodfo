import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff904a47),
      surfaceTint: Color(0xff904a47),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad7),
      onPrimaryContainer: Color(0xff733331),
      secondary: Color(0xff815512),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffddb7),
      onSecondaryContainer: Color(0xff653e00),
      tertiary: Color(0xff765a0b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffdf9a),
      onTertiaryContainer: Color(0xff5a4300),
      error: Color(0xff904a43),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff73332d),
      surface: Color(0xfffff9ed),
      onSurface: Color(0xff1e1c13),
      onSurfaceVariant: Color(0xff534342),
      outline: Color(0xff857371),
      outlineVariant: Color(0xffd8c2c0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff333027),
      inversePrimary: Color(0xffffb3af),
      primaryFixed: Color(0xffffdad7),
      onPrimaryFixed: Color(0xff3b080a),
      primaryFixedDim: Color(0xffffb3af),
      onPrimaryFixedVariant: Color(0xff733331),
      secondaryFixed: Color(0xffffddb7),
      onSecondaryFixed: Color(0xff2a1700),
      secondaryFixedDim: Color(0xfff7bb70),
      onSecondaryFixedVariant: Color(0xff653e00),
      tertiaryFixed: Color(0xffffdf9a),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xffe7c26c),
      onTertiaryFixedVariant: Color(0xff5a4300),
      surfaceDim: Color(0xffe0d9cc),
      surfaceBright: Color(0xfffff9ed),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffaf3e5),
      surfaceContainer: Color(0xfff4eddf),
      surfaceContainerHigh: Color(0xffeee8da),
      surfaceContainerHighest: Color(0xffe8e2d4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb3af),
      surfaceTint: Color(0xffffb3af),
      onPrimary: Color(0xff571d1d),
      primaryContainer: Color(0xff733331),
      onPrimaryContainer: Color(0xffffdad7),
      secondary: Color(0xfff7bb70),
      onSecondary: Color(0xff462a00),
      secondaryContainer: Color(0xff653e00),
      onSecondaryContainer: Color(0xffffddb7),
      tertiary: Color(0xffe7c26c),
      onTertiary: Color(0xff3f2e00),
      tertiaryContainer: Color(0xff5a4300),
      onTertiaryContainer: Color(0xffffdf9a),
      error: Color(0xffffb4ab),
      onError: Color(0xff561e19),
      errorContainer: Color(0xff73332d),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff15130b),
      onSurface: Color(0xffe8e2d4),
      onSurfaceVariant: Color(0xffd8c2c0),
      outline: Color(0xffa08c8b),
      outlineVariant: Color(0xff534342),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e2d4),
      inversePrimary: Color(0xff904a47),
      primaryFixed: Color(0xffffdad7),
      onPrimaryFixed: Color(0xff3b080a),
      primaryFixedDim: Color(0xffffb3af),
      onPrimaryFixedVariant: Color(0xff733331),
      secondaryFixed: Color(0xffffddb7),
      onSecondaryFixed: Color(0xff2a1700),
      secondaryFixedDim: Color(0xfff7bb70),
      onSecondaryFixedVariant: Color(0xff653e00),
      tertiaryFixed: Color(0xffffdf9a),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xffe7c26c),
      onTertiaryFixedVariant: Color(0xff5a4300),
      surfaceDim: Color(0xff15130b),
      surfaceBright: Color(0xff3c3930),
      surfaceContainerLowest: Color(0xff100e07),
      surfaceContainerLow: Color(0xff1e1c13),
      surfaceContainer: Color(0xff222017),
      surfaceContainerHigh: Color(0xff2c2a21),
      surfaceContainerHighest: Color(0xff37352b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.onSurfaceVariant, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
