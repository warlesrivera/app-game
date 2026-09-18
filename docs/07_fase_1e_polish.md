# FASE 1E: PULIDO FINAL Y OFFLINE

## Objetivo
Preparar la aplicación para ser un producto profesional, fluido y seguro[cite: 1].

## Tareas a Ejecutar
1. **Modo Offline:** Configurar Firebase Firestore para habilitar la persistencia offline (`FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)`). Mostrar un banner sutil de "Sin conexión" usando un `ConnectivityBloc` si no hay red[cite: 1].
2. **Manejo de Errores y Empty States:**
   - Si la biblioteca está vacía, mostrar un arte o icono gamer invitando a buscar juegos[cite: 1].
   - Si RAWG falla o no hay internet, mostrar botón de reintento.
3. **Reglas de Seguridad Firestore:** Crear el archivo `firestore.rules` asegurando que `request.auth.uid == userId` en todas las lecturas/escrituras[cite: 1].
4. **Performance:** Asegurar el uso de `const` widgets, list builders y evitar rebuilds globales[cite: 1].