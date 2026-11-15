# La Leyenda de Celda — Nontendo

Mazmorra conectada de siete habitaciones, con un puente rodeado de lava,
llaves, armadura, arco, oscuridad, puzzles y un combate final por el medallón.
Implementada en Wollok Game, sobre las mecánicas de los checkpoints anteriores.

**Integrantes:** Lautaro Feruglio, Agustin Eduardo Gomez Utinko,
Ignacio Mariñansky, Mauro Lautaro Montoya y Facundo Sanzo.

## Ejecutar

Desde la raíz del repositorio, con Wollok CLI instalado:

```text
wollok run juego.NombreDeJuego
```

Abrí la dirección que indique la terminal (normalmente
[http://localhost:3000](http://localhost:3000)). También podés ejecutar
`juego.wpgm` desde la extensión de Wollok. El proyecto usa `assets` como
carpeta de recursos, según `package.json`.

Si el puerto está ocupado, detené la instancia anterior con Ctrl+C o usá:

```text
wollok run juego.NombreDeJuego --port 3001
```

## Controles

| Tecla | Acción |
| --- | --- |
| Flechas | Mover una celda; empujar bloques al caminar contra ellas |
| E | Interactuar, recoger, abrir cofres o cruzar puertas |
| T | Reponer las piedras de la habitación sin perder el avance |
| R | Reiniciar toda la partida, incluso después de ganar o perder |
| 1 / 2 en combate | Seleccionar golpe / arco (requiere haberlo recogido) |
| Flecha tras seleccionar un ataque | Atacar en esa dirección |
| Espacio en combate | Terminar el turno |
| 1, 2, 3, 4 y A, S, D, F en el panel | Conectar cables |

Para interactuar, parate sobre el objeto o a una celda de distancia.
Las puertas también se cruzan caminando sobre el hueco abierto del muro.
En combate hay tres pasos y un ataque por turno. E y T quedan deshabilitadas
hasta terminar el encuentro. Hacé clic en el juego si no recibe las teclas.

## Leer el combate

Los tres corazones quedan en una franja propia, siempre sobre la oscuridad,
el panel de cables y el humo. El inventario ocupa el extremo derecho.

- El encabezado indica **TU TURNO** o **TURNO ENEMIGO**, la ronda, pasos
  restantes, ataque disponible y el resultado de la ultima accion.
- **1** selecciona el golpe y **2** el arco. La tarjeta elegida se ilumina.
  Las flechas atacan en esa direccion; **Esc** cancela para volver a moverse.
- El alcance se marca en el piso y los objetivos en otro color. La marca
  se corta en paredes, piedras y el primer enemigo, igual que el ataque real.
- Las barras sobre los slimes muestran su salud. El enemigo que esta actuando
  tiene un marco naranja; durante su turno las acciones aparecen deshabilitadas.
- **Espacio** termina el turno. Su tarjeta se destaca cuando ya no quedan
  pasos ni ataque. Fallar un ataque permite intentar otra direccion o cancelar.

## Explorar

Explora las salas y descubre sus mecanismos. No hay pistas de soluciones
en pantalla. El inventario muestra los sprites de los objetos; las llaves
se consumen al abrir su cerradura. La armadura y el arco se conservan.

La salud se representa con tres corazones, incluso durante el combate.
Los slimes se materializan sobre los charcos, con humo, despues de recuperar
la vision. El combate empieza al entrar en una sala con enemigos vivos;
en la sala oscura comienza al terminar su aparicion. El slime izquierdo
del final es un guardian reforzado con corona, mas vida, velocidad y dano.

Los botones recuperan su base circular. Los tres corazones y la armadura
roja usan los sprites de ALTTP; al equiparse la armadura, Link cambia
de traje en las cuatro direcciones. La victoria reemplaza toda la escena.

La sala de piedras exige despejar un camino moviendo bloques que se
estorban entre si. T repone las piedras y te devuelve a su entrada.

Las habitaciones conservan los objetos recogidos, enemigos derrotados y
mecanismos resueltos durante la partida. R inicia una partida nueva;
no hay guardado en disco.

## Verificación y recursos

```text
wollok lint
wollok test --skipValidations
```

Las pruebas incluyen un recorrido completo con movimiento, interacciones y
combate reales, los bloqueos de progresión, persistencia, reinicio y aparición
condicionada del medallón. Los checkpoints originales se conservan como
fixtures de las pruebas de regresión.

La distribución y sus responsabilidades están explicadas en
[docs/supernivel.md](docs/supernivel.md). El combate se documenta en
[docs/combate-tactico.md](docs/combate-tactico.md).

Los fondos y las variaciones del piso son dibujos propios. Los sprites
de corazones, armadura roja y Link se recortan de las fuentes de ALTTP.
Todos estos recursos se generan mediante
`tools/generar_supernivel.ps1` (PowerShell con System.Drawing). Se incluyen
los PNG listos para jugar. Los recursos anteriores y sus fuentes están
detallados en [assets/CREDITOS.md](assets/CREDITOS.md).
