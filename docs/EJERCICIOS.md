# Ejercicios para aprender el repo de iziBet

Diez ejercicios con el mismo formato de las tareas del profesor (la galería y los ninjas), pero sobre **nuestra** app.
Cada uno dice **qué** hacer, **dónde** está el código, **pistas** y **cómo comprobar** que funciona.
El primero (B1) viene resuelto paso a paso, para que veas el método; el resto lo haces tú.

---

## Antes de empezar: cómo trabajar un cambio

1. **Una rama por ejercicio**, para no romper `main`:
   ```bash
   git checkout fs-dev
   git pull origin main
   git checkout -b ejercicio-b1
   ```
2. **Corre la app** y déjala abierta mientras programas:
   ```bash
   flutter run -d chrome
   ```
   Al guardar un archivo, aprieta `r` en la terminal (*hot reload*) y el cambio aparece al tiro. Si cambiaste un `Provider` o `main.dart`, usa `R` (*hot restart*).
3. **Revisa que no rompiste nada:**
   ```bash
   flutter analyze
   flutter test
   ```
4. **Guarda el avance:** commit con un mensaje que diga qué hiciste, push y Pull Request hacia `main`.

> Regla de oro: lee el archivo entero antes de tocarlo. Casi todo lo que necesitas ya existe en otra parte del repo.

---

## Bloque A — Navegación y animaciones (como la tarea de la galería)

### A1. Una liga más
**Qué:** agregar la Serie A de Italia a la lista de ligas, con una clave que no se repita.
**Dónde:** `lib/models/liga.dart`.
**Pistas:**
- Copia una de las ligas (`static const premier = Liga(...)`) y cámbiale los datos.
- La clave de ESPN para la Serie A es `ita.1`.
- No basta con crearla: tiene que estar en la lista `todas`.
**Comprobar:** recarga la app y deberían aparecer partidos con `SERIE A` sobre el nombre.

### A2. Color al apretar
**Qué:** la tarjeta de un partido se oscurece mientras el dedo (o el mouse) la presiona, con un `AnimatedContainer`.
**Dónde:** `lib/presentation/widgets/partido_card.dart`.
**Pistas:**
- Hoy es un `StatelessWidget`; para recordar si está presionada necesitas un `StatefulWidget` con un `bool _presionada`.
- `GestureDetector` tiene `onTapDown`, `onTapUp` y `onTapCancel`: cada uno hace `setState`.
- Cambia el `Container` por un `AnimatedContainer` con `duration` y un `color` que dependa de `_presionada` (por ejemplo `IziColors.grisE2`).
**Comprobar:** al mantener apretada una tarjeta se oscurece suave, y al soltarla vuelve a blanco.

### A3. El porcentaje también vuela
**Qué:** además del nombre, el `%` viaja de la lista al detalle con su propio `Hero`.
**Dónde:** `partido_card.dart` (origen) y `screens/detalle/detalle_screen.dart` (destino, en `_TarjetaPick`).
**Pistas:**
- Mira cómo está hecho el `Hero` del nombre: un `tag` que se arma con el id del partido, y un `Material(type: MaterialType.transparency)` adentro.
- El nuevo `tag` tiene que ser **distinto** del del nombre (ej. `'prob-${p.id}'`) e **igual** en las dos pantallas.
**Comprobar:** al abrir un partido, el número se mueve y crece hasta la tarjeta negra.

### A4. Volver con un botón
**Qué:** en el detalle, un botón **Volver a partidos**, además del "←" de arriba.
**Dónde:** `detalle_screen.dart`, al final del `ListView`.
**Pistas:** reutiliza `BotonIzi` con `estilo: EstiloBoton.borde`; para volver se usa `Navigator.of(context).pop()`.
**Comprobar:** el botón cierra el detalle y vuelve a la lista.

### A5. Una transición que además desliza
**Qué:** que el detalle entre con un fundido **y** subiendo desde abajo.
**Dónde:** `screens/inicio/inicio_screen.dart`, donde se hace el `push` del detalle.
**Pistas:**
- Hoy se usa `MaterialPageRoute`. Cámbialo por un `PageRouteBuilder`.
- En su `transitionsBuilder` puedes anidar un `FadeTransition` y un `SlideTransition`.
- Para el deslizamiento: `Tween(begin: const Offset(0, 1), end: Offset.zero).animate(animation)`.
- Si la pones en una función `Route rutaDesliza(Widget pantalla)` la puedes reutilizar.
**Comprobar:** el detalle sube desde abajo mientras aparece; el Hero sigue funcionando.

---

## Bloque B — API, Provider y lista (como la tarea de los ninjas)

### B1. Cuántos se ven — RESUELTO PASO A PASO
**Qué:** arriba de la lista, un texto que diga cuántos partidos se muestran, por ejemplo «21 partidos».
**Dónde:** `screens/inicio/inicio_screen.dart`, dentro del `FutureBuilder`, en el caso 3 (Datos).

