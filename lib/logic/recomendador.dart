import 'dart:math';

import '../core/utils/formato.dart';
import '../models/equipo.dart';
import '../models/mercado.dart';
import '../models/partido.dart';

// El motor de picks de iziBet. Lógica pura en Dart: no sabe nada de
// Flutter, de la API ni de Supabase, así que se puede probar sola.
//
// Idea: estimar cuántos goles hará cada equipo (λ) con su ataque, la
// defensa del rival y la localía; con eso, la distribución de Poisson da la
// probabilidad de cada marcador, y de ahí salen los tres mercados.
class Recomendador {
  Recomendador._();

  static const _promedioLiga = 1.35; // goles por equipo y partido
  static const _ventajaLocal = 1.10;
  static const _maxGoles = 8;

  /// Goles esperados de [atacante] contra [defensor].
  static double golesEsperados(Equipo atacante, Equipo defensor, {required bool esLocal}) {
    final ta = atacante.tabla;
    final td = defensor.tabla;
    double ataque;
    double defensa;
    if (ta != null && td != null && ta.jugados > 0 && td.jugados > 0) {
      ataque = ta.favorPorPartido / _promedioLiga;
      defensa = td.contraPorPartido / _promedioLiga;
    } else {
      // Sin tabla, se usa la forma: 15 pts en 5 partidos es la mejor racha.
      ataque = 0.7 + atacante.puntosForma / 15 * 0.6;
      defensa = 1.3 - defensor.puntosForma / 15 * 0.6;
    }
    final lambda = _promedioLiga * ataque * defensa * (esLocal ? _ventajaLocal : 2 - _ventajaLocal);
    return lambda.clamp(0.2, 4.0);
  }

  /// P(X = k) para una Poisson de media [lambda].
  static double poisson(int k, double lambda) {
    var factorial = 1.0;
    for (var i = 2; i <= k; i++) {
      factorial *= i;
    }
    return exp(-lambda) * pow(lambda, k) / factorial;
  }

  static List<Mercado> analizar(Partido p) {
    final lh = golesEsperados(p.local, p.visita, esLocal: true);
    final la = golesEsperados(p.visita, p.local, esLocal: false);

    // Matriz de marcadores: probabilidad de cada resultado h–a.
    // (La visita es el resto: 100 − local − empate.)
    var pLocal = 0.0, pEmpate = 0.0, pMas = 0.0;
    for (var h = 0; h <= _maxGoles; h++) {
      for (var a = 0; a <= _maxGoles; a++) {
        final pr = poisson(h, lh) * poisson(a, la);
        if (h > a) pLocal += pr;
        if (h == a) pEmpate += pr;
        if (h + a > p.cuotas.linea) pMas += pr;
      }
    }
    final pAmbos = (1 - poisson(0, lh)) * (1 - poisson(0, la));

    final razonesBase = _razonesBase(p, lh, la);
    final linea = Formato.decimal(p.cuotas.linea, decimales: 1);

    // Más/menos
    final esMas = pMas >= 0.5;
    final probMas = _pct(pMas);
    final masMenos = _mercado(
      tipo: TipoMercado.masMenos,
      titulo: 'MÁS/MENOS $linea',
      seleccion: esMas ? 'Más de $linea goles' : 'Menos de $linea goles',
      prob: esMas ? probMas : 100 - probMas,
      cuota: esMas ? p.cuotas.mas : p.cuotas.menos,
      reparto: [Reparto('MÁS', probMas), Reparto('MENOS', 100 - probMas)],
      razones: [
        'Poisson estima ${Formato.decimal(lh + la, decimales: 1)} goles esperados para este partido.',
        ...razonesBase,
      ],
    );

    // 1X2
    final r1 = _pct(pLocal), rx = _pct(pEmpate), r2 = 100 - r1 - rx;
    final opciones = [
      (sel: 'Local (${p.local.nombre})', prob: r1, cuota: p.cuotas.local),
      (sel: 'Empate', prob: rx, cuota: p.cuotas.empate),
      (sel: 'Visita (${p.visita.nombre})', prob: r2, cuota: p.cuotas.visita),
    ]..sort((x, y) => y.prob.compareTo(x.prob));
    final top = opciones.first;
    final unoXdos = _mercado(
      tipo: TipoMercado.unoXdos,
      titulo: '1X2',
      seleccion: top.sel,
      prob: top.prob,
      cuota: top.cuota,
      reparto: [Reparto('1', r1), Reparto('X', rx), Reparto('2', r2)],
      razones: [
        '${p.local.nombre} gana el $r1% de las simulaciones; empate $rx%, ${p.visita.nombre} $r2%.',
        ...razonesBase,
      ],
    );

    // Ambos marcan (ESPN no trae cuota para este mercado)
    final probAmbos = _pct(pAmbos);
    final ambosSi = probAmbos >= 50;
    final ambos = _mercado(
      tipo: TipoMercado.ambosMarcan,
      titulo: 'AMBOS MARCAN',
      seleccion: ambosSi ? 'Ambos marcan: Sí' : 'Ambos marcan: No',
      prob: ambosSi ? probAmbos : 100 - probAmbos,
      cuota: null,
      reparto: [Reparto('SÍ', probAmbos), Reparto('NO', 100 - probAmbos)],
      razones: [
        '${p.local.nombre} marca en el ${_pct(1 - poisson(0, lh))}% de los escenarios y ${p.visita.nombre} en el ${_pct(1 - poisson(0, la))}%.',
        ...razonesBase,
      ],
    );

    return [masMenos, unoXdos, ambos];
  }

