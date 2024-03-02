--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `prodiavisita` (
  `procode` varchar(15) NOT NULL COMMENT 'Código de proveedor',
  `dia` varchar(10) NOT NULL COMMENT 'Día en que el proveedor nos visita (preventa o venta directa)',
  KEY `fk_prodiavisita_inproved_idx` (`procode`),
  CONSTRAINT `fk_prodiavisita_inproved` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
