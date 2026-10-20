import wollok.game.*
import sala.*
class Llave {
  const property position
  method nombre() = "Llave"
  method image() = "zelda/llave.png"

  method chocarCon(personaje) {
    personaje.guardar(self)
    game.removeVisual(self)
  }
}

class Boton {
  const property numero
  const property position
  var property activado = false
  method image() = "zelda/boton-" + numero + (if (activado) "-on.png" else ".png")
  method disponible() = true
  
  method interactuar(personaje) { 
    puzzle.presionar(self) 
  }
}

object puzzle {
  var property progreso = 0
  const property botones = [
    new Boton(numero = 1, position = game.at(3, 5)),
    new Boton(numero = 2, position = game.at(6, 5)),
    new Boton(numero = 3, position = game.at(9, 5))
  ]
  method resuelto() = progreso == botones.size()
  method presionar(boton) {
    if (self.resuelto()) {
      sala.informar("Puzzle completo. Busca la llave a la derecha.")
    } else if (boton.numero() == progreso + 1) {
      boton.activado(true)
      progreso += 1
      sala.aplicarEfecto(boton.numero())
    } else {
      self.reiniciar()
      sala.restaurarEfectos()
      sala.informar("Orden incorrecto. Volve a empezar: 1 > 2 > 3.")
    }
  }
  method reiniciar() {
    progreso = 0
    botones.forEach({ b => b.activado(false) })
  }
}