import 'package:dio/dio.dart';

import '../models/equipo.dart';
import '../models/liga.dart';
import '../models/partido.dart';

// Habla con la API pública de ESPN (no oficial: puede cambiar).
// scoreboard → partidos de un día · standings → tabla de posiciones.
class EspnService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static const _site = 'https://site.api.espn.com/apis/site/v2/sports/soccer';
  static const _v2 = 'https://site.api.espn.com/apis/v2/sports/soccer';

  /// Partidos que no han terminado en los próximos [dias] días, de todas las ligas.
  Future<List<Partido>> proximosPartidos({
    List<Liga> ligas = Liga.todas,
    int dias = 7,
  }) async {
    final porLiga = await Future.wait(ligas.map((l) => _partidosDeLiga(l, dias)));
    final todos = porLiga.expand((p) => p).where((p) => p.estado != 'post').toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return todos;
  }

  Future<List<Partido>> _partidosDeLiga(Liga liga, int dias) async {
    final hoy = DateTime.now();
    final fechas = List.generate(dias, (i) => hoy.add(Duration(days: i)));

    // La tabla y los días se piden en paralelo.
    final resultados = await Future.wait([
      _tabla(liga),
      ...fechas.map((f) => _eventosDelDia(liga, f)),
    ]);
    final tabla = resultados.first as Map<String, StatsTabla>;
    final eventos = resultados.skip(1).expand((e) => e as List<Map<String, dynamic>>);

    // Un mismo partido puede aparecer en dos días por la zona horaria.
    final vistos = <String>{};
    return [
      for (final e in eventos)
        if (vistos.add('${e['id']}')) Partido.fromEspn(e, liga, tabla),
    ];
  }

  Future<List<Map<String, dynamic>>> _eventosDelDia(Liga liga, DateTime dia) async {
    final fecha = '${dia.year}${dia.month.toString().padLeft(2, '0')}${dia.day.toString().padLeft(2, '0')}';
    try {
      final res = await _dio.get('$_site/${liga.clave}/scoreboard', queryParameters: {'dates': fecha});
      return ((res.data as Map<String, dynamic>)['events'] as List? ?? [])
          .cast<Map<String, dynamic>>();
    } on DioException {
      return []; // un día que falla no debe botar la lista completa
    }
  }

  /// Tabla de posiciones: id de equipo → estadísticas.
  Future<Map<String, StatsTabla>> _tabla(Liga liga) async {
    try {
      final res = await _dio.get('$_v2/${liga.clave}/standings');
      final data = res.data as Map<String, dynamic>;
      // Las ligas con grupos traen varios "children"; se juntan todos.
      final grupos = (data['children'] as List? ?? [data]).cast<Map<String, dynamic>>();
      final tabla = <String, StatsTabla>{};
      for (final g in grupos) {
        final entries = ((g['standings'] as Map?)?['entries'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        for (final e in entries) {
          final id = '${(e['team'] as Map)['id']}';
          tabla[id] = StatsTabla.fromEspn(e['stats'] as List? ?? []);
        }
      }
      return tabla;
    } on DioException {
      return {}; // sin tabla, el modelo usa la forma de cada equipo
    }
  }
}
