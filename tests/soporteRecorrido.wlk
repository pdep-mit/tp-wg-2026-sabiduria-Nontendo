import wollok.game.*
import sala.*
import personajes.*
import combate.*

// Recorre celdas transitables usando los controles reales del jugador, sin teletransportarlo.
object recorrido {
  method caminarA(x, y) {
    const destino = game.at(x, y)
    const camino = self.buscar([[jugador.position()]], [jugador.position()], destino)
    assert.notThat(camino.isEmpty())
    camino.drop(1).forEach({ paso => self.pasoA(paso) })
    assert.equals(destino, jugador.position())
  }
  method buscar(pendientes, visitadas, destino) {
    if (pendientes.isEmpty()) return []
    const camino = pendientes.min({ candidato => combate.distancia(candidato.last(), destino) })
    pendientes.remove(camino)
    if (camino.last() == destino) return camino
    combate.vecinas(camino.last()).forEach({ vecina =>
      if (!visitadas.contains(vecina) and sala.permitePasar(vecina)
        and !sala.actual().hayCajaEn(vecina) and !combate.hayEnemigoEn(vecina)
        and !combate.enemigosVivos().any({ enemigo => combate.distancia(vecina, enemigo.position()) < 2 })
        and vecina.x() >= 1 and vecina.x() <= 14 and vecina.y() >= 1 and vecina.y() <= 8) {
        visitadas.add(vecina)
        pendientes.add(camino + [vecina])
      }
    })
    return self.buscar(pendientes, visitadas, destino)
  }
  method pasoA(destino) {
    if (destino.x() < jugador.position().x()) jugador.moverIzquierda()
    else if (destino.x() > jugador.position().x()) jugador.moverDerecha()
    else if (destino.y() > jugador.position().y()) jugador.moverArriba()
    else jugador.moverAbajo()
    assert.equals(destino, jugador.position())
  }
  method usarEn(x, y) { self.caminarA(x, y) sala.interactuar() }
  method conectarCables() {
    ["1", "D", "2", "A", "3", "F", "4", "S"].forEach({ etiqueta => sala.presionarCable(etiqueta) })
  }
  method terminarAparicion() {
    const inicio = io.currentTime()
    (1..17).forEach({ instante => io.flushEvents(inicio + instante * 100) })
  }
  method ganarCombateOscuro() {
    jugador.moverIzquierda()
    jugador.moverIzquierda()
    self.atacar(1, "abajo")
    self.pasarTurno()
    jugador.moverDerecha()
    jugador.moverDerecha()
    jugador.moverAbajo()
    self.atacar(1, "abajo")
    self.pasarTurno()
    self.atacar(1, "abajo")
    jugador.moverIzquierda()
    jugador.moverIzquierda()
    jugador.moverIzquierda()
    self.pasarTurno()
    jugador.moverDerecha()
    jugador.moverDerecha()
    self.atacar(1, "derecha")
    assert.notThat(jugador.enCombate())
    assert.equals(2.5, jugador.vida())
  }
  method ganarCombateFinal() {
    (1..3).forEach({ paso => jugador.moverArriba() })
    self.pasarTurno()
    jugador.moverIzquierda()
    jugador.moverAbajo()
    self.atacar(1, "abajo")
    jugador.moverDerecha()
    self.pasarTurno()
    jugador.moverAbajo()
    self.atacar(1, "abajo")
    jugador.moverArriba()
    jugador.moverArriba()
    self.pasarTurno()
    self.atacar(1, "abajo")
    self.pasarTurno()
    self.atacar(1, "abajo")
    assert.notThat(jugador.enCombate())
  }
  method resolverCantera() {
    self.caminarA(7, 4)
    jugador.moverAbajo()
    jugador.moverDerecha()
    (1..3).forEach({ paso => jugador.moverArriba() })
    jugador.moverIzquierda()
    jugador.moverArriba()
    jugador.moverArriba()
    assert.equals(game.at(7, 8), jugador.position())
  }
  method pasarTurno() {
    jugador.pasarTurno()
    const inicio = io.currentTime()
    (1..45).forEach({ instante => io.flushEvents(inicio + instante * 100) })
    assert.that(jugador.estaVivo())
  }
  method atacar(numero, direccion) {
    jugador.seleccionarHabilidad(numero)
    jugador.atacar(direccion)
  }
}

