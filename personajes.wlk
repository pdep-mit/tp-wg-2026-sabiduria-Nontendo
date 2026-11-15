import wollok.game.*
import sala.*
import combate.*
import habilidades.*

class Inventario {
  const property objetos = []
  method tiene(nombre) = objetos.any({ objeto => objeto.nombre() == nombre })
  method agregar(objeto) { if (!self.tiene(objeto.nombre())) objetos.add(objeto) }
  method consumir(nombre) {
    const encontrados = objetos.filter({ objeto => objeto.nombre() == nombre })
    if (encontrados.isEmpty()) return false
    objetos.remove(encontrados.first())
    return true
  }
  method vaciar() { objetos.clear() }
  method texto() = if (objetos.isEmpty()) "vacio" else objetos.map({ objeto => objeto.nombre() }).join(" + ")
}

class Proteccion {
  var property activa = false
  var version = 0

  method activar() {
    activa = true
    version += 1
    const miVersion = version
    sala.informar("Escudo activado! Te protege del proximo golpe (dura 30s).")
    game.schedule(30000, { self.expirar(miVersion) })
  }
  method expirar(miVersion) {
    if (activa and version == miVersion) {
      activa = false
      sala.informar("El escudo se gasto por el tiempo.")
    }
  }
  method absorber() {
    if (activa) {
      activa = false
      sala.informar("El escudo absorbio el golpe!")
      return true
    }
    return false
  }
}

class Combatiente {
  var property vida = 3
  var property enCombate = false
  var property enEspera = false
  var property pasosRestantes = 0
  var property ataqueDisponible = false
  const property pasosPorTurno = 3
  var spriteVisible = true
  var versionParpadeo = 0

  method imagenVisible(sprite) = if (spriteVisible) sprite else "zelda/transparente.png"
  method restaurarSprite() {
    versionParpadeo += 1
    spriteVisible = true
  }
  method parpadear() {
    self.restaurarSprite()
    const version = versionParpadeo
    game.schedule(120, { self.mostrarSprite(false, version) })
    game.schedule(240, { self.mostrarSprite(true, version) })
    game.schedule(360, { self.mostrarSprite(false, version) })
    game.schedule(480, { self.mostrarSprite(true, version) })
  }
  method mostrarSprite(visible, version) {
    if (version == versionParpadeo) spriteVisible = visible
  }

  method estaVivo() = vida > 0
  method turnoAutomatico() = true
  method puedeActuarEnCombate() = enCombate and !enEspera and self.estaVivo()
  method entrarEnCombate() {
    if (!enCombate) {
      enCombate = true
      enEspera = true
    }
  }
  method iniciarTurno() {
    enEspera = false
    pasosRestantes = pasosPorTurno
    ataqueDisponible = true
  }
  method finalizarTurno() { enEspera = true }
  method salirDelCombate() {
    enCombate = false
    enEspera = false
    pasosRestantes = 0
    ataqueDisponible = false
  }
}

object jugador inherits Combatiente {
  var property position = game.at(2, 2)
  var direccion = "abajo"
  const inventario = new Inventario()
  const proteccion = new Proteccion()
  const property habilidades = [new Fisico(), new Distancia()]
  var property habilidadSeleccionada = null
  override method turnoAutomatico() = false

  method image() = self.imagenVisible((if (self.tiene("armadura lava")) "supernivel/link-rojo-" else "zelda/link-") + direccion + ".png")
  method moverArriba() { self.moverA(position.up(1), position.up(2), "arriba") }
  method moverAbajo() { self.moverA(position.down(1), position.down(2), "abajo") }
  method moverIzquierda() { self.moverA(position.left(1), position.left(2), "izquierda") }
  method moverDerecha() { self.moverA(position.right(1), position.right(2), "derecha") }

  method moverA(destino, siguiente, orientacion) {
    if (sala.enCurso() and (!enCombate or self.puedeActuarEnCombate())) {
      direccion = orientacion
      if (enCombate and habilidadSeleccionada != null) {
        self.atacar(orientacion)
      } else if (!enCombate or pasosRestantes > 0) {
        if (self.puedeMoverA(destino, siguiente)) {
          position = destino
          if (enCombate) pasosRestantes -= 1
          else sala.alMoverse()
        } else if (enCombate) sala.informar("Paso bloqueado.")
      } else sala.informar("Sin pasos. Ataca o pasa turno.")
    }
  }

  method puedeMoverA(destino, siguiente) {
    if (combate.hayEnemigoEn(destino)) return false
    if (enCombate) return combate.terrenoLibre(destino)
    return sala.puedeAvanzarA(destino, siguiente)
  }

  method seleccionarHabilidad(numero) {
    if (sala.enCurso() and self.puedeActuarEnCombate() and ataqueDisponible and numero >= 1 and numero <= habilidades.size()) {
      if (numero == 2 and sala.actual().requiereArco() and !self.tiene("arco")) {
        habilidadSeleccionada = null
        sala.informar("Arco no equipado.")
      } else {
        habilidadSeleccionada = habilidades.get(numero - 1)
        sala.informar("Flecha: atacar. ESC: cancelar.")
      }
    }
  }
  method atacar(orientacion) {
    if (self.puedeActuarEnCombate() and ataqueDisponible and habilidadSeleccionada != null) {
      const acerto = habilidadSeleccionada.ejecutar(self, orientacion, combate.enemigosVivos().filter({ enemigo => enemigo.enCombate() }))
      if (acerto) {
        habilidadSeleccionada = null
        ataqueDisponible = false
      } else sala.informar("Sin objetivo. Otra flecha o ESC.")
      combate.verificarFinal()
    }
  }
  method pasarTurno() {
    if (sala.enCurso() and self.puedeActuarEnCombate()) {
      habilidadSeleccionada = null
      combate.anotarTurno("Actuan los enemigos.")
      combate.avanzarTurno()
    }
  }
  method cancelarAtaque() {
    if (self.puedeActuarEnCombate() and habilidadSeleccionada != null) {
      habilidadSeleccionada = null
      sala.informar("Ataque cancelado.")
    }
  }
  override method salirDelCombate() {
    super()
    habilidadSeleccionada = null
  }
  method guardar(objeto) { inventario.agregar(objeto) }
  method tiene(nombre) = inventario.tiene(nombre)
  method inventarioTexto() = inventario.texto()
  method objetosInventario() = inventario.objetos()
  method consumir(nombre) = inventario.consumir(nombre)

