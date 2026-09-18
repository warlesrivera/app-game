# GameVault - Roadmap y Reglas de Desarrollo

## ⚠️ REGLA PARA EL LLM (CURSOR/CLAUDE/GPT)
**NO generes cientos de archivos de una vez.**
Trabaja etapa por etapa. Tras cada paso, explica la arquitectura, archivos modificados y espera confirmación del usuario para avanzar. 

## Fase 1A - Foundation (Paso Actual)
1. Estructura del proyecto base de Flutter.
2. Integración de Firebase y Theme base.
3. Inyección de dependencias (DI) y enrutamiento (GoRouter).
4. Autenticación (Google/Email) usando Cubit.

## Fase 1B - RAWG y Descubrimiento
1. Interfaces de repositorios y modelos (Freezed).
2. `ApiClient` con deduplicación y caché.
3. Dashboard y Búsqueda (debounce con Bloc).
4. Game Details Page (Hero transitions, mapper de plataformas a iconos).

## Fase 1C - La Biblioteca Personal
1. Lógica Firestore: Marcar juegos (Completed, Playing, Wishlist, Abandoned).
2. Pantalla Library con filtros. Sin duplicar catálogo.

## Fase 1D - Asistente IA
1. Abstracción de canales nativos (Platform Channels/Pigeon).
2. Chat UI contextualizado al juego.
3. Persistencia de chats.

## Fase 1E - Polish Final de Fase 1
1. Animaciones finales, skeletons, empty states.
2. Manejo de modo offline (caché).
3. Firebase App Check, Crashlytics.