enum TipoMercado { masMenos, unoXdos, ambosMarcan }

enum Confianza { alta, media, baja }

extension ConfianzaTexto on Confianza {
  String get texto => switch (this) {
        Confianza.alta => 'ALTA',
        Confianza.media => 'MEDIA',
        Confianza.baja => 'BAJA',
      };
}

// Una parte del reparto de probabilidad (ej. "MÁS" 68 / "MENOS" 32).
class Reparto {
  final String etiqueta;
  final int valor;
  const Reparto(this.etiqueta, this.valor);
}

// La recomendación del modelo para un mercado de un partido.
class Mercado {
  final TipoMercado tipo;
  final String titulo; // "MÁS/MENOS 2,5"
  final String seleccion; // "Más de 2,5 goles"
  final int prob; // probabilidad del modelo, 0-100
  final double? cuota; // cuota decimal de la casa, si ESPN la trae
  final Confianza confianza;
  final List<Reparto> reparto;
  final List<String> razones;

  const Mercado({
    required this.tipo,
    required this.titulo,
    required this.seleccion,
    required this.prob,
    required this.cuota,
    required this.confianza,
    required this.reparto,
    required this.razones,
  });

  /// Probabilidad implícita de la cuota: 1 ÷ cuota.
  int? get implicita => cuota == null ? null : (100 / cuota!).round();

  /// Puntos de valor: lo que el modelo ve por sobre la casa.
  int? get valor => implicita == null ? null : prob - implicita!;

  String get tituloCorto => switch (tipo) {
        TipoMercado.masMenos => 'Más/menos',
        TipoMercado.unoXdos => '1X2',
        TipoMercado.ambosMarcan => 'Ambos marcan',
      };
}
