// Una liga de ESPN. La clave es el código que usa la API (ej. "chi.1").
class Liga {
  final String clave;
  final String nombre;
  final String corta; // como aparece sobre cada partido: "PRIMERA CL"
  final String chip; // como aparece en los filtros: "Primera"

  const Liga({
    required this.clave,
    required this.nombre,
    required this.corta,
    required this.chip,
  });

  static const primeraCl = Liga(
    clave: 'chi.1',
    nombre: 'Primera División CL',
    corta: 'PRIMERA CL',
    chip: 'Primera',
  );
  static const premier = Liga(
    clave: 'eng.1',
    nombre: 'Premier League',
    corta: 'PREMIER',
    chip: 'Premier',
  );
  static const champions = Liga(
    clave: 'uefa.champions',
    nombre: 'Champions League',
    corta: 'CHAMPIONS',
    chip: 'UCL',
  );
  static const laLiga = Liga(
    clave: 'esp.1',
    nombre: 'LaLiga',
    corta: 'LALIGA',
    chip: 'LaLiga',
  );

  static const todas = [primeraCl, premier, champions, laLiga];

  static Liga? porClave(String clave) {
    for (final l in todas) {
      if (l.clave == clave) return l;
    }
    return null;
  }
}
