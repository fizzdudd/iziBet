import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';
import '../../providers/picks_provider.dart';
import '../../widgets/estado_vista.dart';
import '../../widgets/etiqueta.dart';
import '../pick_form/pick_form_screen.dart';

// Mis picks: el "ver" del CRUD. Tocar un pick lo abre para editarlo o borrarlo.
class MisPicksScreen extends StatelessWidget {
  const MisPicksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PicksProvider>();

    return ColoredBox(
      color: IziColors.negro,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: IziColors.negro,
          backgroundColor: IziColors.lima,
          onRefresh: prov.cargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text('MIS\nPICKS', style: IziText.display(56, color: IziColors.blanco, height: .85)),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Contador(numero: prov.aciertos, texto: 'ACIERTOS', fondo: IziColors.lima, color: IziColors.negro),
                  const SizedBox(width: 8),
                  _Contador(numero: prov.fallos, texto: 'FALLOS', fondo: IziColors.naranjo, color: IziColors.blanco),
                  const SizedBox(width: 8),
                  _Contador(numero: prov.pendientes, texto: 'PENDIENTES', fondo: IziColors.azul, color: IziColors.blanco),
                ],
              ),
              const SizedBox(height: 14),
              if (prov.cargando && prov.picks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (prov.error != null)
                EstadoVacio(
                  oscuro: true,
                  titulo: 'Sin conexión',
                  texto: prov.error!,
                  accion: 'Reintentar',
                  onAccion: prov.cargar,
                )
              else if (prov.picks.isEmpty)
                const EstadoVacio(
                  oscuro: true,
                  titulo: 'Aún no sigues picks',
                  texto: 'Abre un partido y toca "+ Seguir este pick".',
                )
              else
                for (final p in prov.picks)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PickFormScreen(pick: p)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: IziColors.grafito)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.partido.toUpperCase(), style: IziText.condensed(17, color: IziColors.blanco)),
                                Text(
                                  '${p.seleccion} · ${Formato.decimal(p.cuota)} · ${Formato.diaHora(p.fechaPartido)}',
                                  style: IziText.body(12, color: IziColors.grisB5),
                                ),
                              ],
                            ),
                          ),
                          Etiqueta.estado(p.estado),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  final int numero;
  final String texto;
  final Color fondo;
  final Color color;
  const _Contador({required this.numero, required this.texto, required this.fondo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: fondo,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$numero', style: IziText.condensed(30, weight: FontWeight.w900, color: color, height: 1)),
            Text(texto, style: IziText.mono(10, color: color)),
          ],
        ),
      ),
    );
  }
}
