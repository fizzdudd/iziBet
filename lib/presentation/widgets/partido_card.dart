import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';
import '../../core/utils/formato.dart';
import '../../models/partido.dart';
import 'etiqueta.dart';

// Tarjeta blanca de un partido (lista del inicio, M2): hora y liga, los
// equipos, el pick recomendado y su probabilidad con la confianza.
class PartidoCard extends StatelessWidget {
  final Partido partido;
  final VoidCallback onTap;
  // Inicio y Partidos muestran las mismas tarjetas; el prefijo evita que
  // dos Hero tengan el mismo tag.
  final String heroPrefijo;

  const PartidoCard({
    super.key,
    required this.partido,
    required this.onTap,
    required this.heroPrefijo,
  });

  /// El mismo tag lo recibe el detalle para la animación Hero.
  static String heroTag(String prefijo, Partido p) => '$prefijo-partido-${p.id}';

  @override
  Widget build(BuildContext context) {
    final m = partido.mejor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: IziColors.blanco,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partido.enVivo
                        ? 'EN VIVO · ${partido.liga.corta}'
                        : '${Formato.diaHora(partido.fecha)} · ${partido.liga.corta}',
                    style: IziText.mono(10, color: partido.enVivo ? IziColors.naranjo : IziColors.gris5F),
                  ),
                  const SizedBox(height: 4),
                  Hero(
                    tag: heroTag(heroPrefijo, partido),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text.rich(
                        TextSpan(
                          style: IziText.condensed(19, height: 1),
                          children: [
                            TextSpan(text: partido.local.nombre.toUpperCase()),
                            TextSpan(text: ' vs ', style: IziText.condensed(19, color: IziColors.gris8A, height: 1)),
                            TextSpan(text: partido.visita.nombre.toUpperCase()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.seleccion, style: IziText.body(13, weight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${m.prob}%', style: IziText.display(30, height: .9)),
                const SizedBox(height: 4),
                Etiqueta.confianza(m.confianza),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
