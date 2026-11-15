import wollok.game.*
import personajes.*
import sala.*
import interfaz.*

// Cada participante conserva su estado. Este objeto solo coordina la lista.
object combate {
  const property participantes = []
  const enemigos = []
  var turnoActual = 0
  var property ronda = 0
  var property ultimoEvento = ""
  var eventoDeTurno = false
  var property celdasExploradas = 0
  method anotar(texto) { ultimoEvento = texto eventoDeTurno = false }
  method anotarTurno(texto) { self.anotar(texto) eventoDeTurno = true }

  method activo() = !participantes.isEmpty()
  method participanteActual() = participantes.get(turnoActual)
  method enemigosVivos() = enemigos.filter({ enemigo => enemigo.estaVivo() })
  method registrar(enemigo) {
    if (!enemigos.contains(enemigo)) {
      enemigo.numeroDeEncuentro(enemigos.size() + 1)
      enemigo.registrarVidaMaxima()
      enemigos.add(enemigo)
    }
  }
  method comenzarEncuentro() {
    self.enemigosVivos().forEach({ enemigo => self.incorporar(enemigo) })
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
        ronda = 1
        jugador.iniciarTurno()
        self.anotar("Tres pasos y un ataque por turno.")
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
      if (!self.participanteActual().turnoAutomatico()) {
        ronda += 1
        if (eventoDeTurno) self.anotar("Tu turno: mover o atacar.")
      }
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
        sala.informar(sala.actual().mensajeTrasCombate())
      }
    }
  }

  method finalizar() {
    participantes.forEach({ participante => participante.salirDelCombate() })
    participantes.clear()
    turnoActual = 0
    ronda = 0
  }
  method reiniciar() {
    self.finalizar()
    enemigos.forEach({ enemigo => enemigo.ocultar() })
    enemigos.clear()
  }

  method distancia(primera, segunda) = (primera.x() - segunda.x()).abs() + (primera.y() - segunda.y()).abs()
  method vecina(posicion, orientacion) {
    return self.desplazar(posicion, orientacion, 1)
  }
  method desplazar(posicion, orientacion, pasos) {
    if (orientacion == "arriba") return posicion.up(pasos)
    if (orientacion == "abajo") return posicion.down(pasos)
    if (orientacion == "izquierda") return posicion.left(pasos)
    return posicion.right(pasos)
  }
  method alcanceVisible(direccion, distancia) = jugador.puedeActuarEnCombate()
    and jugador.ataqueDisponible()
    and jugador.habilidadSeleccionada() != null
    and distancia <= jugador.habilidadSeleccionada().alcance()
    and self.rayoLibre(jugador.position(), direccion, distancia)
  method rayoLibre(origen, direccion, restantes) {
    if (restantes == 0) return true
    const proxima = self.vecina(origen, direccion)
    if (!self.terrenoLibre(proxima)) return false
    if (restantes > 1 and self.hayEnemigoEn(proxima)) return false
    return self.rayoLibre(proxima, direccion, restantes - 1)
  }
  method vecinas(posicion) = [posicion.left(1), posicion.right(1), posicion.up(1), posicion.down(1)]
  method terrenoLibre(posicion) = sala.permitePasar(posicion) and !sala.actual().hayCajaEn(posicion)
  method hayEnemigoEn(posicion) = self.enemigosVivos().any({ enemigo => enemigo.position() == posicion })
  method libreParaEnemigo(posicion) = self.terrenoLibre(posicion) and posicion != jugador.position() and !self.hayEnemigoEn(posicion)

  // Primero prueba dos rutas rectas. Si otros slimes las tapan, A* evita
  // recorrer recursivamente toda la sala y conserva un padre por celda.
  method caminoAlJugador(origen) {
    celdasExploradas = 0
    const horizontal = self.caminoDirecto([origen], true)
    if (!horizontal.isEmpty()) return horizontal
    const vertical = self.caminoDirecto([origen], false)
    if (!vertical.isEmpty()) return vertical
    return self.buscarCamino(origen)
  }
  // Primero prueba los dos caminos de Manhattan sin obstaculos. En salas
  // abiertas evita explorar toda la grilla antes de animar cada turno.
  method caminoDirecto(camino, horizontalPrimero) {
    var ruta = camino
    var bloqueado = false
    const ocupadas = self.enemigosVivos().map({ enemigo => self.clave(enemigo.position()) })
    (1..self.distancia(camino.last(), jugador.position()).max(1)).forEach({ paso =>
      if (!bloqueado and self.distancia(ruta.last(), jugador.position()) > 1) {
        const ultima = ruta.last()
        const dx = jugador.position().x() - ultima.x()
        const dy = jugador.position().y() - ultima.y()
        const siguiente = if (dx != 0 and (horizontalPrimero or dy == 0))
          ultima.right(if (dx > 0) 1 else -1)
          else ultima.up(if (dy > 0) 1 else -1)
        if (self.libreParaRuta(siguiente, ocupadas)) ruta = ruta + [siguiente]
        else bloqueado = true
      }
    })
    return if (bloqueado) [] else ruta
  }
  method clave(posicion) = posicion.x() * 16 + posicion.y()
  method libreParaRuta(posicion, ocupadas) = self.terrenoLibre(posicion)
    and posicion != jugador.position() and !ocupadas.contains(self.clave(posicion))
  method buscarCamino(origen) {
    const pendientes = [origen]
    const cerradas = #{}
    const padres = new Dictionary()
    const costos = new Dictionary()
    const ocupadas = self.enemigosVivos().map({ enemigo => self.clave(enemigo.position()) })
    const iteraciones = 1..160
    if (!self.vecinas(jugador.position()).any({ vecina => self.libreParaRuta(vecina, ocupadas) })) return [origen]
    costos.put(self.clave(origen), 0)
    var llegada = null
    // La geometria tiene como maximo 16 x 10 celdas, incluidas las puertas.
    // Este limite tambien garantiza terminar si el jugador esta encerrado.
    iteraciones.forEach({ iteracion =>
      if (null == llegada and !pendientes.isEmpty()) {
        const actual = pendientes.min({ posicion =>
          const distancia = (self.distancia(posicion, jugador.position()) - 1).max(0)
          return (costos.get(self.clave(posicion)) + distancia) * 256 + distancia
        })
        pendientes.remove(actual)
        cerradas.add(self.clave(actual))
        celdasExploradas += 1
        if (self.distancia(actual, jugador.position()) <= 1) llegada = actual
        else self.vecinas(actual).forEach({ vecina =>
          const clave = self.clave(vecina)
          if (!cerradas.contains(clave) and self.libreParaRuta(vecina, ocupadas)) {
            const nuevoCosto = costos.get(self.clave(actual)) + 1
            if (!costos.containsKey(clave) or nuevoCosto < costos.get(clave)) {
              if (!costos.containsKey(clave)) pendientes.add(vecina)
              costos.put(clave, nuevoCosto)
              padres.put(clave, actual)
            }
          }
        })
      }
    })
    if (null == llegada) return [origen]
    var ruta = [llegada]
    var anterior = llegada
    iteraciones.forEach({ paso =>
      if (anterior != origen) {
        // get compara el valor con null; Position no admite esa comparacion.
        anterior = padres.basicGet(self.clave(anterior))
        ruta = [anterior] + ruta
      }
    })
    return ruta
  }
}

object vistaCombate {
  method position() = game.at(6, 11)
  method textColor() = if (jugador.enEspera()) "FFD095" else "C3EFCD"
  method text() {
    if (!jugador.enCombate()) return ""
    const titulo = if (jugador.enEspera()) "TURNO ENEMIGO" else "TU TURNO | Ronda " + combate.ronda()
    const recursos = if (jugador.enEspera()) combate.participanteActual().nombreCombate() + " esta actuando"
      else "Pasos: " + jugador.pasosRestantes() + "/3 | Ataque: " + (if (jugador.ataqueDisponible()) "LISTO" else "USADO")
    return titulo + "\n" + recursos + "\n" + interfaz.textoCorto(combate.ultimoEvento())
  }
}
