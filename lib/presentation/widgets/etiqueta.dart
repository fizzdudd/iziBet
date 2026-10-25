import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';
import '../../models/mercado.dart';
import '../../models/pick.dart';

// Etiqueta rectangular de color: confianza (ALTA/MEDIA/BAJA) o estado de un
// pick (ACIERTO/FALLO/PENDIENTE). Los colores salen del mockup.
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color color;
  final double tamano;

  const Etiqueta({
    super.key,
    required this.texto,
    required this.fondo,
    required this.color,
    this.tamano = 11,
  });

  factory Etiqueta.confianza(Confianza c, {double tamano = 11, String prefijo = ''}) {
    final (fondo, color) = switch (c) {
      Confianza.alta => (IziColors.lima, IziColors.negro),
      Confianza.media => (IziColors.azul, IziColors.blanco),
      Confianza.baja => (IziColors.grisD6, IziColors.negro),
    };
    return Etiqueta(texto: '$prefijo${c.texto}', fondo: fondo, color: color, tamano: tamano);
  }

  factory Etiqueta.estado(EstadoPick e) {
    final (fondo, color) = switch (e) {
      EstadoPick.acierto => (IziColors.lima, IziColors.negro),
      EstadoPick.fallo => (IziColors.naranjo, IziColors.blanco),
      EstadoPick.pendiente => (IziColors.azul, IziColors.blanco),
    };
    return Etiqueta(texto: e.texto, fondo: fondo, color: color, tamano: 13);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      padding: EdgeInsets.symmetric(horizontal: tamano * .6, vertical: tamano * .25),
      child: Text(texto, style: IziText.condensed(tamano, color: color)),
    );
  }
}
