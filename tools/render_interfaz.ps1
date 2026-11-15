$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$raizProyecto = Split-Path $PSScriptRoot -Parent
$carpetaQA = Join-Path $raizProyecto 'log/qa-interfaz'
New-Item -ItemType Directory -Path $carpetaQA -Force | Out-Null
$salidaMotor = & wollok run tools.qa_interfaz.VistaInterfaz --skipValidations -p $raizProyecto
if ($LASTEXITCODE -ne 0) { throw 'No se pudo exportar el estado visual de Wollok.' }
$salidaMotor | Set-Content -LiteralPath (Join-Path $carpetaQA 'estado.txt') -Encoding utf8
$imagen = $null
$lienzo = $null
$nombre = ''
$fuenteTexto = [System.Drawing.Font]::new('Arial',12,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
$formatoTexto = [System.Drawing.StringFormat]::new()
$formatoTexto.Alignment = [System.Drawing.StringAlignment]::Center
$formatoTexto.LineAlignment = [System.Drawing.StringAlignment]::Center
$cultura = [System.Globalization.CultureInfo]::InvariantCulture

function GuardarEscena() {
  if ($null -ne $imagen) {
    $imagen.Save((Join-Path $carpetaQA ($nombre+'.png')),[System.Drawing.Imaging.ImageFormat]::Png)
    $lienzo.Dispose()
    $imagen.Dispose()
  }
}

foreach ($linea in $salidaMotor) {
  $partes = ([string]$linea) -split '\|',5
  if ($partes[0] -eq 'ESCENA') {
    GuardarEscena
    $nombre = $partes[1]
    $imagen = [System.Drawing.Bitmap]::new(768,576)
    $lienzo = [System.Drawing.Graphics]::FromImage($imagen)
    $lienzo.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $lienzo.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $fondo = [System.Drawing.Image]::FromFile((Join-Path $raizProyecto ('assets/'+$partes[2])))
    $lienzo.DrawImageUnscaled($fondo,0,0)
    $fondo.Dispose()
  } elseif ($partes[0] -eq 'IMAGEN') {
    $x = [single]::Parse($partes[1],$cultura)*48
    $y = 576 - [single]::Parse($partes[2],$cultura)*48
    $sprite = [System.Drawing.Image]::FromFile((Join-Path $raizProyecto ('assets/'+$partes[3])))
    $lienzo.DrawImageUnscaled($sprite,[int]$x,[int]($y-$sprite.Height))
    $sprite.Dispose()
  } elseif ($partes[0] -eq 'TEXTO' -and $partes[4]) {
    $x = [single]::Parse($partes[1],$cultura)*48 + 24
    $y = 576 - [single]::Parse($partes[2],$cultura)*48 - 24
    $color = [System.Drawing.ColorTranslator]::FromHtml('#'+$partes[3])
    $pincel = [System.Drawing.SolidBrush]::new($color)
    $renglones = $partes[4].Split('~')
    for ($i=0; $i -lt $renglones.Count; $i++) {
      $lineaY = $y + ($i - ($renglones.Count-1)/2)*15
      $lienzo.DrawString($renglones[$i],$fuenteTexto,$pincel,[single]$x,[single]$lineaY,$formatoTexto)
    }
    $pincel.Dispose()
  }
}
GuardarEscena
$fuenteTexto.Dispose(); $formatoTexto.Dispose()
Write-Output 'Composiciones del estado real exportadas en log/qa-interfaz.'
