--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `notasd` (
  `Notanume` int(10) NOT NULL COMMENT 'Número de Nota de Crédito',
  `facnume` int(11) NOT NULL COMMENT 'Factura o ND a la que se le aplica',
  `facnd` int(11) NOT NULL COMMENT '0 = Factura, > 0 = NC, < 0 = ND',
  `monto` double NOT NULL COMMENT 'Monto aplicado',
  `user` varchar(40) NOT NULL COMMENT 'Usuario que aplicó la nota',
  `fechaAp` datetime NOT NULL COMMENT 'Fecha de aplicado',
  KEY `idx_notasd_facnume` (`facnume`,`facnd`),
  KEY `idx_notasd_Notanume` (`Notanume`),
  CONSTRAINT `FK_notasd_faencabe` FOREIGN KEY (`Notanume`) REFERENCES `faencabe` (`facnume`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Detalle de notas de crédito aplicadas';
--
-- Dump completed on: 2024/03/02 09:10:59
--
