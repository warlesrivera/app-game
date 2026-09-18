# FASE 2: PRICE WATCHER (OFERTAS)

## Objetivo
Sistema de monitoreo de precios para los juegos en la Wishlist del usuario[cite: 1].

## Reglas de Arquitectura
1. **Consumo nulo en cliente:** El teléfono móvil NO debe estar haciendo consultas HTTP en segundo plano[cite: 1].
2. **Abstracción:** Crear `abstract class PriceRepository`[cite: 1].

## Tareas a Ejecutar
1. **UI en GameDetails:** Agregar un botón de "Alerta de Precio" si el juego está en la Wishlist.
2. Permitir seleccionar tiendas objetivo (Steam, PlayStation, Xbox, Epic) mediante un Modal Bottom Sheet oscuro[cite: 1].
3. Guardar estas preferencias en el documento del juego en Firestore (`priceAlerts: true, targetStores: [...]`).
4. *(Nota: La lógica backend de escaneo y envío de Push Notifications vía FCM quedará como una Cloud Function separada, aquí solo se preparará la interfaz móvil y la escritura de la preferencia)*.