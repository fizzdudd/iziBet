import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';
import 'franja.dart';

// "// IZIBET": dos franjas (lima y blanca) más la palabra en itálica.
class IziLogo extends StatelessWidget {
  final double tamano;
  final Color color;

  const IziLogo({super.key, this.tamano = 26, this.color = IziColors.blanco});

  @override
  Widget build(BuildContext context) {
    final alto = tamano * .77;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Franja(color: IziColors.lima, ancho: tamano * .23, alto: alto),
        SizedBox(width: tamano * .12),
        Franja(color: color, ancho: tamano * .23, alto: alto),
        SizedBox(width: tamano * .3),
        Text('IZIBET', style: IziText.display(tamano, color: color, height: 1)),
      ],
    );
  }
}
