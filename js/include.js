/* ==========================================================
   include.js - Carga fragmentos HTML (secciones independientes)
   Uso:  <div data-include="partials/header.html"></div>
   El marcador se reemplaza por el contenido del archivo.
   IMPORTANTE: requiere un servidor (Live Server, GitHub Pages,
   hosting). No funciona abriendo el .html con doble clic.
   ========================================================== */
(function () {
    async function loadPartial(placeholder) {
        const url = placeholder.getAttribute('data-include');
        try {
            const res = await fetch(url);
            if (!res.ok) throw new Error('HTTP ' + res.status);
            placeholder.insertAdjacentHTML('beforebegin', await res.text());
        } catch (err) {
            placeholder.insertAdjacentHTML(
                'beforebegin',
                '<div class="alert alert-warning m-3" role="alert">No se pudo cargar <code>' +
                url + '</code>. Abre el sitio con un servidor local (Live Server).</div>'
            );
        }
        placeholder.remove();
    }

    function markActiveLink() {
        // Las páginas internas (ej. artículos del blog) pueden indicar a qué
        // sección del menú pertenecen con <body data-section="blog.html">
        const current = document.body.dataset.section ||
            location.pathname.split('/').pop() || 'index.html';
        document.querySelectorAll('.navbar .nav-link').forEach(function (link) {
            const active = link.getAttribute('href') === current;
            link.classList.toggle('active', active);
            if (active) {
                link.setAttribute('aria-current', 'page');
            } else {
                link.removeAttribute('aria-current');
            }
        });
    }

    document.addEventListener('DOMContentLoaded', async function () {
        const placeholders = Array.from(document.querySelectorAll('[data-include]'));
        await Promise.all(placeholders.map(loadPartial));
        markActiveLink();
    });
})();
