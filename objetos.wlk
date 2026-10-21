import wollok.game.*
import sala.*

class ObjetoRecogible {
  const property nombre
  const property sprite
  const property position
  var property recogido = false
  method image() = sprite
  method disponible() = !recogido
  method interactuar(personaje) {
    if (self.disponible()) {
      personaje.guardar(self)
      recogido = true
      game.removeVisual(self)
      sala.informar("Guardaste " + nombre + " en el inventario.")
    }
  }
}

object salida {
  var property abierta = false
  method position() = game.at(14, 7)
  method image() = if (abierta) "zelda/salida-abierta.png" else "zelda/salida.png"
  method disponible() = true
  method bloqueaPaso(posicion) = self.position() == posicion
  method interactuar(personaje) {
    if (personaje.tiene("llave")) {
      abierta = true
      sala.ganar()
    } else sala.informar("La salida esta cerrada: necesitas la llave.")
  }
}