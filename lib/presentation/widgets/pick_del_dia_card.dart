import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';
import '../../models/mercado.dart';
import '../../models/partido.dart';
import 'franja.dart';

// Tarjeta lima destacada del inicio: el mejor pick de los próximos días.
class PickDelDiaCard extends StatelessWidget {
  final Partido partido;
  final String heroTag;
  final VoidCallback onTap;

  const PickDelDiaCard({
    super.key,
    required this.partido,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = partido.mejor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(color: IziColors.lima),
        child: Stack(
          children: [
            const Positioned(
              right: -20,
              top: -10,
              child: Franja(color: IziColors.negro, ancho: 40, alto: 200),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 48, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PICK DEL DÍA · CONF. ${m.confianza.texto}',
                    style: IziText.condensed(14, letterSpacing: .84),
                  ),
                  const SizedBox(height: 8),
                  Hero(
                    tag: heroTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(partido.nombre.toUpperCase(), style: IziText.condensed(22, height: 1)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${m.prob}%', style: IziText.display(56, height: .85)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            m.seleccion.toUpperCase(),
                            style: IziText.condensed(16, weight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
