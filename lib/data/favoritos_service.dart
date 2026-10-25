import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorito.dart';

// Ligas y equipos que sigue cada usuario (tabla "favoritos", con RLS).
class FavoritosService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Favorito>> listar() async {
    final filas = await _db.from('favoritos').select('tipo, clave, nombre');
    return filas.map(Favorito.fromMap).toList();
  }

  Future<void> agregar(Favorito f) => _db.from('favoritos').insert(f.toMap());

  Future<void> quitar(Favorito f) =>
      _db.from('favoritos').delete().eq('tipo', f.tipo.name).eq('clave', f.clave);
}
