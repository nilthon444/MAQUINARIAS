document.addEventListener('DOMContentLoaded', () => {
    const formLogin = document.querySelector('.login-form');
    const inputUsuario = document.getElementById('username');
    const inputPassword = document.getElementById('password');
    const togglePassword = document.getElementById('togglePassword');

    // Opcional: Funcionalidad para mostrar u ocultar la contraseña con el icono de ojito
    if (togglePassword) {
        togglePassword.addEventListener('click', () => {
            const type = inputPassword.getAttribute('type') === 'password' ? 'text' : 'password';
            inputPassword.setAttribute('type', type);
            togglePassword.classList.toggle('fa-eye');
            togglePassword.classList.toggle('fa-eye-slash');
        });
    }

    // Evento de envío del formulario al hacer clic en "Ingresar"
    formLogin.addEventListener('submit', async (e) => {
        e.preventDefault(); // Evita que la página se recargue por defecto

        const usuario = inputUsuario.value.trim();
        const password = inputPassword.value.trim();

        if (!usuario || !password) {
            alert('Por favor, complete todos los campos.');
            return;
        }

        try {
            // Petición al servidor backend de Node.js que valida con MySQL
            const response = await fetch('http://localhost:3000/api/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ usuario, password })
            });

            const data = await response.json();

            if (data.success) {
                // Guardamos los datos del usuario logueado en el navegador
                localStorage.setItem('usuarioLogueado', JSON.stringify(data.user));

                alert(`¡Bienvenido al sistema, ${data.user.nombre}!`);

                // Redirección automática al Dashboard principal
                window.location.href = 'dashboard.html';
            } else {
                alert(data.message || 'Usuario o contraseña incorrectos.');
            }

        } catch (error) {
            console.error('Error de conexión:', error);
            alert('No se pudo conectar con el servidor backend. Asegúrate de que el servidor esté encendido.');
        }
    });
});