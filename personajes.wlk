import wollok.game.*
import sala.*

object jugador {
  var property position = game.at(2, 2)
  var property vida = 3
  var direccion = "abajo"
  const inventario = []
  var escudoActivo = false
  var escudoVersion = 0

  method image() = "zelda/link-" + direccion + ".png"
  method moverArriba() { self.moverA(position.up(1), position.up(2), "arriba") }
  method moverAbajo() { self.moverA(position.down(1), position.down(2), "abajo") }
  method moverIzquierda() { self.moverA(position.left(1), position.left(2), "izquierda") }
  method moverDerecha() { self.moverA(position.right(1), position.right(2), "derecha") }

  method moverA(destino, siguiente, orientacion) {
    if (sala.enCurso()) {
      direccion = orientacion
      if (sala.puedeAvanzarA(destino, siguiente)) {
        position = destino
        sala.alMoverse()
      }
    }
  }
  method guardar(objeto) { inventario.add(objeto) }
  method tiene(nombre) = inventario.any({ objeto => objeto.nombre() == nombre })
  method inventarioTexto() = if (inventario.isEmpty()) "vacio" else inventario.map({ objeto => objeto.nombre() }).join(" + ")

  method activarEscudo() {
    escudoActivo = true
    escudoVersion += 1
    const version = escudoVersion
    sala.informar("Escudo activado! Te protege del proximo golpe (dura 30s).")
    game.schedule(30000, { self.expirarEscudo(version) })
  }
  method expirarEscudo(version) {
    if (escudoActivo and escudoVersion == version) {
      escudoActivo = false
      sala.informar("El escudo se gasto por el tiempo.")
    }
  }
  method recibirDanio(cantidad) {
    if (escudoActivo) {
      escudoActivo = false
      sala.informar("El escudo absorbio el golpe!")
    } else {
      vida = (vida - cantidad).max(0)
      if (vida == 0) sala.perder()
      else sala.informar("Recibiste daño: perdiste salud. ¡Cuidado!")
    }
  }
  method reiniciar() {
    position = game.at(2, 2)
    vida = 3
    direccion = "abajo"
    inventario.clear()
    escudoActivo = false
  }
}