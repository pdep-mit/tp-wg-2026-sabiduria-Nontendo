import wollok.game.*
import personajes.*

class Caja {
  var property position
  method text() = "[CAJA]"
  method textColor() = "C9A34D"
}

class Losa {
  const property position
  const property ocupantes
  method presionada() = jugador.position() == position or ocupantes.any({ caja => caja.position() == position })
  method text() = if (self.presionada()) "[X]" else "[ ]"
  method textColor() = if (self.presionada()) "7CFC9A" else "8C8CA8"
}