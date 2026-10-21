import wollok.game.*
import sala.*

class Inventario {
  const objetos = []
  method tiene(nombre) = objetos.any({ objeto => objeto.nombre() == nombre })
  method agregar(objeto) { objetos.add(objeto) }
  method vaciar() { objetos.clear() }
  method texto() = if (objetos.isEmpty()) "vacio" else objetos.map({ objeto => objeto.nombre() }).join(" + ")
}

class Proteccion {
  var property activa = false
  var version = 0

  method activar() {
    activa = true
    version += 1
    const miVersion = version
    sala.informar("Escudo activado! Te protege del proximo golpe (dura 30s).")
    game.schedule(30000, { self.expirar(miVersion) })
  }
  method expirar(miVersion) {
    if (activa and version == miVersion) {
      activa = false
      sala.informar("El escudo se gasto por el tiempo.")
    }
  }
  method absorber() {
    if (activa) {
      activa = false
      sala.informar("El escudo absorbio el golpe!")
      return true
    }
    return false
  }
}

object jugador {
  var property position = game.at(2, 2)
  var property vida = 3
  var direccion = "abajo"
  const inventario = new Inventario()
  const proteccion = new Proteccion()

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
  method guardar(objeto) { inventario.agregar(objeto) }
  method tiene(nombre) = inventario.tiene(nombre)
  method inventarioTexto() = inventario.texto()

  method activarEscudo() { proteccion.activar() }
  method recibirDanio(cantidad) {
    if (!proteccion.absorber()) {
      vida = (vida - cantidad).max(0)
      if (vida == 0) sala.perder()
      else sala.informar("Recibiste daño: perdiste salud. ¡Cuidado!")
    }
  }
  method reiniciar() {
    position = game.at(2, 2)
    vida = 3
    direccion = "abajo"
    inventario.vaciar()
    proteccion.activa(false)
  }
}