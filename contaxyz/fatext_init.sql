--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `fatext` (
  `facnume` int(11) NOT NULL COMMENT 'Número de factura, ND o NC',
  `facnd` int(11) NOT NULL DEFAULT 0 COMMENT '0 = Factura, positivo para las NC y negativo para las ND',
  `factext` varchar(1000) NOT NULL COMMENT 'Texto de la factura',
  PRIMARY KEY (`facnume`,`facnd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Texto que se adjunta a una factura';
--
-- Dump completed on: 2024/03/02 09:05:02
--
