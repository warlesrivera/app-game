# FASE 1C: BIBLIOTECA Y PERFIL (FIREBASE + RAWG)

## Objetivo
Mostrar los juegos guardados por el usuario (completados, jugando, wishlist, abandonados) y las estadísticas de su perfil.

## Reglas de Arquitectura
1. **No duplicar datos:** Firestore (`users/{uid}/games/{rawgGameId}`) SOLO tiene el ID del juego y su estado[cite: 1].
2. **Hidratación de datos:** Para mostrar la Biblioteca, el `LibraryCubit` debe:
   - Leer la lista de IDs desde Firestore.
   - Buscar los detalles visuales (portada, título) de esos IDs usando el `GameRepository` (que primero mira en caché local y luego en RAWG)[cite: 1].

## Tareas a Ejecutar
1. **UI Biblioteca (`LibraryPage`):** 
   - Pantalla con Tabs o Filtros visuales: "Todos", "Jugando", "Completados", "Wishlist", "Abandonados"[cite: 1].
   - Mostrar los juegos usando el mismo widget `GameCard`.
2. **UI Perfil (`ProfilePage`):**
   - Mostrar datos del usuario desde FirebaseAuth/Firestore (Nombre, Correo, Avatar)[cite: 1].
   - Mostrar estadísticas calculadas localmente leyendo los documentos de la biblioteca: "Juegos completados: X", "En Wishlist: Y"[cite: 1].
   - Botón de Logout funcional.