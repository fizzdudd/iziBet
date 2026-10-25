import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pick.dart';

// CRUD de la tabla "picks". Row Level Security hace que cada usuario
// solo vea, cree, edite y borre sus propias filas.
class PicksService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Pick>> listar() async {
    final filas = await _db.from('picks').select().order('fecha_partido', ascending: false);
    return filas.map(Pick.fromMap).toList();
  }

  Future<Pick> crear(Pick pick) async {
    final fila = await _db.from('picks').insert(pick.toMap()).select().single();
    return Pick.fromMap(fila);
  }

  Future<Pick> actualizar(Pick pick) async {
    final fila = await _db.from('picks').update(pick.toMap()).eq('id', pick.id!).select().single();
    return Pick.fromMap(fila);
  }

  Future<void> borrar(String id) => _db.from('picks').delete().eq('id', id);
}
