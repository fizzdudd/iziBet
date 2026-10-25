import 'package:flutter/material.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../widgets/izi_logo.dart';

// Se muestra si todavía no se pegaron la URL y la key de Supabase en
// lib/core/config/env.dart. Evita que la app se caiga al partir.
class ConfigFaltanteScreen extends StatelessWidget {
  const ConfigFaltanteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IziColors.negro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IziLogo(),
              const SizedBox(height: 32),
              Text('FALTA\nSUPABASE.', style: IziText.display(64, color: IziColors.lima)),
              const SizedBox(height: 20),
              Text(
                'Pega la URL y la publishable key de tu proyecto en lib/core/config/env.dart '
                '(Project Settings → API Keys) y vuelve a correr la app.',
                style: IziText.body(16, color: IziColors.grisD6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
