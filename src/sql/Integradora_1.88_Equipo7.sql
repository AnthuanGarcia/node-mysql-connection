/*
Universidad Tecnologica de Chihuahua (UTCH)
TI: Desarrollo de software Multiplataforma
Cuatrimestre III
Mayo-Agosto 2020

Integrantes:
Ricardo Trillo Garcia				6516150032
Luis Daniel Vaquera Delgado			1119150037
Carlos Anthuan Garcia Castellanos	1119150123

								Proyecto Integrador
Se realizara un sitio web  para la venta de
distintos productos y servicios enfocados en el mantenimiento industrial.

El sistema debe ser capaz de:
	# Desplegar un menu con los diferentes tipos de mantenimiento, con sus descripciones y pro medio del cual el cliente sera capaz de solicitar 
	una cotizacion mediante un apartado de envio de mensajes destinado a la empresa, en el cual especificarala cantidad de de equipos con sus correspondientes
	especificacones.
	
	# Mostrar los diferentes productos que maneja y la empresa su disponibilidad.

	# Almacenamiento persistente de los clientes con sus datos de contacto

	# Poder facturar los productos anteriormente mencionados

	# De brindar al administrador la capacidad de adjudicar documentos a las cuentas de los clientes en formato de PDF e imagen.
    
Todo esto con el fin de facilitarle a la empresa la posibilidad de dar conocer sus servicios y productos a los clientes y 
desplegarle algunas un menu de opciones que le faciliten al cliente la adquisicion de ellos. 
*/

/*			Fechas
Fch. inicio: 				20/05/2020
Fch. aprobacion: 			20/06/2020*
Fch. ultima modificacion: 	22/07/2020
Fch. ultima revision: 		30/06/2020*
*/

-- ----------------------------
# Creacion base de datos
-- ----------------------------
CREATE DATABASE IF NOT EXISTS integradora;
USE integradora;

-- ----------------------------
# Alta de usuarios
-- ----------------------------
CREATE USER 'RTrillo'@'localhost' 	IDENTIFIED BY 'bfk7_3k'
									WITH MAX_QUERIES_PER_HOUR 120
                                    FAILED_LOGIN_ATTEMPTS 10 PASSWORD_LOCK_TIME 1; 

CREATE USER 'Operator'@'localhost'	IDENTIFIED BY '795*r26'
									WITH MAX_QUERIES_PER_HOUR 100
                                    FAILED_LOGIN_ATTEMPTS 10 PASSWORD_LOCK_TIME 1;

CREATE USER 'Developer'@'localhost'	IDENTIFIED BY '_e7v7qs'
									FAILED_LOGIN_ATTEMPTS 10 PASSWORD_LOCK_TIME 1;

