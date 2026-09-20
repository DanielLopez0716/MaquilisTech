# MaquilisTech · Sitio web institucional

Proyecto de cátedra **LME901 · Lenguajes de Marcado, Diseño Web y Gestores de Contenido**
Universidad Don Bosco · Ciclo 02-2026 · Docente: Henry Porfirio Avalos Cardoza

**Fase 2 (Sprint II): Desarrollo Front-End** con HTML5, CSS3 y Bootstrap 5.

MaquilisTech (Maquilishuat Intelligence, S.A.S.) ofrece soluciones de agentes de inteligencia artificial para empresas salvadoreñas y de la región. Lema: *Harvesting Innovation*.

## Integrantes

| Integrante | Carnet |
|---|---|
| Barnett Alejandro Morales Flores | MF263365 |
| Isaac Edgardo Galicia | GH263224 |
| Josué Daniel López Corado | LC263395 |
| Nelson Alexander Sandoval Aguilar | SA262437 |

## Cómo ejecutar el sitio

Las páginas se arman a partir de secciones (`partials/`) cargadas con JavaScript, por lo que **no funcionan abriendo el `.html` con doble clic**. Se necesita un servidor local:

1. Abre la carpeta del proyecto en **Visual Studio Code**.
2. Instala la extensión **Live Server** (Ritwick Dey).
3. Clic derecho sobre `index.html` → **Open with Live Server**.

**Alternativa sin instalar nada** (Windows, PowerShell), desde la carpeta del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\serve.ps1
```

y abrir <http://localhost:8080>.

## Estructura del proyecto

```
proyecto/
├── index.html · nosotros.html · servicios.html · faq.html · blog.html · contacto.html
├── articulo-*.html · privacidad.html     ← páginas internas
├── css/style.css                         ← estilos comunes y variables de marca
├── js/
│   ├── include.js                        ← carga las secciones de partials/
│   └── contacto.js                       ← validación del formulario
├── img/                                  ← logotipo e ilustraciones (SVG)
├── media/                                ← videos y otros recursos
├── scripts/                              ← herramientas de desarrollo (no forman parte del sitio)
│   ├── make-images.ps1                   ← genera las ilustraciones SVG de img/
│   ├── make-logo.ps1                     ← genera las variantes del logotipo (SVG)
│   ├── optimize-images.ps1               ← reduce y comprime las fotos de img/originales/
│   └── serve.ps1                         ← servidor local sin dependencias
└── partials/                             ← una carpeta por página, un archivo por sección
    ├── header.html · footer.html         ← compartidos por todo el sitio
    ├── index/ · nosotros/ · servicios/ · faq/ · blog/ · contacto/ · privacidad/
```

### Cómo funcionan las secciones

Cada página (`index.html`, etc.) solo ensambla secciones. Una sección se inserta así:

```html
<div data-include="partials/index/hero.html"></div>
```

Para trabajar en una sección basta con editar su archivo dentro de `partials/`. Para agregar una nueva, se crea el archivo y se añade esa línea en el `<main>` de la página.

## Scripts

Viven en `scripts/` y se ejecutan con PowerShell desde la carpeta del proyecto.

| Script | Para qué sirve | Cómo ejecutarlo |
|---|---|---|
| `make-images.ps1` | Genera las 8 ilustraciones vectoriales de `img/` (banner, servicios y blog) con la paleta de marca. Es determinista: siempre produce los mismos archivos. | `powershell -ExecutionPolicy Bypass -File scripts\make-images.ps1` |
| `make-logo.ps1` | Genera las variantes del logotipo en `img/`: principal, sin tagline, isotipo, monocromática positiva y negativa, y favicon. Convierte las letras a trazos con Montserrat, por lo que no depende de fuentes instaladas. Requiere Internet la primera vez (descarga las fuentes). | `powershell -ExecutionPolicy Bypass -File scripts\make-logo.ps1` |
| `optimize-images.ps1` | Toma las fotos de `img/originales/`, las reduce (sin agrandarlas) y las guarda como JPG de calidad 82 en `img/`. Lee WebP, JPG y PNG. Para sumar una foto, se añade una línea a su tabla `$mapa`. | `powershell -ExecutionPolicy Bypass -File scripts\optimize-images.ps1` |
| `serve.ps1` | Levanta un servidor local en `http://localhost:8080` (parámetro `-Port` para cambiar el puerto). | `powershell -ExecutionPolicy Bypass -File scripts\serve.ps1` |

