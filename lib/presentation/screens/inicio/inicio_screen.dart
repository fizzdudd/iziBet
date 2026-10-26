import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../models/partido.dart';
import '../../providers/auth_provider.dart';
import '../../providers/partidos_provider.dart';
import '../../widgets/avatar_inicial.dart';
import '../../widgets/estado_vista.dart';
import '../../widgets/partido_card.dart';
import '../detalle/detalle_screen.dart';

// Inicio: los partidos de los próximos 7 días con su recomendación.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  Future<void> _confirmarSalida(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final salir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¿CERRAR SESIÓN?', style: IziText.condensed(22)),
        content: Text(auth.usuario?.email ?? '', style: IziText.body(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR', style: IziText.condensed(16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('SALIR', style: IziText.condensed(16, color: IziColors.naranjo)),
          ),
        ],
      ),
    );
    // Al salir, el AuthGate vuelve al login solo.
    if (salir == true) await auth.salir();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<PartidosProvider>();

    return Column(
      children: [
        // Cabecera negra
        Container(
          color: IziColors.negro,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 20),
          child: Row(
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
              AvatarInicial(inicial: auth.inicial, onTap: () => _confirmarSalida(context)),
            ],
          ),
        ),
        // Lista de partidos: FutureBuilder con sus tres casos.
        Expanded(
          child: FutureBuilder<List<Partido>>(
            future: prov.partidos,
            builder: (context, snapshot) {
              // 1) Cargando
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const EstadoCargando();
              }
              // 2) Error
              if (snapshot.hasError) {
                return EstadoError(
                  texto: 'No pudimos traer los partidos de ESPN. Revisa tu conexión.',
                  onReintentar: prov.recargar,
                );
              }
              // 3) Datos
              final partidos = snapshot.data ?? [];
              if (partidos.isEmpty) {
                return const EstadoVacio(
                  titulo: 'Sin partidos',
                  texto: 'No hay partidos en los próximos 7 días.',
                );
              }
              return RefreshIndicator(
                color: IziColors.negro,
                onRefresh: () async => prov.recargar(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: partidos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = partidos[i];
                    return PartidoCard(
                      partido: p,
                      // El partido viaja al detalle por el constructor.
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DetalleScreen(partido: p)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
