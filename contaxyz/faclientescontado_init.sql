--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `faclientescontado` (
  `facnume` int(11) NOT NULL DEFAULT 0 COMMENT 'Número de factura',
  `facnd` int(11) NOT NULL DEFAULT 0 COMMENT '0 = Factura, positivo = NC, negativo = ND',
  `clidesc` varchar(50) NOT NULL COMMENT 'Nombre del cliente',
  PRIMARY KEY (`facnume`,`facnd`),
  CONSTRAINT `fk_faclientescontado_faencabe` FOREIGN KEY (`facnume`, `facnd`) REFERENCES `faencabe` (`facnume`, `facnd`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
