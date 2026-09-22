# FASE 6: ASEGURAR GOOGLE SIGN-IN (CLAVES SHA-1)

## Objetivo
Solucionar y prevenir el error común donde Google Sign-In se queda cargando o falla en Android debido a la falta de certificados SHA-1 en Firebase.

## Pasos Manuales Requeridos
1. **Extraer el SHA-1 del equipo:**
   - En la terminal, ir a la carpeta de Android: `cd android`
   - Ejecutar el reporte de firmas: `./gradlew signingReport`
   - Copiar la clave `SHA1` de la variante `debug`.
2. **Configurar en Firebase:**
   - Ir a la Consola de Firebase -> Configuración del Proyecto.
   - En la app de Android, agregar la huella digital (SHA-1) copiada.
   - (Opcional) Si la app se sube a la Play Store, también hay que agregar el SHA-1 de Google Play Console.
3. **Actualizar el JSON:**
   - Descargar nuevamente el archivo `google-services.json` desde Firebase y reemplazar el existente en `android/app/`.
4. **Build Limpio:** Hacer un `flutter clean` antes de volver a compilar.