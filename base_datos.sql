-- =========================================================================
-- SISTEMA WEB PARA LA GESTIÓN DE MANTENIMIENTO DE MAQUINARIA PESADA
-- Script de Creación de Base de Datos (MySQL / MariaDB)
-- =========================================================================

CREATE DATABASE IF NOT EXISTS gestion_maquinaria_pesada CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gestion_maquinaria_pesada;

-- ------------------------------------------------------------------------
-- 1. TABLA: ROL
-- ------------------------------------------------------------------------
CREATE TABLE ROL (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    estado TINYINT(1) DEFAULT 1
);

-- ------------------------------------------------------------------------
-- 2. TABLA: USUARIO
-- ------------------------------------------------------------------------
CREATE TABLE USUARIO (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    estado TINYINT(1) DEFAULT 1,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES ROL(id_rol)
);

-- ------------------------------------------------------------------------
-- 3. TABLA: MAQUINARIA
-- ------------------------------------------------------------------------
CREATE TABLE MAQUINARIA (
    id_maquinaria INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    placa VARCHAR(20),
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    serie VARCHAR(50) NOT NULL,
    anio YEAR,
    tipo_maquinaria VARCHAR(100),
    horometro_actual DECIMAL(10,2) DEFAULT 0.00,
    estado VARCHAR(20) DEFAULT 'OPERATIVO',
    ubicacion VARCHAR(100),
    observaciones VARCHAR(200)
);

-- ------------------------------------------------------------------------
-- 4. TABLA: OPERADOR
-- ------------------------------------------------------------------------
CREATE TABLE OPERADOR (
    id_operador INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    licencia VARCHAR(30) NOT NULL,
    categoria VARCHAR(20),
    telefono VARCHAR(20),
    estado TINYINT(1) DEFAULT 1
);

-- ------------------------------------------------------------------------
-- 5. TABLA INTERMEDIA: ASIGNACION_MAQ_OPERADOR (N:M)
-- ------------------------------------------------------------------------
CREATE TABLE ASIGNACION_MAQ_OPERADOR (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_maquinaria INT NOT NULL,
    id_operador INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado TINYINT(1) DEFAULT 1,
    CONSTRAINT fk_asig_maquinaria FOREIGN KEY (id_maquinaria) REFERENCES MAQUINARIA(id_maquinaria),
    CONSTRAINT fk_asig_operador FOREIGN KEY (id_operador) REFERENCES OPERADOR(id_operador)
);

-- ------------------------------------------------------------------------
-- 6. TABLA: INSPECCION
-- ------------------------------------------------------------------------
CREATE TABLE INSPECCION (
    id_inspeccion INT AUTO_INCREMENT PRIMARY KEY,
    id_maquinaria INT NOT NULL,
    fecha DATE NOT NULL,
    horometro DECIMAL(10,2) NOT NULL,
    responsable VARCHAR(100) NOT NULL,
    observaciones VARCHAR(250),
    resultado VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'REGISTRADO',
    CONSTRAINT fk_inspeccion_maquinaria FOREIGN KEY (id_maquinaria) REFERENCES MAQUINARIA(id_maquinaria)
);

-- ------------------------------------------------------------------------
-- 7. TABLA: FALLA
-- ------------------------------------------------------------------------
CREATE TABLE FALLA (
    id_falla INT AUTO_INCREMENT PRIMARY KEY,
    id_inspeccion INT,
    sistema VARCHAR(50) NOT NULL,
    descripcion VARCHAR(250) NOT NULL,
    criticidad VARCHAR(20) NOT NULL,
    fecha_reporte DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    CONSTRAINT fk_falla_inspeccion FOREIGN KEY (id_inspeccion) REFERENCES INSPECCION(id_inspeccion)
);

-- ------------------------------------------------------------------------
-- 8. TABLA: ORDEN_TRABAJO
-- ------------------------------------------------------------------------
CREATE TABLE ORDEN_TRABAJO (
    id_orden INT AUTO_INCREMENT PRIMARY KEY,
    id_maquinaria INT NOT NULL,
    id_falla INT,
    tipo VARCHAR(20) NOT NULL,
    prioridad VARCHAR(20) NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_programada DATE,
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR(20) DEFAULT 'EMITIDA',
    descripcion VARCHAR(200),
    CONSTRAINT fk_ot_maquinaria FOREIGN KEY (id_maquinaria) REFERENCES MAQUINARIA(id_maquinaria),
    CONSTRAINT fk_ot_falla FOREIGN KEY (id_falla) REFERENCES FALLA(id_falla)
);

