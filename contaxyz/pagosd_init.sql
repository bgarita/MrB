--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `pagosd` (
  `Recnume` int(10) unsigned NOT NULL COMMENT 'Número de recibo',
  `facnume` int(11) NOT NULL COMMENT 'Factura o ND a la que se le aplica',
  `facnd` int(11) NOT NULL COMMENT '0 = Factura, > 0 = NC, < 0 = ND',
  `monto` double NOT NULL COMMENT 'Monto aplicado',
  KEY `FK_pagosd_faencabe` (`facnume`,`facnd`),
  KEY `idx_pagosd_facnume` (`facnume`,`facnd`),
  KEY `idx_pagosd_recnume` (`Recnume`),
  CONSTRAINT `FK_pagosd_faencabe` FOREIGN KEY (`facnume`, `facnd`) REFERENCES `faencabe` (`facnume`, `facnd`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pagosd_recnume` FOREIGN KEY (`Recnume`) REFERENCES `pagos` (`Recnume`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Detalle de pagos';
--
-- Dump completed on: 2024/03/02 09:10:59
--
