import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Envuelve Supabase Auth con un estado de "cargando" y un mensaje de error
// que las pantallas de login y registro escuchan.
class AuthProvider extends ChangeNotifier {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  User? get usuario => _auth.currentUser;

  /// Nombre guardado al registrarse; si no hay, la parte antes del @.
  String get nombre {
    final meta = usuario?.userMetadata?['nombre'] as String?;
    if (meta != null && meta.trim().isNotEmpty) return meta.trim().split(' ').first;
    return (usuario?.email ?? 'tú').split('@').first;
  }

  String get inicial => nombre.isEmpty ? '?' : nombre[0].toUpperCase();

  Future<bool> entrar(String correo, String clave) => _ejecutar(
        () => _auth.signInWithPassword(email: correo.trim(), password: clave),
      );

  Future<bool> registrar({
    required String nombre,
    required String correo,
    required String clave,
    required DateTime nacimiento,
  }) =>
      _ejecutar(
        () => _auth.signUp(
          email: correo.trim(),
          password: clave,
          // Se guarda en los metadatos del usuario, no en una tabla aparte.
          data: {
            'nombre': nombre.trim(),
            'fecha_nacimiento': nacimiento.toIso8601String().substring(0, 10),
            'acepta_18': true,
          },
        ),
      );

  Future<void> salir() => _auth.signOut();

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _ejecutar(Future<Object?> Function() accion) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await accion();
      return true;
    } on AuthException catch (e) {
      _error = _traducir(e.message);
      return false;
    } catch (_) {
      _error = 'No pudimos conectar. Revisa tu internet e intenta de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  static String _traducir(String mensaje) {
    final m = mensaje.toLowerCase();
    if (m.contains('invalid login')) return 'Correo o contraseña incorrectos.';
    if (m.contains('already registered')) return 'Ese correo ya tiene una cuenta.';
    if (m.contains('email not confirmed')) return 'Confirma tu correo antes de entrar.';
    if (m.contains('password')) return 'La contraseña no cumple los requisitos.';
    return mensaje;
  }
}
