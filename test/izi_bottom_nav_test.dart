import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:izibet/presentation/widgets/izi_bottom_nav.dart';

void main() {
  // En las pruebas no se descargan las fuentes de Google.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('la barra inferior no tapa el contenido de la pantalla', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(key: Key('cuerpo')),
          bottomNavigationBar: IziBottomNav(actual: 0, onCambiar: (_) {}),
        ),
      ),
    );

    final barra = tester.getSize(find.byType(IziBottomNav));
    final cuerpo = tester.getSize(find.byKey(const Key('cuerpo')));
    expect(barra.height, lessThan(120));
    expect(cuerpo.height, greaterThan(700));
  });
}
