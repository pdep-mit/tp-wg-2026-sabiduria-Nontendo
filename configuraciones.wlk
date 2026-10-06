import wollok.game.*
import personajes.*

object configuracion {
    method movimientos(){
        keyboard.up().onPressDo({ jugador.moverArriba() })
        keyboard.down().onPressDo({ jugador.moverAbajo() })
        keyboard.left().onPressDo({ jugador.moverIzquierda() })
        keyboard.right().onPressDo({ jugador.moverDerecha() })
    }
}