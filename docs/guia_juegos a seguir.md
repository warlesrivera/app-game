GAMING ADVISOR --- ESPECIFICACIÓN PARA FLUTTER + GEMINI

1. Objetivo

Crear dentro de la aplicación existente de videojuegos una sección
llamada Gaming Advisor.

La sección debe funcionar como un asistente personal especializado en
videojuegos, capaz de usar:

biblioteca de juegos del usuario

wishlist

juegos completados

juegos abandonados

juego actual

preferencias

hábitos de juego

próximas fechas de lanzamiento

experiencias previas con juegos

La experiencia debe sentirse como un "ChatGPT personal para mi
biblioteca de videojuegos", pero con una diferencia fundamental:

La aplicación recuerda. Gemini razona.

Gemini NO debe ser la base de memoria del usuario.

La app debe mantener una memoria estructurada y enviar a Gemini
únicamente el contexto relevante para cada consulta.

2. Reglas principales

Regla 1 --- No romper la arquitectura existente

Antes de implementar:

Analizar la estructura actual del proyecto.

Identificar arquitectura.

Identificar BLoC/Cubit existentes.

Identificar repositories.

Identificar servicios.

Identificar Firebase.

Identificar integración actual con Gemini.

Identificar API de videojuegos existente.

Identificar navegación y sistema de rutas.

Identificar sistema de tema/componentes UI.

Reutilizar todo lo que ya exista.

NO crear:

una segunda integración de Gemini

un segundo GameRepository

un segundo sistema de Firebase

una segunda arquitectura

modelos duplicados

un sistema de navegación paralelo

3. Stack esperado

Mantener el stack actual.

Principalmente:

Flutter

Dart

BLoC/Cubit

Firebase si ya existe

Gemini API existente

API de videojuegos existente

almacenamiento local existente

Si el proyecto ya utiliza una solución de persistencia adecuada,
reutilizarla.

No agregar una dependencia nueva sin justificarla.

4. Arquitectura

La feature debe seguir la arquitectura existente.

Como referencia:

Presentation
    ↓
Cubit / BLoC
    ↓
Use Cases
    ↓
Repository
    ↓
Data Sources / Services

La UI nunca debe llamar directamente a Gemini.

Flujo:

UI
 ↓
GamingAdvisorCubit
 ↓
AskGamingAdvisorUseCase
 ↓
GamingAdvisorRepository
 ↓
ContextBuilder
 ↓
GeminiService
 ↓
Response

5. Estructura sugerida

Adaptar esta estructura a la arquitectura REAL del proyecto:

lib/features/gaming_advisor/

├── data/
│   ├── datasources/
│   │   ├── gaming_advisor_local_datasource.dart
│   │   └── gaming_advisor_remote_datasource.dart
│   │
│   ├── models/
│   │   ├── gaming_profile_model.dart
│   │   ├── gaming_memory_model.dart
│   │   ├── game_experience_model.dart
│   │   ├── advisor_message_model.dart
│   │   └── gaming_context_model.dart
│   │
│   └── repositories/
│       └── gaming_advisor_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── gaming_profile.dart
│   │   ├── gaming_memory.dart
│   │   ├── game_experience.dart
│   │   ├── advisor_message.dart
│   │   └── gaming_context.dart
│   │
│   ├── repositories/
│   │   └── gaming_advisor_repository.dart
│   │
│   └── usecases/
│       ├── ask_gaming_advisor.dart
│       ├── build_gaming_context.dart
│       ├── get_gaming_profile.dart
│       ├── update_gaming_profile.dart
│       ├── save_gaming_memory.dart
│       └── generate_recommendations.dart
│
└── presentation/
    ├── cubit/
    │   ├── gaming_advisor_cubit.dart
    │   └── gaming_advisor_state.dart
    │
    ├── pages/
    │   ├── gaming_advisor_page.dart
    │   ├── gaming_profile_page.dart
    │   └── gaming_memory_page.dart
    │
    └── widgets/
        ├── advisor_chat.dart
        ├── advisor_message_bubble.dart
        ├── game_recommendation_card.dart
        ├── current_game_card.dart
        ├── gaming_profile_card.dart
        └── memory_card.dart

