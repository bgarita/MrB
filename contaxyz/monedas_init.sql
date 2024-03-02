--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `monedas` (
  `codigo` varchar(3) NOT NULL COMMENT 'Código de moneda',
  `descrip` varchar(25) NOT NULL COMMENT 'Descripción de la moneda',
  `simbolo` char(1) DEFAULT NULL COMMENT 'Símbolo de la moneda',
  `codigoHacienda` varchar(3) NOT NULL COMMENT 'Código de moneda según el Ministerio de Hacienda',
  PRIMARY KEY (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
