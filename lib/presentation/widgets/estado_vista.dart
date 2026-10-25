import 'package:flutter/material.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';
import 'boton_izi.dart';

// Estados de carga, vacío y error para que ninguna pantalla quede en blanco.
class EstadoCargando extends StatelessWidget {
  final String texto;
  const EstadoCargando({super.key, this.texto = 'Calculando picks…'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3, color: IziColors.negro),
          ),
          const SizedBox(height: 14),
          Text(texto.toUpperCase(), style: IziText.mono(11)),
        ],
      ),
    );
  }
}

class EstadoVacio extends StatelessWidget {
  final String titulo;
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;
  final bool oscuro;

  const EstadoVacio({
    super.key,
    required this.titulo,
    required this.texto,
    this.accion,
    this.onAccion,
    this.oscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = oscuro ? IziColors.blanco : IziColors.negro;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(), style: IziText.display(40, color: color)),
          const SizedBox(height: 10),
          Text(texto, style: IziText.body(15, color: oscuro ? IziColors.grisB5 : IziColors.gris5F)),
          if (accion != null) ...[
            const SizedBox(height: 18),
            BotonIzi(
              texto: accion!,
              onTap: onAccion,
              estilo: oscuro ? EstiloBoton.lima : EstiloBoton.negro,
              tamano: 17,
            ),
          ],
        ],
      ),
    );
  }
}

class EstadoError extends StatelessWidget {
  final String texto;
  final VoidCallback onReintentar;
  const EstadoError({super.key, required this.texto, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return EstadoVacio(
      titulo: 'Se cortó el juego',
      texto: texto,
      accion: 'Reintentar',
      onAccion: onReintentar,
    );
  }
}
