import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

// Barra inferior negra con dos pestañas: Partidos y Mis picks.
class IziBottomNav extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onCambiar;

  const IziBottomNav({super.key, required this.actual, required this.onCambiar});

  static const _items = ['Partidos', 'Mis picks'];

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
                    // El cuadro se rellena de lima en la pestaña activa (animación implícita).
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: i == actual ? IziColors.lima : Colors.transparent,
                        border: Border.all(color: i == actual ? IziColors.lima : IziColors.gris8A, width: 2),
                      ),
                    ),
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
