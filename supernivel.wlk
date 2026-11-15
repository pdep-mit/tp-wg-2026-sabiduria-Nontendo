import wollok.game.*
import sala.*
import personajes.*
import objetos.*
import obstaculos.*
import empuje.*
import panel.*
import oscuridad.*
import combate.*
import habilidades.*
import puzzle.*
import interfaz.*

// Las salas viven durante toda la partida: cambiar de mapa no recrea sus objetos.
class Decoracion {
  const property position
  const property sprite
  method image() = "supernivel/" + sprite + ".png"
}

class PuertaConectada {
  const property position
  const property direccion
  const property destino
  const property llegada
  const property condicion = { true }
  const property alAbrir = {}
  const property aviso = "La puerta esta cerrada."
  method abierta() = condicion.apply()
  method image() = "supernivel/puerta-" + direccion + (if (self.abierta()) "-abierta" else "") + ".png"
  method disponible() = true
  method bloqueaPaso(posicion) = position == posicion and !self.abierta()
  method interactuar(personaje) {
    if (self.abierta()) {
      alAbrir.apply()
      mazmorra.irA(destino, llegada)
    }
    else sala.informar(aviso)
  }
}

class AccionDeSala {
  const property position
  const property accion
  const property habilitada = { true }
  const property encendida = { false }
  const property etiqueta = "salida"
  method image() = "supernivel/boton-" + etiqueta + (if (encendida.apply()) "-on" else "") + ".png"
  method disponible() = habilitada.apply()
  method interactuar(personaje) { accion.apply() }
}

class CofreDeArmadura {
  const property position = game.at(7, 7)
  var property abierto = false
  const armadura = new ObjetoRecogible(nombre = "armadura lava", sprite = "supernivel/armadura.png", position = position)
  method image() = "supernivel/cofre" + (if (abierto) "-abierto" else "") + ".png"
  method disponible() = !abierto
  method bloqueaPaso(posicion) = position == posicion
  method interactuar(personaje) {
    if (!abierto) {
      if (personaje.consumir("llave 1")) {
        abierto = true
        personaje.guardar(armadura)
        sala.informar("Armadura equipada.")
      } else sala.informar("Cofre cerrado.")
    }
  }
}

class MedallonFinal inherits ObjetoUsable {
  const property habilitado
  override method disponible() = habilitado.apply() and super()
  override method alUsar(personaje) { sala.ganar() }
}

class SalaConectada inherits Sala {
  method identificador()
  method puertas() = []
  method solidos() = []
  method decoraciones() = []
  method recompensas() = []
  method acciones() = []
  method enemigosDeSala() = []
  method alEntrar() {}
  override method reiniciarCajas() { sala.informar("Esta sala no tiene cajas para reiniciar.") }
  override method requiereArco() = true
  override method fondo() = "supernivel/sala-" + self.identificador() + ".png"
  override method obstaculos() = self.solidos() + self.puertas()
  override method interactuables() = self.puertas() + self.acciones() + self.recompensas().filter({ objeto => objeto.disponible() })
  override method elementosDeEscena() = self.decoraciones() + self.solidos() + self.puertas() + self.acciones() + self.recompensas().filter({ objeto => objeto.disponible() })
  override method permitePasar(posicion) = !self.movimientoBloqueado()
    and ((posicion.x() >= 1 and posicion.x() <= 14 and posicion.y() >= 1 and posicion.y() <= 8)
      or self.puertas().any({ puerta => puerta.position() == posicion and puerta.abierta() }))
    and !self.obstaculos().any({ obstaculo => obstaculo.bloqueaPaso(posicion) })
  override method iniciar() {
    super()
    self.enemigosDeSala().filter({ enemigo => enemigo.estaVivo() }).forEach({ enemigo => enemigo.aparecer() })
    self.alEntrar()
    combate.comenzarEncuentro()
    interfaz.mostrar()
  }
  override method alMoverse() {
    const cruzadas = self.puertas().filter({ puerta => puerta.position() == jugador.position() and puerta.abierta() })
    if (!cruzadas.isEmpty()) cruzadas.first().interactuar(jugador)
  }
}