No copiar esta estructura literalmente si el proyecto ya tiene una
convención diferente.

6. Gaming Profile

Crear un perfil estructurado del jugador.

Ejemplo conceptual:

{
  "storyImportance": 5,
  "combatImportance": 5,
  "explorationImportance": 4,
  "equipmentImportance": 4,
  "buildImportance": 3,
  "characterProgressionImportance": 4,
  "difficultyTolerance": 3,
  "objectiveClarityImportance": 5,
  "repetitionTolerance": 2,
  "mainStoryPreference": true,
  "playsMostlyWeekends": true
}

El modelo debe ser editable.

No asumir que estos valores serán siempre los mismos.

7. Preferencias

Crear preferencias positivas y negativas.

Ejemplo:

LIKES

- story-driven games
- action combat
- attack combinations
- parry/block timing
- equipment
- character progression
- party composition
- exploration with purpose
- discovering locations naturally
- clear progression

DISLIKES

- unclear objectives
- excessive repetition
- excessive grinding
- unclear quest systems
- exploration without direction

No convertir estas preferencias en texto fijo dentro del código.

Deben ser datos.

8. Gaming Memory

Crear memoria persistente específica de videojuegos.

Modelo:

GamingMemory

id
category
content
importance
confidence
source
createdAt
updatedAt

Categorías sugeridas:

preference
dislike
habit
favorite
completed_game
abandoned_game
current_game
playstyle
difficulty
recommendation_feedback

Ejemplo:

{
  "category": "preference",
  "content": "Prefiere juegos centrados en historia.",
  "importance": 0.95,
  "confidence": 0.95
}

9. Game Experience

Cada juego puede tener información específica de la experiencia del
usuario.

Modelo:

GameExperience

gameId
status
rating
favorite
storyScore
combatScore
explorationScore
progressionScore
difficultyScore
positiveNotes
negativeNotes
whyLiked
whyDisliked
completedAt

Estados:

wishlist
owned
playing
completed
abandoned
paused

No obligar al usuario a llenar todos los campos.

10. Current Game

La app debe conocer qué juego está jugando actualmente.

Ejemplo:

{
  "gameId": "mgs4",
  "status": "playing",
  "progress": 25,
  "currentAct": "Act 2",
  "estimatedHoursPlayed": 6,
  "lastPlayedAt": "..."
}

El usuario debe poder actualizar esto manualmente.

También puede actualizarse desde acciones rápidas.

11. Acciones rápidas desde el Advisor

Desde una recomendación, permitir:

Agregar a wishlist

Marcar como jugando

Marcar como completado

Ver detalles

Ver en biblioteca

Comparar

Preguntar "¿por qué me lo recomiendas?"

12. Context Builder

Crear un servicio:

GamingContextBuilder

Su responsabilidad es construir el contexto mínimo necesario para
Gemini.

NO enviar toda la biblioteca.

NO enviar toda la memoria.

NO enviar toda la conversación.

13. Ejemplo de Context Builder

Pregunta:

¿Me gustaría Dragon's Dogma 2?

El Context Builder debe recuperar solamente:

PLAYER PROFILE

Story: high
Combat: high
Exploration: high
Equipment: high
Objective clarity: important
Repetition tolerance: low

RELEVANT GAMES

Shadow of Mordor
- favorite
- likes exploration
- likes action
- likes discovering locations

Onimusha
- completed
- likes parry
- likes action

Lies of P
- completed
- difficulty became tiring

Divinity Original Sin 2
- abandoned
- unclear objectives caused frustration

CURRENT GAME

MGS4

QUESTION

Would Dragon's Dogma 2 fit this player?

No enviar información irrelevante.

14. Relevance Engine

Antes de llamar a Gemini, seleccionar el contexto relevante.

Crear una lógica sencilla de relevancia.

Ejemplo:

Query:
"¿Me gustaría Monster Hunter Wilds?"

Relevant:

