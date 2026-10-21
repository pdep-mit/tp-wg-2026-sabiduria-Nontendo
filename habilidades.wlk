import combate.*

class Habilidad {
  const property nombre
  const property alcance
  const property danio

  method descripcion() = nombre + " | alcance: " + alcance + " | dano: " + danio

  method daniar(objetivo) {
    objetivo.recibirDanio(danio)
  }

  method encontrarObjetivo(atacante, orientacion, objetivos) {
    return self.buscarDesde(atacante.position(), orientacion, objetivos, alcance)
  }
  method buscarDesde(origen, orientacion, objetivos, restantes) {
    if (restantes > 0) {
      const posicion = combate.vecina(origen, orientacion)
      if (!combate.terrenoLibre(posicion)) return null
      const encontrados = objetivos.filter({ objetivo => objetivo.estaVivo() and objetivo.position() == posicion })
      if (!encontrados.isEmpty()) return encontrados.first()
      return self.buscarDesde(posicion, orientacion, objetivos, restantes - 1)
    }
    return null
  }

  method ejecutar(atacante, orientacion, objetivos) {
    const objetivo = self.encontrarObjetivo(atacante, orientacion, objetivos)
    if (objetivo == null) return false
    self.daniar(objetivo)
    return true
  }
}

class Fisico inherits Habilidad(nombre = "Golpe", alcance = 1, danio = 2) {}

class Distancia inherits Habilidad(nombre = "Disparo", alcance = 3, danio = 1) {}
