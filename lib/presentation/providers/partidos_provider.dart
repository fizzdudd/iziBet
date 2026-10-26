import 'package:flutter/foundation.dart';

import '../../data/espn_service.dart';
import '../../models/partido.dart';

// Guarda el Future de los partidos para no volver a pedirlos a la API
// cada vez que se dibuja la pantalla.
class PartidosProvider extends ChangeNotifier {
  final _servicio = EspnService();

  late Future<List<Partido>> _partidos = _servicio.proximosPartidos();

  Future<List<Partido>> get partidos => _partidos;

  void recargar() {
    _partidos = _servicio.proximosPartidos();
    notifyListeners();
  }
}
