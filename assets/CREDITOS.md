# Recursos gráficos

Los sprites de Link, la llave, el colgante y las piezas de mazmorra son de
**The Legend of Zelda: A Link to the Past**, de Nintendo.

## Fuentes

- [Solarus ALTTP resource pack](https://github.com/solarus-games/solarus-alttp-pack/tree/dev/data):
  - `sprites/hero/stopped.tunic.png`: Link en cuatro direcciones.
  - `sprites/entities/miscellaneous.png`: interruptores, bloques y llama.
  - `tilesets/dungeon/blue.tiles.png`: piso, paredes y pinchos.
  - `tilesets/dungeon/blue.entities.png`: puerta cerrada y abierta.
- [SNES Maps — ALTTP sprites](https://www.snesmaps.com/maps/ZeldaALinkToThePast/sprites/Zelda3Sprites.html):
  `items/Key.png` y `items/PendantOfCourage.png`.

Consultados el 7 de octubre de 2026. Las fuentes usadas se guardan en
`assets/fuentes`, por lo que la demo no depende de una conexión a Internet
para sus imágenes.

## Adaptaciones de esta demo

Recortes, escalado con vecino más cercano, números y bordes de colores en
los botones, soporte de antorcha, indicador del paso abierto y composición
del mapa con textos propios. El script `tools/generar_assets.py` permite
regenerarlos con Python y Pillow; utiliza la fuente Consolas de Windows.

Los gráficos de Nintendo conservan sus derechos originales y no están
cubiertos por la licencia del código del proyecto.
