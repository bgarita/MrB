--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `centrocosto` (
  `centroco` char(3) NOT NULL,
  `descrip` varchar(40) NOT NULL,
  PRIMARY KEY (`centroco`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Centros de costo';
--
-- Dump completed on: 2024/03/02 09:04:49
--
