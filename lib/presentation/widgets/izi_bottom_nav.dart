import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

// Barra inferior negra del mockup: Inicio, Partidos, Favoritos, Historial.
// Cada pestaña tiene su figura: cuadro inclinado, círculo, rombo y cuadrado.
class IziBottomNav extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onCambiar;

  const IziBottomNav({super.key, required this.actual, required this.onCambiar});

  static const _items = ['Inicio', 'Partidos', 'Favoritos', 'Historial'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IziColors.negro,
      padding: EdgeInsets.only(top: 12, bottom: 10 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onCambiar(i),
                child: Column(
                  // Sin esto, la Column toma todo el alto y la barra tapa la pantalla.
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Icono(indice: i, activo: i == actual),
                    const SizedBox(height: 6),
                    Text(
                      _items[i].toUpperCase(),
                      style: IziText.condensed(
                        13,
                        weight: FontWeight.w700,
                        color: i == actual ? IziColors.lima : IziColors.gris8A,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Icono extends StatelessWidget {
  final int indice;
  final bool activo;
  const _Icono({required this.indice, required this.activo});

  @override
  Widget build(BuildContext context) {
    final color = activo ? IziColors.lima : IziColors.gris8A;
    final caja = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: activo ? IziColors.lima : Colors.transparent,
        border: activo ? null : Border.all(color: color, width: 2),
        shape: indice == 1 ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
    return switch (indice) {
      0 => Transform(transform: Matrix4.skewX(-0.27), alignment: Alignment.center, child: caja),
      2 => Transform.rotate(angle: 0.785, child: Transform.scale(scale: .8, child: caja)),
      _ => caja,
    };
  }
}
