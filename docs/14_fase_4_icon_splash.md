# FASE 4: ÍCONO Y SPLASH SCREEN (ESTÉTICA PREMIUM)

## Objetivo
Configurar el ícono oficial de la aplicación y una pantalla de carga nativa (Splash Screen) oscura que encaje con la estética "Dark Premium" de GameVault.

## Reglas de Arquitectura
1. **Paquetes:** Instalar `flutter_launcher_icons` y `flutter_native_splash` (en `dev_dependencies`).
2. **Assets:** Utilizar el archivo `assets/images/logo.png` como base para ambos.
3. **Configuración en pubspec.yaml (o archivos separados):**
   - **Ícono:** Configurar `flutter_launcher_icons` para generar íconos en Android e iOS usando `logo.png` con un fondo acorde (ej. `#121212`).
   - **Splash Screen:** Configurar `flutter_native_splash` para que el color de fondo sea oscuro (`#121212` o el color de fondo del tema de la app) y la imagen centrada sea el `logo.png`. Desactivar el splash en web si no es necesario.
4. **Ejecución:** Correr los comandos de generación de ambos paquetes para inyectar los recursos nativos en las carpetas de Android e iOS.