--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `tarjeta` (
  `idtarjeta` int(11) NOT NULL DEFAULT 0 COMMENT 'Código de tarjeta',
  `descrip` varchar(50) NOT NULL COMMENT 'Nombre o descripción de la tarjeta',
  `tipo` varchar(1) NOT NULL COMMENT 'D=Débito, C=Crédito',
  PRIMARY KEY (`idtarjeta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