- combat preference
- equipment preference
- repetition tolerance
- exploration preference
- action games
- wishlist status
- similar games

Irrelevant:

- unrelated games
- unrelated memories
- profile fields that don't affect the answer

15. Límites de contexto

Crear constantes configurables:

const maxRelevantMemories = 8;
const maxRelevantGames = 5;
const maxRecentMessages = 6;

No enviar cientos de elementos a Gemini.

16. Conversación

NO enviar todo el historial de chat.

Mantener:

conversationSummary
+
last 4-6 messages
+
relevant structured context

Ejemplo de summary:

El usuario está jugando MGS4.
Acaba de terminar Onimusha.
Prefiere juegos de acción centrados en historia.
Normalmente juega los fines de semana.
Está planificando jugar The Witcher 3 Remastered después de MGS4.

El summary debe actualizarse solamente cuando sea necesario.

17. Token Optimization

Esta es una parte crítica.

No llamar Gemini para información que la app ya conoce.

Ejemplos:

¿Cuántos juegos tengo?
¿Qué juegos tengo en wishlist?
¿Qué juego estoy jugando?
¿Cuándo sale este juego?
¿Ya terminé este juego?
¿Tengo este juego?

Resolver localmente cuando los datos ya estén disponibles.

18. Gemini se utiliza principalmente para razonamiento

Usar Gemini para:

recomendaciones

comparaciones

análisis de compatibilidad

explicaciones

planificación de juegos

interpretar preferencias

respuestas conversacionales

explicar por qué un juego puede encajar o no

19. Cache

Implementar cache.

Crear una clave basada en:

normalizedQuestion
+
profileVersion
+
relevantGameIds
+
relevantMemoryIds

Si la misma pregunta se realiza con el mismo contexto, reutilizar la
respuesta.

No volver a llamar Gemini innecesariamente.

20. Memory Extraction

No ejecutar extracción de memoria después de cada mensaje.

Detectar posibles preferencias persistentes.

Ejemplos:

"Me encantó Shadow of Mordor."

"Me aburren los juegos donde no sé qué hacer."

"Prefiero jugar juegos de historia."

"Me gusta mucho el parry cuando se siente natural."

Estas frases pueden convertirse en memoria.

Preguntas factuales como:

¿Cuánto dura MGS4?

NO deben generar memoria.

21. Importancia y confianza

Cada memoria debe tener:

importance
confidence

Ejemplo:

{
  "importance": 0.9,
  "confidence": 0.95
}

Si una preferencia aparece repetidamente, aumentar confidence.

Si el usuario contradice una preferencia anterior, actualizarla.

Nunca duplicar memorias equivalentes.

22. Gaming Advisor Chat

Crear una pantalla:

Gaming Advisor

Header:

Tu Gaming Advisor

Tu biblioteca. Tus gustos. Tu próxima aventura.

Input:

Pregúntame sobre tus juegos...

Sugerencias iniciales:

¿Qué debería jugar después?
¿Qué juego me puede gustar?
¿Qué tengo pendiente?
¿Qué debería comprar?
¿Qué juego puedo jugar este fin de semana?
Compara estos dos juegos para mí.

23. UI de respuesta

Las respuestas deben poder incluir:

Texto

Explicación personalizada.

Game Card

Mostrar:

portada

nombre

plataforma

estado

fecha

acción

Recommendation Card

Mostrar:

Shadow of War

¿Por qué?

✓ Te gustó Shadow of Mordor
✓ Te gusta el combate
✓ Te gusta explorar
✓ Te gusta descubrir enemigos y lugares

Posible problema:

⚠ Es un juego largo y tiene bastante contenido opcional.

No mostrar solamente una lista de juegos.

24. Profile Screen

Crear:

Mi perfil de jugador

Secciones:

Me gusta

No me gusta

Cómo juego

Mi tolerancia a dificultad

Lo que más valoro

Mis hábitos

Juegos favoritos

Juegos abandonados

Todo editable.

25. Memory Screen

Crear:

Memoria del Gaming Advisor

Mostrar las memorias que el sistema tiene sobre el usuario.

