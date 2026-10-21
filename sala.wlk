import wollok.game.*
import personajes.*
import obstaculos.*
import objetos.*
import puzzle.*
import panel.*
import empuje.*
import oscuridad.*

class Sala {
  var estado = "jugando"
  var property mensaje = ""

  method mensajeInicial()
  method fondo()
  method obstaculos()
  method interactuables()
  method elementosDeEscena()
  method registrarColisiones() {}
  method prepararEstadoGlobal() {}
  method presionarCable(etiqueta) {}
  method alMoverse() {}
  method movimientoBloqueado() = false

  method enCurso() = estado == "jugando"
  method permitePasar(posicion) =
    !self.movimientoBloqueado()
    and posicion.x() >= 1 and posicion.x() <= 14 and posicion.y() >= 1 and posicion.y() <= 8
    and !self.obstaculos().any({ obstaculo => obstaculo.bloqueaPaso(posicion) })
  method puedeAvanzarA(destino, siguiente) = self.permitePasar(destino)
  method interactuar() {
    if (self.enCurso()) {
      const cercanos = self.interactuables().filter({ objeto => objeto.disponible() and objeto.position().distance(jugador.position()) <= 1 })
      if (cercanos.isEmpty()) self.informar("Acercate a algo interactuable y pulsa E.")
      else cercanos.min({ objeto => objeto.position().distance(jugador.position()) }).interactuar(jugador)
    }
  }
  method informar(texto) { mensaje = texto }
  method ganar() {
    estado = "ganado"
    self.informar("GANASTE! R para volver a jugar.")
  }
  method perder() {
    estado = "perdido"
    self.informar("SIN VIDA! R para reiniciar la demo.")
  }
  method iniciar() {
    game.boardGround(self.fondo())
    self.prepararEstadoGlobal()
    estado = "jugando"
    mensaje = self.mensajeInicial()
    self.elementosDeEscena().forEach({ elemento => game.addVisual(elemento) })
    [jugador, cartelEstado, cartelVida, cartelInventario].forEach({ visual => game.addVisual(visual) })
    self.registrarColisiones()
  }
}

class SalaDeLosTresSellos inherits Sala {
  const llave = new ObjetoRecogible(nombre = "llave", sprite = "zelda/llave.png", position = game.at(12, 5))
  const recuerdo = new ObjetoRecogible(nombre = "colgante", sprite = "zelda/colgante.png", position = game.at(4, 2))
  const muros = (1..8).filter({ y => y != 4 }).map({ y => new Muro(position = game.at(10, y)) })
  const pinchos = [new Pincho(position = game.at(6, 2)), new Pincho(position = game.at(7, 2))]
  const salida = new Salida(position = game.at(14, 8), condicion = { jugador.tiene("llave") }, alCruzar = { mazmorra.avanzar() })
  var llaveVisible = false

  override method mensajeInicial() = "Sala de los tres sellos | Activa 1 > 2 > 3"
  override method fondo() = "zelda/sala.png"
  override method prepararEstadoGlobal() {
    puzzle.reiniciar()
    antorcha.encendida(false)
    barrera.abierta(false)
  }
  override method obstaculos() = muros + [barrera, antorcha, salida]
  override method interactuables() = puzzle.botones() + [recuerdo, salida] + (if (llaveVisible) [llave] else [])
  override method elementosDeEscena() = muros + pinchos + puzzle.botones() + [barrera, antorcha, salida, recuerdo]
  override method registrarColisiones() {
    pinchos.forEach({ pincho => game.onCollideDo(pincho, { elemento => pincho.chocarCon(elemento) }) })
  }
  method revelarLlave() {
    llaveVisible = true
    game.addVisual(llave)
  }
}

