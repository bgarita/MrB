--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `liquidaciondiaria` (
  `vend` tinyint(3) unsigned NOT NULL COMMENT 'Código de vendedor',
  `fecha` date NOT NULL COMMENT 'Fecha de la liquidación',
  `fcontadoef` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Facturas de contado en efectivo',
  `compfacon` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Comparativo contado (viene del sistema)',
  `fcontadoch` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Facturas de contado en cheque',
  `fcredito` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Facturas de crédito',
  `compfcredi` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Comparativo crédito (viene del sistema)',
  `recibosef` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Recibos en efectivo',
  `recibosch` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Recibos en cheque',
  `comprecib` decimal(60,30) NOT NULL DEFAULT 0.000000000000000000000000000000 COMMENT 'Comparativo de recibos (viene del sistema)',
  `Observaciones` varchar(500) NOT NULL DEFAULT ' ' COMMENT 'Observaciones',
  PRIMARY KEY (`vend`,`fecha`),
  KEY `FK_vend_idx` (`vend`),
  CONSTRAINT `FK_vend` FOREIGN KEY (`vend`) REFERENCES `vendedor` (`vend`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Compara los registros del sistema con los que el usuario digite';
--
-- Dump completed on: 2024/03/02 09:10:59
--
