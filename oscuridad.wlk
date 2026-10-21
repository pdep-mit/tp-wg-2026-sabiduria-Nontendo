import wollok.game.*
import personajes.*

class Sombra {
  const property position
  method image() {
    const distancia = jugador.position().distance(position)
    if (distancia <= 1) return "zelda/vision-clara.png"
    if (distancia <= 2) return "zelda/vision-penumbra.png"
    return "zelda/vision-oscura.png"
  }
}

class Niebla {
  const sombras = (1..14).flatMap({ x => (1..8).map({ y => new Sombra(position = game.at(x, y)) }) })

  method elementos() = sombras
  method ocultar() {
    sombras.forEach({ sombra => game.removeVisual(sombra) })
  }
}