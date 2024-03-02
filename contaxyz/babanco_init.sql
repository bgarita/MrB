--
-- Dump created on: 2024/03/02 09:04:18
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `babanco` (
  `idbanco` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Cóigo de la institución bancaria',
  `descrip` varchar(50) NOT NULL DEFAULT '' COMMENT 'Nombre o descripción del banco',
  PRIMARY KEY (`idbanco`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:18
--
