import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';

// Barra de probabilidad del modelo con una línea naranja en la probabilidad
// implícita de la cuota. El relleno se anima solo al cambiar de valor
// (animación implícita con AnimatedFractionallySizedBox).
class BarraProbabilidad extends StatelessWidget {
  final int prob; // 0-100
  final int? implicita; // 0-100, opcional
  final Color relleno;
  final Color fondo;
  final double alto;

  const BarraProbabilidad({
    super.key,
    required this.prob,
    this.implicita,
    this.relleno = IziColors.lima,
    this.fondo = IziColors.grafito,
    this.alto = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: alto + 8,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Container(height: alto, color: fondo),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              widthFactor: (prob / 100).clamp(0.0, 1.0),
              child: Container(height: alto, color: relleno),
            ),
            if (implicita != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                left: c.maxWidth * (implicita! / 100).clamp(0.0, 1.0) - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: IziColors.naranjo),
              ),
          ],
        ),
      ),
    );
  }
}