Ejemplo:

❤️ Le gustan los juegos centrados en historia.

⚔️ Le gusta el combate de acción.

🛡️ Disfruta el parry cuando el timing se siente natural.

🗺️ Le gusta explorar sin depender de demasiados marcadores.

❌ Puede frustrarse cuando los objetivos no son claros.

Cada memoria debe poder editarse o eliminarse.

26. Recommendation Engine local

Crear un sistema local que pueda filtrar candidatos antes de usar
Gemini.

Inputs:

PlayerProfile
GameFeatures
GameStatus
Platform
ReleaseDate
Wishlist
CurrentGame

Generar internamente un:

compatibilityScore

IMPORTANTE:

Ese score es para ordenar internamente candidatos.

No mostrar al usuario:

92%
87%
75%

por defecto.

Gemini debe explicar las diferencias en lenguaje natural.

27. Recommendation Pipeline

Cuando el usuario pregunta:

¿Qué juego debería jugar?

Proceso:

1. Obtener current game
2. Obtener wishlist
3. Obtener owned games
4. Obtener completed games
5. Obtener abandoned games
6. Filtrar plataforma
7. Filtrar disponibilidad
8. Calcular relevancia local
9. Seleccionar máximo 5 candidatos
10. Crear contexto compacto
11. Llamar Gemini
12. Generar explicación
13. Mostrar cards

Nunca mandar toda la biblioteca a Gemini.

28. Release Calendar

Crear sección:

Próximamente

Cada juego debe tener:

title
releaseDate
platform
wishlist
owned
status

El Advisor puede responder localmente preguntas simples sobre fechas.

Gemini solo interviene si se requiere una recomendación.

29. Gaming Timeline

Crear una vista:

Mi aventura

COMPLETADOS

Onimusha
↓
MGS4
↓
...

JUGANDO

MGS4

PRÓXIMOS

The Witcher 3
Shadow of War
Kingdom Hearts III
Dragon's Dogma 2
Ocarina of Time
Monster Hunter Wilds

La timeline se genera con datos reales de la app.

No usar Gemini para construirla.

30. Integración con biblioteca existente

El Gaming Advisor debe estar conectado con la biblioteca.

Desde cualquier juego:

Ask Advisor

Ejemplos:

¿Me gustaría este juego?

¿Por qué está en mi wishlist?

Compáralo con mis favoritos.

¿Debería comprarlo?

¿Qué juegos parecidos ya tengo?

31. Integración con wishlist

Desde la wishlist:

Ask Advisor

Ejemplo:

¿Cuál de estos juegos debería jugar primero?

La app selecciona candidatos localmente y Gemini explica.

32. Integración con juego completado

Cuando el usuario marca un juego como completado:

Mostrar opcionalmente:

¿Qué te pareció?

❤️ Me encantó
🙂 Me gustó
😐 Normal
😕 No me gustó
❌ Lo odié

Después:

¿Qué fue lo que más te gustó?

Opciones:

Historia
Combate
Exploración
Personajes
Mundo
Equipamiento
Progresión
Dificultad
Otro

Esto alimenta GameExperience y GamingProfile.

33. Gemini Prompt

No crear un prompt gigante con todos los datos.

Utilizar:

SYSTEM INSTRUCTIONS

PLAYER PROFILE

RELEVANT MEMORIES

RELEVANT GAMES

CURRENT CONTEXT

QUESTION

System instruction:

You are a personal videogame advisor.

Use only the provided player profile, memories, game information and current context.

Personalize answers using the player's documented preferences.

Do not invent player preferences.

Do not claim the player likes or dislikes something unless supported by the provided context.

Separate factual information about games from personalized recommendations.

If information is missing, say that it is unknown.

When comparing games, explain tradeoffs rather than inventing certainty.

Keep answers concise unless the user asks for detail.

34. API Abstraction

La UI nunca debe depender directamente de Gemini.

Crear una abstracción:

abstract class AIAdvisorService {
  Future<AdvisorResponse> ask(
    AdvisorRequest request,
  );
}

Implementación:

