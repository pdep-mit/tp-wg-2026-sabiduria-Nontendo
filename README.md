# La sala de los tres sellos — Checkpoint 1

**Grupo:** Nontendo

**Integrantes:**
- Lautaro Feruglio
- Agustin Eduardo Gomez Utinko
- Ignacio Mariñansky
- Mauro Lautaro Montoya
- Facundo Sanzo

## Consignas

Todo lo que necesitan saber está explicado en [este documento](https://docs.google.com/document/d/1KoB12RIZk_xPhmnOJ-EfLIPNwkETD_EaYMp2srDu9QY/edit?tab=t.0#heading=h.wnm2lu4cls8j). Para todo lo demás, aseguren prestar atención a los comunicados por Discord.

Recuerden que para cada checkpoint hay [expectativas mínimas](https://docs.google.com/document/d/1KoB12RIZk_xPhmnOJ-EfLIPNwkETD_EaYMp2srDu9QY/edit?tab=t.0#heading=h.56t0qdv908v3) respecto a los conceptos aplicados. Procuren:
- Validar su idea con el equipo docente que corresponda por su canal de Discord
- Para cada checkpoint, asegurar que implementaron lo necesario para esa instancia, y crear un **tag** en el repositorio para facilitar la comparación entre versiones final e intermedias.
- Para la demo final, crear un nuevo tag **demo** y actualizar este README con todo lo necesario.

# Cómo jugar

## Objetivo

Una demo de una sola sala, con sprites de **The Legend of Zelda: A Link to the Past**.
Activá los botones en orden **1 → 2 → 3**, recogé la llave y abrí la salida.
El orden aparece en pantalla: el puzzle es fácil a propósito para presentar
las mecánicas del primer checkpoint.

1. El botón **1** enciende la antorcha.
2. El botón **2** abre la barrera del sector derecho.
3. El botón **3** hace aparecer la llave.
4. La llave se recoge con **E** y aparece en el inventario.
5. Acercate a la puerta y pulsá **E** para ganar.

Si activás un botón fuera de orden, se apagan los botones y la antorcha,
se cierra la barrera y se reinicia la secuencia. Una secuencia completada
queda resuelta hasta reiniciar la partida.

El colgante cerca del inicio se puede recoger para mostrar el sistema
genérico de objetos e inventario. No es necesario para ganar.
Los pinchos rojos quitan un corazón cada vez que entrás a su celda.
Con tres impactos perdés. Podés evitarlos por completo para resolver el puzzle.

## Controles

| Tecla | Acción |
| --- | --- |
| Flechas | Mover a Link una celda |
| E | Activar un botón, recoger un objeto o abrir la salida |
| R | Reiniciar toda la demo, incluso después de ganar o perder |

Para interactuar, parate sobre el objeto o en una celda contigua
(sin diagonales). Si hay varios objetos cerca, se usa el más próximo.
Hacé clic en el juego si el navegador no recibe las teclas.
La vida, los objetos guardados y las indicaciones aparecen arriba.

## Ejecutar

Desde la carpeta del proyecto, con Wollok CLI instalado:

```text
wollok run juego.NombreDeJuego
```

Abrí la dirección que indique la terminal, normalmente
[http://localhost:3000](http://localhost:3000).
También se puede ejecutar `juego.wpgm` desde la extensión de Wollok.

### Si aparece una pantalla en blanco al ejecutar

Si el navegador informa que no encuentra las imágenes, revisá la carpeta
abierta como proyecto en el editor. La carpeta del repositorio
`tp-wg-2026-sabiduria-Nontendo` contiene su propio `package.json`, con
`resourceFolder: "assets"`.

Para trabajar desde la carpeta superior `juegoWollok`, también se dejó
un `package.json` allí, con la ruta
`tp-wg-2026-sabiduria-Nontendo/assets`. Reiniciá la ejecución después de
cambiar esa configuración: el servidor toma la ruta al arrancar.

Usá una sola instancia del juego. Si ya hay una demo ejecutándose en el
puerto 3000, detenela en la terminal con **Ctrl+C** antes de ejecutar
`juego.wpgm` nuevamente desde el editor.

En ese caso la terminal puede mostrar `EADDRINUSE`; esta versión del
ejecutor también puede terminar mostrando `ERR_INVALID_ARG_TYPE` al
procesar ese error. No significa que el archivo del juego esté vacío.

Después de ejecutar el programa, abrí la dirección que indique **esa
ejecución** y recargá la pestaña. Abrir el archivo `.wpgm` en el editor
por sí solo no inicia el juego.

## Recorrido corto para presentar

1. Desde el inicio, movete una celda a la derecha y pulsá **E**:
   el colgante desaparece del mapa y se agrega al inventario.
2. Subí dos celdas y pulsá **E**, debajo del botón 1:
   se enciende la antorcha.
3. Avanzá tres celdas a la derecha y pulsá **E**, debajo del botón 2:
   se abre la barrera.
4. Avanzá otras tres celdas a la derecha y pulsá **E**, debajo del botón 3:
   aparece la llave.
5. Cruzá el paso hacia la derecha. Recogé la llave con **E**
   y acercate a la salida de la esquina superior derecha.
6. Pulsá **E** para ganar y **R** para dejar la demo lista otra vez.

Para mostrar alternativas: activá primero el botón 2; intentá abrir la
puerta antes de recoger la llave; o caminá sobre los pinchos.

## Alcance y entidades del primer checkpoint

| Característica | Entidades y responsabilidad |
| --- | --- |
| Movimiento y límites | `jugador`, `sala`, `Muro`: movimiento por celdas, límites y obstáculos |
| Puzzle ordenado | `Boton`, `puzzle`: secuencia 1–2–3 y reinicio por error |
| Efectos distintos | `antorcha`, `barrera`, llave: encender, abrir y revelar |
| Objetos e inventario | `ObjetoRecogible`, lista de inventario de `jugador`: recolección sin duplicados |
| Salida condicionada | `salida`: verifica que el jugador tenga la llave |
| Daño y derrota opcionales | `Pincho`, vida de `jugador`, estado de `sala` |
| Presentación y controles | Carteles de vida, inventario y estado; `configuracion` |

Al ganar o perder se bloquean el movimiento y la interacción; **R** sigue
disponible. El reinicio restaura objetos, vida, botones y barrera.

Los recursos y sus fuentes están detallados en [assets/CREDITOS.md](assets/CREDITOS.md).

# Explicaciones

La implementación de cada mecánica del primer checkpoint está explicada
paso a paso en [docs/mecanicas.md](docs/mecanicas.md).

Las explicaciones teóricas y diagramas van a encontrarse en [explicaciones.md](explicaciones.md) a partir del Checkpoint #2.
