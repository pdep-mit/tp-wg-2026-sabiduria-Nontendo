import wollok.game.*
import personajes.*
import sala.*

object configuracion {
  method movimientos() {
    keyboard.up().onPressDo({ jugador.moverArriba() })
    keyboard.down().onPressDo({ jugador.moverAbajo() })
    keyboard.left().onPressDo({ jugador.moverIzquierda() })
    keyboard.right().onPressDo({ jugador.moverDerecha() })
    keyboard.e().onPressDo({ if (!jugador.enCombate()) sala.interactuar() })
    keyboard.r().onPressDo({ mazmorra.reiniciarTodo() })
    keyboard.num1().onPressDo({ self.habilidadOCable(1) })
    keyboard.num2().onPressDo({ self.habilidadOCable(2) })
    keyboard.space().onPressDo({ jugador.pasarTurno() })
    keyboard.num3().onPressDo({ self.cable("3") })
    keyboard.num4().onPressDo({ self.cable("4") })
    keyboard.a().onPressDo({ self.cable("A") })
    keyboard.s().onPressDo({ self.cable("S") })
    keyboard.d().onPressDo({ self.cable("D") })
    keyboard.f().onPressDo({ self.cable("F") })
  }
  method habilidadOCable(numero) {
    if (jugador.enCombate()) jugador.seleccionarHabilidad(numero)
    else self.cable(numero.toString())
  }
  method cable(etiqueta) { if (!jugador.enCombate()) sala.presionarCable(etiqueta) }
}
