import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';
import '../../providers/picks_provider.dart';
import '../../widgets/estado_vista.dart';
import '../../widgets/etiqueta.dart';
import '../pick_form/pick_form_screen.dart';

// M5 — Historial y rendimiento: % de acierto y los picks seguidos.
class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PicksProvider>();
    final pct = prov.porcentajeAcierto;
    final barras = prov.barrasSemanales;

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
              Text('TU % DE ACIERTO · 30 DÍAS', style: IziText.mono(11, color: IziColors.lima)),
              const SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  style: IziText.display(150, color: IziColors.blanco, height: .75),
                  children: [
                    TextSpan(text: pct == null ? '—' : '$pct'),
                    const TextSpan(text: '%', style: TextStyle(color: IziColors.lima)),
                  ],
                ),
              ),
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
              const SizedBox(height: 18),
              // Barras: % de acierto de las últimas 8 semanas (la actual en lima).
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < barras.length; i++) ...[
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: barras[i] == null ? 4 : 80 * barras[i]! / 100 + 4,
                          color: i == barras.length - 1
                              ? IziColors.lima
                              : (barras[i] ?? 0) >= 60
                                  ? IziColors.blanco
                                  : IziColors.gris55,
                        ),
                      ),
                      if (i < barras.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('HACE 8 SEMANAS', style: IziText.mono(10, color: IziColors.gris8A)),
                  Text('ESTA SEMANA', style: IziText.mono(10, color: IziColors.gris8A)),
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
                  texto: 'Abre un partido y toca "+ Seguir este pick" para empezar tu historial.',
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
