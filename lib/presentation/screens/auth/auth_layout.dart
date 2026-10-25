import 'package:flutter/material.dart';

import '../../../core/theme/izi_colors.dart';
import '../../widgets/franja.dart';
import '../../widgets/izi_logo.dart';

// Fondo negro con las tres franjas de color y el logo (M1). Lo comparten
// el login y el registro; cada uno pone su titular y su formulario.
class AuthLayout extends StatelessWidget {
  final Widget titular;
  final Widget formulario;

  const AuthLayout({super.key, required this.titular, required this.formulario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IziColors.negro,
      body: Stack(
        children: [
          const Positioned(
            top: 60,
            right: -30,
            child: Row(
              children: [
                Franja(color: IziColors.lima, ancho: 30, alto: 250),
                SizedBox(width: 10),
                Franja(color: IziColors.naranjo, ancho: 30, alto: 250),
                SizedBox(width: 10),
                Franja(color: IziColors.azul, ancho: 30, alto: 250),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IziLogo(),
                  const SizedBox(height: 22),
                  titular,
                  const SizedBox(height: 28),
                  formulario,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
