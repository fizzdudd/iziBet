import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../../core/utils/validadores.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/boton_izi.dart';
import '../../widgets/campo_izi.dart';
import 'auth_layout.dart';

// Crear una cuenta en Supabase Auth.
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

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    // Si algún validator devuelve un mensaje, no se envía nada.
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().registrar(
          nombre: _nombre.text,
          correo: _correo.text,
          clave: _clave.text,
        );
    // Con sesión, el AuthGate ya muestra la app; se cierra el registro.
    if (ok && mounted) Navigator.of(context).pop();
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
            const SizedBox(height: 18),
            Text(
              'Al crear tu cuenta confirmas que eres mayor de 18 años y que iziBet entrega sugerencias, no garantías.',
              style: IziText.body(13, color: IziColors.grisD6, height: 1.4),
            ),
            const SizedBox(height: 18),
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
