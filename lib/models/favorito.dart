enum TipoFavorito { liga, equipo }

// Una liga o un equipo que el usuario sigue (tabla "favoritos" en Supabase).
class Favorito {
  final TipoFavorito tipo;
  final String clave; // clave de liga ("chi.1") o id de equipo de ESPN
  final String nombre;

  const Favorito({
    required this.tipo,
    required this.clave,
    required this.nombre,
  });

  factory Favorito.fromMap(Map<String, dynamic> m) => Favorito(
        tipo: m['tipo'] == 'liga' ? TipoFavorito.liga : TipoFavorito.equipo,
        clave: m['clave'] as String,
        nombre: m['nombre'] as String,
      );

  Map<String, dynamic> toMap() => {
        'tipo': tipo.name,
        'clave': clave,
        'nombre': nombre,
      };
}
