import wollok.game.*
import sala.*
import obstaculos.*

// Motor compartido por los sellos del checkpoint y la secuencia B-A-C.
class SecuenciaOrdenada {
  const property orden
  var property progreso = 0
  method resuelto() = progreso == orden.size()
  method activo(etiqueta) = orden.take(progreso).contains(etiqueta)
  method reiniciar() { progreso = 0 }
  method avanzar(etiqueta) {
    if (self.resuelto()) return true
    if (etiqueta != orden.get(progreso)) {
      progreso = 0
      return false
    }
    progreso += 1
    return true
  }
}

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
  const secuencia = new SecuenciaOrdenada(orden = [1, 2, 3])
  method progreso() = secuencia.progreso()
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
  method resuelto() = secuencia.resuelto()
  method presionar(boton) {
    if (self.resuelto()) sala.informar("Puzzle completo. Busca la llave a la derecha.")
    else if (secuencia.avanzar(boton.numero())) {
      boton.activar()
    } else {
      self.reiniciar()
      sala.informar("Orden incorrecto. Volve a empezar: 1 > 2 > 3.")
    }
  }
  method reiniciar() {
    secuencia.reiniciar()
    botones.forEach({ boton => boton.desactivar() })
  }
}