class SalaDelApagon inherits Sala {
  const panel = new PanelDeCables(position = game.at(2, 7), pares = [["1", "D"], ["2", "A"], ["3", "F"], ["4", "S"]], alResolver = { self.revelarResto() })
  const niebla = new Niebla()
  const puzzleDeCajas = new PuzzleDeCajas(resuelta = { self.salidaYaAbierta() })
  const escudo = new Escudo(nombre = "escudo", sprite = "zelda/escudo.png", position = game.at(12, 3))
  const salida = new Salida(position = game.at(14, 8), condicion = { self.salidaYaAbierta() }, alCruzar = { sala.ganar() })
  var restoVisible = false
  var salidaDesbloqueada = false

  override method mensajeInicial() = "Sala del apagon | Esta oscuro. Se ve algo en la pared, acercate."
  override method fondo() = "zelda/sala2.png"
  override method obstaculos() = [salida]
  override method interactuables() = [salida] + panel.interactuable() + (if (restoVisible) [escudo] else [])
  override method elementosDeEscena() = [salida] + panel.elementosIniciales() + niebla.elementos()
  override method movimientoBloqueado() = panel.bloqueaMovimiento()
  override method presionarCable(etiqueta) { panel.presionar(etiqueta) }
  override method alMoverse() {
    if (restoVisible and !salidaDesbloqueada and puzzleDeCajas.resuelto()) {
      salidaDesbloqueada = true
      salida.actualizarEstado()
      sala.informar("Las tres losas estan pisadas! La salida se abrio permanentemente.")
    }
  }
  override method puedeAvanzarA(destino, siguiente) =
    puzzleDeCajas.intentarEmpujar(destino, siguiente, { posicion => self.permitePasar(posicion) })

  method salidaYaAbierta() = salidaDesbloqueada
  method revelarResto() {
    restoVisible = true
    niebla.ocultar()
    game.addVisual(escudo)
    puzzleDeCajas.elementos().forEach({ elemento => game.addVisual(elemento) })
    game.removeVisual(jugador)
    game.addVisual(jugador)
    sala.informar("Luz restaurada. Empuja las cajas sobre dos losas y parate vos en la tercera.")
    self.activarEnemigo()
  }
  method activarEnemigo() {}
}

object mazmorra {
  var property salaActual = new SalaDeLosTresSellos()
  var alLimpiar = {}
  method configurarAlLimpiar(bloque) { alLimpiar = bloque }
  method reiniciarTodo() {
    game.clear()
    jugador.reiniciar()
    salaActual = new SalaDeLosTresSellos()
    salaActual.iniciar()
    alLimpiar.apply()
  }
  method avanzar() {
    game.clear()
    jugador.position(game.at(2, 2))
    salaActual = new SalaDelApagon()
    salaActual.iniciar()
    alLimpiar.apply()
  }
}

object sala {
  method actual() = mazmorra.salaActual()
  method enCurso() = self.actual().enCurso()
  method mensaje() = self.actual().mensaje()
  method informar(texto) { self.actual().informar(texto) }
  method permitePasar(posicion) = self.actual().permitePasar(posicion)
  method puedeAvanzarA(destino, siguiente) = self.actual().puedeAvanzarA(destino, siguiente)
  method interactuar() { self.actual().interactuar() }
  method presionarCable(etiqueta) { self.actual().presionarCable(etiqueta) }
  method alMoverse() { self.actual().alMoverse() }
  method ganar() { self.actual().ganar() }
  method perder() { self.actual().perder() }
  method iniciar() { self.actual().iniciar() }
  method revelarLlave() { self.actual().revelarLlave() }
}

object cartelEstado {
  method position() = game.at(7.5, 11)
  method text() = sala.mensaje()
  method textColor() = "F8E7B5"
}
object cartelVida {
  method position() = game.at(2, 10)
  method text() = "VIDA: " + jugador.vida() + " / 3"
  method textColor() = "FF9999"
}
object cartelInventario {
  method position() = game.at(9, 10)
  method text() = "INVENTARIO: " + jugador.inventarioTexto()
  method textColor() = "B8F0CA"
}