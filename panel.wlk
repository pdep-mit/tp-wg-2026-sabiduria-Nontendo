import wollok.game.*
import sala.*
import interfaz.*

class PanelDeCables {
  const property position
  const property pares
  const property alResolver
  const marca = new MarcaPanel(position = position, alActivar = { self.activar() })
  const telon = new TelonNegro(position = game.at(1, 1))
  const tablero = new TableroPanel(position = game.at(1.5, 1.5))
  const nodos = ["1", "2", "3", "4", "A", "S", "D", "F"].map({ etiqueta => new NodoCable(etiqueta = etiqueta, position = self.posicionNodo(etiqueta), panel = self) })
  var conectados = []
  var seleccionActual = null
  var activo = false

  method posicionNodo(etiqueta) {
    if (etiqueta == "1") return game.at(6.19, 5.84)
    if (etiqueta == "2") return game.at(6.99, 5.84)
    if (etiqueta == "3") return game.at(7.89, 5.84)
    if (etiqueta == "4") return game.at(8.75, 5.84)
    if (etiqueta == "A") return game.at(6.19, 3.51)
    if (etiqueta == "S") return game.at(6.99, 3.51)
    if (etiqueta == "D") return game.at(7.89, 3.51)
    return game.at(8.75, 3.51)
  }

  method elementosIniciales() = if (self.resuelto()) [] else [marca]
  method interactuable() = if (!activo and !self.resuelto()) [marca] else []
  method bloqueaMovimiento() = activo and !self.resuelto()

  method resuelto() = conectados.size() == pares.size()
  method estaConectado(etiqueta) = conectados.any({ par => par.contains(etiqueta) })
  method mismoPar(par, combinacion) =
    (par.get(0) == combinacion.get(0) and par.get(1) == combinacion.get(1))
    or (par.get(0) == combinacion.get(1) and par.get(1) == combinacion.get(0))

  method activar() {
    activo = true
    game.removeVisual(marca)
    game.addVisual(telon)
    game.addVisual(tablero)
    nodos.forEach({ nodo => game.addVisual(nodo) })
    sala.informar("Panel de cables.")
    interfaz.mostrar()
  }

  method ocultar() {
    nodos.forEach({ nodo => game.removeVisual(nodo) })
    game.removeVisual(tablero)
    game.removeVisual(telon)
  }

  method presionar(etiqueta) {
    if (!self.resuelto() and !self.estaConectado(etiqueta)) {
      if (seleccionActual == null) {
        seleccionActual = etiqueta
      } else if (seleccionActual == etiqueta) {
        sala.informar("Ya tenes ese cable seleccionado.")
      } else {
        const combinacion = [seleccionActual, etiqueta]
        if (pares.any({ par => self.mismoPar(par, combinacion) })) {
          conectados.add(combinacion)
          if (self.resuelto()) {
            sala.informar("Luz restaurada! Se ve el resto de la sala.")
            self.ocultar()
            alResolver.apply()
          } else {
            sala.informar("Cable conectado! " + conectados.size() + "/" + pares.size())
          }
        } else {
          sala.informar("Esos cables no van juntos.")
        }
        seleccionActual = null
      }
    }
  }
}

class NodoCable {
  const property etiqueta
  const property position
  const property panel
  method image() = "zelda/cable-" + etiqueta + (if (panel.estaConectado(etiqueta)) "-on" else "") + ".png"
}

class MarcaPanel {
  const property position
  const property alActivar
  method image() = "zelda/panel-pared.png"
  method disponible() = true
  method interactuar(personaje) { alActivar.apply() }
}

class TableroPanel {
  const property position
  method image() = "zelda/tablero-panel.png"
}

class TelonNegro {
  const property position
  method image() = "zelda/negro-total.png"
}
