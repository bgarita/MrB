--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `comordencomprae` (
  `movorco` varchar(10) NOT NULL COMMENT 'Orden de compra',
  `Movdesc` varchar(150) DEFAULT NULL COMMENT 'Descripción del movimiento',
  `movfech` date NOT NULL COMMENT 'Fecha del movimiento',
  `tipoca` float NOT NULL DEFAULT 1 COMMENT 'Tipo de cambio',
  `user` varchar(40) NOT NULL COMMENT 'Usuario',
  `movtido` smallint(3) unsigned NOT NULL COMMENT 'Ver tabla INTIPOSDOC',
  `movfechac` datetime NOT NULL COMMENT 'Fecha y hora del sistema',
  `codigoTC` varchar(3) DEFAULT NULL COMMENT 'Código del tipo del cambio',
  `procode` varchar(15) DEFAULT NULL COMMENT 'Código de proveedor',
  `movcerr` varchar(1) DEFAULT 'N' COMMENT 'Orden de compra cerrada (S/N)',
  `movdocu` varchar(10) NOT NULL DEFAULT '' COMMENT 'Documento de entrada en inventarios',
  PRIMARY KEY (`movorco`),
  KEY `fk_comOrdenCompraE_monedas_idx` (`codigoTC`),
  KEY `fk_comOrdenCompraE_inproved_idx` (`procode`),
  CONSTRAINT `fk_comOrdenCompraE_inproved` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON UPDATE CASCADE,
  CONSTRAINT `fk_comOrdenCompraE_monedas` FOREIGN KEY (`codigoTC`) REFERENCES `monedas` (`codigo`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
