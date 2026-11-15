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

## Recursos del supernivel

Los fondos, las grietas y variaciones del piso, el humo, las piedras, las
puertas, el cofre y la composición de la victoria son propios. La corona
del guardián modifica el slime propio de `tools/generar_enemigo.ps1`.

Los siguientes recursos de **The Legend of Zelda: A Link to the Past**
se recortan y escalan con vecino más cercano:

- Botones circulares: base de `assets/fuentes/misc.png`, procedente del
  [pack ALTTP de Solarus](https://github.com/solarus-games/solarus-alttp-pack/tree/dev/data/sprites/entities).
  Las letras y números son etiquetas agregadas por el proyecto.
- Tres corazones: `assets/fuentes/hearts.png`, de
  [hud/hearts.png](https://github.com/solarus-games/solarus-alttp-pack/blob/dev/data/sprites/hud/hearts.png).
  Los estados lleno, medio y vacío son recortes de la plancha. Los cuartos
  combinan los mismos píxeles de lleno y vacío.
- Armadura roja: `assets/fuentes/RedMail.png`, del
  [sprite de Red Mail alojado en Wikimedia](https://upload.wikimedia.org/wikibooks/en/d/db/Zelda_ALttP_item_Red_Mail.png).
- Link con traje rojo: tercera fila, y=48, de la plancha existente
  `assets/fuentes/link-sheet.png`; se generan las cuatro direcciones.
- Pose de victoria: `assets/fuentes/victory-tunic.png`, de
  [hero/victory.tunic.png](https://github.com/solarus-games/solarus-alttp-pack/blob/dev/data/sprites/hero/victory.tunic.png).

Los archivos fuente nuevos se incorporaron el 14 de noviembre de 2026.
Todos los PNG finales se regeneran con `tools/generar_supernivel.ps1`.
Los recursos de Nintendo conservan sus derechos originales. El juego sigue
reutilizando los sprites anteriores de llaves, colgante, cajas, losas y cables.
