import 'package:flutter/material.dart';

import '../../widgets/izi_bottom_nav.dart';
import '../favoritos/favoritos_screen.dart';
import '../historial/historial_screen.dart';
import '../inicio/inicio_screen.dart';
import '../partidos/partidos_screen.dart';

// Las cuatro pestañas de la barra inferior. IndexedStack mantiene el estado
// (scroll, búsqueda) de cada pestaña al cambiar entre ellas.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _pestana = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pestana,
        children: const [
          InicioScreen(),
          PartidosScreen(),
          FavoritosScreen(),
          HistorialScreen(),
        ],
      ),
      bottomNavigationBar: IziBottomNav(
        actual: _pestana,
        onCambiar: (i) => setState(() => _pestana = i),
      ),
    );
  }
}