class SalaDelPuente inherits SalaConectada {
  const property caja = new Caja(position = game.at(9, 6))
  var property resuelto = false
  const placa = new Decoracion(position = game.at(4, 6), sprite = "placa")
  const conexiones = [
    new PuertaConectada(position = game.at(7, 9), direccion = "norte", destino = "1-1", llegada = game.at(7, 1), condicion = { resuelto }),
    new PuertaConectada(position = game.at(15, 4), direccion = "este", destino = "2-0", llegada = game.at(1, 4), condicion = { jugador.tiene("armadura lava") })
  ]
  override method identificador() = "1-0"
  override method mensajeInicial() = "1-0 | El puente"
  override method puertas() = conexiones
  override method decoraciones() = [placa, caja]
  method esSueloSeguro(posicion) = (posicion.x() == 7 and posicion.y() <= 4)
    or (posicion.x() >= 3 and posicion.x() <= 11 and posicion.y() >= 5)
  override method permitePasar(posicion) = super(posicion) and (jugador.tiene("armadura lava") or self.esSueloSeguro(posicion))
  override method hayCajaEn(posicion) = caja.position() == posicion
  override method puedeAvanzarA(destino, siguiente) {
    if (!self.permitePasar(destino)) return false
    if (self.hayCajaEn(destino)) {
      const empujable = self.permitePasar(siguiente) and !self.hayCajaEn(siguiente)
        and siguiente.x() >= 3 and siguiente.x() <= 11 and siguiente.y() >= 5 and siguiente.y() <= 8
      if (empujable) caja.position(siguiente)
      return empujable
    }
    return true
  }
  override method alMoverse() {
    if (!resuelto and caja.position() == placa.position()) {
      resuelto = true
      sala.informar("La puerta se abrio.")
    }
    super()
  }
  override method reiniciarCajas() {
    caja.position(game.at(9, 6))
    if (self.hayCajaEn(jugador.position())) jugador.position(game.at(7, 5))
    sala.informar("Caja repuesta. La puerta resuelta conserva su estado.")
  }
}

class PasilloReal inherits SalaConectada {
  const property cofre = new CofreDeArmadura()
  var property puertaLlaveAbierta = false
  const columnas = [game.at(4, 3), game.at(10, 3), game.at(4, 6), game.at(10, 6)].map({ posicion => new Columna(position = posicion) })
  const conexiones = [
    new PuertaConectada(position = game.at(7, 0), direccion = "sur", destino = "1-0", llegada = game.at(7, 8)),
    new PuertaConectada(position = game.at(0, 4), direccion = "oeste", destino = "0-1", llegada = game.at(14, 4)),
    new PuertaConectada(position = game.at(15, 4), direccion = "este", destino = "2-1", llegada = game.at(1, 4), condicion = { self.validarLlave2() }, alAbrir = { self.usarLlave2() })
  ]
  override method identificador() = "1-1"
  override method mensajeInicial() = "1-1 | Pasillo real"
  override method puertas() = conexiones
  override method solidos() = columnas + [cofre]
  override method acciones() = [cofre]
  override method elementosDeEscena() = self.decoraciones() + self.solidos() + self.puertas()
  method validarLlave2() = puertaLlaveAbierta or jugador.tiene("llave 2")
  method usarLlave2() {
    if (!puertaLlaveAbierta and jugador.consumir("llave 2")) puertaLlaveAbierta = true
  }
}

class Columna inherits Muro {
  override method image() = "supernivel/columna.png"
}

