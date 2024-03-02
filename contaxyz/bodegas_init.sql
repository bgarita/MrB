--
-- Dump created on: 2024/03/02 09:04:26
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `bodegas` (
  `bodega` varchar(3) NOT NULL COMMENT 'Código de bodega',
  `descrip` varchar(40) NOT NULL COMMENT 'Nombre de la bodega',
  `cerrada` datetime DEFAULT NULL COMMENT 'Fecha en que se realizó el último cierre',
  PRIMARY KEY (`bodega`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:26
--
