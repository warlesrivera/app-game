# FASE 3B: PERFIL AVANZADO (GRÁFICO DE RADAR Y PROFILING IA)

## Objetivo
Mejorar la pantalla de Perfil (`ProfilePage`) para mostrar un gráfico de radar (pentágono de stats) basado en los géneros jugados, y generar una descripción dinámica del perfil del usuario usando Gemini.

## Reglas de Arquitectura
1. **Paquetes:** Instalar `fl_chart` (la mejor librería para gráficos en Flutter, usaremos su `RadarChart`).
2. **Cálculo de Estadísticas (Radar):**
   - En el `ProfileCubit`, analizar la lista de juegos de la biblioteca del usuario.
   - Contar la frecuencia de los géneros principales (ej. Acción, RPG, Aventura, Shooter, Plataformas, Deportes) basándose en los juegos marcados como "Jugando" o "Completado".
   - Mapear estos conteos a un `RadarChartData` para dibujar el pentágono/hexágono.
3. **Profiling Detallado (Gemini AI):**
   - Crear una función en el Cubit que tome un resumen numérico: "Juegos completados: X, Juegos abandonados: Y, Género favorito: Z".
   - Enviar un prompt oculto a Gemini a través de tu repositorio existente de IA: 
     *"Actúa como un analista de videojuegos. Basado en estas stats: Completados X, Abandonados Y, Género favorito Z. Escribe un 'Perfil de Jugador' épico y divertido de máximo 3 líneas describiendo su personalidad gamer. Usa un título llamativo."*
   - Mostrar este texto debajo del gráfico. Guardar el resultado en caché o Firestore para no llamar a Gemini cada vez que entre al perfil.
4. **UI de la Pantalla:**
   - **Arriba:** Avatar y Nombre (lo que ya hicimos).
   - **Medio (Stats):** El `RadarChart` de `fl_chart` renderizado con los colores del tema oscuro de la app (líneas neón o doradas).
   - **Medio (Descripción):** La tarjeta de texto generada por la IA.
   - **Abajo:** El "Salón de la Fama" (Carrusel de favoritos).