class SalaOscura inherits SalaConectada {
  const property panel = new PanelDeCables(position = game.at(7, 8), pares = [["1", "D"], ["2", "A"], ["3", "F"], ["4", "S"]], alResolver = { self.encenderLuz() })
  const velo = new VeloOscuro()
  var property luzEncendida = false
  var property salidaAbierta = false
  var property enemigosGenerados = false
  var property aparicionEnCurso = false
  var versionAparicion = 0
  const property llave = new ObjetoRecogible(nombre = "llave 1", sprite = "zelda/llave.png", position = game.at(7, 4))
  const restos = [game.at(3, 3), game.at(5, 6), game.at(10, 5), game.at(12, 2)].map({ posicion => new Decoracion(position = posicion, sprite = "slime-derretido") })
  const property slimes = restos.map({ resto => new Slime(position = resto.position(), identificador = "oscuro-" + resto.position().x() + "-" + resto.position().y()) })
  const property humos = restos.map({ resto => new HumoDeAparicion(position = resto.position()) })
  const boton = new AccionDeSala(position = game.at(2, 2), etiqueta = "A", habilitada = { luzEncendida and !aparicionEnCurso }, encendida = { salidaAbierta }, accion = { salidaAbierta = true sala.informar("La puerta se abrio.") })
  const conexiones = [new PuertaConectada(position = game.at(15, 4), direccion = "este", destino = "1-1", llegada = game.at(1, 4), condicion = { salidaAbierta })]
  override method identificador() = "0-1"
  override method mensajeInicial() = "0-1 | La sala oscura"
  override method puertas() = conexiones
  override method decoraciones() = (if (enemigosGenerados) [] else restos) + panel.elementosIniciales()
  override method acciones() = panel.interactuable() + (if (luzEncendida) [boton] else [])
  override method elementosDeEscena() = self.decoraciones() + self.puertas() + (if (luzEncendida) [boton] + self.recompensas().filter({ objeto => objeto.disponible() }) else [])
  override method recompensas() = if (luzEncendida) [llave] else []
  override method enemigosDeSala() = if (enemigosGenerados) slimes else []
  override method movimientoBloqueado() = panel.bloqueaMovimiento() or aparicionEnCurso
  override method modoInterfaz() = if (panel.bloqueaMovimiento()) "cables" else if (aparicionEnCurso) "aparicion" else "explorar"
  override method presionarCable(etiqueta) {
    if (panel.bloqueaMovimiento()) panel.presionar(etiqueta)
  }
  override method alEntrar() {
    if (!luzEncendida) game.addVisual(velo)
    else if (!enemigosGenerados) self.iniciarAparicion()
  }
  override method alSalir() {
    versionAparicion += 1
    aparicionEnCurso = false
  }
  method encenderLuz() {
    if (!luzEncendida) {
      luzEncendida = true
      game.removeVisual(velo)
      game.addVisual(boton)
      if (llave.disponible()) game.addVisual(llave)
      self.jugadorAlFrente()
      sala.informar("Luz restaurada.")
      self.iniciarAparicion()
    }
  }
  method aparicionVigente(version) = version == versionAparicion and mazmorra.salaActual() == self and self.enCurso()
  method iniciarAparicion() {
    if (!enemigosGenerados and !aparicionEnCurso) {
      aparicionEnCurso = true
      versionAparicion += 1
      const version = versionAparicion
      // Una pausa con vision completa, luego humo, materializacion y disipacion.
      game.schedule(650, { if (self.aparicionVigente(version)) self.mostrarHumo() })
      game.schedule(850, { if (self.aparicionVigente(version)) humos.forEach({ humo => humo.etapa(2) }) })
      game.schedule(1050, { if (self.aparicionVigente(version)) self.materializarSlimes() })
      game.schedule(1300, { if (self.aparicionVigente(version)) humos.forEach({ humo => humo.etapa(3) }) })
      game.schedule(1550, { if (self.aparicionVigente(version)) {
        humos.forEach({ humo => if (game.hasVisual(humo)) game.removeVisual(humo) })
        aparicionEnCurso = false
        combate.comenzarEncuentro()
      } })
    }
  }
  method mostrarHumo() {
    humos.forEach({ humo => humo.etapa(1) game.addVisual(humo) })
    self.jugadorAlFrente()
  }
  method materializarSlimes() {
    enemigosGenerados = true
    restos.forEach({ resto => if (game.hasVisual(resto)) game.removeVisual(resto) })
    slimes.forEach({ enemigo => enemigo.aparecer() })
    humos.forEach({ humo => game.removeVisual(humo) game.addVisual(humo) })
    self.jugadorAlFrente()
  }
}

class HumoDeAparicion {
  const property position
  var property etapa = 1
  method image() = "supernivel/humo-" + etapa + ".png"
}

class SalaDelArco inherits SalaConectada {
  const property arco = new ObjetoRecogible(nombre = "arco", sprite = "supernivel/arco.png", position = game.at(6, 5))
  const property llave = new ObjetoRecogible(nombre = "llave 2", sprite = "zelda/llave.png", position = game.at(9, 5))
  const conexiones = [new PuertaConectada(position = game.at(0, 4), direccion = "oeste", destino = "1-0", llegada = game.at(14, 4), condicion = { jugador.tiene("armadura lava") })]
  override method identificador() = "2-0"
  override method mensajeInicial() = "2-0 | El arsenal"
  override method puertas() = conexiones
  override method recompensas() = [arco, llave]
}

// La misma mecanica de secuencia del primer checkpoint, con etiquetas y orden configurables.
class SecuenciaDeSellos inherits SecuenciaOrdenada(orden = ["B", "A", "C"]) {
  const property alResolver = {}
  method presionar(etiqueta) {
    if (!self.resuelto()) {
      if (self.avanzar(etiqueta)) {
        if (self.resuelto()) alResolver.apply()
        else sala.informar("Sello activado.")
      } else {
        sala.informar("Los sellos se apagaron.")
      }
    }
  }
}

class SalaDeLaSecuencia inherits SalaConectada {
  const property secuencia = new SecuenciaDeSellos(alResolver = { sala.informar("La puerta se abrio.") })
  const botones = (0..2).map({ indice =>
    const etiqueta = ["A", "B", "C"].get(indice)
    return new AccionDeSala(position = game.at(4 + indice * 3, 5), etiqueta = etiqueta, encendida = { secuencia.activo(etiqueta) }, accion = { secuencia.presionar(etiqueta) })
  })
  const conexiones = [
    new PuertaConectada(position = game.at(0, 4), direccion = "oeste", destino = "1-1", llegada = game.at(14, 4)),
    new PuertaConectada(position = game.at(15, 4), direccion = "este", destino = "3-1", llegada = game.at(1, 4), condicion = { secuencia.resuelto() })
  ]
  override method identificador() = "2-1"
  override method mensajeInicial() = "2-1 | Los tres sellos"
  override method puertas() = conexiones
  override method acciones() = botones
}

