import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/favoritos_service.dart';
import '../../models/favorito.dart';
import '../../models/partido.dart';

// Ligas y equipos favoritos de quien inició sesión, sincronizados con Supabase.
class FavoritosProvider extends ChangeNotifier {
  final _servicio = FavoritosService();
  final Map<String, Favorito> _favs = {}; // "tipo:clave" → favorito
  late final StreamSubscription<AuthState> _sesion;

  FavoritosProvider() {
    // Cada vez que alguien entra o sale, se cargan SUS favoritos.
    _sesion = Supabase.instance.client.auth.onAuthStateChange.listen((_) => cargar());
  }

  static String _llave(TipoFavorito tipo, String clave) => '${tipo.name}:$clave';

  bool sigueLiga(String clave) => _favs.containsKey(_llave(TipoFavorito.liga, clave));
  bool sigueEquipo(String id) => _favs.containsKey(_llave(TipoFavorito.equipo, id));

  bool siguePartido(Partido p) =>
      sigueLiga(p.liga.clave) || sigueEquipo(p.local.id) || sigueEquipo(p.visita.id);

  List<Favorito> get equipos =>
      _favs.values.where((f) => f.tipo == TipoFavorito.equipo).toList();

  bool get vacio => _favs.isEmpty;

  Future<void> cargar() async {
    _favs.clear(); // nada del usuario anterior
    notifyListeners();
    if (Supabase.instance.client.auth.currentSession == null) return;
    try {
      for (final f in await _servicio.listar()) {
        _favs[_llave(f.tipo, f.clave)] = f;
      }
    } catch (_) {
      // Si falla, la app sigue funcionando sin favoritos.
    }
    notifyListeners();
  }

  /// Optimista: el switch cambia al tiro y vuelve atrás si Supabase falla.
  Future<bool> alternar(Favorito f) async {
    final llave = _llave(f.tipo, f.clave);
    final estaba = _favs.containsKey(llave);
    estaba ? _favs.remove(llave) : _favs[llave] = f;
    notifyListeners();
    try {
      estaba ? await _servicio.quitar(f) : await _servicio.agregar(f);
      return true;
    } catch (_) {
      estaba ? _favs[llave] = f : _favs.remove(llave);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _sesion.cancel();
    super.dispose();
  }
}