**Modificar una ilustración:** abre `make-images.ps1`, busca su escena (comentarios `# 1. BANNER PRINCIPAL`, `# 2. ATENCIÓN AL CLIENTE`, etc.), cambia colores o posiciones y vuelve a ejecutarlo. Si se reemplazan por fotografías o arte propio, basta con guardarlas en `img/` con los mismos nombres o actualizar las rutas en `partials/`.

Las ilustraciones fueron diseñadas con la paleta oficial: azul marino `#12143A`, rosa coral `#E0637A` y rojo naranja `#E65A34`.

## Identidad de marca (Manual de Marca, Fase 1)

| Color | Hex | Uso |
|---|---|---|
| Azul marino profundo | `#12143A` | Fondos, encabezados |
| Rosa coral | `#E0637A` | Acentos y botones |
| Rojo naranja | `#E65A34` | Llamados a la acción |
| Marrón | `#8C5A34` | Elementos naturales del isotipo |
| Blanco | `#FFFFFF` | Contraste |
| Coral accesible | `#C8455F` | Texto coral y botones sobre fondo **claro** (4.7:1 con blanco, cumple WCAG AA) |
| Naranja accesible | `#CF4220` | Estado *hover* de los botones (4.7:1 con blanco) |

El coral original `#E0637A` se conserva sobre fondos **oscuros** (navbar, hero, footer), donde ya cumple (5.25:1). En el CSS: `.text-coral` usa la variante accesible salvo dentro de `.bg-navy`, `.hero`, `.navbar` y `.site-footer`.

**Tipografías:** Montserrat (títulos, subtítulos y tagline) · Arial (cuerpo de texto).

**Logotipo:** no deformarlo, no cambiar sus colores y no bajar de 32 px de alto. Las variantes están en `img/`:

| Archivo | Uso |
|---|---|
| `logo-principal.svg` | Isotipo + nombre + tagline, sobre fondos oscuros (footer) |
| `logo-sin-tagline.svg` | Espacios reducidos, donde el tagline no se lea |
| `isotipo.svg` | Solo el árbol: navbar, avatar de redes, marca de agua |
| `logo-mono-positivo.svg` | Una tinta negra: fondos claros e impresión |
| `logo-mono-negativo.svg` | Una tinta blanca: fondos oscuros |
| `favicon.svg` | Ícono de la pestaña del navegador |
| `logo.jpg` | Logotipo original del Documento Maestro (referencia) |

Las variantes SVG son una **recreación** del logotipo original, con fondo transparente. El contenido de las páginas proviene del Documento Maestro de la Fase 1.

## Trabajo en equipo

- Cada persona edita solo sus secciones dentro de `partials/`.
- Los estilos comunes van en `css/style.css`; evita estilos en línea.
- Antes de subir cambios: `git pull`. Después: `git add .`, `git commit -m "descripción"` y `git push`.

### Responsables por sección

| Sección | Responsable |
|---|---|
| Header y footer | isaac galicia |
| Home | isaac galicia |
| Nosotros | |
| Servicios | daniel lopez |
| FAQ | |
| Blog | |
| Contacto || Barnett Morales |

## Tecnologías

HTML5 · CSS3 · Bootstrap 5.3 (CDN) · Bootstrap Icons · Google Fonts (Montserrat) · JavaScript
