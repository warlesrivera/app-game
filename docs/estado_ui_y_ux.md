# GameVault - Estado y Directrices Visuales

## 1. Cubit vs Bloc
*   **Cubit (Por defecto):** Auth, Profile, Dashboard, Game Details, Library, Settings.
*   **Bloc (Excepciones):** Búsquedas con debounce, cancelación de requests, flujos complejos event-driven.

Los estados de UI deben seguir el patrón: `initial`, `loading`, `loaded`, `updatingStatus`, `error`.

## 2. UI / UX Premium
*   **Estética:** Gaming premium, cinemático. Inspiración: Netflix + PlayStation + Pokédex.
*   **Características:** Fondo oscuro, gradientes sutiles, glassmorphism moderado, tipografía fuerte, excelente jerarquía. SIN exceso de neón o partículas.
*   **Animaciones:** Fade, slide, scale al presionar tarjetas. Shimmer para cargas. Hero transitions de 400-600ms para pasar a Game Details.
*   **Performance:** 60 FPS estricto. Uso de `const`, `ListView.builder`, lazy loading y caché de imágenes.

## 3. Flujo de Navegación (GoRouter)
*   **Splash:** Visual, sin demoras artificiales. Decide ruta según estado de Firebase Auth.
*   **Auth:** Login/Registro con Google o Email.
*   **Dashboard:** Bottom Navigation (Inicio, Biblioteca, Buscar, Perfil).

## 4. IA Local (Game Assistant)
Arquitectura de abstracción estricta:
`GameAIRepository` -> `AndroidOnDeviceProvider` | `IOSOnDeviceProvider` | `CloudProvider (fallback)`.
Nunca mezclar código nativo en la UI.