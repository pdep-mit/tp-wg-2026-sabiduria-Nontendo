import wollok.game.*
import personajes.*
import obstaculos.*
import objetos.*
import puzzle.*

class Sala {
  var estado = "jugando"
  var property mensaje = ""

  method mensajeInicial()
  method obstaculos()
  method interactuables()
  method elementosDeEscena()
  method registrarColisiones() {}
  method reiniciarPropio() {}

  method enCurso() = estado == "jugando"
  method permitePasar(posicion) =
    posicion.x() >= 1 and posicion.x() <= 14 and posicion.y() >= 1 and posicion.y() <= 8
    and !self.obstaculos().any({ obstaculo => obstaculo.bloqueaPaso(posicion) })
  method interactuar() {
    if (self.enCurso()) {
      const cercanos = self.interactuables().filter({ objeto => objeto.disponible() and objeto.position().distance(jugador.position()) <= 1 })
      if (cercanos.isEmpty()) self.informar("Acercate a algo interactuable y pulsa E.")
      else cercanos.min({ objeto => objeto.position().distance(jugador.position()) }).interactuar(jugador)
    }
  }
  method informar(texto) { mensaje = texto }
  method ganar() {
    estado = "ganado"
    self.informar("GANASTE! R para volver a jugar.")
  }
  method perder() {
    estado = "perdido"
    self.informar("SIN VIDA! R para reiniciar la demo.")
  }
  method iniciar() {
    mensaje = self.mensajeInicial()
    self.elementosDeEscena().forEach({ elemento => game.addVisual(elemento) })
    [jugador, cartelEstado, cartelVida, cartelInventario].forEach({ visual => game.addVisual(visual) })
    self.registrarColisiones()
  }
  method reiniciar() {
    game.clear()
    jugador.reiniciar()
    estado = "jugando"
    self.reiniciarPropio()
    self.iniciar()
  }
}

class SalaDeLosTresSellos inherits Sala {
  var llave = new ObjetoRecogible(nombre = "llave", sprite = "zelda/llave.png", position = game.at(12, 5))
  var recuerdo = new ObjetoRecogible(nombre = "colgante", sprite = "zelda/colgante.png", position = game.at(4, 2))
  const muros = (1..8).filter({ y => y != 4 }).map({ y => new Muro(position = game.at(10, y)) })
  const pinchos = [new Pincho(position = game.at(6, 2)), new Pincho(position = game.at(7, 2))]

  override method mensajeInicial() = "Sala de los tres sellos | Activa 1 > 2 > 3"
  override method obstaculos() = muros + [barrera, antorcha, salida]
  override method interactuables() = puzzle.botones() + [recuerdo, salida] + (if (puzzle.resuelto()) [llave] else [])
  override method elementosDeEscena() = muros + pinchos + puzzle.botones() + [barrera, antorcha, salida, recuerdo]
  override method registrarColisiones() {
    pinchos.forEach({ pincho => game.onCollideDo(pincho, { elemento => pincho.chocarCon(elemento) }) })
  }
  override method reiniciarPropio() {
    puzzle.reiniciar()
    salida.abierta(false)
    llave = new ObjetoRecogible(nombre = "llave", sprite = "zelda/llave.png", position = game.at(12, 5))
    recuerdo = new ObjetoRecogible(nombre = "colgante", sprite = "zelda/colgante.png", position = game.at(4, 2))
  }
  method revelarLlave() { game.addVisual(llave) }
}

object mazmorra {
  var property salaActual = new SalaDeLosTresSellos()
}

object sala {
  method actual() = mazmorra.salaActual()
  method enCurso() = self.actual().enCurso()
  method mensaje() = self.actual().mensaje()
  method informar(texto) { self.actual().informar(texto) }
  method permitePasar(posicion) = self.actual().permitePasar(posicion)
  method interactuar() { self.actual().interactuar() }
  method ganar() { self.actual().ganar() }
  method perder() { self.actual().perder() }
  method iniciar() { self.actual().iniciar() }
  method reiniciar() { self.actual().reiniciar() }
  method revelarLlave() { self.actual().revelarLlave() }
}

object cartelEstado {
  method position() = game.at(7.5, 11)
  method text() = sala.mensaje()
  method textColor() = "F8E7B5"
}
object cartelVida {
  method position() = game.at(2, 10)
  method text() = "VIDA: " + jugador.vida() + " / 3"
  method textColor() = "FF9999"
}
object cartelInventario {
  method position() = game.at(9, 10)
  method text() = "INVENTARIO: " + jugador.inventarioTexto()
  method textColor() = "B8F0CA"
}