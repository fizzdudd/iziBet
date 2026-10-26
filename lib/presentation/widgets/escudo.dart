import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

// Círculo con la abreviatura del equipo (o de la liga), como en el mockup.
class Escudo extends StatelessWidget {
  final String abrev;
  final double lado;
  final bool relleno;
  final Color color;

  const Escudo({
    super.key,
    required this.abrev,
    this.lado = 34,
    this.relleno = true,
    this.color = IziColors.negro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lado,
      height: lado,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: relleno ? color : Colors.transparent,
        border: relleno ? null : Border.all(color: color, width: 2),
      ),
      child: Text(
        abrev,
        maxLines: 1,
        style: IziText.condensed(
          lado * .34,
          color: relleno ? IziColors.blanco : color,
        ),
      ),
    );
  }
}
