<#
.SYNOPSIS
    Optimiza las fotografías de img/originales/ y las deja listas para el sitio en img/.

.DESCRIPCION
    Toma cada original (JPG, PNG o WebP), lo reduce al ancho máximo indicado (nunca lo agranda),
    conserva su proporción y lo guarda como JPG con calidad 82. Los originales no se modifican.
    Para agregar una foto nueva, añade una línea a la tabla $mapa.

.USO
    powershell -ExecutionPolicy Bypass -File scripts\optimize-images.ps1
#>

Add-Type -AssemblyName System.Drawing, PresentationCore, WindowsBase

$root = Split-Path $PSScriptRoot -Parent
$src = Join-Path $root "img\originales"
$dst = Join-Path $root "img"
$calidad = 82

# Archivo original -> archivo final, ancho máximo en píxeles
$mapa = @(
    @{ Origen = "images.jpg"; Destino = "servicio-atencion.jpg"; Ancho = 800 }
    @{ Origen = "AdobeStock_1766476124.jpeg"; Destino = "servicio-automatizacion.jpg"; Ancho = 1000 }
    @{ Origen = "images (1).jpg"; Destino = "servicio-datos.jpg"; Ancho = 800 }
    @{ Origen = "images (2).jpg"; Destino = "servicio-consultoria.jpg"; Ancho = 800 }
    @{ Origen = "pngtree-team-of-programmers-working-late-at-night-in-a-modern-office-image_20426396.webp"; Destino = "home-equipo.jpg"; Ancho = 1000 }
    @{ Origen = "istockphoto-2160472791-640x640.jpg"; Destino = "nosotros-oficina.jpg"; Ancho = 900 }
)

function Open-Bitmap($path) {
    if ($path -like "*.webp") {
        # System.Drawing no lee WebP: se decodifica con WPF y se pasa por un PNG en memoria
        $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create((New-Object System.Uri($path)), 'None', 'OnLoad')
        $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
        $enc.Frames.Add($dec.Frames[0])
        $ms = New-Object System.IO.MemoryStream
        $enc.Save($ms); $ms.Position = 0
        return New-Object System.Drawing.Bitmap($ms)
    }
    $img = [System.Drawing.Image]::FromFile($path)
    $bmp = New-Object System.Drawing.Bitmap($img)
    $img.Dispose()
    return $bmp
}

$jpg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$params = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$calidad)

foreach ($m in $mapa) {
    $in = Join-Path $src $m.Origen
    if (-not (Test-Path $in)) { Write-Warning "No existe: $($m.Origen)"; continue }
    $bmp = Open-Bitmap $in
    $w = [math]::Min($bmp.Width, $m.Ancho)
    $h = [int][math]::Round($bmp.Height * $w / $bmp.Width)
    $out = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($out)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($bmp, 0, 0, $w, $h)
    $g.Dispose()
    $file = Join-Path $dst $m.Destino
    $out.Save($file, $jpg, $params)
    $out.Dispose(); $bmp.Dispose()
    "{0,-30} {1}x{2}  {3} KB" -f $m.Destino, $w, $h, [math]::Round((Get-Item $file).Length / 1KB)
}
