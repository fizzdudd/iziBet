import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'izi_colors.dart';

// Las tres tipografías del mockup:
// - Barlow Condensed: titulares (900 itálica) y etiquetas fuertes.
// - Barlow: texto corrido.
// - JetBrains Mono: rótulos chicos tipo "CORREO", "FECHA 24".
class IziText {
  IziText._();

  /// Titular gigante en itálica 900 (ej. "DATOS ANTES QUE CORAZÓN.").
  static TextStyle display(
    double size, {
    Color color = IziColors.negro,
    double height = .86,
  }) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        height: height,
        letterSpacing: -size * .02,
        color: color,
      );

  /// Texto condensado en mayúsculas (botones, chips, nombres de equipos).
  static TextStyle condensed(
    double size, {
    FontWeight weight = FontWeight.w800,
    Color color = IziColors.negro,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );

  /// Texto normal.
  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = IziColors.negro,
    double height = 1.35,
  }) =>
      GoogleFonts.barlow(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  /// Rótulos monoespaciados.
  static TextStyle mono(
    double size, {
    Color color = IziColors.gris5F,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        letterSpacing: letterSpacing,
        color: color,
      );
}
