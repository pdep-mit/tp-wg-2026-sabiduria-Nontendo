# Explicaciones teóricas

## Conceptos ya aplicados (Checkpoint 1)

- **Polimorfismo**: `sala.interactuar()` manda el mensaje `interactuar(jugador)` al
  interactuable más cercano sin preguntar de qué tipo es. `Boton`, `ObjetoRecogible`
  y `salida` responden cada uno a su manera (activar el puzzle, guardarse en el
  inventario, o validar si el jugador tiene la llave).
- **Delegación**: `sala` no resuelve el puzzle, le delega a `puzzle` cuándo un botón
  fue presionado en el orden correcto. `puzzle` a su vez delega en cada `Boton` el
  prenderse o no.

## Conceptos en desarrollo (Checkpoint 2)

- **Herencia + Template Method**: se generaliza `ElementoDanino` como clase base de
  todo lo que puede lastimar al jugador. Define el flujo común (`chocarCon`) y deja
  como hooks abstractos lo que cada subclase decide (`danioQueCausa`,
  `efectoAdicional`). `Pincho` (daño fijo, estático) y `Enemigo` (daño propio, se
  mueve) son subclases concretas. Ver diagrama [ElementoDanino](assets/diagramas/ElementoDanino.png).
- **Colisiones propias de Wollok Game**: se reemplaza el chequeo manual de posición
  por `game.onCollideDo`, para que el motor avise cuándo el jugador choca con un
  `ElementoDanino`.
- **Eventos temporales**: el `Enemigo` se mueve con `game.tick(...)`, el tercer tipo
  de bloque de configuración de eventos (junto a teclado y colisión).
- **Herencia de salas**: `Sala` pasa de ser un objeto único a una clase, con una
  subclase para la sala de los tres sellos y otra para la sala del enemigo. Un
  objeto `mazmorra` sostiene cuál es la sala actual y resuelve la transición entre
  ambas. Ver diagrama [Sala](assets/diagramas/Sala.png).
- **Colecciones**: listas de obstáculos, botones e inventario ya se manejan de forma
  declarativa (`filter`, `map`, `forEach`, `any`), evitando lógica repetida por
  cada elemento.

# Diagramas

![Jerarquía de ElementoDanino](assets/diagramas/ElementoDanino.png)

![Jerarquía de Sala](assets/diagramas/Sala.png)