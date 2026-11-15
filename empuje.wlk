import wollok.game.*
import personajes.*

class Caja {
  var property position
  method image() = "zelda/caja.png"
}

class PiedraMovil inherits Caja {
  override method image() = "supernivel/piedra.png"
}

class Losa {
  const property position
  const property ocupantes
  const property resuelta
  method presionada() = resuelta.apply() or jugador.position() == position or ocupantes.any({ caja => caja.position() == position })
  method image() = if (self.presionada()) "zelda/losa-on.png" else "zelda/losa.png"
}

class PuzzleDeCajas {
  const property resuelta
  const property posicionesIniciales = [game.at(5, 3), game.at(10, 3)]
  const property cajas = posicionesIniciales.map({ posicion => self.nuevaCaja(posicion) })
  const losas = [
    new Losa(position = game.at(5, 2), ocupantes = cajas, resuelta = resuelta),
    new Losa(position = game.at(10, 2), ocupantes = cajas, resuelta = resuelta),
    new Losa(position = game.at(7, 4), ocupantes = cajas, resuelta = resuelta)
  ]

  method elementos() = losas + cajas
  method nuevaCaja(posicion) = new Caja(position = posicion)
  method reiniciar() {
    (0..(cajas.size() - 1)).forEach({ indice => cajas.get(indice).position(posicionesIniciales.get(indice)) })
  }
  method resuelto() = losas.all({ losa => losa.presionada() })
  method posicionValida(posicion) = posicion.x() >= 2 and posicion.x() <= 13 and posicion.y() >= 2 and posicion.y() <= 7
  method hayCajaEn(posicion) = cajas.any({ caja => caja.position() == posicion })
  method intentarEmpujar(destino, siguiente, puedePasar) {
    const cajaEnDestino = cajas.filter({ caja => caja.position() == destino })
    if (cajaEnDestino.isEmpty()) {
      return puedePasar.apply(destino)
    }
    if (puedePasar.apply(siguiente) and self.posicionValida(siguiente) and !self.hayCajaEn(siguiente)) {
      cajaEnDestino.first().position(siguiente)
      return true
    }
    return false
  }
}

class PuzzleDePiedras inherits PuzzleDeCajas(resuelta = { false }, posicionesIniciales = [
  game.at(6, 3), game.at(7, 3), game.at(4, 2), game.at(10, 4),
  game.at(7, 6), game.at(8, 3), game.at(8, 4), game.at(9, 2)
]) {
  override method nuevaCaja(posicion) = new PiedraMovil(position = posicion)
  override method elementos() = cajas
  override method posicionValida(posicion) = posicion.x() >= 1 and posicion.x() <= 14 and posicion.y() >= 1 and posicion.y() <= 8
}