-- ----------------------------
# Estructura BD
-- ----------------------------
CREATE TABLE IF NOT EXISTS productos (
    `idProductos` 	INT NOT NULL,
    `nombre` 		VARCHAR(60) NULL,
    `cantidad` 		INT(6) NULL,
    `precioPro` 	FLOAT NULL,
    `descripcion` 	TEXT,
    PRIMARY KEY (`idProductos`)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS servicios (
    `idServicios` 	INT NOT NULL,
    `nombre` 		VARCHAR(60) NOT NULL,
    `tipo` 			VARCHAR(30) NULL,
    `precioSer` 	FLOAT NULL,
    `descripcion` 	VARCHAR(150) NULL,
    `idEmpleado` 	INT NOT NULL,
    PRIMARY KEY (`idServicios`)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS cliente (
    idCliente 	INT NOT NULL,
    nombre 		VARCHAR(20) NOT NULL,
    apellido 	VARCHAR(20) NOT NULL,
    direccion 	VARCHAR(50) NOT NULL,
    email 		VARCHAR(50) NOT NULL,
    telefono 	INT(10) NOT NULL,
    rfc 		VARCHAR(15) NOT NULL,
    PRIMARY KEY (idCliente)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS empleados (
    idEmpleado 		INT NOT NULL,
    nombre 			VARCHAR(20) NOT NULL,
    apellido 		VARCHAR(20) NOT NULL,
    especialidad 	VARCHAR(30) NOT NULL,
    telefono 		INT(10) NOT NULL,
    email 			VARCHAR(50) NOT NULL,
    PRIMARY KEY (idEmpleado)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS bitacora (
    idBi 			INT AUTO_INCREMENT NOT NULL,
    usuario 		VARCHAR(40) NOT NULL,
    tabla 			VARCHAR(40) NOT NULL,
    modificacion 	DATETIME,
    accion 			VARCHAR(40) NOT NULL,
    PRIMARY KEY (idBi)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS factura (
    idFactura 	INT AUTO_INCREMENT NOT NULL,
    fecha 		DATE NOT NULL,
    idCliente 	INT NOT NULL,
    tipoPago 	VARCHAR(10) NOT NULL,
    PRIMARY KEY (idFactura)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS detalle (
    idDetalle 			INT AUTO_INCREMENT NOT NULL,
    idFactura 			INT NOT NULL,
    idProductos 		INT NOT NULL,
    cantidad INT(10) 	NOT NULL,
    precio FLOAT(10) 	NOT NULL,
    PRIMARY KEY (idDetalle , idFactura)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS cotizacion (
    idCotizacion 	INT NOT NULL,
    idCliente 		INT NOT NULL,
    fecha 			DATE NOT NULL,
    PRIMARY KEY (idCotizacion)
)  ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS detalleServicios (
    idServicios 	INT NOT NULL,
    idCotizacion 	INT NOT NULL,
    PRIMARY KEY (idServicios , idCotizacion)
)  ENGINE=INNODB;

-- ----------------------------
# Llaves foraneas
-- ----------------------------
ALTER TABLE factura
ADD FOREIGN KEY (idCliente)
REFERENCES 	cliente(idCliente);

ALTER TABLE detalle
ADD FOREIGN KEY(idProductos)
REFERENCES productos(idProductos);

ALTER TABLE detalle
ADD FOREIGN KEY(idFactura)
REFERENCES factura(idFactura);

ALTER TABLE cotizacion
ADD FOREIGN KEY (idCliente)
REFERENCES cliente(idCliente);
/*
ALTER TABLE cotizacion
ADD FOREIGN KEY (idServicios)
REFERENCES servicios(idServicios);
*/
ALTER TABLE detalleServicios
ADD FOREIGN KEY (idServicios)
REFERENCES servicios(idServicios);

ALTER TABLE servicios
ADD FOREIGN KEY (idEmpleado)
REFERENCES empleados(idEmpleado);

ALTER TABLE detalleServicios
ADD FOREIGN KEY (idCotizacion)
REFERENCES cotizacion(idCotizacion);

/*
ALTER TABLE factura
add foreign key (idCliente)
references cliente(idCliente);
*/

############ Privilegios Usuarios ############

# RTrillo: Administra y actualiza productos y servicios, aunado con la gestion de empleados
GRANT SELECT, INSERT, UPDATE, DELETE ON integradora.* TO 'RTrillo'@'localhost';

# Operator: Administra y actualiza productos y servicios
GRANT SELECT, INSERT, UPDATE, DELETE ON integradora.productos 		 TO 'Operator'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON integradora.servicios 		 TO 'Operator'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON integradora.detalle 		 TO 'Operator'@'localhost'; 
GRANT SELECT, INSERT, UPDATE, DELETE ON integradora.detalleServicios TO 'Operator'@'localhost';

# Developer: Administrador y tester para pruebas del sistema
GRANT ALL ON integradora.* TO 'Developer'@'localhost';
##############################################

-- ----------------------------
# Disparadores
-- ----------------------------
########	RestaurarCotizacion		##########
-- Trigger para actualizar la fecha de cotizacion al modificar una factura

DELIMITER //
	CREATE TRIGGER RestaurarCotizacion
		AFTER UPDATE 
		ON integradora.factura
			FOR EACH ROW
				BEGIN
					UPDATE cotizacion
                    SET fecha = NOW()
                    WHERE new.idCliente = cotizacion.idCliente;
				END //
DELIMITER ;
/*####	Comprobacion RestaurarCotizacion	####
-- Se actualiza el metodo de pago de un cliente, y por ende se actualiza la cotizacion

SELECT * FROM cotizacion WHERE idCliente = 8;

UPDATE factura
SET tipoPago = "Digital"
WHERE idCliente = 8;

SELECT *
FROM cotizacion
WHERE idCliente = 8;
*/
##############################################

#############	Actualizar	##################
-- Disparador que actualiza la cantidad de productos en "stock", cuando se realiza un compra

#DROP TRIGGER Actualizar;
DELIMITER //
	CREATE TRIGGER Actualizar
		BEFORE INSERT 
		ON integradora.detalle
			FOR EACH ROW
                BEGIN
					UPDATE productos
                    SET productos.cantidad = productos.cantidad - new.cantidad
                    WHERE productos.idProductos = new.idProductos;
				END //
DELIMITER ;

/*
#### Comprobacion Actualizar ####
-- Verificamos la cantidad que hay en stock, para comprobar que la resta al stock es satisfactoria

SELECT P.idProductos AS "Id Producto", (DET.cantidad + P.cantidad) AS "Cantidad original", DET.cantidad AS "Unidades compradas",
P.cantidad AS "Cantidad almac.", cliente.idCliente AS "Id. Cliente"
FROM productos AS P, cliente, detalle AS DET, factura AS F
WHERE DET.idProductos = P.idProductos
AND F.idCliente = cliente.idCliente
AND DET.idFactura = F.idFactura
ORDER BY P.idProductos asc;
*/
##############################################

#############	Eliminar	##################
-- Disparador que actualiza la cant. de productos , al eliminar un pedido

#DROP TRIGGER Eliminar;
DELIMITER //
	CREATE TRIGGER Eliminar
		AFTER DELETE ON integradora.detalle
			FOR EACH ROW
				BEGIN
					UPDATE productos
                    SET productos.cantidad = productos.cantidad + OLD.cantidad
                    WHERE productos.idProductos = OLD.idProductos;
				END //
DELIMITER ;
/* 
#### Comprobacion Eliminacion ####

-- Eliminamos pedidos
DELETE FROM detalle
WHERE idDetalle = 2 
AND idDetalle = 3	
AND idDetalle = 4; 

-- Una vez eliminados los pedidos la cantidad es devuelta a los productos almacenados
SELECT *
FROM productos
WHERE idProductos BETWEEN 2 AND 4;
*/
##############################################

#################  Bitacora  #################

#Disparador para registrar los insert dentro de la tabla pedidos
DELIMITER // 
	CREATE TRIGGER integradora.bitacoraInsert
		BEFORE INSERT ON integradora.detalle
			FOR EACH ROW
				BEGIN
					INSERT INTO integradora.bitacora (idBi, usuario, tabla, modificacion, accion)
						values	(default, user(), "detalle", NOW(), "Insert");
				END //
DELIMITER ;

#Disparador para registrar los update dentro de la tabla servicios
DELIMITER // 
	CREATE TRIGGER integradora.bitacoraUpdate
		BEFORE UPDATE ON integradora.detalle
			FOR EACH ROW
				BEGIN
					INSERT INTO integradora.bitacora (idBi, usuario, tabla, modificacion, accion)
						values	(default, user(), "detalle", NOW(), "Update");
				END //
DELIMITER ;

#Disparador para registrar los delete dentro de la tabla pedidos
DELIMITER // 
	CREATE TRIGGER integradora.bitacoraDelete
		AFTER DELETE ON integradora.detalle
			FOR EACH ROW
				BEGIN
					INSERT INTO integradora.bitacora (idBi, usuario, tabla, modificacion, accion)
						values	(default, user(), "detalle", NOW(), "Delete");
				END //
DELIMITER ;
/*
#####	Comprobaciones bitacora #####

-- Generamos UPDATE Y DELETE para que se vea plasmado en la bitacora
UPDATE factura
SET  fecha = 20210321
WHERE idCliente = 8;

DELETE FROM detalle
WHERE idFactura = 3;

DELETE FROM factura
WHERE idFactura = 3;

-- Mostramos la bitacora de movimientos en detalle
select *
from bitacora;
*/
##############################################
INSERT INTO productos
VALUES (1, 'producto generico', 15, 250.3, 'Conchetumare qliao cara anchoa XD');

SELECT * FROM productos;
#------------------------------
# Procedimientos almacenados
#------------------------------
############# eliminarCotizacion #############
-- Procedimiento para eliminar una cotizacion a elegir

DELIMITER //
	CREATE PROCEDURE eliminarCotizacion(IN idEliminar INT(5))
		BEGIN 
			DELETE FROM cotizacion 
			WHERE idCliente = idEliminar;
		END //
DELIMITER ;

/*
-- Llamada al procedimiento para eliminar cotizaciones
CALL eliminarCotizacion(6);
SELECT * FROM cotizacion;
*/
##############################################

############### actualizarStock ##############
-- Procedimiento para acualizar cantidad de un producto en stock

DELIMITER //
	CREATE PROCEDURE actualizarStock(IN nombreProducto VARCHAR(60), IN new_cantidad INT(5))
		BEGIN 
			UPDATE productos
            SET cantidad = new_cantidad
            WHERE LOWER(nombre) = nombreProducto;
		END //
DELIMITER ;

/*
-- LLamada a actualizar la cantidad de productos
CALL actualizarStock("transpaleta eléctrica", 100);
SELECT * FROM productos;
*/
##############################################


-- ----------------------------
# Registros a traves de procedimientos almacenados
-- ----------------------------
############## agregarEmpleados ##############
# Procedmiento para insertar registros en empleados

DELIMITER //
	CREATE PROCEDURE agregarEmpleados(
	new_idEmpleado	 INT,
    new_nombre		 VARCHAR(20),
    new_apellido	 VARCHAR(20),
    new_especialidad VARCHAR(30),
    new_telefono	 INT(10),
    new_email		 VARCHAR(50))
		BEGIN
			IF NOT EXISTS (SELECT idEmpleado FROM empleados WHERE idEmpleado = new_idEmpleado) THEN
				INSERT INTO empleados(idEmpleado, nombre, apellido, especialidad, telefono, email)
				VALUES (new_idEmpleado, new_nombre, new_apellido, new_especialidad, new_telefono, new_email);
			ELSE
				SELECT "Este empleado ya esta registrado";
			END IF;
		END //
DELIMITER ;
/*
############################ Registos tabla empleado ###########################	
CALL agregarEmpleados(1, "Facio", "Gonzales", "Ingeniero industrial", 614956633, "faacio@hotmail.com");
CALL agregarEmpleados(2, "Omar", "Ortiz", "Ingeniero en electronica", 614555213, "oomaroo@hotmail.com");
CALL agregarEmpleados(3, "Guillermo", "Lara", "Ingeniero en electricidad", 614448575, "guuuuillaermo@hotmail.com");
CALL agregarEmpleados(4, "Carlos", "Martinez", "Ingeniero en mantenimiento", 614885599, "mmarrtinncarlos@hotmail.com");
CALL agregarEmpleados(5, "Daniel", "Loera", "Tecnico industrial", 614885252, "kloera@hotmail.com");
CALL agregarEmpleados(6, "Anthuan", "Rodriguez", "Tecnico en electronica", 845136595, "aaantuan@hotmail.com");
CALL agregarEmpleados(7, "Alberto", "Garcia", "Tecnico en mantenimiento", 874449586, "aalberttto@hotmail.com");
CALL agregarEmpleados(8, "Jorge", "Martinez", "Tecnico en electricidad", 852645144, "jorge01@hotmail.com");
CALL agregarEmpleados(9, "Miguel", "Estebane", "Tecnico en electricidad", 849966144, "estebane01@hotmail.com");
CALL agregarEmpleados(10, "Roberto", "Fernandez", "Tecnico industrial", 555215686, "fernandezzroberto@hotmail.com");
CALL agregarEmpleados(11, "Eduardo", "Rivera", "Ingeniero en mecanica", 552136996, "riveraaaeduardo@hotmail.com");
CALL agregarEmpleados(12, "Luis", "Salazar", "Ingeniero en electricidad", 551244414, "salazarrrr@hotmail.com");
CALL agregarEmpleados(13, "Miguel", "Ortiz", "Ingeniero en electronica", 551234569, "oooortizamiguel@hotmail.com");
CALL agregarEmpleados(14, "Francisco", "Barraza", "Ingeniero en mantenimiento", 881478874, "barraza0111@hotmail.com");
CALL agregarEmpleados(15, "Heradio", "Galaiz", "Ingeniero industrial", 881965885, "galavizzzz@hotmail.com");
CALL agregarEmpleados(16, "Ignacio", "Diaz", "Ingeniero en electronica", 774568558, "diazzzignacio@hotmail.com");
CALL agregarEmpleados(17, "Roberto", "Rodriguez", "Ingeniero en mecanica", 771455555, "rooodddriguezrooo@hotmail.com");
CALL agregarEmpleados(18, "Lupillo", "Rivera", "Tecnico en mecanica", 777862555, "lupiiiilllo@hotmail.com");
CALL agregarEmpleados(19, "Angel", "Gardea", "Tecnico en electricidad", 778889966, "garddeaaaaaan@hotmail.com");
CALL agregarEmpleados(20, "Edgar", "Villalobos", "Tecnico industrial", 778411111, "villlllalobos@hotmail.com");
CALL agregarEmpleados(21, "Angel", "Cobos", "Tecnico en mecanica", 777885525, "cooooobooos@hotmail.com");
CALL agregarEmpleados(22, "Ricardo", "Morales", "Tecnico en mantenimiento", 881987898, "moooooraleeees@hotmail.com");
CALL agregarEmpleados(23, "Jose", "Morelos", "Ingeniero en mantenimiento", 871996656, "mooooreeeelooos@hotmail.com");
CALL agregarEmpleados(24, "Daniel", "Rivera", "Ingeniero industrial", 451222565, "riverrrrraaaaaadaniel@hotmail.com");
CALL agregarEmpleados(25, "Adrian", "Bencomo", "Ingeniero en mecanica", 542221232, "beeencooomo@hotmail.com");
CALL agregarEmpleados(26, "Raul", "Nuñez", "Ingeniero en electronica", 541779899, "nuññññez@hotmail.com");
CALL agregarEmpleados(27, "Enrique", "Marquez", "Ingeniero en mantenimiento", 654255525, "eeenriqueee@hotmail.com");
CALL agregarEmpleados(28, "Ricardo", "Tarango", "Ingeniero industrial", 656411252, "taaaaraaaango@hotmail.com");
CALL agregarEmpleados(29, "Alan", "Roman", "Ingeniero en mantenimiento", 541222398, "rrromannn@hotmail.com");
CALL agregarEmpleados(30, "David", "Rincon", "Tecnico en mantenimiento", 666325255, "rincooooon@hotmail.com");
CALL agregarEmpleados(31, "Kevin", "Contreras", "Tecnico industrial", 658899899, "contrerasssss@hotmail.com");
CALL agregarEmpleados(32, "Plutarco", "Rincon", "Tecnico en mecanica", 654445885, "rincccccon@hotmail.com");
CALL agregarEmpleados(33, "Francisco", "Martinez", "Tecnico en electricidad", 645552552, "martinezzzzzzz0444@hotmail.com");
CALL agregarEmpleados(34, "Martin", "Roa", "Tecnico en electronica", 566666666, "roooooa@hotmail.com");
CALL agregarEmpleados(35, "Albert", "Rincon", "Tecnico en mantenimiento", 663215228, "rinccccon2225@hotmail.com");
CALL agregarEmpleados(36, "Jorge", "Lares", "Tecnico en electricidad", 888711151, "laaaresss@hotmail.com");
CALL agregarEmpleados(37, "Efrain", "Bencomo", "Tecnico en electronica", 844449858, "eeefrainnn@hotmail.com");
CALL agregarEmpleados(38, "Daniel", "Carlos", "Tenico en industrial", 874552559, "carrrrlossss@hotmail.com");
CALL agregarEmpleados(39, "Fernando", "Estrada", "Tecnio en electricidad", 988996588, "fernannndoestr@hotmail.com");
CALL agregarEmpleados(40, "Adrian", "Wiebe", "Tenico en mecanica", 987888211, "wiebe@hotmail.com");
*/
##############################################

############## agregarClientes ###############
# Procedimiento para insertar registros en Clientes

DELIMITER //
	CREATE PROCEDURE agregarClientes(
	new_idCliente	int,
	new_nombre 		varchar(20),
    new_apellido	varchar(20),
	new_direccion 	varchar(50),
	new_email 		varchar(50),
	new_telefono 	INT(10),
    new_rfc			varchar(15))
		BEGIN
			IF NOT EXISTS (SELECT idCliente FROM cliente WHERE idCliente = new_idCliente) THEN
				INSERT INTO cliente (idCliente, nombre, apellido, direccion, email, telefono, rfc)
				VALUES (new_idCliente, new_nombre, new_apellido, new_direccion, new_email, new_telefono, new_rfc);
			ELSE
				SELECT "Este cliente ya esta registrado";
			END IF;
		END //
DELIMITER ;

############################ Registos tabla Cliente ###########################
/*
CALL agregarClientes(1, "Arturo"   ," Fernandez"    , "Panfilo castro #8530"     , "arturo123as@hotmail.com"         ,614589632,"VECJ880326XXX");
CALL agregarClientes(2, "Brian"    ," Estrada"      , "Luis Castillo #8745"      , "brianwe12@hotmail.com"           ,614356987,"VECJ880326XXa");
CALL agregarClientes(3, "Maritza"  ," Martinez"     , "Calle 8va #8521"          , "Maritza198@hotmail.com"          ,614895632,"VECJ850326XXX");
CALL agregarClientes(4, "Jose"     ," Melendez"     , "Calle 11va #8496"         , "Joselo128@hotmail.com"           ,614895147,"VwCJ880326XXX");
CALL agregarClientes(5, "Javier"   ," Loera"        , "Puerto Benito #8741"      , "Javierasd@hotmail.com"           ,614852361,"VECJ580326XXX");
CALL agregarClientes(6, "Javier"   ," Lopez"        , "Puerta del sol #8475"     , "jajajavier@hotmail.com"          ,614546829,"VECJ430326XXX");
CALL agregarClientes(7, "Alejandro"," Estrada"      , "Francisco villa #8495"    , "aleeejaaa@hotmail.com"           ,614321698,"VECJ88032632X");
CALL agregarClientes(8, "Jorge"    ," Jurado"       , "Calle los caporales #8456", "Jorrrge@hotmail.com"             ,614521487,"VEDJ880326XXX");
CALL agregarClientes(9, "Francisco"," Escobedo"     , "Calle R. almada #8527"    , "Franciscoooo@hotmail.com"        ,614521456,"VWCJ880326XXX");
CALL agregarClientes(10, "Nahomi"  ," Juarez"       , "Luis Donaldo #7415"       , "Nahoooomiii@hotmail.com"         ,614852963,"VYTJ880326XXX");
CALL agregarClientes(11, "Alberto" ," Castro"       , "Calle escondida #8492"    , "Alberrtoooo@hotmail.com"         ,614951247,"VEC880326XXX");
CALL agregarClientes(12, "Enrique" ," Martinez"     , "Diana Laura #7832"        , "Enriiiqueee@hotmail.com"         ,614957852,"VACJ880326XXX");
CALL agregarClientes(13, "Plutarco"," Lopez"        , "3 de mayo #7934"          , "Pluuutarrccoo@hormail.com"       ,614957348,"VECJ8N0326XXX");
CALL agregarClientes(14,"Roberto"  ," Martinez"     , "pascual #8118"            , "Rob_rob@hotmail.com"             ,159654325,"VEUY880326XXX");
CALL agregarClientes(15,"Manuel"   ," Aristegui"    , "nolose #48955"            , "Menyelmejor@gmail.com"           ,789987425,"VECY880326XXX");
CALL agregarClientes(16,"Fernanda" ," Campos"       , "LOQUEVENGA #44456"        , "Fernandaprogre@gmail.com"        ,744775533,"VRR880326XXX");
CALL agregarClientes(17,"Carlos"   ," Fredrich"     , "vamosvamos #66233"        , "carlitos6262@gmail.com"          ,745856412,"VECJ88032634X");
CALL agregarClientes(18,"Santiago" ," Sanchez"      , "valor #7896"              , "Santimirey@hotmail.com"          ,951159675,"VEW880326XXX");
CALL agregarClientes(19,"Luisa"    ," Alejandro"    , "LOQUEVENGA #84955"        , "Luisaprincess@gmail.com"         ,852968374,"WCJ880326XXX");
CALL agregarClientes(20,"Maria"    ," Gonzales"     , "meoqui #12343"            , "Maaariii@hotmail.com"            ,778799633,"VECJWQ803XXX");
CALL agregarClientes(21,"ANGEL"    ," DOLORES"      , "hellstreet #666"          , "angelfromhellstreet@hotmail.com" ,666333833,"VECTY880326XXX");
CALL agregarClientes(22,"Ramon"    ," Fernandez"    , "Mockingbird Lane #1313"   , "rami@gmail.com"                  ,615616558,"VECJ880326XWA");
CALL agregarClientes(23,"JESUS"    ," Gomez"        , "Windsor Gardens #32"      , "LeYisus@gmail.com"               ,741255896,"VECJ843326XXX");
CALL agregarClientes(24,"Eula"     ," Thompson"     , "Easy Via #2711"           , "feli.kah@arvinmeritor.info "     ,940351278,"VEJ843326XXX");
CALL agregarClientes(25,"Leverett" ," Forst"        , "Honey Willow Island #9508", "le-fors@arvinmeritor.info"       ,859648249,"VCJ843326XXX");
CALL agregarClientes(26,"Jamal"    ," Travers"      , "Cozy Parkway #9601"       , "jamaltra@progressenergyinc.info" ,430890358,"VECJ7643326XXX");
CALL agregarClientes(27,"Fenwick"  ," Ridley"       , "Harvest View #1760"       , "fe_ridl@arvinmeritor.info"       ,563990581,"VEwe843326XXX");
CALL agregarClientes(28,"Vinod"    ," Busbee"       , "Velvet Hills Road #7730"  , "vinobusbe@diaperstack.com"       ,7750555,"21CJ843326XXX");
CALL agregarClientes(29,"Alexis", "Zael", "Diego Lucero #14454", "alexxxis@hotmail.com", 61475495,"VECJ843326Xew");
CALL agregarClientes(30, "Adan","Ortiz", "Che guevara #1423", "aadan@hotmail.com", 61485298,"VECJ843326XX22");
CALL agregarClientes(31, "Adrian", "Estrada", "Toribio Ortega #1599", "adddrian@hotmail.com", 61457549,"VECJ832326XXX");
CALL agregarClientes(32, "Agustin", "Torres", "Lucio Cabañas #1555", "attoress@hotmail.com", 61485655,"VEd843326XXX");
CALL agregarClientes(33, "Aitor", "Hernandez", "Tomas Urbina #1233", "aaaiiitor@hotmail.com", 61455144,"PQCJ843326XXX");
CALL agregarClientes(34, "Alan", "Lucero", "Arturo Ganiz #4512", "aallan12@hotmail.com", 61485562,"VECJ843326ERX");
CALL agregarClientes(35, "Alberto", "Rodriguez", "Miguel Trillo #1325" ,"aaaalbe1323@hotmail.com", 61422522,"VECJ843326MXX");
CALL agregarClientes(36, "Alejandro", "Manjarrez", "Francisco Villa #4111", "alezxxxxx@hotmail.com", 61444444,"VECJ8UC326XXX");
CALL agregarClientes(37, "Alfonso", "Herrera", "Rodolfo Fierro #1115", "alfff123@hotmail.com", 61455512,"VECJ843326UXX");
CALL agregarClientes(38, "Alfredo", "Gamez", "Calle 17a #1777", "alfredooooo@hotmail.com", 61455545,"VECJ84332WWXX");
CALL agregarClientes(39, "Alvaro", "Gonzalez", "Calle 21a #1112", "alvvvaro@hotmail.com", 61489949,"VECJ8433WXX");
CALL agregarClientes(40, "Andres", "Carlos", "Martin Lopez #4558", "andessssssss@hotmail.com", 61498533,"AECJ880326XXX");
*/
##############################################

############# agregarProductos ###############
# Procedimiento para insertar registros en Productos

DELIMITER //
	CREATE PROCEDURE agregarProductos(
      new_id		INT(5),
	  new_nombre	VARCHAR(30),
      new_cant		INT(5),
      new_precio	FLOAT,
      new_descrip	TEXT)
		BEGIN
			IF NOT EXISTS (SELECT idProductos FROM productos WHERE idProductos = new_id) THEN
            
				INSERT INTO productos(idProductos, nombre, cantidad, precioPro, descripcion)
				VALUES	(new_id, new_nombre, new_cant, new_precio, new_descrip);
                
			ELSE
				SELECT "Este producto ya existe";
			END IF;
		END //
DELIMITER ;

############################ Registos tabla productos ###########################
/*		
CALL agregarProductos(1, "Transpaleta eléctrica", 15, 1500, "Tipo : PLL 200, Capacidad de carga (Q) : 2.000 Kg.");
CALL agregarProductos(2, "Puertas de cortadora", 12, 2600, "acero inoxidable y juego de cuchillas");
CALL agregarProductos(3, "Impresora tij", 5, 3020, "Muy fácil de usar con pantalla táctil.");
CALL agregarProductos(4, "Curvadora de perfiles", 24, 1220, "tubos 360º de 3 rodillos motrices hidráulica");
CALL agregarProductos(5, "Caldera de vapor", 3, 4500, " categoria C. capacidad 2000 Kg/hora");
CALL agregarProductos(6, "Valla de seguridad", 7, 4300, "Se utiliza en construcción");
CALL agregarProductos(7, "Calefactor eléctrico", 14, 3210, "Calefactor eléctrico de aire caliente totalmente automático");
CALL agregarProductos(8, "Cerr. de tarros", 4, 5800, "Maquinaria ModeloT40 Año de fabricaciónNuevaPotencia motor");
CALL agregarProductos(9, "Ventilador Industrial", 18, 1200, "Ventilador HVLS - Modelo ECO");
CALL agregarProductos(10, "Pinza Crimpadora", 52, 230, "Pinza crimpadora con ajuste de presion.");
CALL agregarProductos(11, "Mezclador de sólidos", 9, 2320, "Efectividad en su mezcla facilidad de limpieza.");
CALL agregarProductos(12, "Rollos pre cosidos", 42, 269, "Para la fabricacion de filtros de bolsas");
CALL agregarProductos(13, "Máquina inyectora", 4, 4521, "Incluye los bolígrafos de plástico");
CALL agregarProductos(14, "Caladora Bañolas", 12, 2225, "Esta máquina trabaja por sistema sumergido");
CALL agregarProductos(15, "Camino de rodillos motorizado", 15, 2220, "Dos caminos de rodillos motorizados tienen 1,5m de largo x 1,2m de ancho.");
CALL agregarProductos(16, "Haulotte hd-15-di", 2, 15000, "Plataformas móviles Haulotte HA-15-DI");
CALL agregarProductos(17, "Amasadora de brazos", 5, 3600, "amasadora de brazos Perfecto estado.");
CALL agregarProductos(18, "Transpaleta eléctrica ", 4, 4500, "Transpaleta Eléctrica NOBLELIFT PT18L");
CALL agregarProductos(19, "Estufa de leña industrial", 3, 2600, "Estufa industrial a leña ECO POL de 100kW");
CALL agregarProductos(20, "Calefactor a gas", 5, 3207, "Estufa de gas para la calefacción ");
CALL agregarProductos(21, "Recambios para aire", 10, 2003, "recambios para aire acondicionado compresores, placas electronicas");
CALL agregarProductos(22, "Aire acondicionado conductos", 5, 4888, "Capacidad frigorifica : 72.670 con bomba de calor");
CALL agregarProductos(23, "Cassette de 4 tubos", 1, 10000, "Cassette de 4 tubos 8 vías");
CALL agregarProductos(24, "Calefactor eléctrico", 2, 1200, "Calefactor eléctrico de aire");
CALL agregarProductos(25, "Aire acondicionado split", 5, 8660, "capacidad enfriamiento:,- (12000-14000) Btu/h,- (3000-3500) Frig");
CALL agregarProductos(26, "Calefactor eléctrico", 3, 4885, "Calefactor eléctrico de aire caliente ");
CALL agregarProductos(27, "Calefactor eléctrico ", 5, 5889, "Calefactor eléctrico de aire caliente ");
CALL agregarProductos(28, "Maquina formadora ", 1, 10200, "Sistema de control PLC con botonera");
CALL agregarProductos(29, "Maquina clinchadora", 5, 8552, "7.6t Alimentacion;220V/3/60Hz");
CALL agregarProductos(30, "Ventiladores centrífugos", 9, 9855, "fancoil unit, fancoil horizontal oculto, fancoil horizontal visto");
CALL agregarProductos(31, "Máquina formadora", 2, 12000, "Máquina formadora automática de codo redondo HVAC codo elbow machine");
CALL agregarProductos(32, "Máquina de conducto", 4, 2660, "Máquina de conducto redonda(circular)");
CALL agregarProductos(33, "Maquinas de ductos ", 10, 5220, "maquinas de conductos rectangulares, circulares, engargoladora, dobladora, plegadora");
CALL agregarProductos(34, "Maquina de tubo helicoidal", 3, 4221, "MAQUINA DE TUBO HELICOIDAL");
CALL agregarProductos(35, "Maquina conducto de aire TDC", 4, 4855, "El sistema de brida enchufable del conducto de aire TDC ");
CALL agregarProductos(36, "Máquina de bloqueo pittsburgh", 4, 4855, "Máquina de bloqueo pittsburgh de alta velocidad engargolada");
CALL agregarProductos(37, "Máq pleg neum y man", 1, 15000, "máquina plegadora neumática manual");
CALL agregarProductos(38, "Fiber EL6", 20, 200, "Programador fiber");
CALL agregarProductos(39, "Limpiamoquetas ", 3, 16000, "Sabrina es una máquina idónea también para un uso intenso");
CALL agregarProductos(40, "Tunel de lavado", 1, 22000, "Túnel de lavado de cajas y bandejas fabricado en acero inoxidable");
/*
-- Llamada al procedimiento para insertar registros
-- CALL agregarProductos(102, "wea", 200, 5.5, "Este es un campo de descripcion severamente largo, para probar");
-- SELECT * FROM productos WHERE idProductos BETWEEN 35 AND 110;
*/
##############################################

############# agregarServicios ###############
# Procedimiento para insertar registros en Servicios

DELIMITER //
	CREATE PROCEDURE agregarServicios(
	  new_idServicios 	INT,
	  new_nombre		VARCHAR(60),
	  new_tipo			VARCHAR(30),
	  new_precioSer		FLOAT,
	  new_descripcion 	VARCHAR(150),
	  new_idEmpleado	INT					)
		BEGIN
			IF NOT EXISTS (SELECT idServicios FROM servicios WHERE idServicios = new_idServicios) THEN
				INSERT INTO servicios (idServicios, nombre,  tipo, precioSer, descripcion, idEmpleado)
				VALUES (new_idServicios, new_nombre, new_tipo, new_precioSer, new_descripcion, new_idEmpleado);
			ELSE
				SELECT "Este servicio ya esta registrado";
			END IF;
		END //
DELIMITER ;

############################ Registos tabla Servicios ###########################
/*   
CALL agregarServicios(1, "limpieza quimica", "preventivo", 4200, "Desincrustación", 1);
CALL agregarServicios(2, "limpieza hidrodinamica", "preventivo", 3100, "agua a alta presión para eliminar suciedad", 2);
CALL agregarServicios(3, "limpieza por pollypigs", "preventivo", 4120, "suelta en el interior de tuberías, gasoductos, etc.", 3);
CALL agregarServicios(4, "flusihng de aceite", "preventivo", 5100, "Proceso para eliminar contaminantes del aceite ", 4);
CALL agregarServicios(5, "pruebas hidroestaticas", "preventivo", 3780, "Es la aplicación de presión a un equipo o línea de tuberías", 5);
CALL agregarServicios(6 , "Instalaciones eléctricas"                          , " "         , 1200, "Diseño e instalación de líneas de distribución en baja tensión, residencial, comercial e industrial.", 6);
CALL agregarServicios(7 , "Servicios de Ingeniería"                         , " "         , 4230, "Diseño de recipientes a presión bajo ASME", 7);
CALL agregarServicios(8 , "PLC’s y HMI’s"                                   , " "         , 5620, "Desarrollo de Lógica de Control de PLC’s, HMI’s Allen Bradley y Wonderware.", 8);
CALL agregarServicios(9 , "Lmpieza de motores trifasicos", "preventivo", 4800, " motores trifásicos son máquinas", 9);
CALL agregarServicios(10, "Instalaciones hidrosanitarias"                   , " "         , 3412, " conjunto de tuberías y conexiones de diferentes diámetros y diferentes materiales para alimentar y distribuir agua", 10);
CALL agregarServicios(11, "Instalaciones neumaticas"                        , " "         , 4200, "sistema neumático en una perforadora neumática", 11);
CALL agregarServicios(12, "Desmantelamiento"                                , " "         , 5400, "Desarmar, desarticular o desmontar totalmente cierto equipo industrial", 12);
CALL agregarServicios(13, "Limpieza de tanques", "Correctivo", 6220, "Limpieza interna tanques de combustible con equipo automatizado", 13);
CALL agregarServicios(14, "Instalacion de tableros electricos", " ", 2100, "Un cuadro de distribución, cuadro eléctrico, centro de carga", 14);
CALL agregarServicios(15, "Mantenimiento a maquinaria de lineas de produccion", "preventivo", 4220, "Limpieza completa de maquinarias de linea de produccion", 15);
CALL agregarServicios(16, "Mantenimiento a maquinaria de empacado", "preventivo", 4220, "Limpieza completa de maquinarias de empacado", 16);
CALL agregarServicios(17, "Mantenimiento a maquinaria llenadoras industriales", "preventivo", 4220, "Limpieza completa de maquinarias llenadoras industriales", 17);
CALL agregarServicios(18, "Mantenimiento a maquinaria taponadoras industriales", "preventivo", 4220, "Limpieza completa de maquinarias taponadoras industriales", 18);
CALL agregarServicios(19, "Mantenimiento a maquinaria armadoras de cajas", "preventivo", 4220, "Limpieza completa de maquinarias armadoras de cajas", 19);
CALL agregarServicios(20, "Mantenimiento a maquinas transportadoras", "preventivo", 4220, "Limpieza completa de maquinarias transportadoras", 20);
CALL agregarServicios(21, "Mantenimiento a paletizadores industriales", "preventivo", 4220, "Limpieza completa de maquinas paletizadoras insdustriales", 21);
CALL agregarServicios(22, "Mantenimiento a maquinas de inyeccion", "preventivo", 4220, "Limpieza completa de maquinas de inyeccion", 22);
CALL agregarServicios(23, "Distribución de alumbrado (DIAlux).", " ", 5880, "El precio puede varias dependiendo de que tan grande sea la distribucion", 23);
CALL agregarServicios(24, "Diseño y Armado de Tableros Eléctricos", " ", 8633, "Diseño del centro de carga o tablero de distribución ", 24);
CALL agregarServicios(25, "Diseño y Armado de CCM’s.", " ", 9888, "Un Centro de Control de Motores esencialmente consiste en motores", 25);
CALL agregarServicios(26, "Diseño de piezas especiales en 3D", " ", 2202, "SOLIDWORKS es un software de diseño CAD 3D", 26);
CALL agregarServicios(27, "Reparacion de tableros electricos", "correctivo", 4880, "Reparacion del centro de carga", 27);
CALL agregarServicios(28, "Reparacion de maquinarias de linea de produccion", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 28);
CALL agregarServicios(29, "Reparacion de maquinaria de empacado", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 29);
CALL agregarServicios(30, "Reparacion de maquinaria llenadoras industriales", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 30);
CALL agregarServicios(31, "Reparacion de maquinaria taponadoras industriales", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 31);
CALL agregarServicios(32, "Reparacion de maquinaria armadoras de cajas", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 32);
CALL agregarServicios(33, "Reparacion de maquinas transportadoras", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 33);
CALL agregarServicios(34, "Reparacion de paletizadores industriales", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 34);
CALL agregarServicios(35, "Reparacion de maquinas de inyeccion", "correctivo", 4880, "Pueden aplicar gastos adicionales dependiendo de la falla", 35);
CALL agregarServicios(36, "Sintonización de Lazos de Control.", " ", 8889, "La finalidad del lazo es hacer que el valor de la variable de proceso.", 36);
CALL agregarServicios(37, "Instalacion Sistemas SCADA de Monitoreo.", " ", 2230, "Instalacion completa de un kit basico", 37);
CALL agregarServicios(38, "Modificación de secuencias de Procesos y Máquinas.", " ", 1230, "Precio sujeto a solo un proceso o maquina", 38);
CALL agregarServicios(39, "Integración de Máquinas de Producción", " ", 4520, "Precio sujeto a una sola maquina", 39);
CALL agregarServicios(40, "Mantenimiento a maquinas de produccion", "preventivo", 2230, "Limpieza completa de una maquina de produccion", 40);
*/
##############################################

############## agregarFactura ################
# Procedimiento para insertar registros en Factura

DELIMITER //
	CREATE PROCEDURE agregarFactura(
	  new_idFactura	INT,
      new_fecha		DATE,
	  new_idCliente	INT,
      new_tipoPago	VARCHAR(10))
		BEGIN
			IF NOT EXISTS (SELECT idFactura FROM factura WHERE idFactura = new_idFactura) THEN
				INSERT INTO factura(IdFactura, fecha, idCliente, tipoPago)
				VALUES (new_idFactura, new_fecha, new_idCliente, new_tipoPago);
			ELSE
				SELECT "Este factura ya existe";
			END IF;
		END //
DELIMITER ;

############################ Registos tabla factura ###########################
/*
	CALL agregarFactura(NULL, now(), 1, "efectivo");
	CALL agregarFactura(NULL, now(), 2, "digital");
	CALL agregarFactura(NULL, now(), 3, "efectivo");
	CALL agregarFactura(NULL, now(), 4, "efectivo");
	CALL agregarFactura(NULL, now(), 5, "digital");
	CALL agregarFactura(NULL, now(), 6, "efectivo");
	CALL agregarFactura(NULL, now(), 7, "efectivo");
	CALL agregarFactura(NULL, now(), 8, "efectivo");
	CALL agregarFactura(NULL, now(), 9, "digital");
	CALL agregarFactura(NULL, now(), 10, "efectivo");
	CALL agregarFactura(NULL, NOW(), 11 , "digital");
	CALL agregarFactura(NULL, NOW(), 12 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 13 , "digital");
	CALL agregarFactura(NULL, NOW(), 14 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 15 , "digital");
	CALL agregarFactura(NULL, NOW(), 16 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 17 , "digital");
	CALL agregarFactura(NULL, NOW(), 18 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 19 , "digital");
	CALL agregarFactura(NULL, NOW(), 20 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 21 , "digital");
	CALL agregarFactura(NULL, NOW(), 22 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 23 , "digital");
	CALL agregarFactura(NULL, NOW(), 24 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 25 , "digital");
	CALL agregarFactura(NULL, NOW(), 26 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 27 , "digital");
	CALL agregarFactura(NULL, NOW(), 28 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 29 , "digital");
	CALL agregarFactura(NULL, NOW(), 30 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 31 , "digital");
	CALL agregarFactura(NULL, NOW(), 32 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 33 , "digital");
	CALL agregarFactura(NULL, NOW(), 34 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 35 , "digital");
	CALL agregarFactura(NULL, NOW(), 36 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 37 , "digital");
	CALL agregarFactura(NULL, NOW(), 38 , "efectivo");
	CALL agregarFactura(NULL, NOW(), 39 , "digital");
	CALL agregarFactura(NULL, NOW(), 40 , "efectivo");
*/
##############################################

############ agregarCotizacion ###############
# Procedimiento para insertar registros en Cotizacion

DELIMITER //
	CREATE PROCEDURE agregarCotizacion(
	  new_idCotizacion	INT,
	  new_idCliente		INT,
      new_fecha			DATE)
		BEGIN
			IF NOT EXISTS (SELECT idCotizacion FROM cotizacion WHERE idCotizacion = new_idCotizacion) THEN
				INSERT INTO cotizacion(idCotizacion, idCliente, fecha)
				VALUES (new_idCotizacion, new_idCliente, new_fecha);
			ELSE
				SELECT "Este cotizacion ya existe";
			END IF;
		END //
DELIMITER ;

############################ Registos tabla cotizacion ###########################
/*           
		CALL agregarCotizacion(1,1, now());
		CALL agregarCotizacion(2,2, now());
        CALL agregarCotizacion(3,2, now());
        CALL agregarCotizacion(4,2, now());
        CALL agregarCotizacion(5,5, now());
        CALL agregarCotizacion(7,7, now());
        CALL agregarCotizacion(8,8, now());
        CALL agregarCotizacion(9,9, now());
		CALL agregarCotizacion(10,10, now());
        CALL agregarCotizacion(11,11, now());
        CALL agregarCotizacion(12,12,now());
		CALL agregarCotizacion( 13 , 25 , now());
		CALL agregarCotizacion( 14 , 7 , now());
		CALL agregarCotizacion( 15 , 32 , now());
		CALL agregarCotizacion( 16 , 16 , now());
		CALL agregarCotizacion( 17 , 39 , now());
		CALL agregarCotizacion( 18 , 7 , now());
		CALL agregarCotizacion( 19 , 19 , now());
		CALL agregarCotizacion( 20 , 13 , now());
		CALL agregarCotizacion( 21 , 18 , now());
		CALL agregarCotizacion( 22 , 38 , now());
		CALL agregarCotizacion( 23 , 2 , now());
		CALL agregarCotizacion( 24 , 27 , now());
		CALL agregarCotizacion( 25 , 25 , now());
		CALL agregarCotizacion( 26 , 28 , now());
		CALL agregarCotizacion( 27 , 14 , now());
		CALL agregarCotizacion( 28 , 12 , now());
		CALL agregarCotizacion( 29 , 15 , now());
		CALL agregarCotizacion( 30 , 14 , now());
		CALL agregarCotizacion( 31 , 20 , now());
		CALL agregarCotizacion( 32 , 36 , now());
		CALL agregarCotizacion( 33 , 17 , now());
		CALL agregarCotizacion( 34 , 17 , now());
		CALL agregarCotizacion( 35 , 30 , now());
		CALL agregarCotizacion( 36 , 8 , now());
		CALL agregarCotizacion( 37 , 37 , now());
		CALL agregarCotizacion( 38 , 21 , now());
		CALL agregarCotizacion( 39 , 39 , now());
		CALL agregarCotizacion( 40 , 10 , now());
*/
##############################################

############ agregarDetalle_ser ##############
# Procedimiento para insertar registros en Detalle Servicios

DELIMITER //
	CREATE PROCEDURE agregarDetalle_ser(
	  new_idServicios		int,
	  new_idCotizacion		int)
		BEGIN
			IF NOT EXISTS (SELECT idServicios FROM detalleServicios WHERE idServicios = new_idServicios) THEN
				INSERT INTO detalleServicios(idServicios, idCotizacion)
				VALUES (new_idServicios, new_idCotizacion);
			ELSE
				SELECT "Este solicitud de servicio ya existe";
			END IF;
		END //
DELIMITER ;

############################ Registos tabla detalleServicios ###########################
/*            
		CALL agregarDetalle_ser(1, 2);
		CALL agregarDetalle_ser( 2 , 5 );
		CALL agregarDetalle_ser( 3 , 5 );
		CALL agregarDetalle_ser( 4 , 40 );
		CALL agregarDetalle_ser( 5 , 1 );
		CALL agregarDetalle_ser( 6 , 25 );
		CALL agregarDetalle_ser( 7 , 15 );
		CALL agregarDetalle_ser( 8 , 23 );
		CALL agregarDetalle_ser( 9 , 22 );
		CALL agregarDetalle_ser( 10 , 23 );
		CALL agregarDetalle_ser( 11 , 19 );
		CALL agregarDetalle_ser( 12 , 25 );
		CALL agregarDetalle_ser( 13 , 8 );
		CALL agregarDetalle_ser( 14 , 40 );
		CALL agregarDetalle_ser( 15 , 9 );
		CALL agregarDetalle_ser( 16 , 9 );
		CALL agregarDetalle_ser( 17 , 38 );
		CALL agregarDetalle_ser( 18 , 18 );
		CALL agregarDetalle_ser( 19 , 7 );
		CALL agregarDetalle_ser( 20 , 3 );
		CALL agregarDetalle_ser( 21 , 13 );
		CALL agregarDetalle_ser( 22 , 8 );
		CALL agregarDetalle_ser( 23 , 31 );
		CALL agregarDetalle_ser( 24 , 40 );
		CALL agregarDetalle_ser( 25 , 23 );
		CALL agregarDetalle_ser( 26 , 7 );
		CALL agregarDetalle_ser( 27 , 23 );
		CALL agregarDetalle_ser( 28 , 40 );
		CALL agregarDetalle_ser( 29 , 16 );
		CALL agregarDetalle_ser( 30 , 23 );
		CALL agregarDetalle_ser( 31 , 24 );
		CALL agregarDetalle_ser( 32 , 1 );
		CALL agregarDetalle_ser( 33 , 2 );
		CALL agregarDetalle_ser( 34 , 27 );
		CALL agregarDetalle_ser( 35 , 40 );
		CALL agregarDetalle_ser( 36 , 35 );
		CALL agregarDetalle_ser( 37 , 12 );
		CALL agregarDetalle_ser( 38 , 36 );
		CALL agregarDetalle_ser( 39 , 28 );
		CALL agregarDetalle_ser( 40 , 9 );
*/
##############################################

################# NewPedido ##################
# Procedimiento para solicitar(Insertar) un nuevo pedido hacia la tabla detalle

DELIMITER //
	CREATE PROCEDURE NewPedido(	
      new_id			INT(5),
	  new_factura		INT(5),
	  new_idProducto	INT(5),
	  new_cantidad		INT(5),
	  new_precio		FLOAT(5))
		BEGIN
			DECLARE IVA FLOAT(5);
            SET IVA = new_precio * 0.16; -- Calculo del IVA del precio insertado
            
            START TRANSACTION;
				IF NOT EXISTS 
					(SELECT idDetalle
					FROM detalle 
					WHERE IdDetalle = new_id)
				THEN
					INSERT INTO detalle(idDetalle, idFactura, idProductos, cantidad, precio)
					VALUES (new_id, new_factura, new_idProducto, new_cantidad, (new_precio + IVA));
                    
                    COMMIT;
				ELSE
					SELECT "Este pedido ya existe";
                    ROLLBACK;
				END IF;
		END //
DELIMITER ;

############################ Registos tabla detalle ###########################
/*	 
		CALL NewPedido(NULL, 1, 2, 7, 1500);
		CALL NewPedido(NULL, 2, 8, 6, 5800);
        CALL NewPedido(NULL, 3, 9, 7, 3210);
        CALL NewPedido(NULL, 4, 22, 9, 1200);
        CALL NewPedido(NULL, 5, 34, 1, 1500);
        CALL NewPedido(NULL, 6, 39, 2, 2600);
        CALL NewPedido(NULL, 7, 39, 5, 2120);
        CALL NewPedido(NULL, 8, 1, 7, 1500);
        CALL NewPedido(NULL, 9, 22, 23, 350);
        CALL NewPedido(NULL, 10, 32, 4, 490);
        CALL NewPedido(NULL, 11 , 16 , 40 , 350 );
		CALL NewPedido(NULL, 12 , 18 , 8 , 700 );
		CALL NewPedido(NULL, 13 , 5 , 19 , 1050 );
		CALL NewPedido(NULL, 14 , 36 , 13 , 1400 );
		CALL NewPedido(NULL, 15 , 28 , 29 , 1750 );
		CALL NewPedido(NULL, 16 , 33 , 14 , 2100 );
		CALL NewPedido(NULL, 17 , 19 , 16 , 2450 );
		CALL NewPedido(NULL, 18 , 13 , 38 , 2800 );
		CALL NewPedido(NULL, 19 , 13 , 22 , 3150 );
		CALL NewPedido(NULL, 20 , 29 , 16 , 3500 );
		CALL NewPedido(NULL, 21 , 26 , 28 , 3850 );
		CALL NewPedido(NULL, 22 , 19 , 24 , 4200 );
		CALL NewPedido(NULL, 23 , 17 , 33 , 4550 );
		CALL NewPedido(NULL, 24 , 27 , 28 , 4900 );
		CALL NewPedido(NULL, 25 , 32 , 31 , 5250 );
		CALL NewPedido(NULL, 26 , 11 , 36 , 5600 );
		CALL NewPedido(NULL, 27 , 17 , 17 , 5950 );
		CALL NewPedido(NULL, 28 , 26 , 20 , 6300 );
		CALL NewPedido(NULL, 29 , 6 , 27 , 6650 );
		CALL NewPedido(NULL, 30 , 31 , 35 , 7000 );
		CALL NewPedido(NULL, 31 , 28 , 8 , 7350 );
		CALL NewPedido(NULL, 32 , 26 , 19 , 7700 );
		CALL NewPedido(NULL, 33 , 5 , 24 , 8050 );
		CALL NewPedido(NULL, 34 , 22 , 38 , 8400 );
		CALL NewPedido(NULL, 35 , 4 , 22 , 8750 );
		CALL NewPedido(NULL, 36 , 1 , 10 , 9100 );
		CALL NewPedido(NULL, 37 , 6 , 5 , 9450 );
		CALL NewPedido(NULL, 38 , 40 , 4 , 9800 );
		CALL NewPedido(NULL, 39 , 10 , 2 , 10150 );
		CALL NewPedido(NULL, 40 , 12 , 40 , 10500 );
*/
##############################################

########### aviso_nuevos_pedidos #############
#Simple mensaje para avisar al usuario cuantos pedidos se han realizado

DELIMITER //
	CREATE PROCEDURE aviso_nuevos_pedidos(OUT pedidos_totales INT(5))
		BEGIN
			SET pedidos_totales = (SELECT COUNT(idDetalle) FROM detalle);
            SELECT CONCAT("Se han realizado ",pedidos_totales," pedidos hasta el momento") AS "Aviso";
		END //
DELIMITER ;
/*
#Aviso de cuantos registros se han hecho en detallle
CALL aviso_nuevos_pedidos(@aviso);
*/
##############################################

############## cambiarDetalle ################
#Procedimiento para cambiar campos de la tabla detalle

DELIMITER //
	CREATE PROCEDURE cambiarDetalle(
      IN columna VARCHAR(20),
      IN old_campo INT(5),
      IN new_campo INT(5))
		BEGIN
        START TRANSACTION;
			CASE
				WHEN (LOWER(columna) = "factura" OR LOWER(columna) = "f") THEN
					UPDATE detalle
                    SET idFactura = new_campo
                    WHERE idDetalle = old_campo;
                    
				WHEN (LOWER(columna) = "productos" OR LOWER(columna) = "pro") THEN
					UPDATE detalle
                    SET idProductos = new_campo
                    WHERE idDetalle = old_campo;
                    
				WHEN (LOWER(columna) = "cantidad" OR LOWER(columna) = "c") THEN
					UPDATE detalle
                    SET cantidad = new_campo
                    WHERE idDetalle = old_campo;
                    
				WHEN (LOWER(columna) = "precio" OR LOWER(columna) = "p") THEN
					UPDATE detalle
                    SET precio = new_campo
                    WHERE idDetalle = old_campo;
			END CASE;
		COMMIT;
		SELECT "Se han guardado los cambios en la base de datos" AS "Aviso";
		END //
DELIMITER ;

/*
# Llamada al procedimiento que cambia el valor de un campo en especifico en la tabla detalle
# c = cantidad
# pro = producto
# p = precio
# f = factura
# ▲▲▲▲▲▲▲▲▲▲▲▲
# columnas para cambiar los campos de la tabla detalle

SELECT * FROM detalle WHERE idDetalle = 2;
CALL cambiarDetalle("cantidad", 2, 100);
SELECT * FROM detalle WHERE idDetalle = 2;
*/
##############################################

############# eliminarDetalle ################
# Procedimiento que elimina un registro especificio de la tabla detalle

DELIMITER //
	CREATE PROCEDURE eliminarDetalle (IN campo_eliminar INT(5))
		BEGIN
        START TRANSACTION;
			IF campo_eliminar IN (SELECT idDetalle FROM detalle) THEN
            
				SELECT CONCAT("Se ha eliminado el registro ", campo_eliminar ," del cliente ",(	
				SELECT CONCAT(C.nombre," ",C.apellido)
				FROM cliente AS C, detalle AS DET, factura AS F		# Subconsulta para obtener el nombre
				WHERE C.idCliente = F.idCliente						# del usuario del que se elimino el 
				AND DET.idFactura = F.idFactura						# pedido
				AND DET.idDetalle = campo_eliminar )) AS "Aviso"; 
                
				DELETE FROM detalle
                WHERE idDetalle = campo_eliminar;
				COMMIT;
                
			ELSE
				SELECT "Este pedido no existe" AS "Aviso";
                ROLLBACK;
			END IF;
		END //
DELIMITER ;
/*
# Procedimiento que elimina un registro especifico de detalle
SELECT * FROM detalle;
CALL eliminarDetalle(8);
SELECT * FROM detalle;
*/ 
##############################################

################## Bonus #####################
/*
# Procedimiento que aplica un descuento si un cliente tiene mas de 2 cotizaciones a su nombre
# No es necesario, pero tras hacer pruebas salio este procedimiento.
DELIMITER //
	CREATE PROCEDURE descuentoTotalPagar()
		BEGIN
			DECLARE id_n INT DEFAULT 1;
            WHILE id_n <= (SELECT COUNT(idCliente) FROM cotizacion) DO
				UPDATE detalle
				SET precio = precio - (precio * 0.10)
				WHERE (	SELECT COUNT(idCliente)
						FROM cotizacion AS C
						WHERE idCliente = id_n
						GROUP BY C.idCliente
						LIMIT 1) > 2;
				SET id_n = id_n + 1;
			END WHILE;
		END //
DELIMITER ;

-- Procedimiento que hace un descuento si un cliente cuenta con mas de 2 cotizaciones 
CALL descuentoTotalPagar();
SELECT * FROM detalle;
*/
##############################################

-- ----------------------------
# Consultas
-- ----------------------------
/*
# Se realiza una consulta del nombre y el tipo de servicio con su respectiva descripcion
SELECT nombre AS "Nombre", tipo AS "Tipo", descripcion AS "Descripcion"
FROM servicios;

#Se realiza una consulta del precio total de los productos 
SELECT precioPro AS "Precio"
FROM productos;

# Se realiza una consulta del nombre del ciente con su ID
SELECT idCliente AS "ID", nombre AS "Nombre"
FROM cliente;

#Se hace una consulta del total de productos y servicios
SELECT P.nombre AS "Producto", S.nombre AS "Servicio"
FROM productos AS P, servicios AS S
WHERE P.idProductos = S.idServicios;

#Se hace una consulta de de manera cartesiana de los empleados y servicios
SELECT E.nombre AS "Empleado","especializado en", S.nombre "Servicios"
FROM empleados AS E, servicios AS S
WHERE S.idEmpleado = E.idEmpleado;

#Se hace una consulta de manera cartesiana de los productos y detalles
SELECT D.*, P.nombre AS "Productos", P.cantidad AS "Disponibles", P.precioPro AS "Precio producto"
FROM detalle AS D, productos AS P
WHERE D.idProductos = P.idProductos;

#------------------------------
# SubConsultas
#------------------------------
-- Consultar los productos mas costosos, que han comprado los clientes

SELECT
    t1.*,
    t2.*,
    t3.idProductos,
    t3.precio
FROM cliente AS t1
    INNER JOIN factura AS t2 ON t1.idCliente = t2.idCliente
    INNER JOIN
    (
	SELECT
        t4.idFactura,
        -- t4.idDetalle,
        t4.idProductos,
        MAX(t5.precioPro) AS precio
    FROM factura AS t3
        INNER JOIN detalle AS t4 ON t3.idFactura = t4.idFactura
        INNER JOIN productos AS t5 ON t5.idProductos = t4.idProductos
    -- ORDER BY idFactura DESC
    GROUP BY idFactura
) AS t3 ON t2.idFactura = t3.idFactura;

-- Esto es igual al inner join

# SELECT *
# FROM t1, t2
# WHERE t1.id = t2.id

-- Sumarizado
SELECT
    t4.idFactura,
    -- t4.idDetalle,
    t4.idProductos,
    MAX(t5.precioPro) AS precio
FROM factura AS t3
    INNER JOIN detalle AS t4 ON t3.idFactura = t4.idFactura
    INNER JOIN productos AS t5 ON t5.idProductos = t4.idProductos
-- ORDER BY idFactura DESC
GROUP BY idFactura;

-- Sin sumarizar
SELECT
    t4.idFactura,
    t4.idDetalle,
    t4.idProductos,
    t5.precioPro
FROM factura AS t3
    INNER JOIN detalle AS t4 ON t3.idFactura = t4.idFactura
    INNER JOIN productos AS t5 ON t5.idProductos = t4.idProductos
ORDER BY idFactura DESC;

#------------------------------
# Vistas
#------------------------------
-- Vista que muestra los servicios contratados por un cliente
#DROP VIEW ServiciosContratados;
CREATE VIEW ServiciosContratados AS (	
										SELECT C.nombre AS "Cliente", S.idServicios AS "ID",S.nombre AS "Servicios"
                                        FROM cliente AS C, servicios AS S, cotizacion AS COT, detalleServicios AS DET
                                        WHERE C.idCliente = COT.idCliente
                                        AND S.idServicios = DET.idServicios
                                        AND COT.idCotizacion = DET.idCotizacion
									);

SELECT *
FROM ServiciosContratados;

-- Muestra los productos por debajo de 4000
CREATE VIEW ProductoslowPrice AS(	
									SELECT nombre AS Nombre, precioPro AS Precio, descripcion AS Descripcion
                                    FROM productos
                                    WHERE precioPro < 4000
                                    ORDER BY precioPro DESC
								);

SELECT *
FROM ProductosLowPrice;

-- Muestra cuanto pagara cada cliente por todos los productos pedidos
CREATE VIEW PagarTotal AS(
							SELECT C.nombre AS Cliente, P.nombre AS "Producto", P.cantidad AS "Cantidad",
                            (P.precioPro * D.cantidad) AS "Total a pagar"
                            FROM productos AS P, cliente AS C, detalle AS D, factura AS F
                            WHERE P.idProductos = D.idProductos
                            AND F.idCliente = C.idCliente
                            AND D.idFactura = F.idFactura
						);
SELECT *
FROM PagarTotal;
*/