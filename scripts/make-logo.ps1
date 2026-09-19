<#
.SYNOPSIS
    Genera las variantes del logotipo de MaquilisTech en SVG (carpeta img/).

.DESCRIPCION
    Recrea el logotipo del Manual de Marca (árbol de maquilishuat con circuitos) y produce:
      logo-principal.svg        isotipo + nombre + tagline (a color, para fondos oscuros)
      logo-sin-tagline.svg      isotipo + nombre (espacios reducidos)
      isotipo.svg               solo el árbol (avatar de redes, marca de agua)
      logo-mono-positivo.svg    una sola tinta negra (fondos claros, impresión)
      logo-mono-negativo.svg    una sola tinta blanca (fondos oscuros)
      favicon.svg               isotipo sobre cuadrado azul marino
    Todas tienen fondo transparente. Las letras se convierten a trazos vectoriales
    (Montserrat Bold Italic y Montserrat Medium, licencia OFL), por lo que se ven igual
    sin necesidad de tener la fuente instalada.

.USO
    powershell -ExecutionPolicy Bypass -File scripts\make-logo.ps1

.NOTAS
    Es una recreación del logotipo original (img/logo.jpg), no el archivo de diseño.
    Requiere Windows (usa las bibliotecas de texto de WPF) y conexión a Internet
    la primera vez, para descargar las fuentes a la carpeta temporal.
#>

[Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
Add-Type -AssemblyName PresentationCore, WindowsBase

$out = Join-Path (Split-Path $PSScriptRoot -Parent) "img"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$fontDir = Join-Path $env:TEMP "mt-fonts"
New-Item -ItemType Directory -Force -Path $fontDir | Out-Null

function Get-FontFile($name) {
    $f = Join-Path $fontDir $name
    if (-not (Test-Path $f)) {
        Invoke-WebRequest "https://raw.githubusercontent.com/JulietaUla/Montserrat/master/fonts/ttf/$name" -OutFile $f -UseBasicParsing
    }
    $f
}

function N($v) { [math]::Round([double]$v, 2) }

# ---------- Texto -> trazos SVG ----------
function GeoToPath($geo, $dx, $dy) {
    $pg = [System.Windows.Media.PathGeometry]::CreateFromGeometry($geo)
    $sb = New-Object System.Text.StringBuilder
    foreach ($fig in $pg.Figures) {
        [void]$sb.Append("M$(N ($fig.StartPoint.X + $dx)) $(N ($fig.StartPoint.Y + $dy))")
        foreach ($seg in $fig.Segments) {
            $pts = @()
            switch ($seg.GetType().Name) {
                'LineSegment' { [void]$sb.Append("L$(N ($seg.Point.X + $dx)) $(N ($seg.Point.Y + $dy))") }
                'PolyLineSegment' { foreach ($p in $seg.Points) { [void]$sb.Append("L$(N ($p.X + $dx)) $(N ($p.Y + $dy))") } }
                'BezierSegment' { [void]$sb.Append("C$(N ($seg.Point1.X + $dx)) $(N ($seg.Point1.Y + $dy)) $(N ($seg.Point2.X + $dx)) $(N ($seg.Point2.Y + $dy)) $(N ($seg.Point3.X + $dx)) $(N ($seg.Point3.Y + $dy))") }
                'PolyBezierSegment' {
                    $p = $seg.Points
                    for ($i = 0; $i + 2 -lt $p.Count; $i += 3) { [void]$sb.Append("C$(N ($p[$i].X + $dx)) $(N ($p[$i].Y + $dy)) $(N ($p[$i + 1].X + $dx)) $(N ($p[$i + 1].Y + $dy)) $(N ($p[$i + 2].X + $dx)) $(N ($p[$i + 2].Y + $dy))") }
                }
                'QuadraticBezierSegment' { [void]$sb.Append("Q$(N ($seg.Point1.X + $dx)) $(N ($seg.Point1.Y + $dy)) $(N ($seg.Point2.X + $dx)) $(N ($seg.Point2.Y + $dy))") }
                'PolyQuadraticBezierSegment' {
                    $p = $seg.Points
                    for ($i = 0; $i + 1 -lt $p.Count; $i += 2) { [void]$sb.Append("Q$(N ($p[$i].X + $dx)) $(N ($p[$i].Y + $dy)) $(N ($p[$i + 1].X + $dx)) $(N ($p[$i + 1].Y + $dy))") }
                }
            }
        }
        if ($fig.IsClosed) { [void]$sb.Append("Z") }
    }
    $sb.ToString()
}

# Devuelve el path del texto centrado en $cx con la línea base en $baseY, y su ancho
function TextPath($text, $fontFile, $size, $spacing, $cx, $baseY) {
    $gt = New-Object System.Windows.Media.GlyphTypeface((New-Object System.Uri($fontFile)))
    $glyphs = @(); $total = 0
    foreach ($ch in $text.ToCharArray()) {
        $gi = [uint16]$gt.CharacterToGlyphMap[[int][char]$ch]
        $adv = $gt.AdvanceWidths[$gi] * $size
        $glyphs += , @($gi, $adv); $total += $adv + $spacing
    }
    $total -= $spacing
    $x = $cx - $total / 2; $d = ""
    foreach ($g in $glyphs) {
        $geo = $gt.GetGlyphOutline($g[0], $size, $size)
        if ($geo -ne $null -and -not $geo.IsEmpty()) { $d += GeoToPath $geo $x $baseY }
        $x += $g[1] + $spacing
    }
    $d
}

# ---------- Árbol simétrico de circuitos ----------
$script:tree = ""; $script:flow = ""; $script:li = 0; $script:mi = 0
$script:bb = @(9999, 9999, -9999, -9999)
function Upd($x, $y, $pad) {
    if ($x - $pad -lt $script:bb[0]) { $script:bb[0] = $x - $pad }
    if ($y - $pad -lt $script:bb[1]) { $script:bb[1] = $y - $pad }
    if ($x + $pad -gt $script:bb[2]) { $script:bb[2] = $x + $pad }
    if ($y + $pad -gt $script:bb[3]) { $script:bb[3] = $y + $pad }
}
function RingPath($cx, $cy, $r, $ri, $fill) {
    "<path fill-rule=`"evenodd`" fill=`"$fill`" d=`"M$(N ($cx - $r)) ${cy}a$r,$r 0 1,0 $(N (2 * $r)),0a$r,$r 0 1,0 -$(N (2 * $r)),0ZM$(N ($cx - $ri)) ${cy}a$ri,$ri 0 1,0 $(N (2 * $ri)),0a$ri,$ri 0 1,0 -$(N (2 * $ri)),0Z`"/>"
}
$script:lens = @(94, 70, 52, 40)
$script:spread = @(38, 32, 28, 25)
function Branch($x, $y, $ang, $lvl, $mono, $c) {
    $len = $script:lens[$lvl]
    $rad = $ang * [math]::PI / 180
    $x2 = [math]::Round($x + [math]::Sin($rad) * $len, 2); $y2 = [math]::Round($y - [math]::Cos($rad) * $len, 2)
    $sw = @(5.2, 4, 3, 2.4)[$lvl]
    $lineCol = if ($mono) { $c } else { "#D9788E" }
    $script:tree += "<line x1=`"$(N $x)`" y1=`"$(N $y)`" x2=`"$x2`" y2=`"$y2`" stroke=`"$lineCol`" stroke-width=`"$sw`" stroke-linecap=`"round`"/>"
    if ($lvl -eq 3) {
        # Puntas de las ramas: flores rosadas grandes, flores naranja y hojas
        $k = $script:li % 4; $script:li++
        if ($k -eq 0 -or $k -eq 2) {
            $fc = if ($mono) { $c } else { "#EE6C93" }
            $script:flow += RingPath $x2 $y2 15.5 6 $fc; Upd $x2 $y2 15.5
        } elseif ($k -eq 1) {
            $fc = if ($mono) { $c } else { "#E65A34" }
            $script:flow += RingPath $x2 $y2 11.5 4 $fc; Upd $x2 $y2 11.5
        } else {
            $fc = if ($mono) { $c } else { "#E8663F" }
            $script:flow += "<ellipse cx=`"$x2`" cy=`"$y2`" rx=`"6.5`" ry=`"13`" transform=`"rotate($([int]$ang) $x2 $y2)`" fill=`"$fc`"/>"; Upd $x2 $y2 13
        }
        return
    }
    if ($lvl -eq 2) {
        # Nudos intermedios: alternan hoja y flor naranja para llenar la copa
        $m = $script:mi % 2; $script:mi++
        $fc = if ($mono) { $c } else { "#E8663F" }
        if ($m -eq 0) {
            $script:flow += "<ellipse cx=`"$x2`" cy=`"$y2`" rx=`"5.5`" ry=`"11`" transform=`"rotate($([int]($ang + 50)) $x2 $y2)`" fill=`"$fc`"/>"; Upd $x2 $y2 11
        } else {
            $script:flow += RingPath $x2 $y2 9 3.2 $fc; Upd $x2 $y2 9
        }
    }
    $nc = if ($mono) { $c } else { "#F59AB0" }
    $script:tree += "<circle cx=`"$x2`" cy=`"$y2`" r=`"3.8`" fill=`"$nc`"/>"
    $a = $script:spread[$lvl + 1]
    Branch $x2 $y2 ($ang - $a) ($lvl + 1) $mono $c
    if ($lvl -le 0) { Branch $x2 $y2 $ang ($lvl + 1) $mono $c }
    Branch $x2 $y2 ($ang + $a) ($lvl + 1) $mono $c
}

# Devuelve el árbol completo (copa + tronco + base) y calcula su caja en $script:bb
function BuildTree($mono, $c) {
    $script:tree = ""; $script:flow = ""; $script:li = 0; $script:mi = 0; $script:bb = @(9999, 9999, -9999, -9999)
    $topY = 322
    Branch 250 $topY (-36) 0 $mono $c
    Branch 250 $topY 0 0 $mono $c
    Branch 250 $topY 36 0 $mono $c
    $t1 = if ($mono) { $c } else { "#8C5A34" }
    $t2 = if ($mono) { $c } else { "#A46A3E" }
    $trunk = "<path d=`"M226 432C232 402 240 352 244 316L256 316C260 352 268 402 274 432Z`" fill=`"$t1`"/>"
    if (-not $mono) { $trunk += "<path d=`"M250 316L256 316C260 352 268 402 274 432L250 432Z`" fill=`"$t2`"/>" }
    $trunk += "<rect x=`"168`" y=`"430`" width=`"164`" height=`"7`" rx=`"3.5`" fill=`"$t1`"/>"
    Upd 168 437 0; Upd 332 437 0; Upd 226 432 0
    $trunk + $script:tree + $script:flow
}

function Svg($vb, $body) { "<svg xmlns=`"http://www.w3.org/2000/svg`" viewBox=`"$vb`">$body</svg>" }
function Save($name, $svg) { [IO.File]::WriteAllText("$out\$name", $svg, $utf8); "{0}  {1} KB" -f $name, [math]::Round((Get-Item "$out\$name").Length / 1KB, 1) }

$fBold = Get-FontFile "Montserrat-BoldItalic.ttf"
$fMed = Get-FontFile "Montserrat-Medium.ttf"

function Wordmark($fill, $baseY) { "<path fill=`"$fill`" d=`"$(TextPath 'MaquilisTech' $fBold 58 0 250 $baseY)`"/>" }
function Tagline($fill, $baseY) { "<path fill=`"$fill`" d=`"$(TextPath 'HARVESTING INNOVATION' $fMed 14.5 2.7 250 $baseY)`"/>" }

# ---- Color ----
$tree = BuildTree $false ""
$bb = $script:bb
$vbIso = "$(N ($bb[0] - 10)) $(N ($bb[1] - 10)) $(N ($bb[2] - $bb[0] + 20)) $(N ($bb[3] - $bb[1] + 20))"
$word = Wordmark "#C16678" 512
$tag = Tagline "#A991B8" 552
$top = N ($bb[1] - 14)
Save "logo-principal.svg" (Svg "0 $top 500 $(N (572 - $top))" ($tree + $word + $tag))
Save "logo-sin-tagline.svg" (Svg "0 $top 500 $(N (530 - $top))" ($tree + $word))
Save "isotipo.svg" (Svg $vbIso $tree)

# ---- Monocromáticas ----
foreach ($v in @(@("positivo", "#000000"), @("negativo", "#FFFFFF"))) {
    $t = BuildTree $true $v[1]
    $w = Wordmark $v[1] 512; $g = Tagline $v[1] 552
    Save "logo-mono-$($v[0]).svg" (Svg "0 $top 500 $(N (572 - $top))" ($t + $w + $g))
}

# ---- Favicon: isotipo sobre cuadrado azul marino ----
$w = $bb[2] - $bb[0]; $h = $bb[3] - $bb[1]
$s = [math]::Round(50 / [math]::Max($w, $h), 4)
$tx = N (32 - ($bb[0] + $w / 2) * $s); $ty = N (32 - ($bb[1] + $h / 2) * $s)
Save "favicon.svg" (Svg "0 0 64 64" "<rect width=`"64`" height=`"64`" rx=`"14`" fill=`"#12143A`"/><g transform=`"translate($tx $ty) scale($s)`">$tree</g>")
