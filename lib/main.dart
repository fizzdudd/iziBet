import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/theme/izi_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/favoritos_provider.dart';
import 'presentation/providers/partidos_provider.dart';
import 'presentation/providers/picks_provider.dart';
import 'presentation/screens/auth/auth_gate.dart';
import 'presentation/screens/config/config_faltante_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.supabaseConfigurado) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildIziTheme(),
      home: const ConfigFaltanteScreen(),
    ));
    return;
  }

  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseKey);
  runApp(const IziBetApp());
}

class IziBetApp extends StatelessWidget {
  const IziBetApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Los providers viven arriba de MaterialApp para compartirse entre pantallas.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PartidosProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => PicksProvider()),
      ],
      child: MaterialApp(
        title: 'iziBet',
        debugShowCheckedModeBanner: false,
        theme: buildIziTheme(),
        home: const AuthGate(),
      ),
    );
  }
}