  method activarEscudo() { proteccion.activar() }
  method recibirDanio(cantidad) {
    if (!proteccion.absorber()) {
      vida = (vida - cantidad).max(0)
      if (cantidad > 0) self.parpadear()
      if (vida == 0) {
        sala.perder()
        combate.verificarFinal()
      }
      else sala.informar("Recibiste -" + cantidad + " de salud.")
    }
  }
  method reiniciar() {
    self.restaurarSprite()
    combate.reiniciar()
    self.salirDelCombate()
    position = game.at(2, 2)
    vida = 3
    direccion = "abajo"
    inventario.vaciar()
    proteccion.activa(false)
  }
}

class Enemigo inherits Combatiente {
  var property position
  const property habilidad = new Fisico(nombre = "Mordida", danio = 0.5)
  var visible = false
  const property identificador = "enemigo"
  const property sprite = "zelda/enemigo.png"
  const property alMorir = {}
  const property milisegundosPorPaso = 220
  var property numeroDeEncuentro = 0
  var property vidaMaxima = 0
  const property barraVida = new BarraDeVidaEnemigo(enemigo = self)
  var versionMovimiento = 0

  method nombreCombate() = "Slime " + numeroDeEncuentro
  method registrarVidaMaxima() { if (vidaMaxima == 0) vidaMaxima = vida }
  method image() = self.imagenVisible(sprite)
  method aparecer() {
    if (self.estaVivo() and !visible) {
      visible = true
      combate.registrar(self)
      game.addVisual(self)
      game.addVisual(barraVida)
    }
  }
  method ocultar() {
    if (visible) {
      game.removeVisual(self)
      if (game.hasVisual(barraVida)) game.removeVisual(barraVida)
      visible = false
    }
    self.salirDelCombate()
  }
  method jugarTurno() {
    if (self.puedeActuarEnCombate()) {
      versionMovimiento += 1
      self.acercarseAlJugador()
    }
  }
  method acercarseAlJugador() {
    const camino = combate.caminoAlJugador(position)
    const pasos = pasosRestantes.min(camino.size() - 1)
    const version = versionMovimiento
    if (pasos > 0) {
      (1..pasos).forEach({ indice =>
        game.schedule(indice * milisegundosPorPaso, { self.darPaso(camino.get(indice), version) })
      })
    }
    game.schedule((pasos + 1) * milisegundosPorPaso, { self.completarTurno(version) })
  }
  method movimientoVigente(version) = version == versionMovimiento and enCombate and !enEspera
  method darPaso(destino, version) {
    if (self.movimientoVigente(version) and self.estaVivo() and pasosRestantes > 0 and combate.distancia(position, destino) == 1 and combate.libreParaEnemigo(destino)) {
      position = destino
      pasosRestantes -= 1
    }
  }
  method completarTurno(version) {
    if (self.movimientoVigente(version)) {
      self.atacarSiEstaAlLado()
      if (self.movimientoVigente(version)) combate.avanzarTurno()
    }
  }
  override method salirDelCombate() {
    versionMovimiento += 1
    super()
  }
  method atacarSiEstaAlLado() {
    if (self.puedeActuarEnCombate() and ataqueDisponible and combate.distancia(position, jugador.position()) == 1) {
      habilidad.daniar(jugador)
      ataqueDisponible = false
    }
  }
  method recibirDanio(cantidad) {
    if (self.estaVivo()) {
      self.registrarVidaMaxima()
      vida = (vida - cantidad).max(0)
      if (cantidad > 0 and enCombate) combate.anotar(self.nombreCombate() + " recibe -" + cantidad + ".")
      if (cantidad > 0 and self.estaVivo()) self.parpadear()
      if (!self.estaVivo() and visible) {
        game.removeVisual(self)
        if (game.hasVisual(barraVida)) game.removeVisual(barraVida)
        visible = false
      }
      if (!self.estaVivo()) alMorir.apply()
    }
  }
}

// Modelo comun; el guardian conserva su silueta y suma una corona visible.
class Slime inherits Enemigo(vida = 2, sprite = "zelda/enemigo.png") {}

class SlimeGuardian inherits Slime(vida = 4, pasosPorTurno = 5,
  habilidad = new Fisico(nombre = "Embestida", danio = 1),
  sprite = "supernivel/slime-guardian.png", milisegundosPorPaso = 160) {
  override method nombreCombate() = "Guardian"
}

class BarraDeVidaEnemigo {
  const property enemigo
  method position() = enemigo.position().up(1).right(0.083333)
  method segmentos() = ((enemigo.vida() / enemigo.vidaMaxima()) * 8).ceil().max(0).min(8)
  method image() = if (enemigo.enCombate() and enemigo.estaVivo()) "supernivel/vida-enemigo-" + self.segmentos() + ".png" else "zelda/transparente.png"
}
