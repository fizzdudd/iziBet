import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/izi_colors.dart';
import '../../../core/theme/izi_text.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/boton_izi.dart';
import '../../widgets/campo_izi.dart';
import 'auth_layout.dart';
import 'registro_screen.dart';
import '../../../core/utils/validadores.dart';

// Iniciar sesión con correo y contraseña (Supabase Auth).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _verClave = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    // Si entra, el AuthGate cambia de pantalla solo.
    await context.read<AuthProvider>().entrar(_correo.text, _clave.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthLayout(
      titular: Text.rich(
        TextSpan(
          style: IziText.display(68, color: IziColors.blanco, height: .84),
          children: const [
            TextSpan(text: 'APUESTA\nCON\n'),
            TextSpan(text: 'DATOS.', style: TextStyle(color: IziColors.lima)),
          ],
        ),
      ),
      formulario: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CampoIzi(
              rotulo: 'Correo',
              controller: _correo,
              teclado: TextInputType.emailAddress,
              validator: Validadores.correo,
            ),
            const SizedBox(height: 14),
            CampoIzi(
              rotulo: 'Contraseña',
              controller: _clave,
              oculto: !_verClave,
              validator: Validadores.clave,
              sufijo: IconButton(
                icon: Icon(_verClave ? Icons.visibility_off : Icons.visibility, color: IziColors.grisB5, size: 20),
                onPressed: () => setState(() => _verClave = !_verClave),
              ),
            ),
            const SizedBox(height: 18),
            if (auth.error != null) ...[
              Text(auth.error!, style: IziText.body(14, color: IziColors.naranjo)),
              const SizedBox(height: 12),
            ],
            BotonIzi(texto: 'Entrar →', onTap: _entrar, cargando: auth.cargando),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () {
                  auth.limpiarError();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistroScreen()));
                },
                child: Text.rich(
                  TextSpan(
                    style: IziText.body(14, color: IziColors.grisB5),
                    children: [
                      const TextSpan(text: '¿No tienes cuenta? '),
                      TextSpan(
                        text: 'Créala aquí',
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
