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
  const posicionPanel = game.at(2, 7)
  const marcaPanel = new MarcaPanel(position = posicionPanel, alActivar = { self.activarPanel() })
  const panel = new PanelDeCables(pares = [["1", "D"], ["2", "A"], ["3", "F"], ["4", "S"]], alResolver = { self.revelarResto() })
  const nodosNumericos = [
    new NodoCable(etiqueta = "1", position = game.at(6.19, 5.84), panel = panel),
    new NodoCable(etiqueta = "2", position = game.at(6.99, 5.84), panel = panel),
    new NodoCable(etiqueta = "3", position = game.at(7.89, 5.84), panel = panel),
    new NodoCable(etiqueta = "4", position = game.at(8.75, 5.84), panel = panel)
  ]
  const nodosLetra = [
    new NodoCable(etiqueta = "A", position = game.at(6.19, 3.51), panel = panel),
    new NodoCable(etiqueta = "S", position = game.at(6.99, 3.51), panel = panel),
    new NodoCable(etiqueta = "D", position = game.at(7.89, 3.51), panel = panel),
    new NodoCable(etiqueta = "F", position = game.at(8.75, 3.51), panel = panel)
  ]
  const escudo = new Escudo(nombre = "escudo", sprite = "zelda/escudo.png", position = game.at(12, 3))
  const cajas = [new Caja(position = game.at(5, 3)), new Caja(position = game.at(10, 3))]
  const losas = [
    new Losa(position = game.at(5, 2), ocupantes = cajas, resuelta = { self.salidaYaAbierta() }),
    new Losa(position = game.at(10, 2), ocupantes = cajas, resuelta = { self.salidaYaAbierta() }),
    new Losa(position = game.at(7, 4), ocupantes = cajas, resuelta = { self.salidaYaAbierta() })
  ]
  const salida = new Salida(position = game.at(14, 8), condicion = { self.salidaYaAbierta() }, alCruzar = { sala.ganar() })
  const sombras = (1..14).flatMap({ x => (1..8).map({ y => new Sombra(position = game.at(x, y)) }) })
  const telonNegro = new TelonNegro(position = game.at(1, 1))
  const tableroPanel = new TableroPanel(position = game.at(1.5, 1.5))
  var panelActivo = false
  var restoVisible = false
  var salidaDesbloqueada = false

  override method mensajeInicial() = "Sala del apagon | Esta oscuro. Se ve algo en la pared, acercate."
  override method fondo() = "zelda/sala2.png"
  override method obstaculos() = [salida]
  override method interactuables() = [salida] + (if (!panelActivo) [marcaPanel] else []) + (if (restoVisible) [escudo] else [])
  override method elementosDeEscena() = [salida, marcaPanel] + sombras
  override method movimientoBloqueado() = panelActivo and !panel.resuelto()
  override method presionarCable(etiqueta) { panel.presionar(etiqueta) }
  override method alMoverse() {
    if (restoVisible and !salidaDesbloqueada and self.losasResueltas()) {
      salidaDesbloqueada = true
      salida.actualizarEstado()
      sala.informar("Las tres losas estan pisadas! La salida se abrio permanentemente.")
    }
  }
  override method puedeAvanzarA(destino, siguiente) {
    const cajaEnDestino = cajas.filter({ caja => caja.position() == destino })
    if (cajaEnDestino.isEmpty()) {
      return self.permitePasar(destino)
    }
    if (self.permitePasar(siguiente) and self.posicionValidaParaCaja(siguiente) and cajas.filter({ caja => caja.position() == siguiente }).isEmpty()) {
      cajaEnDestino.first().position(siguiente)
      return true
    }
    return false
  }
  method posicionValidaParaCaja(posicion) = posicion.x() >= 2 and posicion.x() <= 13 and posicion.y() >= 2 and posicion.y() <= 7
  method losasResueltas() = losas.all({ losa => losa.presionada() })
  method salidaYaAbierta() = salidaDesbloqueada
  method activarPanel() {
    panelActivo = true
    game.removeVisual(marcaPanel)
    game.addVisual(telonNegro)
    game.addVisual(tableroPanel)
    (nodosNumericos + nodosLetra).forEach({ nodo => game.addVisual(nodo) })
    sala.informar("Panel encontrado! Conecta cada numero con su letra (1234 y ASDF).")
  }
  method revelarResto() {
    restoVisible = true
    (nodosNumericos + nodosLetra).forEach({ nodo => game.removeVisual(nodo) })
    game.removeVisual(tableroPanel)
    game.removeVisual(telonNegro)
    sombras.forEach({ sombra => game.removeVisual(sombra) })
    game.addVisual(escudo)
    (losas + cajas).forEach({ elemento => game.addVisual(elemento) })
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