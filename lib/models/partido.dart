import '../logic/recomendador.dart';
import 'equipo.dart';
import 'liga.dart';
import 'mercado.dart';

// Cuotas decimales de la casa (ESPN las entrega en formato americano).
class Cuotas {
  final double? local;
  final double? empate;
  final double? visita;
  final double? mas;
  final double? menos;
  final double linea; // línea de goles, normalmente 2,5

  const Cuotas({
    this.local,
    this.empate,
    this.visita,
    this.mas,
    this.menos,
    this.linea = 2.5,
  });

  static const vacias = Cuotas();

  // "+220" → 3,20 · "-145" → 1,69 · "EVEN" → 2,00
  static double? americanaADecimal(Object? texto) {
    if (texto == null) return null;
    final limpio = '$texto'.trim().toUpperCase();
    if (limpio == 'EVEN') return 2;
    final n = double.tryParse(limpio.replaceAll('+', ''));
    if (n == null || n == 0) return null;
    final dec = n > 0 ? 1 + n / 100 : 1 + 100 / n.abs();
    return double.parse(dec.toStringAsFixed(2));
  }

  factory Cuotas.fromEspn(Map<String, dynamic>? odds) {
    if (odds == null) return vacias;
    // Usa la cuota de cierre y, si no está, la de apertura.
    double? leer(Map<String, dynamic>? lado) {
      if (lado == null) return null;
      final close = lado['close'] as Map<String, dynamic>?;
      final open = lado['open'] as Map<String, dynamic>?;
      return americanaADecimal(close?['odds'] ?? open?['odds']);
    }

    final ml = odds['moneyline'] as Map<String, dynamic>?;
    final total = odds['total'] as Map<String, dynamic>?;
    return Cuotas(
      local: leer(ml?['home'] as Map<String, dynamic>?),
      empate: leer(ml?['draw'] as Map<String, dynamic>?),
      visita: leer(ml?['away'] as Map<String, dynamic>?),
      mas: leer(total?['over'] as Map<String, dynamic>?),
      menos: leer(total?['under'] as Map<String, dynamic>?),
      linea: (odds['overUnder'] as num?)?.toDouble() ?? 2.5,
    );
  }
}

class Partido {
  final String id;
  final Liga liga;
  final DateTime fecha; // en hora local
  final String estadio;
  final String estado; // "pre", "in" o "post"
  final Equipo local;
  final Equipo visita;
  final Cuotas cuotas;

  Partido({
    required this.id,
    required this.liga,
    required this.fecha,
    required this.estadio,
    required this.estado,
    required this.local,
    required this.visita,
    required this.cuotas,
  });

  String get nombre => '${local.nombre} vs ${visita.nombre}';
  bool get enVivo => estado == 'in';

  // Los mercados se calculan una sola vez, la primera vez que se piden.
  late final List<Mercado> mercados = Recomendador.analizar(this);

  /// El mercado que la app recomienda para este partido.
  Mercado get mejor => Recomendador.elegirMejor(mercados);

  // Un "event" del scoreboard de ESPN.
  factory Partido.fromEspn(
    Map<String, dynamic> evento,
    Liga liga,
    Map<String, StatsTabla> tablaPorId,
  ) {
    final comp = (evento['competitions'] as List).first as Map<String, dynamic>;
    final competidores = (comp['competitors'] as List).cast<Map<String, dynamic>>();
    final local = competidores.firstWhere(
      (c) => c['homeAway'] == 'home',
      orElse: () => competidores.first,
    );
    final visita = competidores.firstWhere(
      (c) => c['homeAway'] == 'away',
      orElse: () => competidores.last,
    );
    // A veces ESPN trae elementos nulos en la lista de cuotas.
    final odds = (comp['odds'] as List? ?? []).whereType<Map<String, dynamic>>().toList();

    return Partido(
      id: '${evento['id']}',
      liga: liga,
      fecha: DateTime.parse(evento['date'] as String).toLocal(),
      estadio: ((comp['venue'] as Map?)?['fullName'] as String?) ?? '',
      estado: (((evento['status'] as Map)['type'] as Map)['state'] as String?) ?? 'pre',
      local: Equipo.fromEspn(local, tablaPorId),
      visita: Equipo.fromEspn(visita, tablaPorId),
      cuotas: Cuotas.fromEspn(odds.isEmpty ? null : odds.first),
    );
  }
}
