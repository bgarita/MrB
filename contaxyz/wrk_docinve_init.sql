--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `wrk_docinve` (
  `movdocu` varchar(10) NOT NULL COMMENT 'Numero de documento',
  `movtimo` char(1) NOT NULL COMMENT 'Tipo de movimiento (E=Entrada, S=Salida)',
  `movorco` varchar(10) DEFAULT NULL COMMENT 'Orden de compra',
  `Movdesc` varchar(150) DEFAULT NULL COMMENT 'Descripción del movimiento',
  `movfech` date NOT NULL COMMENT 'Fecha del movimiento',
  `tipoca` float NOT NULL DEFAULT 1 COMMENT 'Tipo de cambio',
  `user` varchar(40) NOT NULL COMMENT 'Usuario',
  `movtido` smallint(3) unsigned NOT NULL COMMENT 'Ver tabla INTIPOSDOC',
  `movsolic` varchar(30) DEFAULT NULL COMMENT 'Persona que solicita',
  `movfechac` datetime NOT NULL COMMENT 'Fecha y hora del sistema',
  `codigoTC` char(3) DEFAULT NULL COMMENT 'Código del tipo del cambio',
  PRIMARY KEY (`movdocu`,`movtido`),
  KEY `fk_wrk_docinve_intiposdoc_idx` (`movtido`),
  CONSTRAINT `fk_wrk_docinve_intiposdoc` FOREIGN KEY (`movtido`) REFERENCES `intiposdoc` (`Movtido`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
