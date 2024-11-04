import 'package:flutter/material.dart';

TextTheme createTextTheme(BuildContext context) {
  return Theme.of(context).textTheme.apply(
        fontFamily: 'Roboto',
      );
}

class MaterialTheme {
  const MaterialTheme(this.textTheme);
  final TextTheme textTheme;

  ThemeData theme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF006600),
      brightness: Brightness.dark,
    );
    return ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );
  }
}
