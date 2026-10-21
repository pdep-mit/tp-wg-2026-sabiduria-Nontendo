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