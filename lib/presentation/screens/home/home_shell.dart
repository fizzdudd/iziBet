import 'package:flutter/material.dart';

import '../../widgets/izi_bottom_nav.dart';
import '../inicio/inicio_screen.dart';
import '../mis_picks/mis_picks_screen.dart';

// Las dos pestañas de la barra inferior. IndexedStack mantiene el estado
// (por ejemplo, el scroll) de cada pestaña al cambiar entre ellas.
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
          MisPicksScreen(),
        ],
      ),
      bottomNavigationBar: IziBottomNav(
        actual: _pestana,
        onCambiar: (i) => setState(() => _pestana = i),
      ),
    );
  }
}
