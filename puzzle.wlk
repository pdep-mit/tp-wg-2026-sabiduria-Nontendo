import wollok.game.*
import sala.*
import obstaculos.*

class Boton {
  const property numero
  const property position
  const property onActivar
  const property onDesactivar
  var property activado = false
  method image() = "zelda/boton-" + numero + (if (activado) "-on.png" else ".png")
  method disponible() = true
  method interactuar(personaje) { puzzle.presionar(self) }
  method activar() {
    activado = true
    onActivar.apply()
  }
  method desactivar() {
    activado = false
    onDesactivar.apply()
  }
}

object puzzle {
  var property progreso = 0
  const property botones = [
    new Boton(numero = 1, position = game.at(3, 5),
      onActivar = {
        antorcha.encendida(true)
        sala.informar("1/3: antorcha encendida! Ahora activa el boton 2.")
      },
      onDesactivar = { antorcha.encendida(false) }),
    new Boton(numero = 2, position = game.at(6, 5),
      onActivar = {
        barrera.abierta(true)
        sala.informar("2/3: barrera abierta! Falta el boton 3.")
      },
      onDesactivar = { barrera.abierta(false) }),
    new Boton(numero = 3, position = game.at(9, 5),
      onActivar = {
        sala.revelarLlave()
        sala.informar("3/3: aparecio la llave! Recogela con E y abri la salida.")
      },
      onDesactivar = { })
  ]
  method resuelto() = progreso == botones.size()
  method presionar(boton) {
    if (self.resuelto()) sala.informar("Puzzle completo. Busca la llave a la derecha.")
    else if (boton.numero() == progreso + 1) {
      boton.activar()
      progreso += 1
    } else {
      self.reiniciar()
      sala.informar("Orden incorrecto. Volve a empezar: 1 > 2 > 3.")
    }
  }
  method reiniciar() {
    progreso = 0
    botones.forEach({ boton => boton.desactivar() })
  }
}