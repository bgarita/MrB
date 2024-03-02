--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cotipasient` (
  `tipo_comp` tinyint(2) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento',
  `descrip` varchar(30) NOT NULL COMMENT 'Descripción',
  `consecutivo` int(11) NOT NULL DEFAULT 0 COMMENT 'Número consecutivo',
  PRIMARY KEY (`tipo_comp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
