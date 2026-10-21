import wollok.game.*

class ElementoDanino {
  const property position
  method chocarCon(personaje) {
    if (self.estaActivo()) {
      personaje.recibirDanio(self.danioQueCausa())
      self.efectoAdicional(personaje)
    }
  }
  method estaActivo() = true
  method danioQueCausa()
  method efectoAdicional(personaje) {}
}

class Pincho inherits ElementoDanino {
  method image() = "zelda/pinchos.png"
  override method danioQueCausa() = 1
}

class Muro {
  const property position
  method image() = "zelda/muro.png"
  method bloqueaPaso(posicion) = self.position() == posicion
}

object barrera {
  var property abierta = false
  method position() = game.at(10, 4)
  method image() = if (abierta) "zelda/barrera-abierta.png" else "zelda/barrera.png"
  method bloqueaPaso(posicion) = !abierta and self.position() == posicion
}

object antorcha {
  var property encendida = false
  method position() = game.at(3, 7)
  method image() = if (encendida) "zelda/antorcha-encendida.png" else "zelda/antorcha.png"
  method bloqueaPaso(posicion) = self.position() == posicion
}