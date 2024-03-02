--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `comordencomprad` (
  `movorco` varchar(10) NOT NULL COMMENT 'Número de documento',
  `artcode` varchar(20) NOT NULL,
  `bodega` varchar(3) NOT NULL,
  `movcant` decimal(14,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad a pedir',
  `artcosfob` decimal(14,4) unsigned NOT NULL DEFAULT 0.0000,
  `artcost` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo actual',
  `movreci` decimal(12,4) DEFAULT 0.0000 COMMENT 'Cantidad recibida',
  KEY `fk_comOrdenCompraD_comOrdendComparaE_idx` (`movorco`),
  KEY `fk_comOrdenCompraD_bodexis_idx` (`bodega`,`artcode`),
  CONSTRAINT `fk_comOrdenCompraD_bodexis` FOREIGN KEY (`bodega`, `artcode`) REFERENCES `bodexis` (`bodega`, `artcode`) ON UPDATE CASCADE,
  CONSTRAINT `fk_comOrdenCompraD_comOrdendComparaE` FOREIGN KEY (`movorco`) REFERENCES `comordencomprae` (`movorco`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