**Paso 1. Entender dónde están los datos.** En el `builder` del `FutureBuilder`, cuando llegan los datos, la lista está en:
```dart
final partidos = snapshot.data ?? [];
```
El número que buscamos es `partidos.length`.

**Paso 2. Dónde ponerlo.** Hoy el caso 3 devuelve un `ListView.separated`. Para poner algo **arriba** de la lista, se envuelve en una `Column` y la lista va en un `Expanded` (si no, Flutter no sabe qué alto darle):
```dart
return Column(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${partidos.length} partidos',
          style: IziText.mono(11),
        ),
      ),
    ),
    Expanded(
      child: RefreshIndicator(
        // ... lo que ya estaba ...
      ),
    ),
  ],
);
```

**Paso 3. Detalle fino:** con 1 partido diría «1 partidos». Se arregla con un operador ternario:
```dart
'${partidos.length} ${partidos.length == 1 ? 'partido' : 'partidos'}'
```

**Paso 4. Comprobar:** `r` en la terminal y arriba de la lista aparece «21 partidos» (o los que haya hoy). `flutter analyze` sin errores.

**Qué aprendiste:** dónde viven los datos de un `FutureBuilder`, por qué un `ListView` dentro de una `Column` necesita `Expanded`, y cómo armar textos con interpolación (`'${...}'`).

### B2. Un buscador y "sin resultados"
**Qué:** un buscador arriba de la lista que filtra por nombre de equipo. Si no hay coincidencias, en vez de la lista vacía aparece «Ningún partido coincide con la búsqueda».
**Dónde:** `providers/partidos_provider.dart` (el texto buscado) e `inicio_screen.dart` (el `TextField` y el filtro).
**Pistas:**
- En el provider: un `String _busqueda = ''`, un getter y un método `buscar(String texto)` que guarde el texto en minúsculas y llame a `notifyListeners()`.
- En la pantalla: `TextField(onChanged: prov.buscar)`, y antes de armar la lista:
  `final visibles = partidos.where((p) => p.nombre.toLowerCase().contains(prov.busqueda)).toList();`
- Si `visibles.isEmpty`, devuelve un `EstadoVacio` con el mensaje.
- Ojo: el contador de B1 debería contar `visibles`, no `partidos`.
**Comprobar:** escribe «colo» y quedan los de Colo-Colo; escribe «zzz» y aparece el mensaje.

### B3. Ordenar por probabilidad
**Qué:** un botón que ordena la lista de mayor a menor probabilidad del pick y, al tocarlo otra vez, vuelve al orden original (por fecha).
**Dónde:** `partidos_provider.dart` y la cabecera de `inicio_screen.dart`.
**Pistas:**
- En el provider: `bool _ordenarPorProb = false` y un método `alternarOrden()`.
- **No ordenes la lista original** (la que viene de la API): haz una copia, `final copia = [...visibles]`, y ordena la copia con `copia.sort((a, b) => b.mejor.prob.compareTo(a.mejor.prob));`.
- El botón puede ser un `IconButton` con `Icons.sort` en la cabecera negra.
**Comprobar:** al tocarlo, el partido con el % más alto queda primero; al tocarlo de nuevo vuelve el orden por fecha.

### B4. Un total en el detalle
**Qué:** en el detalle, cuántos goles a favor lleva cada equipo en la temporada.
**Dónde:** `detalle_screen.dart`, dentro de `_FormaUltimos`.
**Pistas:**
- Cada `Equipo` tiene `tabla` (puede ser `null`), y dentro `golesFavor` y `jugados`.
- Usa `e.tabla?.golesFavor ?? 0` para no caerte cuando no hay tabla.
**Comprobar:** bajo la forma de cada equipo aparece algo como «50 goles en 24 partidos».

### B5. Buscar también por liga
**Qué:** que el buscador de B2 encuentre partidos por equipo **o** por liga (con «premier» aparecen todos los de la Premier).
**Dónde:** el `where` que escribiste en B2.
**Pistas:** une dos condiciones con `||`; el nombre de la liga está en `p.liga.nombre`.
**Comprobar:** «premier» muestra solo partidos de la Premier League; «arsenal» sigue funcionando.

---

## Mapa rápido del repo (para orientarte)

| Si quieres cambiar… | Mira en… |
|---|---|
| Colores y tipografías | `lib/core/theme/` |
| Qué datos trae la API | `lib/data/espn_service.dart` y `lib/models/` |
| Cómo se calcula el pick | `lib/logic/recomendador.dart` |
| El estado compartido | `lib/presentation/providers/` |
| Una pantalla | `lib/presentation/screens/` |
| Un componente que se repite | `lib/presentation/widgets/` |
| La base de datos | `supabase/schema.sql` |
