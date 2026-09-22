# FASE 2: ALERTAS DE PRECIO (PRICE WATCHER)

## Objetivo
Implementar un rastreador de precios para los juegos que el usuario tiene marcados en su estado de "Wishlist" (Deseos).

## API a Utilizar (CheapShark - Gratis y sin API Key)
- **Endpoint Búsqueda:** `GET https://www.cheapshark.com/api/1.0/games?title={GAME_NAME}`
- **Respuesta Esperada:** Devuelve un arreglo. Usaremos el primer resultado, que contiene el campo `cheapest` (el precio más bajo histórico o actual) y `cheapestDealID`.

## Reglas de Arquitectura
1. **Modelos:**
   - Crear un modelo `GameDeal` que contenga `String gameID`, `String cheapestPrice`, y `String externalTitle`.
2. **Capa de Datos:**
   - Crear un `PriceRepository` que haga peticiones a CheapShark usando el nombre exacto del juego.
3. **Gestión de Estado y UI:**
   - En la pestaña de **Lista de Deseos (Wishlist)**, por cada juego en la lista, el Cubit/Bloc debe consultar asíncronamente a CheapShark.
   - Modificar la UI de la tarjeta del juego en la Wishlist para mostrar una pequeña etiqueta verde ("🏷️ Oferta: $X.XX") debajo del título si se encuentra un precio.
   - Mostrar un estado de carga (pequeño CircularProgressIndicator o Shimmer en el área del precio) mientras se consulta la API.