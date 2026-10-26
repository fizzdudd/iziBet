import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../models/partido.dart';
import '../../providers/favoritos_provider.dart';
import '../../providers/partidos_provider.dart';
import '../../widgets/estado_vista.dart';
import '../../widgets/filtro_ligas.dart';
import '../../widgets/partido_card.dart';
import '../detalle/detalle_screen.dart';

// Todos los partidos de los próximos días, agrupados por día, con buscador.
class PartidosScreen extends StatelessWidget {
  const PartidosScreen({super.key});

  static const _hero = 'partidos';
  static const _dias = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO'];

  String _tituloDia(DateTime f) {
    final hoy = DateTime.now();
    final dia = DateTime(f.year, f.month, f.day);
    final diff = dia.difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
    if (diff == 0) return 'HOY';
    if (diff == 1) return 'MAÑANA';
    return '${_dias[f.weekday - 1]} ${f.day}';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PartidosProvider>();
    final favs = context.watch<FavoritosProvider>();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PARTIDOS', style: IziText.display(56, height: .85)),
                const SizedBox(height: 16),
                TextField(
                  onChanged: prov.buscar,
                  cursorColor: IziColors.negro,
                  style: IziText.body(15),
                  decoration: InputDecoration(
                    hintText: 'Buscar equipo…',
                    hintStyle: IziText.body(15, color: IziColors.gris5F),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: IziColors.negro, width: 2),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: IziColors.azul, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const FiltroLigas(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Partido>>(
              future: prov.partidos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const EstadoCargando(texto: 'Cargando partidos…');
                }
                if (snapshot.hasError) {
                  return EstadoError(
                    texto: 'No pudimos traer los partidos de ESPN.',
                    onReintentar: prov.recargar,
                  );
                }
                final lista = prov.filtrar(snapshot.data ?? [], favs);
                if (lista.isEmpty) {
                  return const EstadoVacio(
                    titulo: 'Nada por aquí',
                    texto: 'Prueba con otro equipo u otra liga.',
                  );
                }

                // Se arma la lista con un encabezado cada vez que cambia el día.
                final filas = <Widget>[];
                String? diaActual;
                for (final p in lista) {
                  final dia = _tituloDia(p.fecha);
                  if (dia != diaActual) {
                    diaActual = dia;
                    filas.add(Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(dia, style: IziText.mono(11)),
                    ));
                  }
                  filas.add(Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PartidoCard(
                      partido: p,
                      heroPrefijo: _hero,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetalleScreen(partido: p, heroTag: PartidoCard.heroTag(_hero, p)),
                        ),
                      ),
                    ),
                  ));
                }
                return RefreshIndicator(
                  color: IziColors.negro,
                  onRefresh: () async => prov.recargar(),
                  child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: filas),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
