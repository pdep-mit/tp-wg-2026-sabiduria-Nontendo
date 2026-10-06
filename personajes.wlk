import wollok.game.*
import juego.*

object jugador{
    var property position = game.at(1, 1)
    var property vida = 100
    method image() = "player.png"

    method moverArriba() {
        position = position.up(1)
    }
    method moverAbajo() {
        position = position.down(1)
    }
    method moverIzquierda() {
        position = position.left(1)
    }
    method moverDerecha() {
        position = position.right(1)
    }
}