-- ------------------------------------------------------------------------
-- 9. TABLA: MANTENIMIENTO
-- ------------------------------------------------------------------------
CREATE TABLE MANTENIMIENTO (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    fecha_mantenimiento DATE NOT NULL,
    descripcion_trabajo VARCHAR(250) NOT NULL,
    diagnostico VARCHAR(250),
    recomendaciones VARCHAR(250),
    horometro DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_mantenimiento_orden FOREIGN KEY (id_orden) REFERENCES ORDEN_TRABAJO(id_orden)
);

-- ------------------------------------------------------------------------
-- 10. TABLA: PERSONAL_TECNICO
-- ------------------------------------------------------------------------
CREATE TABLE PERSONAL_TECNICO (
    id_personal INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    especialidad VARCHAR(100) NOT NULL,
    cargo VARCHAR(100),
    telefono VARCHAR(20),
    estado TINYINT(1) DEFAULT 1
);

-- ------------------------------------------------------------------------
-- 11. TABLA INTERMEDIA: DETALLE_ORDEN_PERSONAL (N:M)
-- ------------------------------------------------------------------------
CREATE TABLE DETALLE_ORDEN_PERSONAL (
    id_detalle_personal INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    id_personal INT NOT NULL,
    rol_en_trabajo VARCHAR(50),
    horas_trabajadas DECIMAL(5,2) DEFAULT 0.00,
    CONSTRAINT fk_dop_orden FOREIGN KEY (id_orden) REFERENCES ORDEN_TRABAJO(id_orden),
    CONSTRAINT fk_dop_personal FOREIGN KEY (id_personal) REFERENCES PERSONAL_TECNICO(id_personal)
);

-- ------------------------------------------------------------------------
-- 14. TABLA: PROVEEDOR (Definida antes de repuesto por su dependencia)
-- ------------------------------------------------------------------------
CREATE TABLE PROVEEDOR (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    razon_social VARCHAR(150) NOT NULL,
    ruc VARCHAR(20) NOT NULL UNIQUE,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(100),
    estado TINYINT(1) DEFAULT 1
);

-- ------------------------------------------------------------------------
-- 13. TABLA: REPUESTO
-- ------------------------------------------------------------------------
CREATE TABLE REPUESTO (
    id_repuesto INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    estado TINYINT(1) DEFAULT 1,
    CONSTRAINT fk_repuesto_proveedor FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id_proveedor)
);

-- ------------------------------------------------------------------------
-- 12. TABLA INTERMEDIA: DETALLE_ORDEN_REPUESTO (N:M)
-- ------------------------------------------------------------------------
CREATE TABLE DETALLE_ORDEN_REPUESTO (
    id_detalle_repuesto INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    id_repuesto INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_dor_orden FOREIGN KEY (id_orden) REFERENCES ORDEN_TRABAJO(id_orden),
    CONSTRAINT fk_dor_repuesto FOREIGN KEY (id_repuesto) REFERENCES REPUESTO(id_repuesto)
);

-- ------------------------------------------------------------------------
-- 15. TABLA: COSTO_MANTENIMIENTO
-- ------------------------------------------------------------------------
CREATE TABLE COSTO_MANTENIMIENTO (
    id_costo INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL UNIQUE,
    costo_repuestos DECIMAL(12,2) DEFAULT 0.00,
    costo_mano_obra DECIMAL(12,2) DEFAULT 0.00,
    costo_servicios DECIMAL(12,2) DEFAULT 0.00,
    otros_costos DECIMAL(12,2) DEFAULT 0.00,
    costo_total DECIMAL(12,2) DEFAULT 0.00,
    CONSTRAINT fk_costo_orden FOREIGN KEY (id_orden) REFERENCES ORDEN_TRABAJO(id_orden)
);

-- ------------------------------------------------------------------------
-- 16. TABLA: AUDITORIA
-- ------------------------------------------------------------------------
CREATE TABLE AUDITORIA (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,
    registro_id INT NOT NULL,
    accion VARCHAR(20) NOT NULL,
    detalle TEXT,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(45),
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
);


