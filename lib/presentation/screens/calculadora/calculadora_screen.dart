import 'package:flutter/material.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';

// M6 — Calculadora: cuota → probabilidad implícita, comparada con el modelo.
// El veredicto cambia de color con una animación implícita (AnimatedContainer).
class CalculadoraScreen extends StatefulWidget {
  final int? probModelo; // viene del detalle; si no, se ajusta a mano
  final double? cuotaInicial;

  const CalculadoraScreen({super.key, this.probModelo, this.cuotaInicial});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  late double _cuota = widget.cuotaInicial ?? 1.85;
  late int _modelo = widget.probModelo ?? 60;

  void _cambiarCuota(double delta) =>
      setState(() => _cuota = double.parse((_cuota + delta).clamp(1.05, 10.0).toStringAsFixed(2)));

  @override
  Widget build(BuildContext context) {
    final implicita = (100 / _cuota).round();
    final valor = _modelo - implicita;
    final (fondo, color, titulo, texto) = valor >= 5
        ? (IziColors.lima, IziColors.negro, 'Hay valor: +$valor', 'El modelo ve más probabilidad que la casa. Pick con valor estadístico.')
        : valor > 0
            ? (IziColors.grisE2, IziColors.negro, 'Valor justo: +$valor', 'La cuota está casi alineada con el modelo.')
            : (IziColors.naranjo, IziColors.blanco, 'Sin valor: $valor', 'La casa paga menos de lo que indica el modelo. Mejor pasar.');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('← VOLVER', style: IziText.condensed(16)),
              ),
            ),
            const SizedBox(height: 14),
            Text('¿CUÁNTO\nVALE LA\nCUOTA?', style: IziText.display(56, height: .85)),
            const SizedBox(height: 20),
            Text('CUOTA DE LA CASA', style: IziText.mono(11)),
            const SizedBox(height: 8),
            _Stepper(
              valor: Formato.decimal(_cuota),
              onMenos: () => _cambiarCuota(-0.05),
              onMas: () => _cambiarCuota(0.05),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Caja(rotulo: 'IMPLÍCITA', valor: '$implicita%', fondo: IziColors.negro),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    // Sin un partido de origen, el % del modelo se ajusta tocando.
                    onTap: widget.probModelo == null ? () => setState(() => _modelo = _modelo >= 90 ? 30 : _modelo + 5) : null,
                    child: _Caja(rotulo: 'MODELO IZIBET', valor: '$_modelo%', fondo: IziColors.azul),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              color: fondo,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo.toUpperCase(), style: IziText.display(38, color: color, height: .9)),
                  const SizedBox(height: 6),
                  Text(texto, style: IziText.body(14, color: color, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.probModelo == null
                  ? 'Probabilidad implícita = 1 ÷ cuota. Toca + / − para probar, y la caja azul para cambiar el % del modelo.'
                  : 'Probabilidad implícita = 1 ÷ cuota. Toca + / − para probar.',
              style: IziText.body(12, color: IziColors.gris5F, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String valor;
  final VoidCallback onMenos;
  final VoidCallback onMas;
  const _Stepper({required this.valor, required this.onMenos, required this.onMas});

  @override
  Widget build(BuildContext context) {
    Widget boton(String s, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 64,
            alignment: Alignment.center,
            color: IziColors.negro,
            child: Text(s, style: IziText.condensed(30, color: IziColors.blanco)),
          ),
        );

    return Row(
      children: [
        boton('−', onMenos),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: IziColors.blanco,
              border: Border.all(color: IziColors.negro, width: 2),
            ),
            child: Text(valor, style: IziText.condensed(40, weight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 6),
        boton('+', onMas),
      ],
    );
  }
}

class _Caja extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color fondo;
  const _Caja({required this.rotulo, required this.valor, required this.fondo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: IziText.mono(10, color: IziColors.grisD6)),
          const SizedBox(height: 4),
          Text(valor, style: IziText.display(52, color: IziColors.blanco, height: .9)),
        ],
      ),
    );
  }
}
