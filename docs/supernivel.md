# Supernivel: implementación

## Habitaciones y conexiones

Las coordenadas se numeran de izquierda a derecha y de abajo hacia arriba.
Cada escena usa el mismo tablero: interior `x=1..14`, `y=1..8`; puertas en
los huecos del perímetro `x=0/15` o `y=0/9`. El jugador aparece siempre
una celda hacia adentro de la puerta correspondiente.

| Sala | Clase | Conexiones y condición |
| --- | --- | --- |
| 1-0 | SalaDelPuente | Norte a 1-1 tras colocar la caja; este a 2-0 con armadura |
| 1-1 | PasilloReal | Sur al inicio, oeste a oscuridad, este a 2-1 con llave 2 |
| 0-1 | SalaOscura | Regreso este al pasillo tras encender la luz y pulsar el botón |
| 2-0 | SalaDelArco | Oeste por la ruta de lava, arco y llave 2 recogibles |
| 2-1 | SalaDeLaSecuencia | Oeste al pasillo, este a 3-1 tras B-A-C |
| 3-1 | SalaDeLasCajas | Oeste a botones; norte al pasaje tras despejar las piedras |
| Pasaje | PasajeSuperior | Sur a cajas, corredor visible en L hacia el oeste a 2-2 |
| 2-2 | SalaDelMedallon | Este al pasaje, cerrada durante el encuentro |

`PuertaConectada` comparte su condición entre imagen, colisión e interacción.
Una puerta abierta permite ocupar su celda y dispara la transición al pisarla;
también se puede cruzar con E desde una celda contigua. No hay muros sólidos
adicionales sobre las puertas del fondo. El pasaje restringe las colisiones a
las mismas celdas en L que dibuja el generador del mapa.

## Estado y reutilización

`mazmorra` mantiene una única instancia por habitación durante la partida.
`irA` cancela turnos y eventos del mapa anterior, limpia los visuales, cambia
la posición y vuelve a mostrar los objetos disponibles de la misma instancia.
Los enemigos vivos reaparecen con la vida y posición que tenían; los muertos
no se registran otra vez. El inventario pertenece a `jugador`.

Se reutilizan `PuzzleDeCajas`, `PanelDeCables`, `VeloOscuro`,
`ObjetoRecogible`, `ObjetoUsable`, `Combatiente`, `Enemigo`, las habilidades y
el coordinador `combate`. `SecuenciaOrdenada` es el motor compartido por los
botones originales y los sellos B-A-C. La habilidad de distancia se habilita
al recoger el arco en el supernivel.

Antes de la armadura, la lava bloquea el movimiento: no puede cruzarse
sacrificando corazones ni llegarse al arco por un atajo. La armadura permanece
equipada. La llave 1 abre exclusivamente el cofre; la llave 2 habilita la
puerta del pasillo. Cada llave se consume en su propia cerradura y no reaparece. El cofre concede la armadura una sola vez.

## Interfaz y apariciones

El HUD se vuelve a agregar al final de la lista visual despues de cada
velo, panel y efecto. Su fondo opaco reserva los primeros 96 pixeles:
corazones grandes a la izquierda, turno y eventos en el centro, inventario
a la derecha y tres tarjetas de accion debajo. No se dibuja sobre el mapa
ni se comparten celdas entre los corazones y las instrucciones de combate.

Las tarjetas reflejan seleccion, ataque usado, arco bloqueado, espera enemiga
y fin de turno recomendado. Esc cancela una seleccion sin gastar recursos.
Los indicadores de alcance usan las mismas colisiones y alcance que las
habilidades; se dibujan debajo de los personajes. Las barras de salud se
mueven con cada enemigo y se eliminan al derrotarlo o abandonar la escena.

`tools/render_interfaz.ps1` exporta los visuales del motor con el programa
`tools/qa_interfaz.wpgm` y compone vistas de oscuridad, cables, seleccion de
ataque y turno enemigo en `log/qa-interfaz`, sin iniciar un navegador.

`interfaz.wlk` mantiene tres sprites de corazones, con estados vacio,
cuarto, medio, tres cuartos y completo, ademas de ocho ranuras de inventario.
Los sprites se calculan desde la salud y los objetos actuales cada vez que
se dibujan: al consumir una llave, desaparece su icono inmediatamente.
Los corazones y objetos tambien son visibles durante los turnos de combate.

