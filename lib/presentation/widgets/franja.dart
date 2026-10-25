import 'package:flutter/material.dart';

// Las barras inclinadas (skewX -20°) que decoran las pantallas del mockup.
class Franja extends StatelessWidget {
  final Color color;
  final double ancho;
  final double alto;
  final double inclinacion;

  const Franja({
    super.key,
    required this.color,
    required this.ancho,
    required this.alto,
    this.inclinacion = -0.364, // tan(-20°)
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(inclinacion),
      child: SizedBox(width: ancho, height: alto, child: ColoredBox(color: color)),
    );
  }
}
