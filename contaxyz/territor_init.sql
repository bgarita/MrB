--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `territor` (
  `terr` tinyint(3) unsigned NOT NULL COMMENT 'Código de zona o territorio',
  `descrip` varchar(50) NOT NULL COMMENT 'Descripción',
  PRIMARY KEY (`terr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Zonas o territorios';
--
-- Dump completed on: 2024/03/02 09:10:59
--
