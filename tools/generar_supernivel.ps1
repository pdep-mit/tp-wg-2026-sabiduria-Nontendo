$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$raizProyecto = Split-Path $PSScriptRoot -Parent
$salidaAssets = Join-Path $raizProyecto 'assets/supernivel'
New-Item -ItemType Directory -Path $salidaAssets -Force | Out-Null
function Color($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Rect($g, $hex, $x, $y, $w, $h) {
  $b = [System.Drawing.SolidBrush]::new((Color $hex))
  $g.FillRectangle($b, [int]$x, [int]$y, [int]$w, [int]$h)
  $b.Dispose()
}
function Line($g, $hex, $x1, $y1, $x2, $y2, $width = 2) {
  $p = [System.Drawing.Pen]::new((Color $hex), $width)
  $g.DrawLine($p, $x1, $y1, $x2, $y2)
  $p.Dispose()
}
function Label($g, $text, $hex, $x, $y, $size = 14) {
  $f = [System.Drawing.Font]::new('Consolas', $size, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $b = [System.Drawing.SolidBrush]::new((Color $hex))
  $g.DrawString($text, $f, $b, [single]$x, [single]$y)
  $b.Dispose(); $f.Dispose()
}
function Sprite($name, $paint) {
  $bmp = [System.Drawing.Bitmap]::new(48, 48)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  & $paint $g
  $bmp.Save((Join-Path $salidaAssets "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}
function Region($g, $imagen, $sx, $sy, $sw, $sh, $dx, $dy, $dw, $dh) {
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $destino = [System.Drawing.Rectangle]::new($dx, $dy, $dw, $dh)
  $g.DrawImage($imagen, $destino, $sx, $sy, $sw, $sh, [System.Drawing.GraphicsUnit]::Pixel)
}
$fuenteCorazones = [System.Drawing.Bitmap]::new((Join-Path $raizProyecto 'assets/fuentes/hearts.png'))
$fuenteTunicas = [System.Drawing.Bitmap]::new((Join-Path $raizProyecto 'assets/fuentes/link-sheet.png'))
$fuenteArmadura = [System.Drawing.Bitmap]::new((Join-Path $raizProyecto 'assets/fuentes/RedMail.png'))
$fuenteBotones = [System.Drawing.Bitmap]::new((Join-Path $raizProyecto 'assets/fuentes/misc.png'))
function BotonCircular($g, $activado, $texto) {
  $sx = if ($activado) { 16 } else { 0 }
  $boton = $fuenteBotones.Clone([System.Drawing.Rectangle]::new($sx, 0, 16, 16), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
      if (($x-7.5)*($x-7.5)+($y-7.5)*($y-7.5) -gt 38) { $boton.SetPixel($x,$y,[System.Drawing.Color]::Transparent) }
    }
  }
  Region $g $boton 0 0 16 16 0 0 48 48
  $boton.Dispose()
  if ($texto) { Label $g $texto '#fff2d0' 18 14 17 }
}
function Floor($g, $x, $y) {
  $variante = ([int]($x/48) * 19 + [int]($y/48) * 31) % 11
  Rect $g '#333b4b' $x $y 48 48
  $tonoPiso = if ($variante -eq 0) { '#3b4657' } elseif ($variante -eq 5) { '#485162' } else { '#414b5b' }
  Rect $g $tonoPiso ($x + 2) ($y + 2) 44 44
  Line $g '#4c5766' ($x + 4) ($y + 4) ($x + 42) ($y + 4) 1
  Line $g '#29323e' $x ($y + 47) ($x + 47) ($y + 47) 2
  if ($variante -eq 2) {
    Line $g '#242d3a' ($x+12) ($y+8) ($x+20) ($y+18) 2
    Line $g '#242d3a' ($x+20) ($y+18) ($x+16) ($y+29) 2
    Line $g '#242d3a' ($x+16) ($y+29) ($x+29) ($y+38) 2
    Line $g '#242d3a' ($x+20) ($y+18) ($x+33) ($y+16) 2
    Line $g '#617084' ($x+18) ($y+30) ($x+29) ($y+39) 1
  } elseif ($variante -eq 7) {
    Line $g '#29313f' ($x+34) ($y+8) ($x+28) ($y+19) 2
    Line $g '#29313f' ($x+28) ($y+19) ($x+33) ($y+30) 2
    Line $g '#29313f' ($x+28) ($y+19) ($x+14) ($y+22) 2
    Line $g '#617084' ($x+15) ($y+23) ($x+24) ($y+21) 1
  } elseif ($variante -eq 9) {
    Line $g '#29313f' ($x+10) ($y+36) ($x+20) ($y+29) 2
    Line $g '#29313f' ($x+20) ($y+29) ($x+28) ($y+33) 2
    Line $g '#29313f' ($x+20) ($y+29) ($x+22) ($y+21) 2
  } elseif ($variante -in @(3,6)) {
    Rect $g '#313c4b' ($x+9) ($y+32) 7 3
    Rect $g '#556174' ($x+11) ($y+35) 5 2
    Rect $g '#354052' ($x+31) ($y+11) 3 4
  }
}
function Wall($g, $x, $y) {
  Rect $g '#171e2b' $x $y 48 48
  foreach ($dy in @(2, 18, 34)) {
    Rect $g '#586378' ($x + 2) ($y + $dy) 44 12
    Line $g '#8290a1' ($x + 3) ($y + $dy) ($x + 44) ($y + $dy) 2
    $dx = if ($dy -eq 18) { 12 } else { 30 }
    Line $g '#242f40' ($x + $dx) ($y + $dy) ($x + $dx) ($y + $dy + 12) 3
  }
}
function Lava($g, $x, $y) {
  Rect $g '#8d231d' $x $y 48 48
  Rect $g '#c43c20' ($x + 3) ($y + 3) 42 42
  foreach ($dy in @(9, 29)) {
    Line $g '#fa9c35' ($x + 2) ($y + $dy) ($x + 18) ($y + $dy + 4) 4
    Line $g '#ffd57a' ($x + 18) ($y + $dy + 4) ($x + 31) ($y + $dy - 2) 3
    Line $g '#ef6828' ($x + 31) ($y + $dy - 2) ($x + 47) ($y + $dy + 3) 4
  }
}

# Arte propio, generado en la misma cuadricula exacta que las colisiones.
$sueloCantera = [System.Collections.Generic.HashSet[string]]::new()
@('1,4','2,4','3,4','4,2','5,2','6,2','7,2','8,2','9,2','10,2',
  '6,3','7,3','8,3','9,3','10,3','4,4','5,4','6,4','7,4','8,4','10,4',
  '4,5','8,5','10,5','5,6','6,6','7,6','8,6','9,6','10,6','5,7','7,7','8,7','10,7','7,8') |
  ForEach-Object { $sueloCantera.Add($_) | Out-Null }
foreach ($id in @('1-0', '1-1', '0-1', '2-0', '2-1', '3-1', 'pasaje', '2-2')) {
  $bmp = [System.Drawing.Bitmap]::new(768, 576)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear((Color '#111722'))
  for ($y = 0; $y -le 9; $y++) {
    for ($x = 0; $x -le 15; $x++) {
      $px = $x * 48; $py = (11 - $y) * 48
      $borde = $x -eq 0 -or $x -eq 15 -or $y -eq 0 -or $y -eq 9
      if ($borde) { Wall $g $px $py; continue }
      if ($id -eq '3-1' -and !$sueloCantera.Contains("$x,$y")) { Wall $g $px $py; continue }
      if ($id -eq 'pasaje' -and !(($x -eq 7 -and $y -le 5) -or ($y -eq 5 -and $x -le 7))) {
        Wall $g $px $py; continue
      }
      if ($id -eq '1-0') {
        $seguro = ($x -eq 7 -and $y -le 4) -or ($x -ge 3 -and $x -le 11 -and $y -ge 5)
        if (!$seguro) { Lava $g $px $py; continue }
        if ($y -le 4) {
          Rect $g '#50392f' $px $py 48 48
          foreach ($dy in @(0, 12, 24, 36)) {
            Rect $g '#9b744a' ($px + 4) ($py + $dy + 1) 40 10
            Line $g '#d7b87a' ($px + 6) ($py + $dy + 2) ($px + 40) ($py + $dy + 2) 1
          }
          continue
        }
      }
      Floor $g $px $py
      if (($id -eq '1-1' -and $x -ge 6 -and $x -le 8) -or ($id -eq '2-2' -and $y -eq 5)) {
        Rect $g '#742b42' ($px + 1) $py 46 48
        if ($x -eq 6 -or $id -eq '2-2') { Line $g '#cea965' ($px + 4) $py ($px + 4) ($py + 48) 2 }
        if ($x -eq 8 -or $id -eq '2-2') { Line $g '#cea965' ($px + 44) $py ($px + 44) ($py + 48) 2 }
      }
    }
  }
  $bmp.Save((Join-Path $salidaAssets "sala-$id.png"), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

foreach ($direccion in @('norte', 'sur', 'este', 'oeste')) {
  foreach ($abierta in @($false, $true)) {
    $bmp = [System.Drawing.Bitmap]::new(48, 48)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    Floor $g 0 0
    Rect $g '#1c2431' 0 0 7 48
    Rect $g '#1c2431' 41 0 7 48
    Rect $g '#a49a7f' 2 0 7 48
    Rect $g '#a49a7f' 39 0 7 48
    Rect $g '#a49a7f' 2 0 44 6
    if (!$abierta) {
      Rect $g '#553e35' 9 6 30 42
      foreach ($x in @(12, 21, 30)) { Rect $g '#89613e' $x 7 6 40 }
      Rect $g '#b3a27a' 9 17 30 5
      Rect $g '#b3a27a' 9 35 30 5
      Rect $g '#f1c362' 29 24 5 6
    } else { Line $g '#7db7a1' 10 7 37 7 3 }
    $g.Dispose()
    if ($direccion -eq 'sur') { $bmp.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
    if ($direccion -eq 'este') { $bmp.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
    if ($direccion -eq 'oeste') { $bmp.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
    $sufijo = if ($abierta) { '-abierta' } else { '' }
    $bmp.Save((Join-Path $salidaAssets "puerta-$direccion$sufijo.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
  }
}

Sprite 'columna' {
  param($g)
  Rect $g '#202939' 6 42 38 5
  Rect $g '#737e8d' 10 4 28 38
  Rect $g '#b4b8ba' 13 8 5 32
  Rect $g '#969eaa' 22 8 5 32
  Rect $g '#525f71' 32 8 5 32
  Rect $g '#c4bea8' 5 2 38 7
  Rect $g '#c4bea8' 5 39 38 7
}
foreach ($abierto in @($false, $true)) {
  $sufijo = if ($abierto) { '-abierto' } else { '' }
  Sprite "cofre$sufijo" {
    param($g)
    Rect $g '#1a202b' 4 36 40 9
    Rect $g '#ae783d' 6 12 36 29
    Rect $g '#5d3f2c' 9 15 30 23
    Rect $g '#e6bd69' 6 25 36 5
    Rect $g '#e6bd69' 9 12 5 29
    Rect $g '#e6bd69' 34 12 5 29
    if ($abierto) { Rect $g '#171c29' 14 14 20 12; Rect $g '#b28b4f' 6 5 36 7 }
    else { Rect $g '#e6bd69' 21 24 7 11 }
  }
}
Sprite 'armadura' {
  param($g)
  Region $g $fuenteArmadura 0 0 $fuenteArmadura.Width $fuenteArmadura.Height 8 8 32 32
}
foreach ($direccion in @(@('derecha',0),@('arriba',24),@('izquierda',72),@('abajo',96))) {
  Sprite ('link-rojo-' + $direccion[0]) { param($g) Region $g $fuenteTunicas ([int]$direccion[1]) 48 24 24 0 0 48 48 }
}
Sprite 'arco' {
  param($g)
  Line $g '#e0c18a' 14 6 31 17 4
  Line $g '#e0c18a' 31 17 31 31 4
  Line $g '#e0c18a' 31 31 14 42 4
  Line $g '#eee5c9' 14 6 14 42 1
  Line $g '#c8d7da' 6 24 42 24 2
  Line $g '#c8d7da' 36 19 42 24 2
  Line $g '#c8d7da' 36 29 42 24 2
}
Sprite 'pedestal' {
  param($g)
  Rect $g '#242b3b' 2 34 44 11
  Rect $g '#a89f88' 5 29 38 11
  Rect $g '#6b7384' 9 18 30 15
  Rect $g '#cac1a3' 5 13 38 10
  Rect $g '#dfc276' 13 16 22 4
}
Sprite 'placa' {
  param($g)
  BotonCircular $g $false ''
}
Sprite 'slime-derretido' {
  param($g)
  Rect $g '#481c3a' 5 31 38 12
  Rect $g '#b93e60' 9 28 30 12
  Rect $g '#f47d8e' 14 30 9 3
  Rect $g '#481c3a' 26 34 4 3
}
Sprite 'piedra' {
  param($g)
  Rect $g '#232634' 3 7 42 37
  Rect $g '#6c7180' 6 4 36 35
  Rect $g '#8e929e' 9 7 30 26
  Rect $g '#b7b5b4' 12 7 21 4
  Rect $g '#525767' 9 33 30 6
  Line $g '#626775' 16 16 21 22 3
  Line $g '#626775' 21 22 18 30 3
  Line $g '#626775' 21 22 31 24 3
}

foreach ($cuartos in 0..4) {
  Sprite "corazon-$cuartos" {
    param($g)
    $sx = if ($cuartos -eq 4) { 0 } elseif ($cuartos -eq 2) { 8 } else { 16 }
    Region $g $fuenteCorazones $sx 0 8 8 8 8 32 32
    if ($cuartos -in @(1,3)) {
      # Fracciones de cuarto: se combinan los mismos pixeles de lleno y vacio.
      $g.SetClip([System.Drawing.Rectangle]::new(8,8,($cuartos*8),32))
      Region $g $fuenteCorazones 0 0 8 8 8 8 32 32
      $g.ResetClip()
    }
  }
}
foreach ($etapa in 1..3) {
  Sprite "humo-$etapa" {
    param($g)
    $alpha = if ($etapa -eq 3) { 100 } else { 220 }
    $pincel = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($alpha, 221, 215, 229))
    $oscuro = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($alpha, 147, 143, 171))
    $radio = if ($etapa -eq 1) { 14 } else { 21 }
    $g.FillEllipse($oscuro, (24-$radio), (25-$radio), ($radio*2), ($radio*2))
    $g.FillEllipse($pincel, (16-$radio/2), (17-$radio/2), $radio, $radio)
    $g.FillEllipse($pincel, (30-$radio/2), (24-$radio/2), $radio, $radio)
    $g.FillEllipse($pincel, (20-$radio/2), (33-$radio/2), $radio, $radio)
    $pincel.Dispose(); $oscuro.Dispose()
  }
}
foreach ($etiqueta in @('A', 'B', 'C', 'salida', '1', '2', '3')) {
  foreach ($encendido in @($false, $true)) {
    $sufijo = if ($encendido) { '-on' } else { '' }
    Sprite "boton-$etiqueta$sufijo" {
      param($g)
      $texto = if ($etiqueta -eq 'salida') { '>' } else { $etiqueta }
      BotonCircular $g $encendido $texto
    }
    if ($etiqueta -in @('1','2','3')) { Copy-Item -LiteralPath (Join-Path $salidaAssets "boton-$etiqueta$sufijo.png") -Destination (Join-Path $raizProyecto "assets/zelda/boton-$etiqueta$sufijo.png") }
  }
}
Sprite 'slime-guardian' {
  param($g)
  $slime = [System.Drawing.Bitmap]::new((Join-Path $raizProyecto 'assets/zelda/enemigo.png'))
  Region $g $slime 0 0 48 48 0 0 48 48
  $slime.Dispose()
  Rect $g '#70462e' 12 3 24 9
  Rect $g '#f6d46e' 15 3 4 7
  Rect $g '#f6d46e' 23 0 4 10
  Rect $g '#f6d46e' 31 3 4 7
  Rect $g '#c39342' 15 8 20 4
  Rect $g '#fcf2be' 23 9 4 3
}

# Pantalla opaca de victoria del mismo tamano que el tablero completo.
$pantallaVictoria = [System.Drawing.Bitmap]::new(768,576)
$gVictoria = [System.Drawing.Graphics]::FromImage($pantallaVictoria)
$gVictoria.Clear((Color '#111423'))
Rect $gVictoria '#222238' 24 24 720 528
Rect $gVictoria '#bd9954' 28 28 712 520
Rect $gVictoria '#111423' 31 31 706 514
foreach ($estrella in @(@(100,112),@(190,330),@(655,155),@(590,390),@(130,450),@(638,470),@(210,100),@(560,94))) {
  Rect $gVictoria '#c9ac6d' $estrella[0] $estrella[1] 3 9
  Rect $gVictoria '#c9ac6d' ($estrella[0]-3) ($estrella[1]+3) 9 3
}
$pincelOro = [System.Drawing.SolidBrush]::new((Color '#efd27e'))
foreach ($triangulo in @(@(384,76),@(354,124),@(414,124))) {
  $puntos = [System.Drawing.Point[]]@([System.Drawing.Point]::new($triangulo[0],$triangulo[1]),[System.Drawing.Point]::new($triangulo[0]-27,$triangulo[1]+45),[System.Drawing.Point]::new($triangulo[0]+27,$triangulo[1]+45))
  $gVictoria.FillPolygon($pincelOro,$puntos)
}
$pincelOro.Dispose()
function TextoCentradoVictoria($texto,$y,$tamano,$color) {
  $fuente = [System.Drawing.Font]::new('Consolas',$tamano,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
  $pincel = [System.Drawing.SolidBrush]::new((Color $color))
  $formato = [System.Drawing.StringFormat]::new()
  $formato.Alignment = [System.Drawing.StringAlignment]::Center
  $gVictoria.DrawString($texto,$fuente,$pincel,[single]384,[single]$y,$formato)
  $fuente.Dispose(); $pincel.Dispose(); $formato.Dispose()
}
TextoCentradoVictoria 'VICTORIA' 196 48 '#f6df9c'
TextoCentradoVictoria 'LA LEYENDA DE CELDA' 252 15 '#b8b3c2'
$fuenteVictoria = [System.Drawing.Bitmap]::new((Join-Path $raizProyecto 'assets/fuentes/victory-tunic.png'))
Region $gVictoria $fuenteVictoria 0 48 24 24 336 295 96 96
$fuenteVictoria.Dispose()
TextoCentradoVictoria 'El medallon vuelve a brillar.' 426 20 '#e7dcc3'
TextoCentradoVictoria 'R  /  NUEVA PARTIDA' 491 16 '#a7bcb0'
$pantallaVictoria.Save((Join-Path $salidaAssets 'victoria.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$gVictoria.Dispose(); $pantallaVictoria.Dispose()

function ImagenUI($nombre, $ancho, $alto, $pintar) {
  $imagen = [System.Drawing.Bitmap]::new($ancho,$alto)
  $lienzo = [System.Drawing.Graphics]::FromImage($imagen)
  & $pintar $lienzo
  $imagen.Save((Join-Path $salidaAssets "$nombre.png"),[System.Drawing.Imaging.ImageFormat]::Png)
  $lienzo.Dispose(); $imagen.Dispose()
}
ImagenUI 'hud' 768 96 {
  param($g)
  Rect $g '#0d1520' 0 0 768 96
  Rect $g '#304254' 12 4 132 40
  Rect $g '#17222e' 13 5 130 38
  Rect $g '#304254' 156 2 288 44
  Rect $g '#17222e' 157 3 286 42
  Rect $g '#304254' 452 4 304 40
  Rect $g '#17222e' 453 5 302 38
  Line $g '#576a79' 12 48 756 48 1
  Line $g '#9d8860' 0 95 768 95 2
}
foreach ($numeroAccion in 1..3) {
  foreach ($estadoAccion in @('explorar','cables','aparicion','disponible','seleccionado','usado','bloqueado','espera','urgente')) {
    ImagenUI "accion-$numeroAccion-$estadoAccion" 240 44 {
      param($g)
      $borde = if ($estadoAccion -eq 'seleccionado') { '#f4d586' } elseif ($estadoAccion -eq 'urgente') { '#edaa69' } else { '#475a6b' }
      $fondo = if ($estadoAccion -eq 'seleccionado') { '#3c3528' } elseif ($estadoAccion -eq 'urgente') { '#483024' } else { '#182633' }
      $texto = if ($estadoAccion -in @('usado','bloqueado','espera')) { '#788895' } else { '#f4e6c6' }
      Rect $g $borde 0 0 240 44
      Rect $g $fondo 2 2 236 40
      $titulo = switch ($numeroAccion) { 1 { '[1] GOLPE' }; 2 { '[2] ARCO' }; 3 { '[ESPACIO] FIN DE TURNO' } }
      $detalle = switch ($numeroAccion) { 1 { '2 dano | 1 casilla' }; 2 { '1 dano | 3 casillas' }; 3 { 'Ceder turno a los enemigos' } }
      if ($estadoAccion -eq 'cables') {
        $titulo = switch ($numeroAccion) { 1 { '[1] [2] [3] [4]' }; 2 { '[A] [S] [D] [F]' }; 3 { 'CONECTAR CABLES' } }
        $detalle = switch ($numeroAccion) { 1 { 'Cables superiores' }; 2 { 'Cables inferiores' }; 3 { 'Pulsa las teclas de dos extremos' } }
      } elseif ($estadoAccion -eq 'aparicion') {
        $titulo = 'ESPERA UN MOMENTO'
        $detalle = 'Los slimes se estan materializando'
      } elseif ($estadoAccion -eq 'explorar') {
        $titulo = switch ($numeroAccion) { 1 { '[FLECHAS] MOVER' }; 2 { '[E] INTERACTUAR' }; 3 { '[T] REPONER  [R] REINICIAR' } }
        $detalle = switch ($numeroAccion) { 1 { 'Explora la sala' }; 2 { 'Recoger, activar o cruzar' }; 3 { 'Piedras / Partida nueva' } }
      } elseif ($estadoAccion -eq 'seleccionado') { $detalle = 'FLECHA: atacar | ESC: cancelar' }
      elseif ($estadoAccion -eq 'usado') { $detalle = 'Ataque ya usado este turno' }
      elseif ($estadoAccion -eq 'bloqueado') { $detalle = 'Arco no equipado' }
      elseif ($estadoAccion -eq 'espera') { $detalle = 'Espera: turno del enemigo' }
      elseif ($estadoAccion -eq 'urgente') { $detalle = 'Sin acciones. Termina tu turno.' }
      Label $g $titulo $texto 12 5 13
      Label $g $detalle $texto 12 24 11
    }
  }
}
foreach ($tipoMarca in @('alcance-ataque','objetivo-ataque','turno-enemigo')) {
  Sprite $tipoMarca {
    param($g)
    $tono = if ($tipoMarca -eq 'alcance-ataque') { '#8fcea7' } elseif ($tipoMarca -eq 'objetivo-ataque') { '#ff9a87' } else { '#f4b95d' }
    $colorMarca = Color $tono
    $pincel = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(38,$colorMarca.R,$colorMarca.G,$colorMarca.B))
    $g.FillRectangle($pincel,2,2,44,44)
    $pincel.Dispose()
    foreach ($esquina in @(@(3,3,1,1),@(44,3,-1,1),@(3,44,1,-1),@(44,44,-1,-1))) {
      Line $g $tono $esquina[0] $esquina[1] ($esquina[0]+9*$esquina[2]) $esquina[1] 2
      Line $g $tono $esquina[0] $esquina[1] $esquina[0] ($esquina[1]+9*$esquina[3]) 2
    }
  }
}
foreach ($segmentosVida in 0..8) {
  ImagenUI "vida-enemigo-$segmentosVida" 40 8 {
    param($g)
    Rect $g '#141b25' 0 0 40 8
    Rect $g '#b0ad97' 1 1 38 6
    Rect $g '#323841' 2 2 36 4
    $tonoVida = if ($segmentosVida -le 2) { '#e5817c' } elseif ($segmentosVida -le 4) { '#e8c374' } else { '#7bc6a0' }
    Rect $g $tonoVida 2 2 ([int][Math]::Ceiling(36*$segmentosVida/8)) 4
  }
}
$fuenteCorazones.Dispose(); $fuenteTunicas.Dispose(); $fuenteArmadura.Dispose(); $fuenteBotones.Dispose()
Write-Output 'Fondos y sprites del supernivel generados.'
