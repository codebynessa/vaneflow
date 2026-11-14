import 'package:flutter/material.dart';

/// Guarda o modo de tema atual. O MaterialApp escuta este notifier,
/// entao qualquer mudanca vale para TODAS as telas (login, tarefas, etc.).
final ValueNotifier<ThemeMode> temaNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

class AppTheme {
  static const Color sage = Color(0xFF7C8A70);
  static const Color terracotta = Color(0xFFC27B5A);
  static const Color cream = Color(0xFFF6F0E6);
  static const Color beige = Color(0xFFE9DFD0);
  static const Color coffee = Color(0xFF493B32);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: sage,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E6D9),
      onPrimaryContainer: Color(0xFF293326),
      secondary: terracotta,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF1DDD2),
      onSecondaryContainer: Color(0xFF4D2B1E),
      surface: cream,
      onSurface: coffee,
      outline: Color(0xFF8B7D70),
    ),
    scaffoldBackgroundColor: cream,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: cream,
      foregroundColor: coffee,
    ),
    cardTheme: const CardThemeData(color: beige),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB7C4A9),
      onPrimary: Color(0xFF263021),
      primaryContainer: Color(0xFF3D4A37),
      onPrimaryContainer: Color(0xFFE0E6D9),
      secondary: Color(0xFFE0A083),
      onSecondary: Color(0xFF452719),
      secondaryContainer: Color(0xFF633F30),
      onSecondaryContainer: Color(0xFFF1DDD2),
      surface: Color(0xFF211F1B),
      onSurface: Color(0xFFF2E9DC),
      outline: Color(0xFFAA9A88),
    ),
    scaffoldBackgroundColor: const Color(0xFF211F1B),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF211F1B),
      foregroundColor: Color(0xFFF2E9DC),
    ),
    cardTheme: const CardThemeData(color: Color(0xFF302C26)),
  );
}
