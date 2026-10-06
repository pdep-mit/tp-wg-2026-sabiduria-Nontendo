import wollok.game.*
import personajes.*
import obstaculos.*

object configuracion {
    method movimientos(){
        keyboard.up().onPressDo({ jugador.moverArriba() })
        keyboard.down().onPressDo({ jugador.moverAbajo() })
        keyboard.left().onPressDo({ jugador.moverIzquierda() })
        keyboard.right().onPressDo({ jugador.moverDerecha() })
    }

   method agregarObstaculos() {
        const pincho1 = new Pincho(position = game.at(3, 4))
        const pincho2 = new Pincho(position = game.at(5, 2))
        const pincho3 = new Pincho(position = game.at(8, 7))

        game.addVisual(pincho1)
        game.addVisual(pincho2)
        game.addVisual(pincho3)
    }
}