  /// Prefiere el mercado con más valor; si ninguno tiene valor claro, el más probable.
  static Mercado elegirMejor(List<Mercado> mercados) {
    final conValor = mercados.where((m) => (m.valor ?? -100) >= 3).toList()
      ..sort((a, b) => b.valor!.compareTo(a.valor!));
    if (conValor.isNotEmpty) return conValor.first;
    final porProb = [...mercados]..sort((a, b) => b.prob.compareTo(a.prob));
    return porProb.first;
  }

  static Confianza confianza(int prob, int? valor) {
    if (prob >= 65 || (prob >= 50 && (valor ?? 0) >= 8)) return Confianza.alta;
    if (prob >= 50) return Confianza.media;
    return Confianza.baja;
  }

  static Mercado _mercado({
    required TipoMercado tipo,
    required String titulo,
    required String seleccion,
    required int prob,
    required double? cuota,
    required List<Reparto> reparto,
    required List<String> razones,
  }) {
    final implicita = cuota == null ? null : (100 / cuota).round();
    return Mercado(
      tipo: tipo,
      titulo: titulo,
      seleccion: seleccion,
      prob: prob,
      cuota: cuota,
      confianza: confianza(prob, implicita == null ? null : prob - implicita),
      reparto: reparto,
      razones: razones.take(3).toList(),
    );
  }

  static List<String> _razonesBase(Partido p, double lh, double la) {
    final razones = <String>[];
    final tl = p.local.tabla, tv = p.visita.tabla;
    if (tl != null && tv != null && tl.jugados > 0 && tv.jugados > 0) {
      razones.add(
        '${p.local.nombre} promedia ${Formato.decimal(tl.favorPorPartido, decimales: 1)} goles a favor; '
        '${p.visita.nombre} recibe ${Formato.decimal(tv.contraPorPartido, decimales: 1)} por partido.',
      );
    }
    if (p.local.forma.isNotEmpty && p.visita.forma.isNotEmpty) {
      razones.add(
        'Forma últ. 5: ${p.local.nombre} suma ${p.local.puntosForma} pts y ${p.visita.nombre} ${p.visita.puntosForma} pts.',
      );
    }
    razones.add(
      'Goles esperados: ${p.local.nombre} ${Formato.decimal(lh, decimales: 1)} · ${p.visita.nombre} ${Formato.decimal(la, decimales: 1)}.',
    );
    return razones;
  }

  static int _pct(double p) => (p * 100).round().clamp(0, 100);
}
