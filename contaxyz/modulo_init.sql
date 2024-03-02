--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `modulo` (
  `modulo` varchar(3) NOT NULL COMMENT 'Código del módulo',
  `Descrip` varchar(45) NOT NULL DEFAULT '' COMMENT 'Nombre del módulo',
  PRIMARY KEY (`modulo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
