/* ==========================================================
   contacto.js - Validación y confirmación del formulario
   Usa delegación de eventos porque el formulario se inserta
   después de cargar la página (ver include.js).
   Solo front-end: aún no envía datos a ningún servidor.
   ========================================================== */
document.addEventListener('submit', function (event) {
    const form = event.target;
    if (!form.matches('#formContacto')) return;

    event.preventDefault();
    const alerta = document.getElementById('alertaContacto');

    if (!form.checkValidity()) {
        event.stopPropagation();
        form.classList.add('was-validated');
        alerta.innerHTML =
            '<div class="alert alert-danger" role="alert">' +
            '<i class="bi bi-exclamation-triangle me-2" aria-hidden="true"></i>' +
            'Revisa los campos marcados en rojo antes de enviar.</div>';
        return;
    }

    const nombre = form.nombre.value.trim();
    alerta.innerHTML =
        '<div class="alert alert-success alert-dismissible fade show" role="alert">' +
        '<i class="bi bi-check-circle me-2" aria-hidden="true"></i>' +
        '¡Gracias, ' + nombre.replace(/[<>&"]/g, '') + '! Recibimos tu solicitud y te contactaremos pronto.' +
        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button></div>';

    form.reset();
    form.classList.remove('was-validated');
});
