import wollok.game.*
import personajes.*
import combate.*
import sala.*

class CorazonHUD {
  const property indice
  method position() = game.at(0.25 + indice * 0.75, 11)
  method cuartos() = ((jugador.vida() - indice).max(0).min(1) * 4).round()
  method image() = "supernivel/corazon-" + self.cuartos() + ".png"
}

class IconoInventario {
  const property indice
  method position() = game.at(9.25 + indice * 0.75, 11)
  method image() = if (indice < jugador.objetosInventario().size()) jugador.objetosInventario().get(indice).image() else "zelda/transparente.png"
}

object fondoHUD {
  method position() = game.at(0, 10)
  method image() = "supernivel/hud.png"
}

class TarjetaAccion {
  const property numero
  method position() = game.at(0.25 + (numero - 1) * 5.25, 10)
  method estado() {
    if (!jugador.enCombate()) return sala.actual().modoInterfaz()
    if (jugador.enEspera()) return "espera"
    if (numero == 3) return if (jugador.pasosRestantes() == 0 and !jugador.ataqueDisponible()) "urgente" else "disponible"
    if (numero == 2 and sala.actual().requiereArco() and !jugador.tiene("arco")) return "bloqueado"
    if (!jugador.ataqueDisponible()) return "usado"
    return if (jugador.habilidadSeleccionada() == jugador.habilidades().get(numero - 1)) "seleccionado" else "disponible"
  }
  method image() = "supernivel/accion-" + numero + "-" + self.estado() + ".png"
}

class CasillaDeAtaque {
  const property direccion
  const property distancia
  method position() = combate.desplazar(jugador.position(), direccion, distancia)
  method image() {
    if (!combate.alcanceVisible(direccion, distancia)) return "zelda/transparente.png"
    return if (combate.hayEnemigoEn(self.position())) "supernivel/objetivo-ataque.png" else "supernivel/alcance-ataque.png"
  }
}

object indicadorTurnoEnemigo {
  method visible() = combate.activo() and combate.participanteActual().turnoAutomatico()
  method position() = if (self.visible()) combate.participanteActual().position() else game.at(0, 0)
  method image() = if (self.visible()) "supernivel/turno-enemigo.png" else "zelda/transparente.png"
}

object interfaz {
  const property corazones = (0..2).map({ indice => new CorazonHUD(indice = indice) })
  const property iconos = (0..7).map({ indice => new IconoInventario(indice = indice) })
  const property acciones = (1..3).map({ numero => new TarjetaAccion(numero = numero) })
  const property alcances = self.crearAlcances()
  method crearAlcances() {
    const marcas = []
    ["arriba", "abajo", "izquierda", "derecha"].forEach({ direccion =>
      (1..3).forEach({ distancia => marcas.add(new CasillaDeAtaque(direccion = direccion, distancia = distancia)) })
    })
    return marcas
  }
  method elementos() = [fondoHUD] + corazones + iconos + acciones + [cartelEstado, vistaCombate]
  method indicadoresDeEscena() = alcances + [indicadorTurnoEnemigo]
  method mostrar() {
    self.elementos().forEach({ visual => if (game.hasVisual(visual)) game.removeVisual(visual) })
    self.elementos().forEach({ visual => game.addVisual(visual) })
  }
  method textoCorto(texto) = if (texto.size() > 32) texto.take(30) + ".." else texto
}
