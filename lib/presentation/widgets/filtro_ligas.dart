import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/liga.dart';
import '../providers/partidos_provider.dart';
import 'izi_chip.dart';

// Fila de chips: ★ Favs y una por liga. Tocar el chip activo lo apaga
// (vuelve a "todas"). El filtro vive en PartidosProvider, así que Inicio y
// Partidos comparten la misma selección.
class FiltroLigas extends StatelessWidget {
  final bool sobreOscuro;
  const FiltroLigas({super.key, this.sobreOscuro = false});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PartidosProvider>();

    Widget chip(String texto, String filtro) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IziChip(
            texto: texto,
            activo: prov.filtro == filtro,
            sobreOscuro: sobreOscuro,
            onTap: () => prov.cambiarFiltro(
              prov.filtro == filtro ? PartidosProvider.filtroTodas : filtro,
            ),
          ),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('★ Favs', PartidosProvider.filtroFavs),
          for (final l in Liga.todas) chip(l.chip, l.clave),
        ],
      ),
    );
  }
}
