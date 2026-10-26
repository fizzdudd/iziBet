import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/formato.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/boton_izi.dart';
import '../../widgets/campo_izi.dart';
import 'auth_layout.dart';
import '../../../core/utils/validadores.dart';

// M1 — Registro + verificación 18+.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _fechaTexto = TextEditingController();
  DateTime? _nacimiento;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    _fechaTexto.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _nacimiento ?? DateTime(hoy.year - 20, hoy.month, hoy.day),
      firstDate: DateTime(1920),
      lastDate: hoy,
      helpText: 'FECHA DE NACIMIENTO',
    );
    if (elegida == null) return;
    setState(() {
      _nacimiento = elegida;
      _fechaTexto.text = Formato.fechaCorta(elegida);
    });
  }

  Future<void> _crear() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.registrar(
      nombre: _nombre.text,
      correo: _correo.text,
      clave: _clave.text,
      nacimiento: _nacimiento!,
    );
    if (!ok || !mounted) return;

    if (Supabase.instance.client.auth.currentSession == null) {
      // El proyecto Supabase pide confirmar el correo antes de entrar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Revisa tu correo para confirmarla y luego inicia sesión.')),
      );
    }
    // Con sesión, el AuthGate ya muestra la app; se cierra el registro.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthLayout(
      titular: Text.rich(
        TextSpan(
          style: IziText.display(68, color: IziColors.blanco, height: .84),
          children: const [
            TextSpan(text: 'DATOS\nANTES QUE\n'),
            TextSpan(text: 'CORAZÓN.', style: TextStyle(color: IziColors.lima)),
          ],
        ),
      ),
      formulario: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CampoIzi(
              rotulo: 'Nombre',
              controller: _nombre,
              validator: (v) => Validadores.requerido(v, 'tu nombre'),
            ),
            const SizedBox(height: 10),
            CampoIzi(
              rotulo: 'Correo',
              controller: _correo,
              teclado: TextInputType.emailAddress,
              validator: Validadores.correo,
            ),
            const SizedBox(height: 10),
            CampoIzi(
              rotulo: 'Contraseña',
              controller: _clave,
              oculto: true,
              validator: Validadores.clave,
            ),
            const SizedBox(height: 10),
            CampoIzi(
              rotulo: 'Fecha de nacimiento',
              controller: _fechaTexto,
              soloLectura: true,
              pista: 'DD / MM / AAAA',
              onTap: _elegirFecha,
              validator: (_) {
                if (_nacimiento == null) return 'Elige tu fecha de nacimiento';
                if (Validadores.edad(_nacimiento!) < 18) return 'Debes ser mayor de 18 años';
                return null;
              },
            ),
            const SizedBox(height: 22),
            // El check también es un campo del Form, con su propio validator.
            FormField<bool>(
              initialValue: false,
              validator: (v) => v == true ? null : 'Debes confirmar que eres mayor de edad',
              builder: (campo) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => campo.didChange(!(campo.value ?? false)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: campo.value == true ? IziColors.lima : Colors.transparent,
                            border: campo.value == true ? null : Border.all(color: IziColors.blanco, width: 2),
                          ),
                          child: campo.value == true
                              ? Text('✓', style: IziText.body(14, weight: FontWeight.w800, height: 1))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Confirmo que soy mayor de 18 años y entiendo que iziBet entrega sugerencias, no garantías.',
                            style: IziText.body(13, color: IziColors.grisD6, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (campo.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(campo.errorText!, style: IziText.body(12, color: IziColors.naranjo)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (auth.error != null) ...[
              Text(auth.error!, style: IziText.body(14, color: IziColors.naranjo)),
              const SizedBox(height: 12),
            ],
            BotonIzi(texto: 'Crear cuenta →', onTap: _crear, cargando: auth.cargando),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () {
                  auth.limpiarError();
                  Navigator.of(context).pop();
                },
                child: Text.rich(
                  TextSpan(
                    style: IziText.body(14, color: IziColors.grisB5),
                    children: [
                      const TextSpan(text: '¿Ya tienes cuenta? '),
                      TextSpan(
                        text: 'Inicia sesión',
                        style: IziText.body(14, color: IziColors.blanco).copyWith(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
