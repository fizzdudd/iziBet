import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';
import '../../../models/equipo.dart';
import '../../../models/partido.dart';
import '../../../models/pick.dart';
import '../../providers/picks_provider.dart';
import '../../widgets/barra_probabilidad.dart';
import '../../widgets/boton_izi.dart';
import '../../widgets/etiqueta.dart';
import '../../widgets/forma_cuadros.dart';
import '../../widgets/franja.dart';
import '../../widgets/partido_card.dart';
import '../pick_form/pick_form_screen.dart';

// Detalle del partido: la recomendación del modelo explicada.
class DetalleScreen extends StatelessWidget {
  final Partido partido;

  const DetalleScreen({super.key, required this.partido});

  /// Seguir: abre el formulario para crear el pick; si ya se sigue, para editarlo.
  void _abrirFormulario(BuildContext context, Pick? existente) {
    final m = partido.mejor;
    final pick = existente ??
        Pick(
          partidoId: partido.id,
          partido: partido.nombre,
          liga: partido.liga.corta,
          mercado: m.tituloCorto,
          seleccion: m.seleccion,
          prob: m.prob,
          cuota: m.cuota ?? 0,
          fechaPartido: partido.fecha,
        );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PickFormScreen(pick: pick)));
  }

  @override
  Widget build(BuildContext context) {
    final seguido = context.watch<PicksProvider>().buscar(partido.id);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cabecera(partido: partido),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TarjetaPick(partido: partido),
                const SizedBox(height: 8),
                _PorQue(razones: partido.mejor.razones),
                const SizedBox(height: 8),
                _FormaUltimos(local: partido.local, visita: partido.visita),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: BotonIzi(
          texto: seguido == null ? '+ Seguir este pick' : '✓ Ya lo sigues · editar',
          estilo: seguido == null ? EstiloBoton.negro : EstiloBoton.lima,
          tamano: 19,
          onTap: () => _abrirFormulario(context, seguido),
        ),
      ),
    );
  }
}

// Cabecera azul con el nombre del partido (destino del Hero).
class _Cabecera extends StatelessWidget {
  final Partido partido;
  const _Cabecera({required this.partido});

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
                  tag: PartidoCard.heroTag(partido),
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
                  partido.enVivo ? 'EN VIVO' : Formato.fechaLarga(partido.fecha),
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

// Tarjeta negra con el pick recomendado: probabilidad, cuota y valor.
class _TarjetaPick extends StatelessWidget {
  final Partido partido;
  const _TarjetaPick({required this.partido});

  @override
  Widget build(BuildContext context) {
    final m = partido.mejor;
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
              Text('${m.prob}%', style: IziText.display(64, color: IziColors.lima, height: .8)),
              const Spacer(),
              Text(
                m.cuota == null
                    ? 'SIN CUOTA'
                    : 'CUOTA ${Formato.decimal(m.cuota!)}\nVALOR ${m.valor! > 0 ? '+' : ''}${m.valor}',
                textAlign: TextAlign.right,
                style: IziText.mono(11, color: IziColors.blanco),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // La barra se llena con una animación implícita.
          BarraProbabilidad(prob: m.prob, implicita: m.implicita),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('POR QUÉ', style: IziText.condensed(18)),
          const SizedBox(height: 8),
          for (final r in razones)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('· $r', style: IziText.body(13)),
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
              Expanded(child: Text(e.nombre.toUpperCase(), style: IziText.condensed(16, weight: FontWeight.w700))),
              FormaCuadros(forma: e.forma),
            ],
          ),
        );

    return Container(
      color: IziColors.blanco,
      padding: const EdgeInsets.all(16),
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
