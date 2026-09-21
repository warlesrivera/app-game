# FASE 1G: LOGOS DE PLATAFORMAS (Mapeo Local)

## Objetivo
Mostrar los logos de las consolas en las tarjetas de los juegos usando el `slug` de RAWG.

## Contexto de Assets
Los assets están ubicados en `assets/icons/platforms/`.
Tenemos una mezcla de formatos `.svg` y `.png`.
Lista de slugs confirmados: 
- nintendo-64 (.png)
- nintendo-switch-2 (.png)
- nintendo-switch (.svg)
- playstation, playstation2, playstation3, playstation4, playstation5, playstationvita, psp (.svg)
- xbox (.svg)

## Reglas de Arquitectura
1. **Paquetes:** Instalar `flutter_svg`.
2. **Configuración:** Registrar la carpeta `assets/icons/platforms/` en el `pubspec.yaml`.
3. **Mapper (PlatformIconMapper):**
   - Crear un helper estático que reciba el `slug` (String).
   - Debe retornar un Widget (sea `SvgPicture.asset` para los .svg, o `Image.asset` para los .png).
   - Si el slug no está en la lista conocida, debe retornar un `Icon(Icons.videogame_asset)` por defecto.
4. **UI:** Mostrar estos iconos en una fila en `GameCard` y `GameDetailsPage` con un tamaño pequeño (ej. 16x16 o 20x20).