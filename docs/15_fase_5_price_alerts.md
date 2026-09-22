# FASE 5: ALERTAS DE PRECIO (BACKGROUND NOTIFICATIONS)

## Objetivo
El teléfono debe notificar al usuario (Push Notification Local) si un juego de su Wishlist baja de precio, incluso si la app está cerrada.

## Reglas de Arquitectura
1. **Paquetes:** Instalar `workmanager` (para tareas en segundo plano) y `flutter_local_notifications` (para mostrar la alerta en el centro de notificaciones).
2. **Lógica de Tarea en Segundo Plano (Background Task):**
   - Configurar `workmanager` para que se ejecute una vez al día.
   - En el callback del background, leer la base de datos local (Hive) o la lista de Deseos en caché para obtener los nombres de los juegos en la Wishlist.
   - Iterar sobre esos nombres y consultar la API de CheapShark (ej. `GET https://www.cheapshark.com/api/1.0/games?title={NAME}`).
3. **Lanzar la Notificación:**
   - Si se encuentra un juego y su precio bajó (o si hay una oferta relevante), usar `flutter_local_notifications` para lanzar un aviso: "🏷️ ¡Oferta! {Juego} ha bajado a {Precio}".
4. **Permisos:** Asegurarse de pedir los permisos de notificaciones en Android (`<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`).