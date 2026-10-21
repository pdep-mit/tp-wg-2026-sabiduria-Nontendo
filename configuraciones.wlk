import wollok.game.*
import personajes.*
import sala.*

object configuracion {
  method movimientos() {
    keyboard.up().onPressDo({ jugador.moverArriba() })
    keyboard.down().onPressDo({ jugador.moverAbajo() })
    keyboard.left().onPressDo({ jugador.moverIzquierda() })
    keyboard.right().onPressDo({ jugador.moverDerecha() })
    keyboard.e().onPressDo({ sala.interactuar() })
    keyboard.r().onPressDo({ mazmorra.reiniciarTodo() })
  }
}