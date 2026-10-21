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

class ObjetoUsable inherits ObjetoRecogible {
  override method interactuar(personaje) {
    if (self.disponible()) {
      super(personaje)
      self.alUsar(personaje)
    }
  }
  method alUsar(personaje) {}
}

class Escudo inherits ObjetoUsable {
  override method alUsar(personaje) {
    personaje.activarEscudo()
  }
}

class Salida {
  const property position
  const property condicion
  const property alCruzar
  var property abierta = false

  method actualizarEstado() { abierta = condicion.apply() }
  method image() = if (abierta) "zelda/salida-abierta.png" else "zelda/salida.png"
  method disponible() = true
  method bloqueaPaso(posicion) = self.position() == posicion
  method interactuar(personaje) {
    self.actualizarEstado()
    if (abierta) alCruzar.apply()
    else sala.informar("La salida esta cerrada.")
  }
}