GeminiAdvisorService

Esto permite posteriormente cambiar de proveedor sin cambiar la UI.

35. Error handling

Si Gemini falla:

NO dejar inutilizable la aplicación.

Mostrar:

No pude consultar el asistente ahora.

Después ejecutar recomendación local si es posible.

Ejemplo:

Según tu perfil y tu biblioteca, estas son las opciones más relevantes:

36. Loading state

Mostrar:

Analizando tus gustos...

en lugar de solamente un CircularProgressIndicator.

Estados:

initial
loading
loaded
sending
success
error

37. Cubit

Crear o adaptar:

GamingAdvisorCubit

Métodos mínimos:

loadAdvisor();

askQuestion(String question);

refreshProfile();

updatePreference();

setCurrentGame();

saveMemory();

deleteMemory();

generateRecommendations();

clearConversation();

Adaptar nombres al estándar existente del proyecto.

38. Testing

Crear tests para:

Context Builder

Comprobar que:

no envía toda la biblioteca

selecciona memorias relevantes

respeta maxRelevantMemories

respeta maxRelevantGames

Recommendation Engine

Comprobar:

filtros

plataforma

wishlist

completed

current game

Memory

Comprobar:

crear

actualizar

evitar duplicados

eliminar

Cubit

Comprobar:

loading

success

error

retry

Gemini

Mockear el servicio.

Los tests NO deben depender de una llamada real a Gemini.

39. Performance

Evitar:

rebuilds innecesarios

llamadas repetidas a Firebase

llamadas repetidas a RAWG

llamadas repetidas a Gemini

Usar cache donde corresponda.

40. Seguridad

Nunca enviar a Gemini:

password

authentication tokens

email si no es necesario

información personal irrelevante

datos privados de Firebase

Enviar únicamente información relacionada con videojuegos.

41. Fases de desarrollo

FASE 1 --- Arquitectura y memoria

Implementar:

GamingProfile

GamingMemory

GameExperience

CurrentGame

ContextBuilder

Repository

Cubit

almacenamiento

Objetivo:

La aplicación puede guardar y recuperar el perfil del jugador.

FASE 2 --- Chat

Implementar:

Gaming Advisor page

chat

GeminiService existente

contexto compacto

cache

errores

loading

Objetivo:

El usuario puede preguntar sobre sus juegos.

FASE 3 --- Recommendations

Implementar:

local recommendation engine

candidate filtering

Gemini explanation

recommendation cards

wishlist integration

FASE 4 --- Memory intelligence

Implementar:

memory extraction

confidence

importance

deduplication

profile updates

FASE 5 --- Experience tracking

Implementar:

completed game feedback

rating

favorite features

dislikes

game experience

FASE 6 --- Release Calendar

Implementar:

upcoming games

release dates

wishlist

platform

filters

FASE 7 --- Timeline

Implementar:

completed

current

upcoming

gaming history

42. Regla crítica de implementación

NO implementar todas las fases en una sola modificación.

Primero:

ANALYZE PROJECT
↓
PHASE 1
↓
RUN TESTS
↓
RUN FLUTTER ANALYZE
↓
RUN BUILD

Después reportar.

Solo continuar a Phase 2 cuando Phase 1 esté estable.

43. Entregable esperado de Cursor

Al finalizar cada fase mostrar:

## Implemented

- file
- file
- file

## Modified

- file
- file

## Architecture

Explanation

## Token optimization

Explanation

## Tests

Results

## Flutter Analyze

Result

## Known limitations

List

44. Resultado final esperado

El usuario debe poder abrir:

Gaming Advisor

y preguntar:

¿Qué juego debería jugar después de MGS4?

La aplicación debe conocer:

- sus juegos favoritos
- sus juegos completados
- sus juegos abandonados
- su wishlist
- su juego actual
- sus preferencias
- sus hábitos

y responder usando únicamente el contexto relevante.

El sistema debe funcionar bajo este principio:

LA APP RECUERDA.

EL MOTOR LOCAL FILTRA.

GEMINI RAZONA.

LA APP EJECUTA.