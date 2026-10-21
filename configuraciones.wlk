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
    keyboard.num1().onPressDo({ sala.presionarCable("1") })
    keyboard.num2().onPressDo({ sala.presionarCable("2") })
    keyboard.num3().onPressDo({ sala.presionarCable("3") })
    keyboard.num4().onPressDo({ sala.presionarCable("4") })
    keyboard.a().onPressDo({ sala.presionarCable("A") })
    keyboard.s().onPressDo({ sala.presionarCable("S") })
    keyboard.d().onPressDo({ sala.presionarCable("D") })
    keyboard.f().onPressDo({ sala.presionarCable("F") })
  }
}