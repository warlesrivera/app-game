# FASE 1H: PESTAÑA DE LORE (WIKIPEDIA API)

## Objetivo
Crear una pestaña o sección de "Lore / Historia" en los detalles del juego reciclando el código existente de Wikipedia, pero optimizándolo para buscar el argumento del juego.

## Endpoint a Utilizar (MediaWiki API)
`GET https://es.wikipedia.org/w/api.php?action=query&prop=extracts&titles={GAME_NAME}_(videojuego)&format=json`
*(Nota: Añadir "_(videojuego)" al final de la búsqueda ayuda a evitar que Wikipedia devuelva páginas genéricas, por ejemplo, buscando la película en lugar del juego).*

## Reglas de Arquitectura
1. **Reciclar Código Muerto:**
   - Buscar los repositorios, Cubits o modelos de Wikipedia que ya existen en el código fuente pero que están sin uso, y refactorizarlos para este nuevo propósito.
2. **Paquetes:**
   - Usar `flutter_html` para renderizar el texto que devuelve Wikipedia (la propiedad `extract` viene con etiquetas HTML como `<p>` y `<h2>`).
3. **Gestión de Estado (Hive Caché):**
   - Como Wikipedia no cambia todos los días, guardar el resultado de la petición en la caché de Hive (usando la regla de 7 días que tenemos para detalles).
4. **UI:**
   - Agregar el botón o pestaña "Lore" en la `GameDetailsPage`.
   - Mostrar un Shimmer mientras busca en Wikipedia.
   - Si Wikipedia no encuentra el juego, mostrar un mensaje elegante tipo "Lore no disponible en los archivos".