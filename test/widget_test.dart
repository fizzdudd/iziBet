import 'package:flutter_test/flutter_test.dart';
import 'package:izibet/logic/recomendador.dart';
import 'package:izibet/models/equipo.dart';
import 'package:izibet/models/liga.dart';
import 'package:izibet/models/mercado.dart';
import 'package:izibet/models/partido.dart';

// Pruebas del motor de picks: no necesitan ni la API ni Supabase.
Partido _partido({Cuotas cuotas = Cuotas.vacias}) => Partido(
      id: '1',
      liga: Liga.primeraCl,
      fecha: DateTime(2026, 10, 31, 18),
      estadio: 'Monumental',
      estado: 'pre',
      local: const Equipo(
        id: 'cc',
        nombre: 'Colo-Colo',
        abrev: 'CC',
        forma: [Resultado.g, Resultado.g, Resultado.e, Resultado.g, Resultado.p],
        tabla: StatsTabla(jugados: 24, golesFavor: 50, golesContra: 27, puntos: 54, posicion: 1),
      ),
      visita: const Equipo(
        id: 'uch',
        nombre: 'U. de Chile',
        abrev: 'UCH',
        forma: [Resultado.g, Resultado.p, Resultado.g, Resultado.e, Resultado.g],
        tabla: StatsTabla(jugados: 24, golesFavor: 40, golesContra: 30, puntos: 44, posicion: 3),
      ),
      cuotas: cuotas,
    );

void main() {
  test('las probabilidades de Poisson suman ~1', () {
    var suma = 0.0;
    for (var k = 0; k <= 15; k++) {
      suma += Recomendador.poisson(k, 1.6);
    }
    expect(suma, closeTo(1, 0.0001));
  });

  test('cuota americana a decimal', () {
    expect(Cuotas.americanaADecimal('+220'), 3.2);
    expect(Cuotas.americanaADecimal('-145'), 1.69);
    expect(Cuotas.americanaADecimal('EVEN'), 2);
    expect(Cuotas.americanaADecimal(null), isNull);
  });

  test('analiza los tres mercados y el 1X2 suma 100', () {
    final mercados = _partido().mercados;
    expect(mercados.map((m) => m.tipo), TipoMercado.values);
    final r = mercados[1].reparto;
    expect(r.fold<int>(0, (s, x) => s + x.valor), 100);
  });

  test('el valor es probabilidad del modelo menos la implícita', () {
    final p = _partido(cuotas: const Cuotas(local: 1.85, empate: 3.6, visita: 4.2, mas: 1.9, menos: 1.9));
    final m = p.mercados.firstWhere((m) => m.tipo == TipoMercado.unoXdos);
    expect(m.implicita, isNotNull);
    expect(m.valor, m.prob - m.implicita!);
  });
}
