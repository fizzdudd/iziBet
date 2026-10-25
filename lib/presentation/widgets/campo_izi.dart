import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/izi_colors.dart';
import '../../core/theme/izi_text.dart';

// Campo de formulario con el estilo del mockup: rótulo monoespaciado arriba
// y una línea abajo (sobre fondo oscuro) o un borde de 2 px (sobre claro).
class CampoIzi extends StatelessWidget {
  final String rotulo;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool oscuro;
  final bool oculto;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formatos;
  final String? pista;
  final bool soloLectura;
  final VoidCallback? onTap;
  final int lineas;
  final Widget? sufijo;

  const CampoIzi({
    super.key,
    required this.rotulo,
    this.controller,
    this.validator,
    this.oscuro = true,
    this.oculto = false,
    this.teclado,
    this.formatos,
    this.pista,
    this.soloLectura = false,
    this.onTap,
    this.lineas = 1,
    this.sufijo,
  });

  @override
  Widget build(BuildContext context) {
    final texto = oscuro ? IziColors.blanco : IziColors.negro;
    final linea = oscuro
        ? const UnderlineInputBorder(borderSide: BorderSide(color: IziColors.blanco, width: 2))
        : const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: IziColors.negro, width: 2),
          );
    final lineaError = oscuro
        ? const UnderlineInputBorder(borderSide: BorderSide(color: IziColors.naranjo, width: 2))
        : const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: IziColors.naranjo, width: 2),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo.toUpperCase(), style: IziText.mono(10, color: oscuro ? IziColors.grisB5 : IziColors.gris5F)),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: oculto,
          keyboardType: teclado,
          inputFormatters: formatos,
          readOnly: soloLectura,
          onTap: onTap,
          maxLines: oculto ? 1 : lineas,
          cursorColor: oscuro ? IziColors.lima : IziColors.negro,
          style: IziText.body(17, color: texto),
          decoration: InputDecoration(
            isDense: true,
            hintText: pista,
            hintStyle: IziText.body(17, color: oscuro ? IziColors.gris8A : IziColors.gris8A),
            contentPadding: oscuro
                ? const EdgeInsets.only(top: 6, bottom: 12)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: linea,
            focusedBorder: linea.copyWith(
              borderSide: BorderSide(color: oscuro ? IziColors.lima : IziColors.azul, width: 2),
            ),
            errorBorder: lineaError,
            focusedErrorBorder: lineaError,
            errorStyle: IziText.body(12, color: IziColors.naranjo),
            filled: !oscuro,
            fillColor: IziColors.blanco,
            suffixIcon: sufijo,
          ),
        ),
      ],
    );
  }
}
