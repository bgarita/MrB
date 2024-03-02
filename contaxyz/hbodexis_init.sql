--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hbodexis` (
  `bodega` varchar(3) NOT NULL COMMENT 'Código de bodega',
  `artcode` varchar(20) NOT NULL COMMENT 'Código de artículo',
  `artexis` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Existencia',
  `artreserv` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad reservada',
  `minimo` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad mínima en existencia',
  `artperi` datetime NOT NULL COMMENT 'Fecha de periodo',
  PRIMARY KEY (`bodega`,`artcode`,`artperi`),
  KEY `FK_hbodexis_bodegas` (`bodega`),
  KEY `FK_Hinarticu` (`artcode`,`artperi`),
  CONSTRAINT `fk_hbodexis_hintarticu` FOREIGN KEY (`artcode`) REFERENCES `hinarticu` (`artcode`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
