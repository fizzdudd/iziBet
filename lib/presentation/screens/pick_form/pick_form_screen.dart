import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';
import '../../../core/utils/validadores.dart';
import '../../../models/pick.dart';
import '../../providers/picks_provider.dart';
import '../../widgets/boton_izi.dart';
import '../../widgets/campo_izi.dart';
import '../../widgets/izi_chip.dart';

// Crear o editar un pick seguido (tabla "picks" en Supabase).
// Si el pick no tiene id es nuevo; si tiene, se edita y se puede borrar.
class PickFormScreen extends StatefulWidget {
  final Pick pick;
  const PickFormScreen({super.key, required this.pick});

  @override
  State<PickFormScreen> createState() => _PickFormScreenState();
}

class _PickFormScreenState extends State<PickFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _cuota = TextEditingController(
    text: widget.pick.cuota >= 1.01 ? Formato.decimal(widget.pick.cuota) : '',
  );
  late final _monto = TextEditingController(
    text: widget.pick.monto == null ? '' : widget.pick.monto!.round().toString(),
  );
  late final _nota = TextEditingController(text: widget.pick.nota ?? '');
  late EstadoPick _estado = widget.pick.estado;
  bool _guardando = false;

  bool get _esNuevo => widget.pick.id == null;

  @override
  void dispose() {
    _cuota.dispose();
    _monto.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final prov = context.read<PicksProvider>();
    final monto = _monto.text.trim().isEmpty ? null : double.parse(_monto.text.replaceAll('.', '').replaceAll(',', '.'));
    final pick = widget.pick.copyWith(
      cuota: double.parse(_cuota.text.replaceAll(',', '.')),
      monto: monto,
      borrarMonto: monto == null,
      nota: _nota.text.trim(),
      estado: _estado,
    );

    setState(() => _guardando = true);
    try {
      _esNuevo ? await prov.crear(pick) : await prov.actualizar(pick);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_esNuevo ? 'Pick guardado en tu historial.' : 'Pick actualizado.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Intenta de nuevo.')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _borrar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¿BORRAR ESTE PICK?', style: IziText.condensed(22)),
        content: Text('Se quitará de tu historial.', style: IziText.body(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR', style: IziText.condensed(16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('BORRAR', style: IziText.condensed(16, color: IziColors.naranjo)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    try {
      await context.read<PicksProvider>().borrar(widget.pick);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo borrar.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pick;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _form,
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
              Text(_esNuevo ? 'SEGUIR\nPICK' : 'EDITAR\nPICK', style: IziText.display(56, height: .85)),
              const SizedBox(height: 20),
              // Resumen del pick (no se edita)
              Container(
                color: IziColors.negro,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.liga} · ${Formato.fechaLarga(p.fechaPartido)}', style: IziText.mono(10, color: IziColors.grisB5)),
                    const SizedBox(height: 6),
                    Text(p.partido.toUpperCase(), style: IziText.condensed(20, color: IziColors.blanco, height: 1)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p.mercado.toUpperCase()} · ${p.seleccion}',
                            style: IziText.body(14, color: IziColors.blanco),
                          ),
                        ),
                        Text('${p.prob}%', style: IziText.display(34, color: IziColors.lima, height: .9)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CampoIzi(
                rotulo: 'Cuota de la casa',
                controller: _cuota,
                oscuro: false,
                pista: '1,85',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                formatos: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                validator: Validadores.cuota,
              ),
              const SizedBox(height: 14),
              CampoIzi(
                rotulo: 'Monto (opcional, CLP)',
                controller: _monto,
                oscuro: false,
                pista: '5000',
                teclado: TextInputType.number,
                formatos: [FilteringTextInputFormatter.digitsOnly],
                validator: Validadores.montoOpcional,
              ),
              const SizedBox(height: 14),
              CampoIzi(
                rotulo: 'Nota',
                controller: _nota,
                oscuro: false,
                lineas: 3,
                pista: '¿Por qué lo sigues?',
                validator: (v) => (v ?? '').length > 200 ? 'Máximo 200 caracteres' : null,
              ),
              if (!_esNuevo) ...[
                const SizedBox(height: 18),
                Text('RESULTADO', style: IziText.mono(10)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final e in EstadoPick.values)
                      IziChip(texto: e.texto, activo: _estado == e, onTap: () => setState(() => _estado = e)),
                  ],
                ),
              ],
              const SizedBox(height: 26),
              BotonIzi(
                texto: _esNuevo ? '+ Seguir este pick' : 'Guardar cambios',
                estilo: EstiloBoton.negro,
                cargando: _guardando,
                onTap: _guardar,
              ),
              if (!_esNuevo) ...[
                const SizedBox(height: 10),
                BotonIzi(texto: 'Borrar pick', estilo: EstiloBoton.borde, tamano: 17, onTap: _borrar),
              ],
              const SizedBox(height: 12),
              Text(
                'iziBet no maneja dinero: el monto es solo para tu registro.',
                textAlign: TextAlign.center,
                style: IziText.body(12, color: IziColors.gris5F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
