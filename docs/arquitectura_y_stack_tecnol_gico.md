# GameVault - Arquitectura y Stack Tecnológico

## 1. Concepto Principal
GameVault es una plataforma personal (PokéAPI + Netflix + Biblioteca Gamer) para administrar videojuegos jugados y deseados.
**Regla de Oro:** La app NO tiene base de datos propia con el catálogo de juegos. RAWG provee el catálogo, Firebase provee la relación del usuario con esos juegos.

## 2. Stack Tecnológico
*   **Framework:** Flutter (Dart)
*   **Gestión de Estado:** `flutter_bloc` (Cubit preferido, Bloc para flujos complejos)
*   **Backend & Auth:** Firebase (Auth, Firestore, Crashlytics, App Check)
*   **Networking:** `dio` (con interceptores para deduplicación y caché)
*   **Modelado:** `freezed`, `json_serializable`
*   **Navegación:** `go_router`
*   **Imágenes:** `cached_network_image`

## 3. Clean Architecture Simplificada
El flujo de dependencias es estrictamente unidireccional:
`Presentation (UI)` -> `Cubit / Bloc` -> `UseCase` -> `Repository` -> `DataSource (RAWG / Firebase / Local)`

*   **PROHIBIDO:** Llamar a RAWG, Firebase, Dio o Firestore directamente desde la UI.
*   **PROHIBIDO:** Acoplar el dominio directamente a RAWG. El dominio debe conocer `GameRepository`, no `RawgGameRepository`. Esto permite cambiar de API en el futuro (ej. IGDB).

## 4. Estructura de Carpetas
```text
lib/
├── app/
│   ├── app.dart
│   ├── router/          # Configuración de GoRouter
│   ├── theme/           # UI premium, colores, tipografía
│   └── di/              # Inyección de dependencias
├── core/
│   ├── constants/
│   ├── errors/          # Manejo global de excepciones
│   ├── network/         # ApiClient, interceptores, deduplicación
│   ├── cache/           # Lógica de Hive/SQLite
│   ├── utils/
│   └── widgets/         # Componentes UI reutilizables
└── features/
    ├── auth/            # data/, domain/, presentation/
    ├── profile/
    ├── dashboard/
    ├── games/           # Catálogo RAWG abstraído
    ├── library/         # Relación usuario-juegos
    └── ai_chat/         # IA On-device
```