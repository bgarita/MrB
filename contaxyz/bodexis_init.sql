--
-- Dump created on: 2024/03/02 09:04:26
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `bodexis` (
  `bodega` varchar(3) NOT NULL COMMENT 'Código de bodega',
  `artcode` varchar(20) NOT NULL COMMENT 'Código de artículo',
  `artexis` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Existencia',
  `artreserv` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad reservada',
  `minimo` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad mínima en existencia',
  `localiz` varchar(7) NOT NULL DEFAULT '' COMMENT 'Localización',
  PRIMARY KEY (`bodega`,`artcode`),
  KEY `FK_Bodegas` (`bodega`),
  KEY `FK_bodexis_inarticu` (`artcode`),
  CONSTRAINT `FK_bodexis_bodegas` FOREIGN KEY (`bodega`) REFERENCES `bodegas` (`bodega`) ON UPDATE CASCADE,
  CONSTRAINT `FK_bodexis_inarticu` FOREIGN KEY (`artcode`) REFERENCES `inarticu` (`artcode`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:26
--
