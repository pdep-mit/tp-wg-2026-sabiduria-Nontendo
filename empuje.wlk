import wollok.game.*
import personajes.*

class Caja {
  var property position
  method image() = "zelda/caja.png"
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
  const cajas = [new Caja(position = game.at(5, 3)), new Caja(position = game.at(10, 3))]
  const losas = [
    new Losa(position = game.at(5, 2), ocupantes = cajas, resuelta = resuelta),
    new Losa(position = game.at(10, 2), ocupantes = cajas, resuelta = resuelta),
    new Losa(position = game.at(7, 4), ocupantes = cajas, resuelta = resuelta)
  ]

  method elementos() = losas + cajas
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