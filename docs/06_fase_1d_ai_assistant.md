# FASE 1D: ASISTENTE IA (GAME ASSISTANT)

## Objetivo
Proveer un chat contextualizado sobre el videojuego actual utilizando IA on-device o cloud[cite: 1].

## Reglas de Arquitectura
1. **Abstracción:** Implementar `abstract class GameAIRepository` con métodos `sendMessage` e `isAvailable`[cite: 1].
2. **Persistencia:** Guardar las conversaciones en Firestore bajo `users/{uid}/ai_chats/{chatId}` para el historial, y los mensajes en la subcolección `messages`[cite: 1].
3. **No tokens enormes:** No guardar prompts de sistema gigantes en la BD, solo el rol (user/assistant) y el texto[cite: 1].

## Tareas a Ejecutar
1. **Botón Flotante/Acción:** En `GameDetailsPage`, agregar un botón "✨ Pregúntale a la IA".
2. **UI Chat (`AIChatPage`):** Pantalla de chat similar a iMessage o WhatsApp, con fondo oscuro. 
3. **Cubit (`AIChatCubit`):** Manejar el estado del chat, agregar mensajes optimísticamente a la UI, y comunicarse con `GameAIRepository`.
4. Implementar un Provider base usando la API gratuita de Gemini (usando el paquete `google_generative_ai`) u otra que esté disponible en el entorno del desarrollador, contextualizando a la IA con el nombre del juego actual.