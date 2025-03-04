-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS ControlGastos;
USE ControlGastos;

-- Crear la tabla de Usuarios
CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL
);

-- Crear la tabla de Categorías
CREATE TABLE Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- Crear la tabla de Métodos de Pago
CREATE TABLE MetodosPago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- Crear la tabla de Gastos
CREATE TABLE Gastos (
    id_gasto INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_categoria INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria),
    FOREIGN KEY (id_metodo_pago) REFERENCES MetodosPago(id_metodo_pago)
);

-- Crear la tabla de Ingresos
CREATE TABLE Ingresos (
    id_ingreso INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

-- Script para Control de Gastos Familiares - Segunda Entrega
-- Alumno: Bosatta


-- ----------------------------------------
-- INSERCIÓN DE DATOS DE PRUEBA
-- ----------------------------------------

-- Insertar usuarios
INSERT INTO Usuarios (nombre, email, contraseña) VALUES
('Juan Pérez', 'juan@example.com', SHA2('password123', 256)),
('María García', 'maria@example.com', SHA2('securepass', 256)),
('Carlos Rodríguez', 'carlos@example.com', SHA2('mypassword', 256)),
('Ana López', 'ana@example.com', SHA2('12345678', 256));

-- Insertar categorías de gastos
INSERT INTO Categorias (nombre) VALUES
('Alimentación'),
('Transporte'),
('Vivienda'),
('Entretenimiento'),
('Salud'),
('Educación'),
('Ropa'),
('Servicios'),
('Otros');

-- Insertar métodos de pago
INSERT INTO MetodosPago (nombre) VALUES
('Efectivo'),
('Tarjeta de Crédito'),
('Tarjeta de Débito'),
('Transferencia Bancaria'),
('Aplicación Móvil');

-- Insertar gastos
INSERT INTO Gastos (id_usuario, id_categoria, id_metodo_pago, monto, fecha, descripcion) VALUES
(1, 1, 1, 150.50, '2023-01-15', 'Compra semanal en supermercado'),
(1, 2, 2, 50.00, '2023-01-16', 'Gasolina'),
(1, 4, 2, 120.00, '2023-01-20', 'Cena en restaurante'),
(2, 1, 3, 200.30, '2023-01-10', 'Compras en supermercado'),
(2, 3, 4, 800.00, '2023-01-05', 'Alquiler de vivienda'),
(2, 5, 3, 150.00, '2023-01-18', 'Consulta médica'),
(3, 1, 1, 100.00, '2023-02-05', 'Compra de víveres'),
(3, 6, 4, 300.00, '2023-02-10', 'Curso en línea'),
(3, 7, 2, 120.50, '2023-02-15', 'Compra de ropa'),
(4, 8, 5, 75.00, '2023-02-08', 'Pago de teléfono'),
(4, 3, 4, 700.00, '2023-02-03', 'Alquiler'),
(4, 4, 3, 85.00, '2023-02-18', 'Suscripción a streaming'),
(1, 1, 1, 180.20, '2023-03-10', 'Compra en supermercado'),
(2, 2, 2, 60.00, '2023-03-12', 'Transporte público mensual'),
(3, 5, 3, 200.00, '2023-03-15', 'Medicamentos'),
(4, 4, 5, 150.00, '2023-03-20', 'Concierto');

-- Insertar ingresos
INSERT INTO Ingresos (id_usuario, monto, fecha, descripcion) VALUES
(1, 3000.00, '2023-01-05', 'Salario mensual'),
(1, 500.00, '2023-01-20', 'Trabajo freelance'),
(2, 2800.00, '2023-01-05', 'Salario'),
(2, 400.00, '2023-01-15', 'Venta de artículos usados'),
(3, 3200.00, '2023-02-05', 'Salario'),
(3, 300.00, '2023-02-25', 'Reembolso de gastos'),
(4, 2500.00, '2023-02-05', 'Salario'),
(4, 600.00, '2023-02-18', 'Bono por desempeño'),
(1, 3000.00, '2023-03-05', 'Salario mensual'),
(2, 2800.00, '2023-03-05', 'Salario'),
(3, 3200.00, '2023-03-05', 'Salario'),
(4, 2500.00, '2023-03-05', 'Salario');

-- ----------------------------------------
-- CREACIÓN DE TABLAS ADICIONALES PARA TRIGGERS
-- ----------------------------------------

-- Tabla para estadísticas de categorías
CREATE TABLE IF NOT EXISTS Estadisticas_Categorias (
    id_categoria INT NOT NULL,
    total_gastado DECIMAL(15,2) DEFAULT 0,
    cantidad_transacciones INT DEFAULT 0,
    ultimo_gasto DATE,
    PRIMARY KEY (id_categoria),
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

-- Inicializar la tabla con las categorías existentes
INSERT INTO Estadisticas_Categorias (id_categoria, total_gastado, cantidad_transacciones)
SELECT id_categoria, 0, 0 FROM Categorias
ON DUPLICATE KEY UPDATE total_gastado = total_gastado;

-- Tabla para auditoría de cambios en usuarios
CREATE TABLE IF NOT EXISTS Log_Cambios_Usuario (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    accion VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_db VARCHAR(100),
    datos_anteriores TEXT,
    datos_nuevos TEXT
);

-- ----------------------------------------
-- CREACIÓN DE VISTAS
-- ----------------------------------------

-- Vista para resumen de gastos mensuales
CREATE OR REPLACE VIEW v_resumen_gastos_mensuales AS
SELECT 
    YEAR(g.fecha) AS año,
    MONTH(g.fecha) AS mes,
    c.nombre AS categoria,
    u.nombre AS usuario,
    SUM(g.monto) AS total_gastado,
    COUNT(*) AS cantidad_transacciones
FROM 
    Gastos g
JOIN 
    Categorias c ON g.id_categoria = c.id_categoria
JOIN 
    Usuarios u ON g.id_usuario = u.id_usuario
GROUP BY 
    YEAR(g.fecha), MONTH(g.fecha), c.nombre, u.nombre
ORDER BY 
    YEAR(g.fecha), MONTH(g.fecha), total_gastado DESC;

-- Vista para balance mensual
CREATE OR REPLACE VIEW v_balance_mensual AS
SELECT 
    u.nombre AS usuario,
    YEAR(periodo) AS año,
    MONTH(periodo) AS mes,
    SUM(ingresos) AS total_ingresos,
    SUM(gastos) AS total_gastos,
    SUM(ingresos - gastos) AS balance
FROM (
    SELECT 
        id_usuario,
        fecha AS periodo,
        monto AS ingresos,
        0 AS gastos
    FROM 
        Ingresos
    UNION ALL
    SELECT 
        id_usuario,
        fecha AS periodo,
        0 AS ingresos,
        monto AS gastos
    FROM 
        Gastos
) AS movimientos
JOIN 
    Usuarios u ON movimientos.id_usuario = u.id_usuario
GROUP BY 
    u.nombre, YEAR(periodo), MONTH(periodo)
ORDER BY 
    u.nombre, YEAR(periodo), MONTH(periodo);

-- Vista para métodos de pago frecuentes
CREATE OR REPLACE VIEW v_metodos_pago_frecuentes AS
SELECT 
    u.nombre AS usuario,
    mp.nombre AS metodo_pago,
    COUNT(*) AS frecuencia_uso,
    SUM(g.monto) AS total_gastado,
    ROUND((COUNT(*) * 100.0 / user_counts.total), 2) AS porcentaje_uso
FROM 
    Gastos g
JOIN 
    Usuarios u ON g.id_usuario = u.id_usuario
JOIN 
    MetodosPago mp ON g.id_metodo_pago = mp.id_metodo_pago
JOIN (
    SELECT id_usuario, COUNT(*) AS total
    FROM Gastos
    GROUP BY id_usuario
) AS user_counts ON g.id_usuario = user_counts.id_usuario
GROUP BY 
    u.nombre, mp.nombre
ORDER BY 
    u.nombre, frecuencia_uso DESC;

-- Vista para gastos por categoría
CREATE OR REPLACE VIEW v_gastos_por_categoria AS
SELECT 
    u.nombre AS usuario,
    c.nombre AS categoria,
    SUM(g.monto) AS total_gastado,
    ROUND((SUM(g.monto) * 100.0 / user_totals.total), 2) AS porcentaje_del_total
FROM 
    Gastos g
JOIN 
    Usuarios u ON g.id_usuario = u.id_usuario
JOIN 
    Categorias c ON g.id_categoria = c.id_categoria
JOIN (
    SELECT id_usuario, SUM(monto) AS total
    FROM Gastos
    GROUP BY id_usuario
) AS user_totals ON g.id_usuario = user_totals.id_usuario
GROUP BY 
    u.nombre, c.nombre
ORDER BY 
    u.nombre, total_gastado DESC;

-- ----------------------------------------
-- CREACIÓN DE FUNCIONES
-- ----------------------------------------

-- Función para calcular total de gastos en un período
DELIMITER //
CREATE FUNCTION f_calcular_total_gastos_periodo(
    p_id_usuario INT, 
    p_fecha_inicio DATE, 
    p_fecha_fin DATE
) RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(15,2);
    
    SELECT COALESCE(SUM(monto), 0) INTO total
    FROM Gastos
    WHERE id_usuario = p_id_usuario
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    RETURN total;
END //
DELIMITER ;

-- Función para calcular balance en un período
DELIMITER //
CREATE FUNCTION f_calcular_balance_periodo(
    p_id_usuario INT, 
    p_fecha_inicio DATE, 
    p_fecha_fin DATE
) RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE total_ingresos DECIMAL(15,2);
    DECLARE total_gastos DECIMAL(15,2);
    DECLARE balance DECIMAL(15,2);
    
    -- Calcular total de ingresos
    SELECT COALESCE(SUM(monto), 0) INTO total_ingresos
    FROM Ingresos
    WHERE id_usuario = p_id_usuario
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    -- Calcular total de gastos
    SELECT COALESCE(SUM(monto), 0) INTO total_gastos
    FROM Gastos
    WHERE id_usuario = p_id_usuario
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    -- Calcular balance
    SET balance = total_ingresos - total_gastos;
    
    RETURN balance;
END //
DELIMITER ;

-- Función para calcular porcentaje de gasto por categoría
DELIMITER //
CREATE FUNCTION f_porcentaje_gasto_categoria(
    p_id_usuario INT, 
    p_id_categoria INT,
    p_fecha_inicio DATE, 
    p_fecha_fin DATE
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_categoria DECIMAL(15,2);
    DECLARE total_general DECIMAL(15,2);
    DECLARE porcentaje DECIMAL(5,2);
    
    -- Calcular total de gastos en la categoría
    SELECT COALESCE(SUM(monto), 0) INTO total_categoria
    FROM Gastos
    WHERE id_usuario = p_id_usuario
    AND id_categoria = p_id_categoria
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    -- Calcular total de gastos general
    SELECT COALESCE(SUM(monto), 0) INTO total_general
    FROM Gastos
    WHERE id_usuario = p_id_usuario
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    -- Calcular porcentaje
    IF total_general > 0 THEN
        SET porcentaje = (total_categoria / total_general) * 100;
    ELSE
        SET porcentaje = 0;
    END IF;
    
    RETURN ROUND(porcentaje, 2);
END //
DELIMITER ;

-- Función para identificar meses sin gastos
DELIMITER //
CREATE FUNCTION f_meses_sin_gastos(
    p_id_usuario INT,
    p_año INT
) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE meses_sin_gastos VARCHAR(255) DEFAULT '';
    DECLARE mes INT;
    DECLARE tiene_gastos BOOLEAN;
    
    SET mes = 1;
    
    WHILE mes <= 12 DO
        SELECT EXISTS(
            SELECT 1 FROM Gastos 
            WHERE id_usuario = p_id_usuario 
            AND YEAR(fecha) = p_año 
            AND MONTH(fecha) = mes
        ) INTO tiene_gastos;
        
        IF NOT tiene_gastos THEN
            SET meses_sin_gastos = CONCAT(meses_sin_gastos, 
                                         CASE 
                                             WHEN mes = 1 THEN 'Enero'
                                             WHEN mes = 2 THEN 'Febrero'
                                             WHEN mes = 3 THEN 'Marzo'
                                             WHEN mes = 4 THEN 'Abril'
                                             WHEN mes = 5 THEN 'Mayo'
                                             WHEN mes = 6 THEN 'Junio'
                                             WHEN mes = 7 THEN 'Julio'
                                             WHEN mes = 8 THEN 'Agosto'
                                             WHEN mes = 9 THEN 'Septiembre'
                                             WHEN mes = 10 THEN 'Octubre'
                                             WHEN mes = 11 THEN 'Noviembre'
                                             WHEN mes = 12 THEN 'Diciembre'
                                         END, 
                                         ', ');
        END IF;
        
        SET mes = mes + 1;
    END WHILE;
    
    -- Eliminar la última coma y espacio si hay meses sin gastos
    IF LENGTH(meses_sin_gastos) > 0 THEN
        SET meses_sin_gastos = SUBSTRING(meses_sin_gastos, 1, LENGTH(meses_sin_gastos) - 2);
    ELSE
        SET meses_sin_gastos = 'Ninguno';
    END IF;
    
    RETURN meses_sin_gastos;
END //
DELIMITER ;

-- ----------------------------------------
-- CREACIÓN DE STORED PROCEDURES
-- ----------------------------------------

-- SP para insertar un nuevo gasto
DELIMITER //
CREATE PROCEDURE sp_insertar_gasto(
    IN p_id_usuario INT,
    IN p_id_categoria INT,
    IN p_id_metodo_pago INT,
    IN p_monto DECIMAL(10,2),
    IN p_fecha DATE,
    IN p_descripcion TEXT,
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    DECLARE usuario_existe INT;
    DECLARE categoria_existe INT;
    DECLARE metodo_pago_existe INT;
    
    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO usuario_existe FROM Usuarios WHERE id_usuario = p_id_usuario;
    
    -- Verificar si la categoría existe
    SELECT COUNT(*) INTO categoria_existe FROM Categorias WHERE id_categoria = p_id_categoria;
    
    -- Verificar si el método de pago existe
    SELECT COUNT(*) INTO metodo_pago_existe FROM MetodosPago WHERE id_metodo_pago = p_id_metodo_pago;
    
    -- Validar y procesar
    IF usuario_existe = 0 THEN
        SET p_mensaje = 'Error: El usuario no existe';
    ELSEIF categoria_existe = 0 THEN
        SET p_mensaje = 'Error: La categoría no existe';
    ELSEIF metodo_pago_existe = 0 THEN
        SET p_mensaje = 'Error: El método de pago no existe';
    ELSEIF p_monto <= 0 THEN
        SET p_mensaje = 'Error: El monto debe ser mayor que cero';
    ELSE
        -- Insertar el gasto
        INSERT INTO Gastos (id_usuario, id_categoria, id_metodo_pago, monto, fecha, descripcion)
        VALUES (p_id_usuario, p_id_categoria, p_id_metodo_pago, p_monto, p_fecha, p_descripcion);
        
        SET p_mensaje = 'Gasto registrado correctamente';
    END IF;
END //
DELIMITER ;

-- SP para actualizar categoría
DELIMITER //
CREATE PROCEDURE sp_actualizar_categoria(
    IN p_id_categoria INT,
    IN p_nombre VARCHAR(50),
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE nombre_existente INT;
    
    -- Verificar si ya existe una categoría con ese nombre
    SELECT COUNT(*) INTO nombre_existente 
    FROM Categorias 
    WHERE nombre = p_nombre AND id_categoria != p_id_categoria;
    
    IF nombre_existente > 0 THEN
        SET p_resultado = 'Error: Ya existe una categoría con ese nombre';
    ELSE
        UPDATE Categorias 
        SET nombre = p_nombre 
        WHERE id_categoria = p_id_categoria;
        
        IF ROW_COUNT() > 0 THEN
            SET p_resultado = 'Categoría actualizada correctamente';
        ELSE
            SET p_resultado = 'Error: No se encontró la categoría o no se realizaron cambios';
        END IF;
    END IF;
END //
DELIMITER ;

-- SP para generar reporte mensual
DELIMITER //
CREATE PROCEDURE sp_generar_reporte_mensual(
    IN p_id_usuario INT,
    IN p_año INT,
    IN p_mes INT
)
BEGIN
    DECLARE fecha_inicio DATE;
    DECLARE fecha_fin DATE;
    
    -- Definir el rango de fechas para el mes especificado
    SET fecha_inicio = DATE(CONCAT(p_año, '-', p_mes, '-01'));
    SET fecha_fin = LAST_DAY(fecha_inicio);
    
    -- Información general del período
    SELECT 
        CONCAT('Reporte del mes de ', 
               CASE 
                   WHEN p_mes = 1 THEN 'Enero'
                   WHEN p_mes = 2 THEN 'Febrero'
                   WHEN p_mes = 3 THEN 'Marzo'
                   WHEN p_mes = 4 THEN 'Abril'
                   WHEN p_mes = 5 THEN 'Mayo'
                   WHEN p_mes = 6 THEN 'Junio'
                   WHEN p_mes = 7 THEN 'Julio'
                   WHEN p_mes = 8 THEN 'Agosto'
                   WHEN p_mes = 9 THEN 'Septiembre'
                   WHEN p_mes = 10 THEN 'Octubre'
                   WHEN p_mes = 11 THEN 'Noviembre'
                   WHEN p_mes = 12 THEN 'Diciembre'
               END, 
               ' de ', p_año) AS periodo,
        (SELECT nombre FROM Usuarios WHERE id_usuario = p_id_usuario) AS usuario;
    
    -- Resumen de ingresos
    SELECT 
        'INGRESOS' AS tipo,
        SUM(monto) AS total,
        COUNT(*) AS num_transacciones,
        ROUND(AVG(monto), 2) AS promedio
    FROM 
        Ingresos
    WHERE 
        id_usuario = p_id_usuario AND
        fecha BETWEEN fecha_inicio AND fecha_fin;
    
    -- Resumen de gastos
    SELECT 
        'GASTOS' AS tipo,
        SUM(monto) AS total,
        COUNT(*) AS num_transacciones,
        ROUND(AVG(monto), 2) AS promedio
    FROM 
        Gastos
    WHERE 
        id_usuario = p_id_usuario AND
        fecha BETWEEN fecha_inicio AND fecha_fin;
    
    -- Balance del período
    SELECT 
        (SELECT COALESCE(SUM(monto), 0) FROM Ingresos 
         WHERE id_usuario = p_id_usuario AND fecha BETWEEN fecha_inicio AND fecha_fin) -
        (SELECT COALESCE(SUM(monto), 0) FROM Gastos 
         WHERE id_usuario = p_id_usuario AND fecha BETWEEN fecha_inicio AND fecha_fin) AS balance;
    
    -- Desglose de gastos por categoría
    SELECT 
        c.nombre AS categoria,
        SUM(g.monto) AS total_gastado,
        COUNT(*) AS num_transacciones,
        ROUND(AVG(g.monto), 2) AS promedio_por_transaccion,
        ROUND((SUM(g.monto) * 100.0 / 
              (SELECT COALESCE(SUM(monto), 0) FROM Gastos 
               WHERE id_usuario = p_id_usuario AND fecha BETWEEN fecha_inicio AND fecha_fin)), 2) AS porcentaje_del_total
    FROM 
        Gastos g
    JOIN 
        Categorias c ON g.id_categoria = c.id_categoria
    WHERE 
        g.id_usuario = p_id_usuario AND
        g.fecha BETWEEN fecha_inicio AND fecha_fin
    GROUP BY 
        c.nombre
    ORDER BY 
        total_gastado DESC;
    
    -- Desglose de gastos por método de pago
    SELECT 
        mp.nombre AS metodo_pago,
        SUM(g.monto) AS total_gastado,
        COUNT(*) AS num_transacciones
    FROM 
        Gastos g
    JOIN 
        MetodosPago mp ON g.id_metodo_pago = mp.id_metodo_pago
    WHERE 
        g.id_usuario = p_id_usuario AND
        g.fecha BETWEEN fecha_inicio AND fecha_fin
    GROUP BY 
        mp.nombre
    ORDER BY 
        total_gastado DESC;
    
    -- Listado detallado de gastos
    SELECT 
        g.fecha,
        c.nombre AS categoria,
        mp.nombre AS metodo_pago,
        g.monto,
        g.descripcion
    FROM 
        Gastos g
    JOIN 
        Categorias c ON g.id_categoria = c.id_categoria
    JOIN 
        MetodosPago mp ON g.id_metodo_pago = mp.id_metodo_pago
    WHERE 
        g.id_usuario = p_id_usuario AND
        g.fecha BETWEEN fecha_inicio AND fecha_fin
    ORDER BY 
        g.fecha;
END //
DELIMITER ;

-- SP para transferir gastos entre usuarios
DELIMITER //
CREATE PROCEDURE sp_transferir_gastos(
    IN p_id_usuario_origen INT,
    IN p_id_usuario_destino INT,
    OUT p_gastos_transferidos INT
)
BEGIN
    DECLARE usuario_origen_existe INT;
    DECLARE usuario_destino_existe INT;
    
    -- Verificar si los usuarios existen
    SELECT COUNT(*) INTO usuario_origen_existe FROM Usuarios WHERE id_usuario = p_id_usuario_origen;
    SELECT COUNT(*) INTO usuario_destino_existe FROM Usuarios WHERE id_usuario = p_id_usuario_destino;
    
    -- Validar usuarios
    IF usuario_origen_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de origen no existe';
    ELSEIF usuario_destino_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de destino no existe';
    ELSEIF p_id_usuario_origen = p_id_usuario_destino THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los usuarios de origen y destino son los mismos';
    ELSE
        -- Transferir gastos
        UPDATE Gastos 
        SET id_usuario = p_id_usuario_destino 
        WHERE id_usuario = p_id_usuario_origen;
        
        -- Retornar cantidad de gastos transferidos
        SET p_gastos_transferidos = ROW_COUNT();
    END IF;
END //
DELIMITER ;

-- ----------------------------------------
-- CREACIÓN DE TRIGGERS
-- ----------------------------------------

-- Trigger para actualizar estadísticas después de insertar gasto
DELIMITER //
CREATE TRIGGER trg_after_insert_gasto
AFTER INSERT ON Gastos
FOR EACH ROW
BEGIN
    -- Actualizar estadísticas de categoría
    UPDATE Estadisticas_Categorias
    SET 
        total_gastado = total_gastado + NEW.monto,
        cantidad_transacciones = cantidad_transacciones + 1,
        ultimo_gasto = NEW.fecha
    WHERE id_categoria = NEW.id_categoria;
END //
DELIMITER ;

-- Trigger para prevenir eliminación de categorías en uso
DELIMITER //
CREATE TRIGGER trg_before_delete_categoria
BEFORE DELETE ON Categorias
FOR EACH ROW
BEGIN
    DECLARE gastos_asociados INT;
    
    -- Verificar si hay gastos asociados a la categoría
    SELECT COUNT(*) INTO gastos_asociados FROM Gastos WHERE id_categoria = OLD.id_categoria;
    
    -- Si hay gastos asociados, prevenir la eliminación
    IF gastos_asociados > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar esta categoría porque tiene gastos asociados';
    END IF;
END //
DELIMITER ;

-- Trigger para registrar cambios en usuarios
DELIMITER //
CREATE TRIGGER trg_after_update_usuario
AFTER UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Log_Cambios_Usuario (id_usuario, accion, usuario_db, datos_anteriores, datos_nuevos)
    VALUES (
        NEW.id_usuario,
        'UPDATE',
        CURRENT_USER(),
        CONCAT('Nombre: ', OLD.nombre, ', Email: ', OLD.email),
        CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email)
    );
END //
DELIMITER ;

-- Trigger para registrar eliminación de usuarios
DELIMITER //
CREATE TRIGGER trg_before_delete_usuario
BEFORE DELETE ON Usuarios
FOR EACH ROW
BEGIN
    -- Registrar la acción de eliminación
    INSERT INTO Log_Cambios_Usuario (id_usuario, accion, usuario_db, datos_anteriores, datos_nuevos)
    VALUES (
        OLD.id_usuario,
        'DELETE',
        CURRENT_USER(),
        CONCAT('Nombre: ', OLD.nombre, ', Email: ', OLD.email),
        NULL
    );
    
    -- Verificar si hay gastos o ingresos asociados
    DECLARE gastos_asociados INT;
    DECLARE ingresos_asociados INT;
    
    SELECT COUNT(*) INTO gastos_asociados FROM Gastos WHERE id_usuario = OLD.id_usuario;
    SELECT COUNT(*) INTO ingresos_asociados FROM Ingresos WHERE id_usuario = OLD.id_usuario;
    
    -- Si hay registros asociados, prevenir la eliminación
    IF gastos_asociados > 0 OR ingresos_asociados > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar este usuario porque tiene gastos o ingresos asociados';
    END IF;
END //
DELIMITER ;
