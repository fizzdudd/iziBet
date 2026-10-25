import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';
import '../../models/equipo.dart';

// La racha de los últimos 5: G en lima, E en gris, P en naranjo.
class FormaCuadros extends StatelessWidget {
  final List<Resultado> forma;
  final double lado;

  const FormaCuadros({super.key, required this.forma, this.lado = 22});

  @override
  Widget build(BuildContext context) {
    if (forma.isEmpty) {
      return Text('SIN DATOS', style: IziText.mono(10));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final r in forma) ...[
          Container(
            width: lado,
            height: lado,
            alignment: Alignment.center,
            color: switch (r) {
              Resultado.g => IziColors.lima,
              Resultado.e => IziColors.grisD6,
              Resultado.p => IziColors.naranjo,
            },
            child: Text(
              r.name.toUpperCase(),
              style: IziText.condensed(
                lado * .55,
                color: r == Resultado.p ? IziColors.blanco : IziColors.negro,
              ),
            ),
          ),
          const SizedBox(width: 3),
        ],
      ],
    );
  }
}
