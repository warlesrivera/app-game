# GameVault - Modelo de Datos y Estrategia de Red

## 1. Reglas de Firebase
Firestore **solo** almacena la relación del usuario con el juego. NO duplicar metadatos de RAWG (portadas, descripciones, etc.).

### Estructura Firestore
*   `users/{uid}`: `{ name, age, email, avatarId, createdAt }`
*   `users/{uid}/games/{rawgGameId}`: `{ status: 'completed'|'playing'|'wishlist'|'abandoned', personalRating, notes, updatedAt }`
*   `users/{uid}/ai_chats/{chatId}`: Historial de IA local (sin tokens pesados).

### Seguridad
*   Reglas estrictas de Firestore: `request.auth.uid == uid`
*   App Check habilitado.

## 2. Estrategia RAWG API
Para mantener la app en el tier gratuito y optimizar batería/datos, se exige un control de requests estricto en la capa `core/network`.

*   **Memory Cache:** Para navegación rápida entre pantallas activas.
*   **Persistent Cache:** TTL de 30-60 minutos para el Dashboard (Discover).
*   **Request Deduplication:** Si la UI pide el Juego 12345 dos veces simultáneamente, el `ApiClient` solo dispara UNA petición HTTP a RAWG.
*   **Debounce:** Búsquedas limitadas a 350-500ms de espera.
*   **Retry Policy:** Exponential backoff. Nunca reintentos infinitos. Límite para errores 429.

## 3. Entidad Core (Dominio)
```dart
class Game {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final List<String> screenshotUrls;
  final List<Platform> platforms; // Mapeado a iconos locales
  // ... adaptado de RAWG
}
```