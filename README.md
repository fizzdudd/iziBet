# iziBet

App Flutter de recomendaciones de apuestas deportivas basadas en estadísticas.
Proyecto de la Unidad 2 de IIP323W (UDD).

> Sugerencias estadísticas, no garantías. iziBet no maneja dinero. Juego responsable · 18+.

## Qué hace

- **Partidos de los próximos 7 días** (Primera División CL, Premier League, Champions y LaLiga) desde la API pública de ESPN.
- **Motor de picks** (`lib/logic/recomendador.dart`): estima los goles esperados de cada equipo con la tabla y la forma, usa la distribución de Poisson para calcular la probabilidad de **Más/menos**, **1X2** y **Ambos marcan**, y la compara con la cuota de la casa (probabilidad implícita = 1 ÷ cuota) para encontrar *valor*.
- **Seguir picks** y llevar un **historial** con % de acierto (tabla `picks` en Supabase).
- **Favoritos**: ligas y equipos que sigues (tabla `favoritos` en Supabase).
- **Calculadora** de cuota → probabilidad.

## Requisitos de la unidad

| # | Requisito | Dónde está |
|---|---|---|
| 1 | Login con Supabase (registro, entrar, salir) | `screens/auth/` · `providers/auth_provider.dart` |
| 2 | Datos de una API con FutureBuilder | `data/espn_service.dart` · `screens/inicio/` · `screens/partidos/` |
| 3 | Navegación con el dato por constructor | `DetalleScreen(partido: …)` · `PickFormScreen(pick: …)` |
| 4 | Hero + animación implícita | Hero en el nombre del partido (lista → detalle) · `AnimatedFractionallySizedBox`, `AnimatedContainer`, `AnimatedSwitcher` |
| 5 | Tabla en Supabase con RLS y CRUD | `supabase/schema.sql` · `data/picks_service.dart` |
| 6 | Formulario con validación | Registro (18+) · `screens/pick_form/` |
| 7 | Estado con Provider | `presentation/providers/` (4 `ChangeNotifier`) |
| 8 | Widgets propios en su archivo | `presentation/widgets/` |
| 9 | GitHub con commits de todos | — |

## Estructura

```
lib/
  main.dart                 Supabase.initialize + MultiProvider + AuthGate
  core/                     config (env), tema (colores y tipografías del mockup), utilidades
  models/                   Liga, Equipo, Partido, Mercado, Pick, Favorito
  data/                     servicios: ESPN (dio) y Supabase
  logic/recomendador.dart   motor de picks (Dart puro, con pruebas)
  presentation/
    providers/              Auth, Partidos, Favoritos, Picks
    screens/                auth, inicio, partidos, detalle, favoritos, historial, pick_form, calculadora
    widgets/                componentes reutilizables
supabase/schema.sql         tablas y políticas RLS
```

## Cómo correrla

1. Crea un proyecto en [supabase.com](https://supabase.com).
2. En **SQL Editor → New query**, pega `supabase/schema.sql` y ejecútalo.
3. Para probar sin confirmar correos: **Authentication → Sign In / Providers → Email** y desactiva *Confirm email*.
4. Copia la **Project URL** y la **publishable key** (Project Settings → API Keys) en `lib/core/config/env.dart`, o pásalas al correr:

   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_KEY=sb_publishable_xxxx
   ```

5. Instala dependencias y corre:

   ```bash
   flutter pub get
   flutter run            # emulador Android o teléfono
   flutter run -d chrome  # navegador
   ```

## Pruebas

```bash
flutter test
```

Prueban el motor de picks (Poisson, conversión de cuotas, que el 1X2 sume 100 % y el cálculo de valor) sin depender de la API ni de Supabase.
