--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `coperiodoco_bk` (
  `mes` tinyint(2) unsigned NOT NULL COMMENT 'Mes contable',
  `año` smallint(5) unsigned NOT NULL COMMENT 'Mes contable',
  `descrip` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Descripción',
  `fecha_in` date NOT NULL COMMENT 'Fecha inicial del mes',
  `fecha_fi` date NOT NULL COMMENT 'Fecha final del mes',
  `cerrado` tinyint(1) unsigned NOT NULL COMMENT '0=Abierto, 1=Cerrado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
