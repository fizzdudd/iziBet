import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/picks_service.dart';
import '../../models/pick.dart';

// Los picks que sigue el usuario: crear, ver, editar y borrar.
class PicksProvider extends ChangeNotifier {
  final _servicio = PicksService();
  late final StreamSubscription<AuthState> _sesion;

  List<Pick> _picks = [];
  bool _cargando = false;
  String? _error;

  PicksProvider() {
    // Cada vez que alguien entra o sale, se cargan SUS picks.
    _sesion = Supabase.instance.client.auth.onAuthStateChange.listen((_) => cargar());
  }

  List<Pick> get picks => _picks;
  bool get cargando => _cargando;
  String? get error => _error;

  int get aciertos => _picks.where((p) => p.estado == EstadoPick.acierto).length;
  int get fallos => _picks.where((p) => p.estado == EstadoPick.fallo).length;
  int get pendientes => _picks.where((p) => p.estado == EstadoPick.pendiente).length;

  /// El pick que ya se sigue para ese partido, si existe.
  Pick? buscar(String partidoId) {
    for (final p in _picks) {
      if (p.partidoId == partidoId) return p;
    }
    return null;
  }

  Future<void> cargar() async {
    if (Supabase.instance.client.auth.currentSession == null) {
      _picks = [];
      notifyListeners();
      return;
    }
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _picks = await _servicio.listar();
    } catch (_) {
      _error = 'No pudimos cargar tus picks.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> crear(Pick pick) async {
    final nuevo = await _servicio.crear(pick);
    _picks = [nuevo, ..._picks];
    notifyListeners();
  }

  Future<void> actualizar(Pick pick) async {
    final guardado = await _servicio.actualizar(pick);
    _picks = [for (final p in _picks) p.id == guardado.id ? guardado : p];
    notifyListeners();
  }

  Future<void> borrar(Pick pick) async {
    await _servicio.borrar(pick.id!);
    _picks = _picks.where((p) => p.id != pick.id).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _sesion.cancel();
    super.dispose();
  }
}
