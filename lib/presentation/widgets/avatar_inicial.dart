import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

// Círculo azul con la inicial del usuario.
class AvatarInicial extends StatelessWidget {
  final String inicial;
  final VoidCallback? onTap;

  const AvatarInicial({super.key, required this.inicial, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: IziColors.azul),
        child: Text(inicial, style: IziText.condensed(18, color: IziColors.blanco)),
      ),
    );
  }
}
