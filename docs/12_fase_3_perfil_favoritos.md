# FASE 3: SISTEMA DE PERFIL Y JUEGOS FAVORITOS

## 1. Sistema de Favoritos (Firestore & UI)
**Objetivo:** Permitir al usuario marcar juegos como "Favoritos" únicamente si ya los completó.
**Reglas:**
- **Modelo:** Actualizar el modelo de Firestore de la biblioteca del usuario agregando el campo `bool isFavorite` (por defecto `false`).
- **Lógica de Negocio:** 
  - En la vista de detalles (`GameDetailsPage`), agregar un botón de "Corazón" (Favorito).
  - **RESTRICCIÓN CRÍTICA:** Este botón solo debe estar habilitado si el estado del juego en la biblioteca es `Completado`. Si está en otro estado o no está en la biblioteca, el botón debe estar deshabilitado o mostrar un SnackBar explicando: "Debes completar el juego para agregarlo a favoritos".
  - Si el usuario cambia el estado de un juego de "Completado" a "Abandonado" o lo elimina, `isFavorite` debe volver a `false` automáticamente.

## 2. Pantalla de Perfil de Jugador
**Objetivo:** Crear un dashboard de jugador en la pestaña "Perfil" de la Shell.
**Estructura de la Pantalla:**
- **Cabecera (Avatar y Nombre):** 
  - Mostrar el nombre del usuario autenticado (Firebase Auth).
  - Para el Avatar, implementar un selector que consuma la **Amiibo API** (`https://amiiboapi.com/api/amiibo/`). Permitir al usuario elegir una imagen de la lista y guardarla en su documento de Firestore (`avatarUrl`). Si no tiene, mostrar un avatar Pixel Art por defecto usando: `https://api.dicebear.com/9.x/pixel-art/svg?seed={UserEmail}`.
- **Estadísticas de Jugador:**
  - Leer la colección de la biblioteca en Firestore y calcular:
    - Total de juegos jugados / completados.
    - Géneros favoritos (calcular el género que más se repite en su biblioteca).
- **Salón de la Fama (Favoritos):**
  - Un carrusel o grid horizontal mostrando únicamente las portadas de los juegos marcados con `isFavorite == true`.