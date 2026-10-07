import wollok.game.*

class Pincho {
  const property position
  method image() = "zelda/pinchos.png"
  method daniar(personaje) { personaje.recibirDanio() }
}
class Muro {
  const property position
  method image() = "zelda/muro.png"
}
object barrera {
  var property abierta = false
  method position() = game.at(10, 4)
  method image() = if (abierta) "zelda/barrera-abierta.png" else "zelda/barrera.png"
}
object antorcha {
  var property encendida = false
  method position() = game.at(3, 7)
  method image() = if (encendida) "zelda/antorcha-encendida.png" else "zelda/antorcha.png"
}
