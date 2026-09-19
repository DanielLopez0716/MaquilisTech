<#
.SYNOPSIS
    Genera las ilustraciones SVG del sitio MaquilisTech (carpeta img/).

.DESCRIPTION
    Crea 8 imágenes vectoriales con la paleta de marca (#12143A, #E0637A, #E65A34):
    banner-principal, atencion-cliente, automatizacion, analisis-datos,
    proceso-implementacion, blog-agente-ia, blog-automatizacion y blog-atencion-cliente.
    Son deterministas: cada ejecución produce los mismos archivos.

.USO
    Desde la carpeta del proyecto:   powershell -ExecutionPolicy Bypass -File scripts\make-images.ps1
    Para cambiar una imagen, edita su escena (buscar el comentario "# N. NOMBRE") y vuelve a ejecutar.

.NOTAS
    Las funciones auxiliares se llaman Rnd1, Gear, Tree, etc. No usar los nombres R ni Rd,
    porque en PowerShell son alias de otros comandos y la función nunca se ejecutaría.
#>

[Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$out = Join-Path (Split-Path $PSScriptRoot -Parent) "img"   # <proyecto>/img
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Rnd1($v) { [math]::Round([double]$v, 1) }
function Save($name, $svg) { [IO.File]::WriteAllText("$out\$name", $svg, $utf8); "{0}  {1} KB" -f $name, [math]::Round((Get-Item "$out\$name").Length / 1KB, 1) }

# ---------- Base: fondo, gradientes, cuadrícula de puntos, halo ----------
function Defs($w, $h, $gx, $gy) {
@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $w $h" width="$w" height="$h">
<defs>
<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#090A29"/><stop offset=".55" stop-color="#12143A"/><stop offset="1" stop-color="#262A72"/></linearGradient>
<linearGradient id="coral" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#F59AB0"/><stop offset=".5" stop-color="#E0637A"/><stop offset="1" stop-color="#E65A34"/></linearGradient>
<linearGradient id="coral2" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stop-color="#E65A34"/><stop offset="1" stop-color="#E0637A"/></linearGradient>
<linearGradient id="trunk" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#6E4326"/><stop offset=".5" stop-color="#A46A3E"/><stop offset="1" stop-color="#6E4326"/></linearGradient>
<linearGradient id="area" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E0637A" stop-opacity=".5"/><stop offset="1" stop-color="#E0637A" stop-opacity="0"/></linearGradient>
<radialGradient id="halo" cx="$gx" cy="$gy" r=".6"><stop offset="0" stop-color="#E0637A" stop-opacity=".32"/><stop offset="1" stop-color="#E0637A" stop-opacity="0"/></radialGradient>
<filter id="glow" x="-60%" y="-60%" width="220%" height="220%"><feGaussianBlur stdDeviation="5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
<pattern id="dots" width="28" height="28" patternUnits="userSpaceOnUse"><circle cx="2" cy="2" r="1.2" fill="#fff" fill-opacity=".08"/></pattern>
</defs>
<rect width="$w" height="$h" fill="url(#bg)"/>
<rect width="$w" height="$h" fill="url(#dots)"/>
<rect width="$w" height="$h" fill="url(#halo)"/>

"@
}

function Particles($w, $h, $n, $seed) {
    $rnd = New-Object System.Random $seed
    $s = ""
    for ($i = 0; $i -lt $n; $i++) {
        $x = Rnd1 ($rnd.NextDouble() * $w); $y = Rnd1 ($rnd.NextDouble() * $h)
        $r = Rnd1 (1 + $rnd.NextDouble() * 2.6); $o = Rnd1 (0.15 + $rnd.NextDouble() * 0.5)
        $c = if ($rnd.Next(0, 3) -eq 0) { "#E65A34" } else { "#F59AB0" }
        $s += "<circle cx=`"$x`" cy=`"$y`" r=`"$r`" fill=`"$c`" fill-opacity=`"$o`"/>`n"
    }
    $s
}

function Gear($cx, $cy, $r, $teeth, $rot, $fill, $hole) {
    $ri = $r * 0.8; $step = 2 * [math]::PI / ($teeth * 4); $pts = @()
    for ($i = 0; $i -lt $teeth * 4; $i++) {
        $a = $rot + $i * $step
        $rad = if (($i % 4) -lt 2) { $r } else { $ri }
        $pts += "$(Rnd1 ($cx + $rad * [math]::Cos($a))),$(Rnd1 ($cy + $rad * [math]::Sin($a)))"
    }
    "<polygon points=`"$($pts -join ' ')`" fill=`"$fill`"/><circle cx=`"$cx`" cy=`"$cy`" r=`"$(Rnd1 ($r * $hole))`" fill=`"#12143A`"/><circle cx=`"$cx`" cy=`"$cy`" r=`"$(Rnd1 ($r * 0.55))`" fill=`"none`" stroke=`"#fff`" stroke-opacity=`".25`" stroke-width=`"2`"/>"
}

function Hex($cx, $cy, $r) {
    $p = @()
    for ($i = 0; $i -lt 6; $i++) { $a = [math]::PI / 180 * (30 + 60 * $i); $p += "$(Rnd1 ($cx + $r * [math]::Cos($a))),$(Rnd1 ($cy + $r * [math]::Sin($a)))" }
    $p -join ' '
}

function Robot($cx, $cy, $k) {
    $w = 76 * $k; $h = 58 * $k
    $x = Rnd1 ($cx - $w / 2); $y = Rnd1 ($cy - $h / 2)
@"
<line x1="$cx" y1="$y" x2="$cx" y2="$(Rnd1 ($y - 18 * $k))" stroke="#fff" stroke-width="$(Rnd1 (3 * $k))" stroke-linecap="round"/>
<circle cx="$cx" cy="$(Rnd1 ($y - 22 * $k))" r="$(Rnd1 (5 * $k))" fill="#fff" filter="url(#glow)"/>
<rect x="$(Rnd1 ($x - 8 * $k))" y="$(Rnd1 ($cy - 10 * $k))" width="$(Rnd1 (8 * $k))" height="$(Rnd1 (20 * $k))" rx="3" fill="#E0637A"/>
<rect x="$(Rnd1 ($x + $w))" y="$(Rnd1 ($cy - 10 * $k))" width="$(Rnd1 (8 * $k))" height="$(Rnd1 (20 * $k))" rx="3" fill="#E0637A"/>
<rect x="$x" y="$y" width="$(Rnd1 $w)" height="$(Rnd1 $h)" rx="$(Rnd1 (18 * $k))" fill="url(#coral)"/>
<circle cx="$(Rnd1 ($cx - 18 * $k))" cy="$(Rnd1 ($cy - 4 * $k))" r="$(Rnd1 (7 * $k))" fill="#12143A"/>
<circle cx="$(Rnd1 ($cx + 18 * $k))" cy="$(Rnd1 ($cy - 4 * $k))" r="$(Rnd1 (7 * $k))" fill="#12143A"/>
<path d="M$(Rnd1 ($cx - 16 * $k)) $(Rnd1 ($cy + 13 * $k)) Q$cx $(Rnd1 ($cy + 24 * $k)) $(Rnd1 ($cx + 16 * $k)) $(Rnd1 ($cy + 13 * $k))" fill="none" stroke="#12143A" stroke-width="$(Rnd1 (3.5 * $k))" stroke-linecap="round"/>
"@
}

function Lines($x, $y, $ws, $op, $fill) {
    $s = ""; $yy = $y
    foreach ($w in $ws) { $s += "<rect x=`"$x`" y=`"$yy`" width=`"$w`" height=`"10`" rx=`"5`" fill=`"$fill`" fill-opacity=`"$op`"/>`n"; $yy += 22 }
    $s
}

function Doc($x, $y, $rot, $ok) {
    $cx = $x + 32; $cy = $y + 40
    $s = "<g transform=`"rotate($rot $cx $cy)`"><rect x=`"$x`" y=`"$y`" width=`"64`" height=`"80`" rx=`"8`" fill=`"#1D2062`" stroke=`"#fff`" stroke-opacity=`".35`" stroke-width=`"2`"/>"
    $s += "<rect x=`"$($x + 12)`" y=`"$($y + 16)`" width=`"40`" height=`"7`" rx=`"3.5`" fill=`"#fff`" fill-opacity=`".6`"/><rect x=`"$($x + 12)`" y=`"$($y + 32)`" width=`"30`" height=`"7`" rx=`"3.5`" fill=`"#fff`" fill-opacity=`".35`"/><rect x=`"$($x + 12)`" y=`"$($y + 48)`" width=`"36`" height=`"7`" rx=`"3.5`" fill=`"#fff`" fill-opacity=`".35`"/>"
    if ($ok) { $s += "<circle cx=`"$($x + 60)`" cy=`"$($y + 6)`" r=`"15`" fill=`"url(#coral)`" filter=`"url(#glow)`"/><path d=`"M$($x + 53) $($y + 6) l5 5 l9 -11`" fill=`"none`" stroke=`"#fff`" stroke-width=`"3.5`" stroke-linecap=`"round`" stroke-linejoin=`"round`"/>" }
    $s + "</g>"
}

# ---------- Árbol de circuitos (isotipo de la marca) ----------
$script:tl = ""; $script:tn = ""; $script:rnd = $null
function Branch([double]$x, [double]$y, [double]$ang, [double]$len, [int]$d) {
    $rad = $ang * [math]::PI / 180
    $x2 = Rnd1 ($x + [math]::Sin($rad) * $len); $y2 = Rnd1 ($y - [math]::Cos($rad) * $len)
    $sw = Rnd1 ([math]::Max(1.8, $d * 1.5))
    $script:tl += "<line x1=`"$(Rnd1 $x)`" y1=`"$(Rnd1 $y)`" x2=`"$x2`" y2=`"$y2`" stroke=`"#D97E92`" stroke-width=`"$sw`" stroke-linecap=`"round`"/>`n"
    if ($d -le 0) {
        $t = $script:rnd.Next(0, 4)
        if ($t -le 1) {
            $script:tn += "<circle cx=`"$x2`" cy=`"$y2`" r=`"13`" fill=`"none`" stroke=`"#F59AB0`" stroke-opacity=`".55`" stroke-width=`"1.6`"/><circle cx=`"$x2`" cy=`"$y2`" r=`"9`" fill=`"url(#coral)`"/><circle cx=`"$x2`" cy=`"$y2`" r=`"3.4`" fill=`"#12143A`"/>`n"
        } elseif ($t -eq 2) {
            $script:tn += "<circle cx=`"$x2`" cy=`"$y2`" r=`"8`" fill=`"#E65A34`"/><circle cx=`"$x2`" cy=`"$y2`" r=`"3`" fill=`"#12143A`"/>`n"
        } else {
            $script:tn += "<ellipse cx=`"$x2`" cy=`"$y2`" rx=`"5`" ry=`"10`" transform=`"rotate($([int]($ang + 40)) $x2 $y2)`" fill=`"#E65A34`" fill-opacity=`".85`"/>`n"
        }
        return
    }
    $script:tn += "<circle cx=`"$x2`" cy=`"$y2`" r=`"4.5`" fill=`"#12143A`" stroke=`"#F59AB0`" stroke-width=`"2`"/>`n"
    $a1 = 20 + $script:rnd.Next(0, 16); $a2 = 20 + $script:rnd.Next(0, 16)
    $f = 0.66 + $script:rnd.NextDouble() * 0.08
    Branch $x2 $y2 ($ang - $a1) ($len * $f) ($d - 1)
    Branch $x2 $y2 ($ang + $a2) ($len * $f) ($d - 1)
    if ($d -ge 3 -and $script:rnd.Next(0, 3) -eq 0) { Branch $x2 $y2 ($ang + $script:rnd.Next(-8, 9)) ($len * 0.78) ($d - 2) }
}

function Tree($x, $y, $trunkH, $branchLen, $depth, $seed) {
    $script:rnd = New-Object System.Random $seed
    $script:tl = ""; $script:tn = ""
    $top = $y - $trunkH
    Branch $x $top (-30) $branchLen $depth
    Branch $x $top 0 ($branchLen * 1.05) $depth
    Branch $x $top 30 $branchLen $depth
    $trunk = "<path d=`"M$(Rnd1 ($x - 26)) $y C$(Rnd1 ($x - 22)) $(Rnd1 ($y - $trunkH * 0.5)) $(Rnd1 ($x - 9)) $(Rnd1 ($top + 30)) $(Rnd1 ($x - 8)) $top L$(Rnd1 ($x + 8)) $top C$(Rnd1 ($x + 9)) $(Rnd1 ($top + 30)) $(Rnd1 ($x + 22)) $(Rnd1 ($y - $trunkH * 0.5)) $(Rnd1 ($x + 26)) $y Z`" fill=`"url(#trunk)`"/>"
    "<ellipse cx=`"$x`" cy=`"$($y + 6)`" rx=`"120`" ry=`"12`" fill=`"#E0637A`" fill-opacity=`".18`"/>`n$trunk`n<g filter=`"url(#glow)`" opacity=`".95`">`n$($script:tl)</g>`n<g>`n$($script:tn)</g>"
}

# ==========================================================
# 1. BANNER PRINCIPAL (1680 x 640)
# ==========================================================
$s = Defs 1680 640 .75 .55
$rnd = New-Object System.Random 7
$s += "<g fill=`"none`" stroke=`"#E0637A`" stroke-opacity=`".45`" stroke-width=`"2`">`n"
foreach ($row in @(@(470, 60, 300), @(520, 30, 380), @(570, 90, 260), @(420, 120, 210))) {
    $yy = $row[0]; $x0 = $row[1]; $ln = $row[2]
    $s += "<path d=`"M$x0 $yy H$($x0 + $ln) l30 -30 H$($x0 + $ln + 160)`"/><circle cx=`"$x0`" cy=`"$yy`" r=`"5`" fill=`"#12143A`"/><circle cx=`"$($x0 + $ln + 190)`" cy=`"$($yy - 30)`" r=`"5`" fill=`"#12143A`"/>`n"
}
$s += "</g>`n"
$s += Particles 1680 640 70 11
$s += Tree 1250 615 130 135 5 21
$s += "</svg>"
Save "banner-principal.svg" $s

# ==========================================================
# 2. ATENCIÓN AL CLIENTE (800 x 600)
# ==========================================================
$s = Defs 800 600 .5 .5
$s += Particles 800 600 35 3
$s += @"
<circle cx="400" cy="300" r="150" fill="none" stroke="#fff" stroke-opacity=".08"/>
<circle cx="400" cy="300" r="112" fill="none" stroke="#E0637A" stroke-opacity=".5" stroke-dasharray="4 8"/>
<g fill="none" stroke="#E0637A" stroke-opacity=".75" stroke-width="2.2" filter="url(#glow)">
<path d="M320 185 H350 L385 232"/><path d="M480 390 H465 L452 346"/><path d="M520 152 H470 L447 245"/><path d="M260 435 H330 L358 352"/>
</g>
<g fill="#12143A" stroke="#F59AB0" stroke-width="2.5"><circle cx="320" cy="185" r="5"/><circle cx="480" cy="390" r="5"/><circle cx="520" cy="152" r="5"/><circle cx="260" cy="435" r="5"/></g>
<circle cx="400" cy="300" r="76" fill="#12143A" stroke="#E0637A" stroke-width="3.5" filter="url(#glow)"/>
$(Robot 400 305 1.1)
<rect x="70" y="140" width="250" height="90" rx="24" fill="#1D2062" stroke="#E0637A" stroke-opacity=".6" stroke-width="1.6"/>
<circle cx="102" cy="185" r="18" fill="url(#coral)"/>
$(Lines 134 163 @(150, 110, 130) .65 "#fff")
<rect x="480" y="340" width="250" height="100" rx="24" fill="url(#coral)" filter="url(#glow)"/>
$(Lines 504 362 @(190, 150, 170) .55 "#12143A")
<rect x="90" y="400" width="170" height="70" rx="24" fill="#1D2062" stroke="#E0637A" stroke-opacity=".6" stroke-width="1.6"/>
<circle cx="132" cy="435" r="8" fill="#E0637A"/><circle cx="162" cy="435" r="8" fill="#E0637A" fill-opacity=".7"/><circle cx="192" cy="435" r="8" fill="#E0637A" fill-opacity=".4"/>
<rect x="520" y="120" width="170" height="64" rx="22" fill="#1D2062" stroke="#E0637A" stroke-opacity=".6" stroke-width="1.6"/>
<circle cx="556" cy="152" r="20" fill="url(#coral)"/><path d="M546 152 l8 8 l14 -16" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
$(Lines 588 140 @(70, 50) .6 "#fff")
<circle cx="690" cy="520" r="52" fill="none" stroke="#E0637A" stroke-opacity=".4" stroke-dasharray="3 7"/>
<circle cx="690" cy="520" r="40" fill="#12143A" stroke="#E0637A" stroke-width="4" filter="url(#glow)"/>
<path d="M690 520 V495 M690 520 L708 531" stroke="#fff" stroke-width="4" stroke-linecap="round"/>
<circle cx="690" cy="520" r="4.5" fill="#F59AB0"/>
</svg>
"@
Save "atencion-cliente.svg" $s

# ==========================================================
# 3. AUTOMATIZACIÓN (800 x 600)
# ==========================================================
$s = Defs 800 600 .45 .5
$s += Particles 800 600 35 5
$s += @"
<g fill="none" stroke="#E0637A" stroke-opacity=".7" stroke-width="2.2" filter="url(#glow)">
<path d="M456 202 H520 L560 162 H700"/><path d="M534 379 H600 L630 349 H730"/><path d="M300 190 V110 H150"/>
</g>
<g fill="#12143A" stroke="#F59AB0" stroke-width="2.5"><circle cx="700" cy="162" r="6"/><circle cx="730" cy="349" r="6"/><circle cx="150" cy="110" r="6"/></g>
<rect x="640" y="140" width="70" height="44" rx="10" fill="#1D2062" stroke="#E0637A" stroke-opacity=".7" stroke-width="1.6"/><rect x="650" y="152" width="34" height="8" rx="4" fill="#fff" fill-opacity=".6"/><rect x="650" y="166" width="22" height="8" rx="4" fill="#fff" fill-opacity=".35"/>
$(Gear 250 300 110 12 0 "url(#coral)" 0.38)
$(Gear 390 202 66 9 0.2 "#3A3E8A" 0.36)
$(Gear 420 379 84 10 0.1 "url(#coral2)" 0.36)
<circle cx="250" cy="300" r="14" fill="#F59AB0"/>
<rect x="60" y="504" width="680" height="12" rx="6" fill="#fff" fill-opacity=".12"/>
$(Doc 90 448 -10 $false)
$(Doc 290 452 4 $false)
$(Doc 490 452 0 $false)
<g fill="none" stroke="#E0637A" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"><path d="M200 478 l16 16 l-16 16"/><path d="M400 478 l16 16 l-16 16"/><path d="M596 478 l16 16 l-16 16"/></g>
<circle cx="690" cy="490" r="36" fill="url(#coral)" filter="url(#glow)"/><path d="M673 490 l12 12 l21 -25" fill="none" stroke="#fff" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
"@
Save "automatizacion.svg" $s

# ==========================================================
# 4. ANÁLISIS DE DATOS (800 x 600)
# ==========================================================
$s = Defs 800 600 .6 .45
$s += Particles 800 600 25 9
$s += "<rect x=`"60`" y=`"70`" width=`"680`" height=`"460`" rx=`"26`" fill=`"#0E1033`" fill-opacity=`".85`" stroke=`"#fff`" stroke-opacity=`".14`" stroke-width=`"1.5`"/>`n"
$s += "<circle cx=`"94`" cy=`"102`" r=`"6`" fill=`"#E0637A`"/><circle cx=`"114`" cy=`"102`" r=`"6`" fill=`"#E65A34`"/><circle cx=`"134`" cy=`"102`" r=`"6`" fill=`"#fff`" fill-opacity=`".3`"/><rect x=`"180`" y=`"96`" width=`"170`" height=`"12`" rx=`"6`" fill=`"#fff`" fill-opacity=`".18`"/>`n"
foreach ($gy in 470, 410, 350, 290, 230, 170) { $s += "<line x1=`"92`" y1=`"$gy`" x2=`"430`" y2=`"$gy`" stroke=`"#fff`" stroke-opacity=`".07`"/>`n" }
$hs = 80, 130, 105, 175, 150, 215, 262
for ($i = 0; $i -lt 7; $i++) {
    $bx = 104 + $i * 46; $bh = $hs[$i]; $by = 470 - $bh
    if ($i -eq 6) { $s += "<rect x=`"$bx`" y=`"$by`" width=`"32`" height=`"$bh`" rx=`"7`" fill=`"url(#coral)`" filter=`"url(#glow)`"/>`n" }
    else { $s += "<rect x=`"$bx`" y=`"$by`" width=`"32`" height=`"$bh`" rx=`"7`" fill=`"url(#coral)`" fill-opacity=`"$(Rnd1 (0.32 + $i * 0.07))`"/>`n" }
}
$s += @"
<circle cx="546" cy="182" r="48" fill="none" stroke="#fff" stroke-opacity=".1" stroke-width="14"/>
<circle cx="546" cy="182" r="48" fill="none" stroke="url(#coral)" stroke-width="14" stroke-linecap="round" stroke-dasharray="217 85" transform="rotate(-90 546 182)" filter="url(#glow)"/>
<rect x="622" y="150" width="90" height="12" rx="6" fill="#fff" fill-opacity=".6"/><rect x="622" y="174" width="60" height="10" rx="5" fill="#fff" fill-opacity=".3"/><rect x="622" y="196" width="76" height="10" rx="5" fill="#fff" fill-opacity=".3"/>
<polygon points="474,470 474,440 512,412 552,426 592,360 632,376 672,312 712,282 712,470" fill="url(#area)"/>
<polyline points="474,440 512,412 552,426 592,360 632,376 672,312 712,282" fill="none" stroke="#F59AB0" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round" filter="url(#glow)"/>
<g fill="#12143A" stroke="#E0637A" stroke-width="3.5"><circle cx="512" cy="412" r="6"/><circle cx="552" cy="426" r="6"/><circle cx="592" cy="360" r="6"/><circle cx="632" cy="376" r="6"/><circle cx="672" cy="312" r="6"/></g>
<circle cx="712" cy="282" r="12" fill="#E0637A" fill-opacity=".3"/><circle cx="712" cy="282" r="7" fill="#fff" stroke="#E0637A" stroke-width="3.5"/>
<line x1="466" y1="470" x2="716" y2="470" stroke="#fff" stroke-opacity=".12"/>
</svg>
"@
Save "analisis-datos.svg" $s

# ==========================================================
# 5. PROCESO DE IMPLEMENTACIÓN (800 x 600)
# ==========================================================
$s = Defs 800 600 .5 .5
$s += Particles 800 600 30 13
for ($i = 0; $i -lt 16; $i++) {
    $bx = 40 + $i * 45; $bh = 60 + (($i * 53) % 180)
    $s += "<rect x=`"$bx`" y=`"$(600 - $bh)`" width=`"30`" height=`"$bh`" rx=`"6`" fill=`"#fff`" fill-opacity=`".04`"/>`n"
}
$nodes = @(@(110, 430), @(260, 335), @(410, 405), @(560, 270), @(700, 180))
$s += "<path d=`"M110 430 C185 430 185 335 260 335 S335 405 410 405 S485 270 560 270 S635 180 700 180`" fill=`"none`" stroke=`"#E0637A`" stroke-width=`"5`" stroke-linecap=`"round`" stroke-dasharray=`"2 14`" filter=`"url(#glow)`"/>`n"
$s += "<circle cx=`"700`" cy=`"180`" r=`"70`" fill=`"none`" stroke=`"#E0637A`" stroke-opacity=`".22`"/><circle cx=`"700`" cy=`"180`" r=`"88`" fill=`"none`" stroke=`"#E0637A`" stroke-opacity=`".12`"/>`n"
for ($i = 0; $i -lt 5; $i++) {
    $nx = $nodes[$i][0]; $ny = $nodes[$i][1]; $fill = if ($i -eq 4) { "url(#coral)" } else { "#12143A" }
    $s += "<circle cx=`"$nx`" cy=`"$ny`" r=`"40`" fill=`"$fill`" stroke=`"#E0637A`" stroke-width=`"4`" filter=`"url(#glow)`"/>`n"
    $s += "<text x=`"$nx`" y=`"$($ny + 11)`" text-anchor=`"middle`" font-family=`"Arial, Helvetica, sans-serif`" font-size=`"32`" font-weight=`"700`" fill=`"#fff`">$($i + 1)</text>`n"
    $s += "<rect x=`"$($nx - 46)`" y=`"$($ny + 58)`" width=`"92`" height=`"10`" rx=`"5`" fill=`"#fff`" fill-opacity=`".4`"/><rect x=`"$($nx - 30)`" y=`"$($ny + 76)`" width=`"60`" height=`"8`" rx=`"4`" fill=`"#fff`" fill-opacity=`".2`"/>`n"
}
$s += "</svg>"
Save "proceso-implementacion.svg" $s

# ==========================================================
# 6. BLOG: QUÉ ES UN AGENTE DE IA (1200 x 675)
# ==========================================================
$s = Defs 1200 675 .5 .5
$s += Particles 1200 675 55 17
$s += "<ellipse cx=`"600`" cy=`"337`" rx=`"330`" ry=`"200`" fill=`"none`" stroke=`"#fff`" stroke-opacity=`".12`" stroke-dasharray=`"5 9`"/><ellipse cx=`"600`" cy=`"337`" rx=`"440`" ry=`"270`" fill=`"none`" stroke=`"#fff`" stroke-opacity=`".06`"/>`n"
$sat = @()
foreach ($t in 0, 60, 120, 180, 240, 300) { $rad = $t * [math]::PI / 180; $sat += , @((Rnd1 (600 + 330 * [math]::Cos($rad))), (Rnd1 (337 + 200 * [math]::Sin($rad)))) }
foreach ($p in $sat) {
    $s += "<line x1=`"600`" y1=`"337`" x2=`"$($p[0])`" y2=`"$($p[1])`" stroke=`"#E0637A`" stroke-opacity=`".55`" stroke-width=`"2`" stroke-dasharray=`"6 8`"/>`n"
    $s += "<circle cx=`"$(Rnd1 (600 + ($p[0] - 600) * 0.5))`" cy=`"$(Rnd1 (337 + ($p[1] - 337) * 0.5))`" r=`"6`" fill=`"#F59AB0`" filter=`"url(#glow)`"/>`n"
}
foreach ($p in $sat) { $s += "<rect x=`"$($p[0] - 46)`" y=`"$($p[1] - 46)`" width=`"92`" height=`"92`" rx=`"24`" fill=`"#1D2062`" stroke=`"#E0637A`" stroke-opacity=`".8`" stroke-width=`"2`" filter=`"url(#glow)`"/>`n" }
$s += "<polygon points=`"$(Hex 600 337 122)`" fill=`"#12143A`" stroke=`"#E0637A`" stroke-width=`"4.5`" filter=`"url(#glow)`"/><polygon points=`"$(Hex 600 337 100)`" fill=`"none`" stroke=`"#fff`" stroke-opacity=`".12`"/>`n"
$s += Robot 600 345 1.35
# iconos de los satélites
$x = $sat[0][0]; $y = $sat[0][1]   # documento
$s += "<rect x=`"$($x - 17)`" y=`"$($y - 24)`" width=`"34`" height=`"48`" rx=`"5`" fill=`"none`" stroke=`"#fff`" stroke-width=`"3`"/><path d=`"M$($x - 8) $($y - 8) h16 M$($x - 8) $($y + 3) h16 M$($x - 8) $($y + 14) h10`" stroke=`"#F59AB0`" stroke-width=`"3`" stroke-linecap=`"round`"/>`n"
$x = $sat[1][0]; $y = $sat[1][1]   # chat
$s += "<rect x=`"$($x - 26)`" y=`"$($y - 20)`" width=`"52`" height=`"34`" rx=`"11`" fill=`"url(#coral)`"/><polygon points=`"$($x - 10),$($y + 13) $($x - 16),$($y + 25) $($x + 2),$($y + 13)`" fill=`"#E0637A`"/><circle cx=`"$($x - 12)`" cy=`"$($y - 3)`" r=`"3.5`" fill=`"#12143A`"/><circle cx=`"$x`" cy=`"$($y - 3)`" r=`"3.5`" fill=`"#12143A`"/><circle cx=`"$($x + 12)`" cy=`"$($y - 3)`" r=`"3.5`" fill=`"#12143A`"/>`n"
$x = $sat[2][0]; $y = $sat[2][1]   # gráfico
$s += "<rect x=`"$($x - 22)`" y=`"$($y)`" width=`"12`" height=`"22`" rx=`"3`" fill=`"#F59AB0`"/><rect x=`"$($x - 6)`" y=`"$($y - 14)`" width=`"12`" height=`"36`" rx=`"3`" fill=`"#E0637A`"/><rect x=`"$($x + 10)`" y=`"$($y - 28)`" width=`"12`" height=`"50`" rx=`"3`" fill=`"url(#coral)`"/>`n"
$x = $sat[3][0]; $y = $sat[3][1]   # calendario
$s += "<rect x=`"$($x - 24)`" y=`"$($y - 20)`" width=`"48`" height=`"42`" rx=`"7`" fill=`"none`" stroke=`"#fff`" stroke-width=`"3`"/><rect x=`"$($x - 24)`" y=`"$($y - 20)`" width=`"48`" height=`"12`" rx=`"6`" fill=`"url(#coral)`"/><g fill=`"#F59AB0`"><circle cx=`"$($x - 12)`" cy=`"$($y + 2)`" r=`"3`"/><circle cx=`"$x`" cy=`"$($y + 2)`" r=`"3`"/><circle cx=`"$($x + 12)`" cy=`"$($y + 2)`" r=`"3`"/><circle cx=`"$($x - 12)`" cy=`"$($y + 14)`" r=`"3`"/><circle cx=`"$x`" cy=`"$($y + 14)`" r=`"3`"/></g>`n"
$x = $sat[4][0]; $y = $sat[4][1]   # engranaje
$s += Gear $x $y 26 8 0.2 "url(#coral)" 0.4
$x = $sat[5][0]; $y = $sat[5][1]   # correo
$s += "<rect x=`"$($x - 26)`" y=`"$($y - 18)`" width=`"52`" height=`"36`" rx=`"7`" fill=`"none`" stroke=`"#fff`" stroke-width=`"3`"/><path d=`"M$($x - 24) $($y - 15) L$x $($y + 4) L$($x + 24) $($y - 15)`" fill=`"none`" stroke=`"#F59AB0`" stroke-width=`"3`" stroke-linecap=`"round`" stroke-linejoin=`"round`"/>`n"
$s += "</svg>"
Save "blog-agente-ia.svg" $s

# ==========================================================
# 7. BLOG: AUTOMATIZACIÓN, POR DÓNDE EMPEZAR (1200 x 675)
# ==========================================================
$s = Defs 1200 675 .6 .4
$s += Particles 1200 675 45 19
$s += "<g fill=`"none`" stroke=`"#E0637A`" stroke-opacity=`".4`" stroke-width=`"2`"><path d=`"M40 120 H240 l30 -30 H420`"/><path d=`"M40 200 H160 l30 30 H320`"/><path d=`"M900 560 H1020 l30 -30 H1170`"/><circle cx=`"420`" cy=`"90`" r=`"5`" fill=`"#12143A`"/><circle cx=`"320`" cy=`"230`" r=`"5`" fill=`"#12143A`"/><circle cx=`"1170`" cy=`"530`" r=`"5`" fill=`"#12143A`"/></g>`n"
$hsteps = 110, 200, 290, 380
for ($i = 0; $i -lt 4; $i++) {
    $bx = 190 + $i * 230; $bh = $hsteps[$i]; $by = 575 - $bh
    $s += "<rect x=`"$bx`" y=`"$by`" width=`"230`" height=`"$bh`" fill=`"#1D2062`" fill-opacity=`"$(Rnd1 (0.55 + $i * 0.1))`" stroke=`"#E0637A`" stroke-opacity=`".35`"/>`n"
    $s += "<rect x=`"$bx`" y=`"$by`" width=`"230`" height=`"8`" fill=`"url(#coral)`"/>`n"
    $s += "<circle cx=`"$bx`" cy=`"$by`" r=`"7`" fill=`"#12143A`" stroke=`"#F59AB0`" stroke-width=`"3`"/>`n"
}
$s += "<line x1=`"120`" y1=`"575`" x2=`"1180`" y2=`"575`" stroke=`"#fff`" stroke-opacity=`".18`" stroke-width=`"2`"/>`n"
$s += "<path d=`"M300 385 Q420 330 535 290 T765 200 T980 112`" fill=`"none`" stroke=`"#F59AB0`" stroke-width=`"4`" stroke-dasharray=`"3 13`" stroke-linecap=`"round`" filter=`"url(#glow)`"/><polygon points=`"1006,102 984,92 986,120`" fill=`"#F59AB0`"/>`n"
$s += "<path d=`"M305 465 V395`" stroke=`"#fff`" stroke-width=`"4`" stroke-linecap=`"round`"/><polygon points=`"305,395 356,412 305,430`" fill=`"url(#coral)`" filter=`"url(#glow)`"/>`n"
$s += Gear 535 330 27 9 0.1 "url(#coral)" 0.4
$s += "<rect x=`"742`" y=`"238`" width=`"14`" height=`"22`" rx=`"3`" fill=`"#F59AB0`"/><rect x=`"765`" y=`"224`" width=`"14`" height=`"36`" rx=`"3`" fill=`"#E0637A`"/><rect x=`"788`" y=`"208`" width=`"14`" height=`"52`" rx=`"3`" fill=`"url(#coral)`"/>`n"
$s += "<circle cx=`"995`" cy=`"148`" r=`"34`" fill=`"url(#coral)`" filter=`"url(#glow)`"/><path d=`"M978 148 l12 13 l22 -26`" fill=`"none`" stroke=`"#fff`" stroke-width=`"6`" stroke-linecap=`"round`" stroke-linejoin=`"round`"/>`n"
$s += "</svg>"
Save "blog-automatizacion.svg" $s

# ==========================================================
# 8. BLOG: IA EN ATENCIÓN AL CLIENTE (1200 x 675)
# ==========================================================
$s = Defs 1200 675 .5 .5
$s += Particles 1200 675 50 23
$s += @"
<circle cx="600" cy="340" r="260" fill="none" stroke="#fff" stroke-opacity=".07"/>
<circle cx="600" cy="340" r="210" fill="none" stroke="#E0637A" stroke-opacity=".3" stroke-dasharray="4 10"/>
<g fill="none" stroke="#E0637A" stroke-opacity=".7" stroke-width="2.2" filter="url(#glow)">
<path d="M350 190 H385 L415 300"/><path d="M850 250 H815 L790 330"/><path d="M320 505 H390 L420 400"/><path d="M880 505 H810 L785 410"/>
</g>
<g fill="#12143A" stroke="#F59AB0" stroke-width="2.5"><circle cx="350" cy="190" r="5"/><circle cx="850" cy="250" r="5"/><circle cx="320" cy="505" r="5"/><circle cx="880" cy="505" r="5"/></g>
<path d="M448 345 A152 152 0 0 1 752 345" fill="none" stroke="url(#coral)" stroke-width="24" stroke-linecap="round" filter="url(#glow)"/>
<rect x="410" y="300" width="66" height="124" rx="30" fill="#1D2062" stroke="#E0637A" stroke-width="5" filter="url(#glow)"/><rect x="424" y="322" width="22" height="80" rx="11" fill="#E0637A" fill-opacity=".8"/>
<rect x="724" y="300" width="66" height="124" rx="30" fill="#1D2062" stroke="#E0637A" stroke-width="5" filter="url(#glow)"/><rect x="754" y="322" width="22" height="80" rx="11" fill="#E0637A" fill-opacity=".8"/>
<path d="M757 424 Q757 505 668 505" fill="none" stroke="#fff" stroke-opacity=".85" stroke-width="7" stroke-linecap="round"/>
<rect x="626" y="490" width="52" height="30" rx="15" fill="url(#coral)" filter="url(#glow)"/>
<rect x="90" y="142" width="260" height="96" rx="26" fill="#1D2062" stroke="#E0637A" stroke-opacity=".6" stroke-width="1.6"/>
<circle cx="126" cy="190" r="20" fill="url(#coral)"/>
$(Lines 162 168 @(150, 110, 130) .65 "#fff")
<rect x="850" y="202" width="270" height="96" rx="26" fill="url(#coral)" filter="url(#glow)"/>
$(Lines 878 226 @(190, 150, 170) .55 "#12143A")
<rect x="120" y="470" width="200" height="70" rx="24" fill="#1D2062" stroke="#E0637A" stroke-opacity=".6" stroke-width="1.6"/>
<circle cx="170" cy="505" r="8" fill="#E0637A"/><circle cx="200" cy="505" r="8" fill="#E0637A" fill-opacity=".7"/><circle cx="230" cy="505" r="8" fill="#E0637A" fill-opacity=".4"/>
<rect x="880" y="470" width="200" height="70" rx="24" fill="#1D2062" stroke="#E0637A" stroke-opacity=".6" stroke-width="1.6"/>
<circle cx="920" cy="505" r="20" fill="url(#coral)"/><path d="M910 505 l8 8 l14 -16" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
$(Lines 954 493 @(90, 60) .6 "#fff")
<circle cx="1090" cy="110" r="52" fill="none" stroke="#E0637A" stroke-opacity=".4" stroke-dasharray="3 7"/>
<circle cx="1090" cy="110" r="40" fill="#12143A" stroke="#E0637A" stroke-width="4" filter="url(#glow)"/>
<path d="M1090 110 V85 M1090 110 L1108 121" stroke="#fff" stroke-width="4" stroke-linecap="round"/><circle cx="1090" cy="110" r="4.5" fill="#F59AB0"/>
</svg>
"@
Save "blog-atencion-cliente.svg" $s
