--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `tipocambio` (
  `codigo` varchar(3) NOT NULL COMMENT 'Código de moneda',
  `fecha` datetime NOT NULL COMMENT 'Fecha de vigencia del tipo de cambio',
  `tipoca` float NOT NULL DEFAULT 1 COMMENT 'Tipo de cambio',
  `nConsecutivo` int(10) unsigned NOT NULL DEFAULT 1 COMMENT 'Consecutivo numérico para la navegación',
  PRIMARY KEY (`codigo`,`fecha`),
  KEY `Index_nConsecutivo` (`nConsecutivo`),
  CONSTRAINT `FK_tipocambio_monedas` FOREIGN KEY (`codigo`) REFERENCES `monedas` (`codigo`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Tipos de cambio';
--
-- Dump completed on: 2024/03/02 09:10:59
--
