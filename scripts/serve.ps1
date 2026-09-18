<#
.SYNOPSIS
    Servidor web local mínimo para ver el sitio sin instalar nada.

.USO
    powershell -ExecutionPolicy Bypass -File scripts\serve.ps1            (puerto 8080)
    powershell -ExecutionPolicy Bypass -File scripts\serve.ps1 -Port 5500
    Luego abre http://localhost:8080 en el navegador. Ctrl+C para detenerlo.

.NOTAS
    El sitio necesita un servidor porque carga sus secciones (partials/) con JavaScript.
    Si ya usas Live Server en VS Code, este script no hace falta.
#>
param(
    [int]$Port = 8080,
    [string]$Root = (Split-Path $PSScriptRoot -Parent)
)

$types = @{
    ".html" = "text/html; charset=utf-8"; ".css" = "text/css; charset=utf-8"; ".js" = "application/javascript; charset=utf-8"
    ".svg" = "image/svg+xml"; ".png" = "image/png"; ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"
    ".webp" = "image/webp"; ".ico" = "image/x-icon"; ".mp4" = "video/mp4"; ".json" = "application/json"
}

$rootFull = [IO.Path]::GetFullPath($Root)
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Sirviendo $rootFull en http://localhost:$Port  (Ctrl+C para detener)"

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $rel = [Uri]::UnescapeDataString($ctx.Request.Url.LocalPath).TrimStart('/')
        if ($rel -eq "") { $rel = "index.html" }
        $file = [IO.Path]::GetFullPath((Join-Path $rootFull $rel))

        # Seguridad: no servir nada fuera de la carpeta del proyecto
        if (-not $file.StartsWith($rootFull) -or -not (Test-Path $file -PathType Leaf)) {
            $ctx.Response.StatusCode = 404
        } else {
            $bytes = [IO.File]::ReadAllBytes($file)
            $ext = [IO.Path]::GetExtension($file).ToLower()
            if ($types.ContainsKey($ext)) { $ctx.Response.ContentType = $types[$ext] }
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        $ctx.Response.Close()
    }
} finally {
    $listener.Stop()
}
