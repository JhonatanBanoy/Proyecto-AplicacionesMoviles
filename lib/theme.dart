import 'package:flutter/material.dart';

class AppColors {
  static const Color azulOscuro = Color(0xFF003366);
  static const Color amarillo = Color(0xFFFFD700);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisClaro = Color(0xFFE0E0E0);
  static const Color azulClaro = Color(0xFF81A7CF);
  static const Color grisOscuro = Color(0xFF555555);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.azulOscuro,
  scaffoldBackgroundColor: AppColors.grisClaro,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.azulOscuro,
    primary: AppColors.azulOscuro,
    secondary: AppColors.amarillo,
    background: AppColors.grisClaro,
    surface: AppColors.blanco,
    onPrimary: AppColors.blanco,
    onSecondary: AppColors.azulOscuro,
    onBackground: AppColors.grisOscuro,
    onSurface: AppColors.azulOscuro,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.azulOscuro,
    foregroundColor: AppColors.blanco,
    elevation: 2,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.amarillo,
    foregroundColor: AppColors.azulOscuro,
  ),
  cardColor: AppColors.blanco,
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: AppColors.azulOscuro, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: AppColors.grisOscuro),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.blanco,
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.azulOscuro),
    ),
    labelStyle: TextStyle(color: AppColors.azulOscuro),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.amarillo,
      foregroundColor: AppColors.azulOscuro,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);