import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

// Chip rectangular de filtro. Sobre fondo oscuro, el activo va en lima;
// sobre fondo claro, el activo va en negro.
class IziChip extends StatelessWidget {
  final String texto;
  final bool activo;
  final bool sobreOscuro;
  final VoidCallback? onTap;

  const IziChip({
    super.key,
    required this.texto,
    required this.activo,
    this.sobreOscuro = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borde = sobreOscuro ? IziColors.blanco : IziColors.negro;
    final fondoActivo = sobreOscuro ? IziColors.lima : IziColors.negro;
    final textoActivo = sobreOscuro ? IziColors.negro : IziColors.blanco;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? fondoActivo : Colors.transparent,
          border: Border.all(color: activo ? fondoActivo : borde, width: 1.5),
        ),
        child: Text(
          texto.toUpperCase(),
          style: IziText.condensed(
            14,
            weight: FontWeight.w700,
            color: activo ? textoActivo : borde,
          ),
        ),
      ),
    );
  }
}
