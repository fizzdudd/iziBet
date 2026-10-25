// Datos de tu proyecto Supabase (Project Settings → API Keys).
// La publishable key puede ir en el código: la seguridad la da Row Level
// Security en cada tabla, no esconder la key.
//
// También se pueden pasar al correr la app, sin tocar este archivo:
// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=...
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'TU_SUPABASE_URL',
  );

  static const supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'TU_SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get supabaseConfigurado =>
      supabaseUrl.startsWith('https://') && !supabaseKey.startsWith('TU_');
}
