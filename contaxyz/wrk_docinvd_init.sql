--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `wrk_docinvd` (
  `movdocu` varchar(10) NOT NULL COMMENT 'Número de documento',
  `movtimo` char(1) NOT NULL COMMENT 'E = Entrada, S=Salida',
  `artcode` varchar(20) NOT NULL,
  `bodega` varchar(3) NOT NULL,
  `procode` varchar(15) DEFAULT NULL,
  `movcant` decimal(14,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad',
  `movtido` smallint(3) unsigned NOT NULL COMMENT 'Tipo de documento (ver tabla INTIPOSDOC)',
  `fechaven` date DEFAULT NULL COMMENT 'Fecha de vencimiento',
  `artcosfob` decimal(14,4) unsigned NOT NULL DEFAULT 0.0000,
  `movcoun` decimal(16,6) NOT NULL DEFAULT 0.000000 COMMENT 'Costo unitario',
  KEY `fk_wrk_docinvd_bodexis_idx` (`artcode`,`bodega`),
  KEY `fk_wrk_docinvd_wrk_docinve_idx` (`movdocu`,`movtido`),
  KEY `fk_wrk_docinvd_bodegas_idx` (`bodega`),
  CONSTRAINT `fk_wrk_docinvd_bodegas` FOREIGN KEY (`bodega`) REFERENCES `bodegas` (`bodega`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_wrk_docinvd_inarticu` FOREIGN KEY (`artcode`) REFERENCES `inarticu` (`artcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_wrk_docinvd_wrk_docinve` FOREIGN KEY (`movdocu`, `movtido`) REFERENCES `wrk_docinve` (`movdocu`, `movtido`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
