--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `conteo` (
  `bodega` varchar(3) NOT NULL,
  `artcode` varchar(20) NOT NULL,
  `cantidad` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad contada',
  `artexis` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Existencia en bodega',
  `artcosp` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo promedio',
  `fecha` datetime NOT NULL COMMENT 'Fecha del conteo físico',
  `userDigita` varchar(40) DEFAULT NULL COMMENT 'Usuario que digita el conteo',
  `userAplica` varchar(40) DEFAULT '0' COMMENT 'Usuario que aplica el ajuste',
  `movdocu` varchar(10) DEFAULT NULL COMMENT 'Documento con el que se aplicó el ajuste',
  `pordesc` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Ordenar por descripción',
  `linea` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `InUseByUser` varchar(40) NOT NULL DEFAULT ' ' COMMENT 'Usuario que se encuentra modificando el registro.',
  PRIMARY KEY (`linea`),
  KEY `FK_conteo_bodega` (`bodega`),
  KEY `FK_conteo_inarticu` (`artcode`),
  CONSTRAINT `FK_conteo_bodega` FOREIGN KEY (`bodega`) REFERENCES `bodegas` (`bodega`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_conteo_inarticu` FOREIGN KEY (`artcode`) REFERENCES `inarticu` (`artcode`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6558 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