class SalaDeLasCajas inherits SalaConectada {
  var property resuelto = false
  const property cajas = new PuzzleDePiedras()
  const suelo = [
    [1,4], [2,4], [3,4], [4,2], [5,2], [6,2], [7,2], [8,2], [9,2], [10,2],
    [6,3], [7,3], [8,3], [9,3], [10,3], [4,4], [5,4], [6,4], [7,4], [8,4], [10,4],
    [4,5], [8,5], [10,5], [5,6], [6,6], [7,6], [8,6], [9,6], [10,6], [5,7], [7,7], [8,7], [10,7], [7,8]
  ].map({ celda => game.at(celda.get(0), celda.get(1)) })
  const conexiones = [
    new PuertaConectada(position = game.at(0, 4), direccion = "oeste", destino = "2-1", llegada = game.at(14, 4)),
    new PuertaConectada(position = game.at(7, 9), direccion = "norte", destino = "pasaje", llegada = game.at(7, 1))
  ]
  override method identificador() = "3-1"
  override method mensajeInicial() = "3-1 | La cantera"
  override method puertas() = conexiones
  override method decoraciones() = cajas.elementos()
  override method permitePasar(posicion) = super(posicion) and (suelo.contains(posicion) or self.puertas().any({ puerta => puerta.position() == posicion }))
  override method hayCajaEn(posicion) = cajas.hayCajaEn(posicion)
  override method puedeAvanzarA(destino, siguiente) = cajas.intentarEmpujar(destino, siguiente, { posicion => self.permitePasar(posicion) and !combate.hayEnemigoEn(posicion) })
  override method alMoverse() {
    if (jugador.position() == game.at(7, 8)) resuelto = true
    super()
  }
  override method reiniciarCajas() {
    cajas.reiniciar()
    jugador.position(game.at(1, 4))
    sala.informar("Piedras repuestas.")
  }
}

class PasajeSuperior inherits SalaConectada {
  const conexiones = [
    new PuertaConectada(position = game.at(7, 0), direccion = "sur", destino = "3-1", llegada = game.at(7, 8)),
    new PuertaConectada(position = game.at(0, 5), direccion = "oeste", destino = "2-2", llegada = game.at(14, 5))
  ]
  override method identificador() = "pasaje"
  override method mensajeInicial() = "Pasaje superior"
  override method puertas() = conexiones
  override method permitePasar(posicion) = super(posicion) and ((posicion.x() == 7 and posicion.y() <= 5) or (posicion.y() == 5 and posicion.x() <= 7))
}

class SalaDelMedallon inherits SalaConectada {
  var property estadoFinal = "NO_INICIADA"
  const property guardianes = [
    new Slime(position = game.at(10, 6), identificador = "final-slime1", alMorir = { self.verificarGuardianes() }),
    new Slime(position = game.at(10, 3), identificador = "final-slime2", alMorir = { self.verificarGuardianes() }),
    new SlimeGuardian(position = game.at(4, 5), identificador = "final-slime3", alMorir = { self.verificarGuardianes() })
  ]
  const property medallon = new MedallonFinal(nombre = "medallon", sprite = "zelda/colgante.png", position = game.at(7, 5), habilitado = { estadoFinal == "MEDALLON_DISPONIBLE" })
  const pedestal = new Decoracion(position = game.at(7, 5), sprite = "pedestal")
  const conexiones = [new PuertaConectada(position = game.at(15, 5), direccion = "este", destino = "pasaje", llegada = game.at(1, 5), condicion = { estadoFinal == "MEDALLON_DISPONIBLE" })]
  override method identificador() = "2-2"
  override method mensajeInicial() = "2-2 | El santuario"
  override method puertas() = conexiones
  override method decoraciones() = [pedestal]
  override method recompensas() = [medallon]
  override method enemigosDeSala() = guardianes
  override method mensajeTrasCombate() = "El medallon aparecio."
  override method alEntrar() {
    if (estadoFinal == "NO_INICIADA") {
      estadoFinal = "COMBATE"
    }
  }
  method verificarGuardianes() {
    if (estadoFinal == "COMBATE" and guardianes.all({ enemigo => !enemigo.estaVivo() })) {
      estadoFinal = "MEDALLON_DISPONIBLE"
      game.addVisual(medallon)
      sala.informar("El medallon aparecio.")
    }
  }
  override method ganar() {
    if (estadoFinal == "MEDALLON_DISPONIBLE" and medallon.recogido()) {
      estadoFinal = "VICTORIA"
      super()
    }
  }
}
