--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `infamily` (
  `artfam` char(4) NOT NULL COMMENT 'Código de familia',
  `familia` varchar(25) NOT NULL COMMENT 'Descripcion de la familia',
  PRIMARY KEY (`artfam`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Familias';
--
-- Dump completed on: 2024/03/02 09:10:59
--
