import wollok.game.*
import sala.*

class PanelDeCables {
  const property pares
  const property alResolver
  var conectados = []
  var seleccionActual = null

  method resuelto() = conectados.size() == pares.size()
  method estaConectado(etiqueta) = conectados.any({ par => par.contains(etiqueta) })
  method mismoPar(par, combinacion) =
    (par.get(0) == combinacion.get(0) and par.get(1) == combinacion.get(1))
    or (par.get(0) == combinacion.get(1) and par.get(1) == combinacion.get(0))
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