import 'package:flutter/foundation.dart';

import '../../data/espn_service.dart';
import '../../models/partido.dart';
import 'favoritos_provider.dart';

// Guarda el Future de los partidos para no volver a pedirlos a la API cada
// vez que se dibuja una pantalla; además, el filtro de liga y la búsqueda.
class PartidosProvider extends ChangeNotifier {
  static const filtroTodas = 'todas';
  static const filtroFavs = 'favs';

  final _servicio = EspnService();

  late Future<List<Partido>> _partidos = _servicio.proximosPartidos();
  String _filtro = filtroTodas;
  String _busqueda = '';

  Future<List<Partido>> get partidos => _partidos;
  String get filtro => _filtro;
  String get busqueda => _busqueda;

  void recargar() {
    _partidos = _servicio.proximosPartidos();
    notifyListeners();
  }

  void cambiarFiltro(String filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  void buscar(String texto) {
    _busqueda = texto.trim().toLowerCase();
    notifyListeners();
  }

  /// Aplica el filtro (todas / favs / una liga) y la búsqueda por equipo.
  List<Partido> filtrar(List<Partido> todos, FavoritosProvider favs) {
    return todos.where((p) {
      final pasaFiltro = switch (_filtro) {
        filtroTodas => true,
        filtroFavs => favs.siguePartido(p),
        _ => p.liga.clave == _filtro,
      };
      final pasaBusqueda = _busqueda.isEmpty ||
          p.local.nombre.toLowerCase().contains(_busqueda) ||
          p.visita.nombre.toLowerCase().contains(_busqueda);
      return pasaFiltro && pasaBusqueda;
    }).toList();
  }

  /// El partido con el mejor pick (más valor, o más probabilidad).
  static Partido? pickDelDia(List<Partido> partidos) {
    final proximos = partidos.where((p) => p.estado == 'pre').toList();
    if (proximos.isEmpty) return null;
    int puntaje(Partido p) => (p.mejor.valor ?? 0) * 2 + p.mejor.prob;
    proximos.sort((a, b) => puntaje(b).compareTo(puntaje(a)));
    return proximos.first;
  }
}
