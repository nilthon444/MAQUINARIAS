const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Configuración de la conexión a tu base de datos MySQL local
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '12345', 
    database: 'gestion_maquinaria_pesada'
});

db.connect((err) => {
    if (err) {
        console.error('Error al conectar a la base de datos MySQL:', err);
        return;
    }
    console.log('Conectado exitosamente a la base de datos MySQL.');
});

// Ruta para procesar el inicio de sesión
app.post('/api/login', (req, res) => {
    const { usuario, password } = req.body;
    const query = 'SELECT * FROM USUARIO WHERE usuario = ? AND password = ?';

    db.query(query, [usuario, password], (err, results) => {
        if (err) {
            console.error('Error en la consulta SQL:', err);
            return res.status(500).json({ success: false, message: 'Error en el servidor' });
        }

        if (results.length > 0) {
            const user = results[0];
            res.json({ 
                success: true, 
                message: 'Inicio de sesión exitoso',
                user: { 
                    id: user.id_usuario, 
                    nombre: user.nombres, 
                    rol: user.id_rol 
                }
            });
        } else {
            res.status(401).json({ success: false, message: 'Usuario o contraseña incorrectos' });
        }
    });
});

app.listen(3000, () => {
    console.log('Servidor backend corriendo en http://localhost:3000');
});