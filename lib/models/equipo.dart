// Resultado de un partido en la racha: G (ganó), E (empató), P (perdió).
enum Resultado { g, e, p }

// Estadísticas de la tabla de posiciones de ESPN para un equipo.
class StatsTabla {
  final int jugados;
  final int golesFavor;
  final int golesContra;
  final int puntos;
  final int posicion;

  const StatsTabla({
    required this.jugados,
    required this.golesFavor,
    required this.golesContra,
    required this.puntos,
    required this.posicion,
  });

  double get favorPorPartido => jugados == 0 ? 0 : golesFavor / jugados;
  double get contraPorPartido => jugados == 0 ? 0 : golesContra / jugados;

  // Cada fila de standings trae una lista de stats {name, value}.
  factory StatsTabla.fromEspn(List<dynamic> stats) {
    int valor(String nombre) {
      for (final s in stats) {
        if (s['name'] == nombre) return (s['value'] as num?)?.round() ?? 0;
      }
      return 0;
    }

    return StatsTabla(
      jugados: valor('gamesPlayed'),
      golesFavor: valor('pointsFor'),
      golesContra: valor('pointsAgainst'),
      puntos: valor('points'),
      posicion: valor('rank'),
    );
  }
}

class Equipo {
  final String id;
  final String nombre;
  final String abrev;
  final String? logo;
  final List<Resultado> forma; // últimos 5, en el orden que entrega ESPN
  final StatsTabla? tabla;

  const Equipo({
    required this.id,
    required this.nombre,
    required this.abrev,
    this.logo,
    this.forma = const [],
    this.tabla,
  });

  /// Puntos sumados en la racha (3 por victoria, 1 por empate).
  int get puntosForma => forma.fold(
        0,
        (suma, r) => suma + (r == Resultado.g ? 3 : (r == Resultado.e ? 1 : 0)),
      );

  // Un "competitor" del scoreboard de ESPN. La forma viene como "WDLWW".
  factory Equipo.fromEspn(
    Map<String, dynamic> competitor,
    Map<String, StatsTabla> tablaPorId,
  ) {
    final team = competitor['team'] as Map<String, dynamic>;
    final id = '${team['id']}';
    final formaTexto = (competitor['form'] as String?) ?? '';
    return Equipo(
      id: id,
      nombre: (team['shortDisplayName'] ?? team['displayName'] ?? '') as String,
      abrev: (team['abbreviation'] ?? '') as String,
      logo: team['logo'] as String?,
      forma: formaTexto
          .split('')
          .map((l) => switch (l) {
                'W' => Resultado.g,
                'D' => Resultado.e,
                _ => Resultado.p,
              })
          .toList(),
      tabla: tablaPorId[id],
    );
  }
}
