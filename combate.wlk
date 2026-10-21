import wollok.game.*
import personajes.*
import sala.*

// Cada participante conserva su estado. Este objeto solo coordina la lista.
object combate {
  const property participantes = []
  const enemigos = []
  var turnoActual = 0

  method activo() = !participantes.isEmpty()
  method participanteActual() = participantes.get(turnoActual)
  method enemigosVivos() = enemigos.filter({ enemigo => enemigo.estaVivo() })
  method registrar(enemigo) {
    if (!enemigos.contains(enemigo)) enemigos.add(enemigo)
  }

  method incorporar(enemigo) {
    self.registrar(enemigo)
    if (enemigo.estaVivo() and !participantes.contains(enemigo) and jugador.estaVivo() and sala.enCurso()) {
      const comenzando = !self.activo()
      if (comenzando) {
        participantes.add(jugador)
        jugador.entrarEnCombate()
        turnoActual = 0
      }
      participantes.add(enemigo)
      enemigo.entrarEnCombate()
      if (comenzando) {
        jugador.iniciarTurno()
        sala.informar("En combate! 1/2: habilidad, flecha: direccion, espacio: pasar.")
      }
    }
  }

  method avanzarTurno() {
    self.verificarFinal()
    if (self.activo()) {
      self.participanteActual().finalizarTurno()
      turnoActual = (turnoActual + 1) % participantes.size()
      self.saltarDerrotados()
      self.participanteActual().iniciarTurno()
      if (self.participanteActual().turnoAutomatico()) {
        self.participanteActual().jugarTurno()
      }
    }
  }

  method saltarDerrotados() {
    if (!self.participanteActual().estaVivo()) {
      turnoActual = (turnoActual + 1) % participantes.size()
      self.saltarDerrotados()
    }
  }

  method verificarFinal() {
    if (self.activo()) {
      if (!jugador.estaVivo()) self.finalizar()
      else if (!participantes.any({ participante => participante.turnoAutomatico() and participante.estaVivo() })) {
        self.finalizar()
        sala.informar("Combate terminado! Podes seguir explorando.")
      }
    }
  }

  method finalizar() {
    participantes.forEach({ participante => participante.salirDelCombate() })
    participantes.clear()
    turnoActual = 0
  }
  method reiniciar() {
    self.finalizar()
    enemigos.clear()
  }

  method distancia(primera, segunda) = (primera.x() - segunda.x()).abs() + (primera.y() - segunda.y()).abs()
  method vecina(posicion, orientacion) {
    if (orientacion == "arriba") return posicion.up(1)
    if (orientacion == "abajo") return posicion.down(1)
    if (orientacion == "izquierda") return posicion.left(1)
    return posicion.right(1)
  }
  method vecinas(posicion) = [posicion.left(1), posicion.right(1), posicion.up(1), posicion.down(1)]
  method terrenoLibre(posicion) = sala.permitePasar(posicion) and !sala.actual().hayCajaEn(posicion)
  method hayEnemigoEn(posicion) = self.enemigosVivos().any({ enemigo => enemigo.position() == posicion })
  method libreParaEnemigo(posicion) = self.terrenoLibre(posicion) and posicion != jugador.position() and !self.hayEnemigoEn(posicion)

  // Busca por anchura un camino hasta una casilla al lado del jugador.
  method caminoAlJugador(origen) {
    const pendientes = [[origen]]
    const visitadas = [origen]
    return self.buscarCamino(pendientes, visitadas, origen)
  }
  method buscarCamino(pendientes, visitadas, origen) {
    if (!pendientes.isEmpty()) {
      const camino = pendientes.first()
      pendientes.remove(camino)
      const ultima = camino.last()
      if (self.distancia(ultima, jugador.position()) == 1) return camino
      self.vecinas(ultima).forEach({ vecina =>
        if (!visitadas.contains(vecina) and self.libreParaEnemigo(vecina)) {
          visitadas.add(vecina)
          pendientes.add(camino + [vecina])
        }
      })
      return self.buscarCamino(pendientes, visitadas, origen)
    }
    return [origen]
  }
}

object vistaCombate {
  method position() = game.at(7.5, 9.8)
  method textColor() = "FFFFFF"
  method text() {
    if (!jugador.enCombate()) return ""
    return "EN COMBATE | " + (if (jugador.enEspera()) "Turno enemigo" else "Tu turno")
      + " | Pasos: " + jugador.pasosRestantes()
      + " | Vida: " + jugador.vida()
      + " | Ataque: " + (if (jugador.ataqueDisponible()) "disponible" else "usado")
      + "\n1: " + jugador.habilidades().get(0).descripcion()
      + "\n2: " + jugador.habilidades().get(1).descripcion()
      + "\n" + (if (jugador.habilidadSeleccionada() == null) "Flechas: mover | Espacio: pasar" else "Elegi direccion con una flecha")
  }
}
