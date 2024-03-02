--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cxpnotasd` (
  `Notanume` varchar(10) NOT NULL COMMENT 'Número de nota',
  `factura` varchar(10) NOT NULL COMMENT 'Factura o NCR aplicada',
  `tipo` varchar(3) NOT NULL COMMENT 'Tipo de documento aplicado (FAC, NCR)',
  `monto` double NOT NULL COMMENT 'Monto aplicado',
  `user` varchar(40) NOT NULL COMMENT 'Usuario que aplicó',
  `fechaAp` datetime NOT NULL COMMENT 'Fecha de aplicado',
  `NotaTipo` varchar(3) NOT NULL COMMENT 'Se incluye para formar la llave foránea',
  `procode` varchar(15) NOT NULL COMMENT 'Código de proveedor',
  KEY `fk_cxpnotasd_cxcfacturas` (`factura`,`tipo`,`procode`) USING BTREE,
  KEY `cxpnotasd_factura_idx` (`factura`) USING BTREE,
  KEY `fk_cxpnotasd_inproved_idx` (`procode`),
  KEY `cxpnotasd_notanume_idx` (`Notanume`,`NotaTipo`,`procode`) USING BTREE,
  CONSTRAINT `fk_cxpnotasd_cxpfacturas_fk` FOREIGN KEY (`Notanume`, `NotaTipo`, `procode`) REFERENCES `cxpfacturas` (`Factura`, `tipo`, `procode`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_cxpnotasd_cxpfacturas_fk2` FOREIGN KEY (`factura`, `tipo`, `procode`) REFERENCES `cxpfacturas` (`Factura`, `tipo`, `procode`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_cxpnotasd_inproved` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
