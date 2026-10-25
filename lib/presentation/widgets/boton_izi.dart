import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

enum EstiloBoton { lima, negro, borde }

// Botón rectangular a todo el ancho ("CREAR CUENTA →", "+ SEGUIR ESTE PICK").
class BotonIzi extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  final EstiloBoton estilo;
  final bool cargando;
  final double tamano;

  const BotonIzi({
    super.key,
    required this.texto,
    required this.onTap,
    this.estilo = EstiloBoton.lima,
    this.cargando = false,
    this.tamano = 20,
  });

  @override
  Widget build(BuildContext context) {
    final (fondo, color) = switch (estilo) {
      EstiloBoton.lima => (IziColors.lima, IziColors.negro),
      EstiloBoton.negro => (IziColors.negro, IziColors.blanco),
      EstiloBoton.borde => (Colors.transparent, IziColors.negro),
    };

    return GestureDetector(
      onTap: cargando ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? fondo.withValues(alpha: .5) : fondo,
          border: estilo == EstiloBoton.borde ? Border.all(color: IziColors.negro, width: 2) : null,
        ),
        child: cargando
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
              )
            : Text(
                texto.toUpperCase(),
                style: IziText.condensed(tamano, color: color, letterSpacing: tamano * .04),
              ),
      ),
    );
  }
}
