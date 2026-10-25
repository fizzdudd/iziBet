// Formatos en español de Chile, sin depender de paquetes externos.
class Formato {
  Formato._();

  static const _dias = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  static const _meses = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
  ];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// 1.85 → "1,85"
  static String decimal(double valor, {int decimales = 2}) =>
      valor.toStringAsFixed(decimales).replaceAll('.', ',');

  /// "18:00"
  static String hora(DateTime f) => '${_dos(f.hour)}:${_dos(f.minute)}';

  /// "SÁB 18:00"
  static String diaHora(DateTime f) => '${_dias[f.weekday - 1]} ${hora(f)}';

  /// "SÁB 18 OCT · 18:00"
  static String fechaLarga(DateTime f) =>
      '${_dias[f.weekday - 1]} ${f.day} ${_meses[f.month - 1]} · ${hora(f)}';

  /// "14 / 03 / 2000"
  static String fechaCorta(DateTime f) =>
      '${_dos(f.day)} / ${_dos(f.month)} / ${f.year}';

  /// Lunes de la semana de [f], a medianoche (para agrupar el historial).
  static DateTime inicioSemana(DateTime f) {
    final d = DateTime(f.year, f.month, f.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }
}
