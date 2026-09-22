# FASE 7: LIMPIEZA DE DEUDA TÉCNICA (CÓDIGO MUERTO)

## Objetivo
Eliminar por completo el código, los modelos y los endpoints relacionados con la capa de videos de RAWG (`/movies`), ya que la app ahora utiliza WebViews y enlaces directos para los tráilers, simplificando el mantenimiento.

## Tareas de Limpieza
1. **Modelos:** Eliminar cualquier modelo Freezed relacionado con los videos (ej. `GameVideo`, `RawgMovie`). Volver a correr `build_runner` para actualizar los archivos autogenerados.
2. **Capa de Datos:** 
   - Eliminar los métodos de peticiones HTTP en `RawgRemoteDataSource` que apunten a `.../movies`.
   - Eliminar los métodos correspondientes en `GameRepository`.
3. **Gestión de Estado y UI:**
   - Revisar `GameDetailsCubit` o el Bloc equivalente y limpiar cualquier estado, variable o llamada que intente cargar videos de RAWG.
   - Asegurarse de que en `GameDetailsPage` no queden referencias rotas.