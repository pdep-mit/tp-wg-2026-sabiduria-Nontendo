import wollok.game.*
import sala.*

object jugador {
  var property position = game.at(2, 2)
  var property vida = 3
  var direccion = "abajo"
  const inventario = []
  method image() = "zelda/link-" + direccion + ".png"
  method moverArriba() { self.moverA(position.up(1), "arriba") }
  method moverAbajo() { self.moverA(position.down(1), "abajo") }
  method moverIzquierda() { self.moverA(position.left(1), "izquierda") }
  method moverDerecha() { self.moverA(position.right(1), "derecha") }

  method moverA(destino, orientacion) {
    if (sala.enCurso()) {
      direccion = orientacion
      if (sala.permitePasar(destino)) {
        position = destino
        sala.alPisar(destino)
      }
    }
  }
  method guardar(objeto) { inventario.add(objeto) }
  method tiene(nombre) = inventario.any({ objeto => objeto.nombre() == nombre })
  method inventarioTexto() = if (inventario.isEmpty()) "vacio" else inventario.map({ objeto => objeto.nombre() }).join(" + ")
  method recibirDanio() {
    vida = (vida - 1).max(0)
    if (vida == 0) sala.perder()
    else sala.informar("Pinchos: perdiste un corazon. Cuidado!")
  }
  method reiniciar() {
    position = game.at(2, 2)
    vida = 3
    direccion = "abajo"
    inventario.clear()
  }
}
