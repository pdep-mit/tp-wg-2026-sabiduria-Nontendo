import wollok.game.*
import personajes.*

class VeloOscuro {
  const ancho = 31
  const alto = 23

  method position() = game.at(jugador.position().x() - (ancho - 1) / 2, jugador.position().y() - (alto - 1) / 2)
  method image() = "zelda/oscuridad.png"
}

class MarcoFijo {
  method position() = game.at(0, 0)
  method image() = "zelda/marco-sala2.png"
}

class Niebla {
  const velo = new VeloOscuro()
  const marco = new MarcoFijo()

  method elementos() = [velo, marco]
  method ocultar() {
    self.elementos().forEach({ elemento => game.removeVisual(elemento) })
  }
}