La sala oscura recupera toda la vision antes de iniciar el efecto. A los
650 ms aparece humo en cada charco; a los 1050 ms se materializan cuatro
slimes, uno en cada posicion. El humo termina a los 1550 ms. Durante esa
presentacion se bloquea brevemente el movimiento. Al disiparse el humo
comienza el encuentro con todos los slimes. No hay deteccion por distancia:
reentrar en cualquier sala con enemigos vivos inicia el combate de inmediato.
Una version de la secuencia cancela callbacks viejos al reiniciar o salir.
Al reentrar antes del spawn se retoma la presentacion sin duplicar enemigos.

Los botones se agregan antes de volver a colocar a Link al frente. El boton
de 0-1 comparte el sprite A de los sellos. No se muestran soluciones,
rutas ni secuencias correctas en los mensajes de juego.

## Piedras y recuperacion

La sala de piedras no usa losas ni una puerta magica condicionada al peso:
la puerta esta abierta, pero el camino queda fisicamente obstruido por
varias piedras. Es necesario maniobrar y despejar espacios en el orden
correcto porque algunos bloques impiden empujar a otros. Los bloques no
se apilan, no atraviesan paredes ni se pueden empujar en cadena.

`PuzzleDePiedras` reutiliza el empuje de `PuzzleDeCajas`, con ocho piedras
y posiciones iniciales propias. Las colisiones y el fondo usan la misma
lista de celdas transitables. La prueba de recorrido verifica que la salida
no sea alcanzable inicialmente y comprueba una solucion con movimientos
reales. El solucionador usado para disenar la distribucion encontro una
solucion minima de seis empujes sobre cuatro piedras distintas.

T restaura las piedras y devuelve al jugador a la entrada de esta sala,
conservando vida, inventario y otros mecanismos resueltos. En el puente
se mantiene su caja inicial y el desbloqueo persistente. T no funciona
durante combate ni mientras esta abierto el panel o la animacion de spawn.

## Rutas de enemigos

Las rutas enemigas prueban primero dos caminos directos. Cuando otros slimes
o paredes los bloquean, buscan un rodeo con A* y un limite de 160 celdas.
La busqueda no es recursiva ni copia todos los caminos posibles. Si no hay
acceso a una casilla junto al jugador, el enemigo termina su turno sin moverse.
`tests/turnoAlSepararSlimes.wtest` reproduce la retirada hacia la esquina
superior izquierda de 0-1 y verifica que la ronda vuelva al jugador.

## Encuentro final

`SalaDelMedallon.estadoFinal` pasa de `NO_INICIADA` a `COMBATE` al entrar.
Registra dos slimes comunes y un SlimeGuardian a la izquierda. Los comunes
tienen dos corazones, tres pasos y medio corazon de dano. El guardian tiene
cuatro corazones, cinco pasos, un corazon de dano y pasos de 160 ms en lugar
de 220 ms; su corona permite distinguirlo. Cada
enemigo conserva su propia identidad, vida y callback `alMorir`.

El callback se ejecuta solo en la transición de vivo a muerto. La sala
consulta exclusivamente su lista `guardianes`: no usa el total global de
enemigos ni un contador que pueda decrementarse dos veces. Al quedar todos
muertos, pasa a `MEDALLON_DISPONIBLE`, agrega el visual del medallón y abre
la salida. El objeto solo está disponible en ese estado. Recogerlo pasa a
`VICTORIA` y llama una vez a la victoria existente.

La victoria limpia visuales, eventos, HUD y combate, y sustituye el fondo
por `supernivel/victoria.png`, opaco y del tamano completo del tablero.
Se vuelven a registrar los controles para que R permita iniciar otra partida.

Morir usa la política anterior: derrota y R para reiniciar toda la partida.
Este reinicio recrea las habitaciones, limpia el inventario y oculta el premio.

## Pruebas

`tests/supernivel.wtest` recorre el juego con los métodos reales de movimiento,
interacción y habilidades; durante la pelea avanza los eventos de turnos
enemigos. Comprueba además llaves, lava, reentrada, cajas, secuencia, sprites,
muertes repetidas, enemigos ajenos, medallón persistente y reinicio por derrota.
Los tests anteriores siguen ejecutando los checkpoints mediante
`mazmorra.iniciarDemoAnterior()` para verificar sus mecánicas originales.

Los fondos y visuales propios están en `assets/supernivel`; se regeneran con
`tools/generar_supernivel.ps1`. El juego sigue usando los recursos existentes
para Link, cajas, losas, cables, llaves, colgante y guardia.
