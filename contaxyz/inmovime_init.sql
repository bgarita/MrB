--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `inmovime` (
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
  `estado` char(1) DEFAULT NULL COMMENT 'Blanco = Activo, A = Anulado',
  `userAnula` varchar(40) DEFAULT NULL COMMENT 'Usuario que anula',
  `fechaAnula` datetime DEFAULT NULL COMMENT 'Fecha de la anulación',
  `movCerrado` char(1) NOT NULL DEFAULT 'N' COMMENT 'Indica si el registro pertenece o no a un período cerrado (S/N)',
  PRIMARY KEY (`movdocu`,`movtimo`,`movtido`),
  KEY `FK_Hinmovim_intiposDoc` (`movtido`),
  KEY `FK_inmovime_Tipocambio` (`codigoTC`),
  KEY `Index_movdocu` (`movdocu`),
  KEY `Index_movfech` (`movfech`),
  KEY `Index_movCerrado` (`movCerrado`,`movfech`),
  KEY `Index_recalcular_inv` (`movfech`,`estado`),
  CONSTRAINT `FK_inmovime_intiposDoc` FOREIGN KEY (`movtido`) REFERENCES `intiposdoc` (`Movtido`) ON UPDATE CASCADE,
  CONSTRAINT `FK_inmovime_moneda` FOREIGN KEY (`codigoTC`) REFERENCES `monedas` (`codigo`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Encabezado de movientos';
--
-- Dump completed on: 2024/03/02 09:10:59
--
