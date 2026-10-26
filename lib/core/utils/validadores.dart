// Validadores de los formularios. Devuelven null si el valor está bien,
// o el mensaje que muestra el TextFormField.
class Validadores {
  Validadores._();

  static final _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? correo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!_correo.hasMatch(v.trim())) return 'Ese correo no es válido';
    return null;
  }

  static String? clave(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? requerido(String? v, String campo) =>
      v == null || v.trim().isEmpty ? 'Ingresa $campo' : null;

  /// Edad cumplida a hoy.
  static int edad(DateTime nacimiento) {
    final hoy = DateTime.now();
    var anios = hoy.year - nacimiento.year;
    if (hoy.month < nacimiento.month || (hoy.month == nacimiento.month && hoy.day < nacimiento.day)) {
      anios--;
    }
    return anios;
  }

  /// Cuota decimal: número con coma o punto, entre 1,01 y 100.
  static String? cuota(String? v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    if (n == null) return 'Ingresa la cuota (ej. 1,85)';
    if (n < 1.01) return 'La cuota mínima es 1,01';
    if (n > 100) return 'Revisa la cuota';
    return null;
  }

  /// Monto opcional: si viene, tiene que ser mayor que 0.
  static String? montoOpcional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = double.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
    if (n == null || n <= 0) return 'El monto debe ser mayor a 0';
    return null;
  }
}
