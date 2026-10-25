import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'izi_colors.dart';

// Tema global: esquinas rectas, sin sombras y con los colores del mockup.
ThemeData buildIziTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.barlow().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: IziColors.lima,
      primary: IziColors.negro,
      secondary: IziColors.lima,
      surface: IziColors.hueso,
      error: IziColors.naranjo,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: IziColors.hueso,
    splashFactory: NoSplash.splashFactory,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: IziColors.negro,
      contentTextStyle: GoogleFonts.barlow(color: IziColors.blanco),
      shape: const RoundedRectangleBorder(),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: IziColors.hueso,
      shape: RoundedRectangleBorder(),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: IziColors.hueso,
      shape: RoundedRectangleBorder(),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: IziColors.lima,
    ),
  );
}
