import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';
import '../../../models/equipo.dart';
import '../../../models/mercado.dart';
import '../../../models/partido.dart';
import '../../../models/pick.dart';
import '../../providers/picks_provider.dart';
import '../../widgets/barra_probabilidad.dart';
import '../../widgets/boton_izi.dart';
import '../../widgets/etiqueta.dart';
import '../../widgets/forma_cuadros.dart';
import '../../widgets/franja.dart';
import '../../widgets/izi_chip.dart';
import '../pick_form/pick_form_screen.dart';

// M3 — Detalle del partido: la recomendación explicada por mercado.
class DetalleScreen extends StatefulWidget {
  final Partido partido;
  final String heroTag;

  const DetalleScreen({super.key, required this.partido, required this.heroTag});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  late int _mercado = widget.partido.mercados.indexOf(widget.partido.mejor);

  Partido get p => widget.partido;
  Mercado get m => p.mercados[_mercado];

  /// Seguir: abre el formulario para crear el pick; si ya se sigue, para editarlo.
  void _seguir(Pick? existente) {
    final pick = existente ??
        Pick(
          partidoId: p.id,
          partido: p.nombre,
          liga: p.liga.corta,
          mercado: m.tituloCorto,
          seleccion: m.seleccion,
          prob: m.prob,
          cuota: m.cuota ?? 0,
          fechaPartido: p.fecha,
        );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PickFormScreen(pick: pick)));
  }

  @override
  Widget build(BuildContext context) {
    final seguido = context.watch<PicksProvider>().buscar(p.id, m.seleccion);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cabecera(partido: p, heroTag: widget.heroTag),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                // Pestañas de mercado
                Row(
                  children: [
                    for (var i = 0; i < p.mercados.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: IziChip(
                          texto: p.mercados[i].tituloCorto == 'Más/menos'
                              ? 'Más/menos ${Formato.decimal(p.cuotas.linea, decimales: 1)}'
                              : p.mercados[i].tituloCorto,
                          activo: i == _mercado,
                          onTap: () => setState(() => _mercado = i),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _TarjetaPrediccion(mercado: m),
                const SizedBox(height: 8),
                _PorQue(razones: m.razones),
                const SizedBox(height: 8),
                _FormaUltimos(local: p.local, visita: p.visita),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BotonIzi(
              texto: seguido == null ? '+ Seguir este pick' : '✓ Guardado en historial',
              estilo: seguido == null ? EstiloBoton.negro : EstiloBoton.lima,
              tamano: 19,
              onTap: () => _seguir(seguido),
            ),
            const SizedBox(height: 6),
            Text('Sugerencia estadística · Juego responsable · 18+', style: IziText.body(11, color: IziColors.gris5F)),
          ],
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final Partido partido;
  final String heroTag;
  const _Cabecera({required this.partido, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: IziColors.azul),
      child: Stack(
        children: [
          const Positioned(right: 30, top: -20, child: Franja(color: IziColors.lima, ancho: 50, alto: 320)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    '← ${partido.liga.nombre.toUpperCase()}',
                    style: IziText.condensed(16, color: IziColors.blanco),
                  ),
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: heroTag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      '${partido.local.nombre}\nvs ${partido.visita.nombre}'.toUpperCase(),
                      style: IziText.display(40, color: IziColors.blanco),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  [
                    partido.enVivo ? 'EN VIVO' : Formato.fechaLarga(partido.fecha),
                    if (partido.estadio.isNotEmpty) partido.estadio.toUpperCase(),
                  ].join(' · '),
                  style: IziText.mono(11, color: IziColors.blanco),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// La tarjeta negra con la probabilidad, la cuota, la implícita y el valor.
class _TarjetaPrediccion extends StatelessWidget {
  final Mercado mercado;
  const _TarjetaPrediccion({required this.mercado});

  @override
  Widget build(BuildContext context) {
    final m = mercado;
    final valor = m.valor;
    return Container(
      color: IziColors.negro,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(m.seleccion.toUpperCase(), style: IziText.condensed(22, color: IziColors.blanco)),
              ),
              Etiqueta.confianza(m.confianza, tamano: 12),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Al cambiar de mercado el número se reemplaza con un fundido.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '${m.prob}%',
                  key: ValueKey(m.seleccion),
                  style: IziText.display(64, color: IziColors.lima, height: .8),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: m.cuota == null
                    ? [
                        Text('SIN CUOTA', style: IziText.mono(11, color: IziColors.blanco)),
                        Text('EN ESPN', style: IziText.mono(11, color: IziColors.grisB5)),
                      ]
                    : [
                        Text('CUOTA ${Formato.decimal(m.cuota!)}', style: IziText.mono(11, color: IziColors.blanco)),
                        Text('IMPLÍCITA ${m.implicita}%', style: IziText.mono(11, color: IziColors.blanco)),
                        Text(
                          'VALOR ${valor! > 0 ? '+' : ''}$valor',
                          style: IziText.mono(11, color: valor > 0 ? IziColors.lima : IziColors.naranjo),
                        ),
                      ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          BarraProbabilidad(prob: m.prob, implicita: m.implicita),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final r in m.reparto) ...[
                Text('${r.etiqueta} ${r.valor}%', style: IziText.mono(10, color: IziColors.grisB5)),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PorQue extends StatelessWidget {
  final List<String> razones;
  const _PorQue({required this.razones});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IziColors.blanco,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('POR QUÉ', style: IziText.condensed(18)),
          const SizedBox(height: 8),
          for (var i = 0; i < razones.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: IziText.display(22, color: IziColors.azul, height: 1),
                    ),
                  ),
                  Expanded(child: Text(razones[i], style: IziText.body(13))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FormaUltimos extends StatelessWidget {
  final Equipo local;
  final Equipo visita;
  const _FormaUltimos({required this.local, required this.visita});

  @override
  Widget build(BuildContext context) {
    Widget fila(Equipo e) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  e.nombre.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: IziText.condensed(16, weight: FontWeight.w700),
                ),
              ),
              FormaCuadros(forma: e.forma),
            ],
          ),
        );

    return Container(
      color: IziColors.blanco,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FORMA ÚLT. 5', style: IziText.condensed(18)),
          fila(local),
          fila(visita),
        ],
      ),
    );
  }
}
