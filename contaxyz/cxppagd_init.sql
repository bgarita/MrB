--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cxppagd` (
  `recnume` int(11) NOT NULL COMMENT 'Número de recibo.',
  `factura` varchar(12) NOT NULL COMMENT 'Número de factura aplicada.',
  `tipo` varchar(3) NOT NULL DEFAULT 'FAC' COMMENT 'Tipo de documento (FAC, NDB, NCR)',
  `monto` double DEFAULT NULL,
  KEY `FK_facturas` (`factura`,`tipo`),
  KEY `FK_recibos` (`recnume`),
  CONSTRAINT `FK_facturas` FOREIGN KEY (`factura`, `tipo`) REFERENCES `cxpfacturas` (`Factura`, `tipo`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_recibos` FOREIGN KEY (`recnume`) REFERENCES `cxppage` (`recnume`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Detalle de pagos';
--
-- Dump completed on: 2024/03/02 09:05:01
--
