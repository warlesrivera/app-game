# FASE 1F: DETALLES COMPLETOS Y TRÁILERS (RAWG API)

## Objetivo
Obtener y mostrar la descripción real sin formato HTML (`description_raw`) y los tráilers del juego consumiendo los endpoints específicos de la API de RAWG.

## Endpoints a Utilizar
1. Detalles del juego: `GET https://api.rawg.io/api/games/{id}?key=API_KEY`
2. Tráilers: `GET https://api.rawg.io/api/games/{id}/movies?key=API_KEY`

## Reglas de Arquitectura
1. **Modelos (Freezed):** 
   - Actualizar el modelo `Game` para incluir `String? description`. En el factory de JSON, mapear la llave `description_raw` hacia este campo.
   - Crear el modelo `GameVideo` con los campos `String id`, `String name`, `String preview` (URL de imagen) y `String url` (mapear a `data.max` o `data.480` del JSON).
2. **Capa de Datos:**
   - Agregar `Future<Game> getGameDetails(int id)` y `Future<List<GameVideo>> getGameVideos(int id)` a `GameRepository` y `RawgRemoteDataSource`.
3. **Gestión de Estado:**
   - Como la lista de juegos (`/games`) no trae la descripción completa, `GameDetailsPage` debe usar un Cubit (ej. `GameDetailsCubit`) que reciba el ID del juego al abrir la pantalla y cargue asíncronamente la descripción y los videos.
4. **UI:**
   - Mostrar un `Shimmer` en la sección de descripción y videos mientras se hace la petición HTTP.
   - Mostrar la descripción con una tipografía legible.
   - Mostrar los videos en una lista horizontal (similares a miniaturas de YouTube usando el campo `preview`). Por ahora, al tocar un video, usar el paquete `url_launcher` para abrir el link en el navegador o reproductor nativo.