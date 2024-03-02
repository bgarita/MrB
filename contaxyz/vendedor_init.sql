--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `vendedor` (
  `vend` tinyint(3) unsigned NOT NULL COMMENT 'Código de vendedor',
  `nombre` varchar(50) NOT NULL COMMENT 'Nombre del vendedor',
  PRIMARY KEY (`vend`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Vendedores';
--
-- Dump completed on: 2024/03/02 09:10:59
--
