import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/formato.dart';
import '../../data/picks_service.dart';
import '../../models/pick.dart';

// Los picks que sigue el usuario (crear, ver, editar y borrar) y las
// estadísticas del historial calculadas a partir de ellos.
class PicksProvider extends ChangeNotifier {
  final _servicio = PicksService();
  late final StreamSubscription<AuthState> _sesion;

  List<Pick> _picks = [];
  bool _cargando = false;
  String? _error;

  PicksProvider() {
    _sesion = Supabase.instance.client.auth.onAuthStateChange.listen((_) => cargar());
  }

  List<Pick> get picks => _picks;
  bool get cargando => _cargando;
  String? get error => _error;

  int get aciertos => _picks.where((p) => p.estado == EstadoPick.acierto).length;
  int get fallos => _picks.where((p) => p.estado == EstadoPick.fallo).length;
  int get pendientes => _picks.where((p) => p.estado == EstadoPick.pendiente).length;

  /// % de acierto sobre los picks ya resueltos de los últimos 30 días.
  int? get porcentajeAcierto {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final resueltos = _picks.where((p) => p.estado != EstadoPick.pendiente && p.fechaPartido.isAfter(desde));
    if (resueltos.isEmpty) return null;
    final ok = resueltos.where((p) => p.estado == EstadoPick.acierto).length;
    return (ok / resueltos.length * 100).round();
  }

  /// % de acierto de cada una de las últimas 8 semanas (null = sin picks resueltos).
  List<int?> get barrasSemanales {
    final lunesActual = Formato.inicioSemana(DateTime.now());
    return List.generate(8, (i) {
      final inicio = lunesActual.subtract(Duration(days: 7 * (7 - i)));
      final fin = inicio.add(const Duration(days: 7));
      final semana = _picks.where((p) =>
          p.estado != EstadoPick.pendiente &&
          !p.fechaPartido.isBefore(inicio) &&
          p.fechaPartido.isBefore(fin));
      if (semana.isEmpty) return null;
      final ok = semana.where((p) => p.estado == EstadoPick.acierto).length;
      return (ok / semana.length * 100).round();
    });
  }

  Pick? buscar(String partidoId, String seleccion) {
    for (final p in _picks) {
      if (p.partidoId == partidoId && p.seleccion == seleccion) return p;
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
      _error = 'No pudimos cargar tu historial.';
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
