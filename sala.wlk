import wollok.game.*
import personajes.*
import obstaculos.*
import objetos.*
import puzzle.*

object sala {
  var estado = "jugando"
  var property mensaje = "Sala de los tres sellos | Activa 1 > 2 > 3"
  var llave = new ObjetoRecogible(nombre = "llave", sprite = "zelda/llave.png", position = game.at(12, 5))
  var recuerdo = new ObjetoRecogible(nombre = "colgante", sprite = "zelda/colgante.png", position = game.at(4, 2))
  const muros = (1..8).filter({ y => y != 4 }).map({ y => new Muro(position = game.at(10, y)) })
  const pinchos = [new Pincho(position = game.at(6, 2)), new Pincho(position = game.at(7, 2))]

  method enCurso() = estado == "jugando"
  method obstaculos() = muros + [barrera, antorcha, salida]
  method permitePasar(posicion) =
    posicion.x() >= 1 and posicion.x() <= 14 and posicion.y() >= 1 and posicion.y() <= 8
    and !self.obstaculos().any({ obstaculo => obstaculo.bloqueaPaso(posicion) })
  method registrarColisiones() {
    pinchos.forEach({ pincho => game.onCollideDo(pincho, { elemento => pincho.chocarCon(elemento) }) })
  }

  method interactuar() {
    if (self.enCurso()) {
      const cercanos = self.interactuables().filter({ objeto => objeto.disponible() and objeto.position().distance(jugador.position()) <= 1 })
      if (cercanos.isEmpty()) self.informar("Acercate a un boton, un objeto o la salida y pulsa E.")
      else cercanos.min({ objeto => objeto.position().distance(jugador.position()) }).interactuar(jugador)
    }
  }
  method interactuables() = puzzle.botones() + [recuerdo, salida] + (if (puzzle.resuelto()) [llave] else [])
  method revelarLlave() { game.addVisual(llave) }
  method informar(texto) { mensaje = texto }
  method ganar() {
    estado = "ganado"
    self.informar("GANASTE! Saliste con la llave. R para volver a jugar.")
  }
  method perder() {
    estado = "perdido"
    self.informar("SIN VIDA! R para reiniciar la demo.")
  }
  method iniciar() {
    muros.forEach({ muro => game.addVisual(muro) })
    pinchos.forEach({ pincho => game.addVisual(pincho) })
    puzzle.botones().forEach({ boton => game.addVisual(boton) })
    [barrera, antorcha, salida, recuerdo, jugador, cartelEstado, cartelVida, cartelInventario].forEach({ visual => game.addVisual(visual) })
    self.registrarColisiones()
  }
  method reiniciar() {
    game.clear()
    jugador.reiniciar()
    puzzle.reiniciar()
    salida.abierta(false)
    llave = new ObjetoRecogible(nombre = "llave", sprite = "zelda/llave.png", position = game.at(12, 5))
    recuerdo = new ObjetoRecogible(nombre = "colgante", sprite = "zelda/colgante.png", position = game.at(4, 2))
    estado = "jugando"
    self.informar("Sala de los tres sellos | Activa 1 > 2 > 3")
    self.iniciar()
  }
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