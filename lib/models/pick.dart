enum EstadoPick { pendiente, acierto, fallo }

extension EstadoPickTexto on EstadoPick {
  String get texto => switch (this) {
        EstadoPick.pendiente => 'PENDIENTE',
        EstadoPick.acierto => 'ACIERTO',
        EstadoPick.fallo => 'FALLO',
      };

  static EstadoPick desde(String? valor) => switch (valor) {
        'acierto' => EstadoPick.acierto,
        'fallo' => EstadoPick.fallo,
        _ => EstadoPick.pendiente,
      };
}

// Un pick que el usuario sigue. Es una fila de la tabla "picks" en Supabase.
class Pick {
  final String? id; // null mientras no se guarda
  final String partidoId;
  final String partido; // "Colo-Colo vs U. de Chile"
  final String liga;
  final String mercado; // "Más/menos"
  final String seleccion; // "Más de 2,5 goles"
  final int prob;
  final double cuota;
  final double? monto;
  final String? nota;
  final EstadoPick estado;
  final DateTime fechaPartido;
  final DateTime? creadoEn;

  const Pick({
    this.id,
    required this.partidoId,
    required this.partido,
    required this.liga,
    required this.mercado,
    required this.seleccion,
    required this.prob,
    required this.cuota,
    this.monto,
    this.nota,
    this.estado = EstadoPick.pendiente,
    required this.fechaPartido,
    this.creadoEn,
  });

  factory Pick.fromMap(Map<String, dynamic> m) => Pick(
        id: m['id'] as String,
        partidoId: m['partido_id'] as String,
        partido: m['partido'] as String,
        liga: m['liga'] as String,
        mercado: m['mercado'] as String,
        seleccion: m['seleccion'] as String,
        prob: (m['prob'] as num).round(),
        cuota: (m['cuota'] as num).toDouble(),
        monto: (m['monto'] as num?)?.toDouble(),
        nota: m['nota'] as String?,
        estado: EstadoPickTexto.desde(m['estado'] as String?),
        fechaPartido: DateTime.parse(m['fecha_partido'] as String).toLocal(),
        creadoEn: m['created_at'] == null
            ? null
            : DateTime.parse(m['created_at'] as String).toLocal(),
      );

  // user_id no se manda: Supabase lo llena con auth.uid().
  Map<String, dynamic> toMap() => {
        'partido_id': partidoId,
        'partido': partido,
        'liga': liga,
        'mercado': mercado,
        'seleccion': seleccion,
        'prob': prob,
        'cuota': cuota,
        'monto': monto,
        'nota': nota,
        'estado': estado.name,
        'fecha_partido': fechaPartido.toUtc().toIso8601String(),
      };

  Pick copyWith({
    double? cuota,
    double? monto,
    bool borrarMonto = false,
    String? nota,
    EstadoPick? estado,
  }) =>
      Pick(
        id: id,
        partidoId: partidoId,
        partido: partido,
        liga: liga,
        mercado: mercado,
        seleccion: seleccion,
        prob: prob,
        cuota: cuota ?? this.cuota,
        monto: borrarMonto ? null : (monto ?? this.monto),
        nota: nota ?? this.nota,
        estado: estado ?? this.estado,
        fechaPartido: fechaPartido,
        creadoEn: creadoEn,
      );
}
