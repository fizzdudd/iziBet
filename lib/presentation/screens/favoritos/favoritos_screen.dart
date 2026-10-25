import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../models/favorito.dart';
import '../../../models/liga.dart';
import '../../../models/partido.dart';
import '../../providers/favoritos_provider.dart';
import '../../providers/partidos_provider.dart';
import '../../widgets/escudo.dart';

// M4 — "Tus colores": ligas y equipos que sigue el usuario.
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  String _busqueda = '';

  Future<void> _alternar(Favorito f) async {
    final ok = await context.read<FavoritosProvider>().alternar(f);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Revisa tu conexión.')),
      );
    }
  }

  /// Equipos que juegan en los próximos días, sin repetir, más los ya seguidos.
  List<({String id, String nombre, String abrev, String liga})> _equipos(
    List<Partido> partidos,
    FavoritosProvider favs,
  ) {
    final mapa = <String, ({String id, String nombre, String abrev, String liga})>{};
    for (final p in partidos) {
      for (final e in [p.local, p.visita]) {
        mapa[e.id] ??= (id: e.id, nombre: e.nombre, abrev: e.abrev, liga: p.liga.nombre);
      }
    }
    for (final f in favs.equipos) {
      mapa[f.clave] ??= (id: f.clave, nombre: f.nombre, abrev: f.nombre.substring(0, 3).toUpperCase(), liga: 'Siguiendo');
    }
    final lista = mapa.values
        .where((e) => _busqueda.isEmpty || e.nombre.toLowerCase().contains(_busqueda))
        .toList()
      ..sort((a, b) {
        final sa = favs.sigueEquipo(a.id) ? 0 : 1;
        final sb = favs.sigueEquipo(b.id) ? 0 : 1;
        return sa != sb ? sa - sb : a.nombre.compareTo(b.nombre);
      });
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritosProvider>();
    final partidos = context.watch<PartidosProvider>().partidos;
    final ligas = Liga.todas
        .where((l) => _busqueda.isEmpty || l.nombre.toLowerCase().contains(_busqueda))
        .toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('TUS\nCOLORES', style: IziText.display(56, height: .85)),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => _busqueda = v.trim().toLowerCase()),
            cursorColor: IziColors.negro,
            style: IziText.body(15),
            decoration: InputDecoration(
              hintText: 'Buscar liga o equipo…',
              hintStyle: IziText.body(15, color: IziColors.gris5F),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: IziColors.negro, width: 2),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: IziColors.azul, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('LIGAS', style: IziText.mono(11)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.1,
            children: [
              for (final l in ligas)
                _TarjetaLiga(
                  liga: l,
                  siguiendo: favs.sigueLiga(l.clave),
                  onTap: () => _alternar(Favorito(tipo: TipoFavorito.liga, clave: l.clave, nombre: l.nombre)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('EQUIPOS', style: IziText.mono(11)),
          const SizedBox(height: 10),
          FutureBuilder<List<Partido>>(
            future: partidos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(color: IziColors.negro)),
                );
              }
              final equipos = _equipos(snapshot.data ?? [], favs);
              if (equipos.isEmpty) {
                return Text('No encontramos equipos con ese nombre.', style: IziText.body(14, color: IziColors.gris5F));
              }
              return Column(
                children: [
                  for (final e in equipos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => _alternar(Favorito(tipo: TipoFavorito.equipo, clave: e.id, nombre: e.nombre)),
                        child: Container(
                          color: IziColors.blanco,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Escudo(abrev: e.abrev),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.nombre.toUpperCase(), style: IziText.condensed(18)),
                                    Text(e.liga, style: IziText.body(12, color: IziColors.gris5F)),
                                  ],
                                ),
                              ),
                              _Interruptor(encendido: favs.sigueEquipo(e.id)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TarjetaLiga extends StatelessWidget {
  final Liga liga;
  final bool siguiendo;
  final VoidCallback onTap;
  const _TarjetaLiga({required this.liga, required this.siguiendo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final texto = siguiendo ? IziColors.blanco : IziColors.negro;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        color: siguiendo ? IziColors.negro : IziColors.blanco,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(siguiendo ? '★ SIGUIENDO' : '+ SEGUIR', style: IziText.condensed(13, color: texto)),
            Text(liga.nombre.toUpperCase(), style: IziText.condensed(19, color: texto, height: 1)),
          ],
        ),
      ),
    );
  }
}

// Interruptor cuadrado del mockup (46×26) con la perilla que se desliza.
class _Interruptor extends StatelessWidget {
  final bool encendido;
  const _Interruptor({required this.encendido});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 26,
      padding: const EdgeInsets.all(3),
      color: encendido ? IziColors.negro : IziColors.grisD6,
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: encendido ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          color: encendido ? IziColors.lima : IziColors.blanco,
        ),
      ),
    );
  }
}
