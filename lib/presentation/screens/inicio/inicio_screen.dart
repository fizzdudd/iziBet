import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../models/partido.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favoritos_provider.dart';
import '../../providers/partidos_provider.dart';
import '../../widgets/avatar_inicial.dart';
import '../../widgets/estado_vista.dart';
import '../../widgets/filtro_ligas.dart';
import '../../widgets/partido_card.dart';
import '../../widgets/pick_del_dia_card.dart';
import '../calculadora/calculadora_screen.dart';
import '../detalle/detalle_screen.dart';

// M2 — Inicio: el pick del día y los partidos con su recomendación.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  static const _hero = 'inicio';

  void _abrir(BuildContext context, Partido p, String heroTag) {
    // El partido viaja al detalle por el constructor.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalleScreen(partido: p, heroTag: heroTag)),
    );
  }

  Future<void> _menu(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final opcion = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: IziColors.negro,
      shape: const RoundedRectangleBorder(),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(auth.usuario?.email ?? '', style: IziText.mono(12, color: IziColors.grisB5)),
            ),
            ListTile(
              title: Text('CALCULADORA DE CUOTAS', style: IziText.condensed(18, color: IziColors.blanco)),
              onTap: () => Navigator.pop(context, 'calc'),
            ),
            ListTile(
              title: Text('CERRAR SESIÓN', style: IziText.condensed(18, color: IziColors.naranjo)),
              onTap: () => Navigator.pop(context, 'salir'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (opcion == 'calc') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CalculadoraScreen()));
    } else if (opcion == 'salir') {
      await auth.salir(); // el AuthGate vuelve al login solo
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<PartidosProvider>();
    final favs = context.watch<FavoritosProvider>();

    return Column(
      children: [
        // Cabecera negra
        Container(
          color: IziColors.negro,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRÓXIMOS 7 DÍAS', style: IziText.mono(11, color: IziColors.lima)),
                        const SizedBox(height: 2),
                        Text(
                          'HOLA, ${auth.nombre.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IziText.display(34, color: IziColors.blanco, height: 1),
                        ),
                      ],
                    ),
                  ),
                  AvatarInicial(inicial: auth.inicial, onTap: () => _menu(context)),
                ],
              ),
              const SizedBox(height: 16),
              const FiltroLigas(sobreOscuro: true),
            ],
          ),
        ),
        // Contenido
        Expanded(
          child: FutureBuilder<List<Partido>>(
            future: prov.partidos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const EstadoCargando();
              }
              if (snapshot.hasError) {
                return EstadoError(
                  texto: 'No pudimos traer los partidos de ESPN. Revisa tu conexión.',
                  onReintentar: prov.recargar,
                );
              }
              final lista = prov.filtrar(snapshot.data ?? [], favs);
              if (lista.isEmpty) {
                return EstadoVacio(
                  titulo: prov.filtro == PartidosProvider.filtroFavs ? 'Sin favoritos aún' : 'Sin partidos',
                  texto: prov.filtro == PartidosProvider.filtroFavs
                      ? 'Sigue ligas o equipos en la pestaña Favoritos y aparecerán aquí.'
                      : 'No hay partidos de esta liga en los próximos 7 días.',
                  accion: 'Ver todas las ligas',
                  onAccion: () => prov.cambiarFiltro(PartidosProvider.filtroTodas),
                );
              }
              final destacado = PartidosProvider.pickDelDia(lista);
              final resto = lista.where((p) => p != destacado).toList();

              return RefreshIndicator(
                color: IziColors.negro,
                onRefresh: () async => prov.recargar(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (destacado != null) ...[
                      PickDelDiaCard(
                        partido: destacado,
                        heroTag: 'pdd-${destacado.id}',
                        onTap: () => _abrir(context, destacado, 'pdd-${destacado.id}'),
                      ),
                      const SizedBox(height: 10),
                    ],
                    for (final p in resto) ...[
                      PartidoCard(
                        partido: p,
                        heroPrefijo: _hero,
                        onTap: () => _abrir(context, p, PartidoCard.heroTag(_hero, p)),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
