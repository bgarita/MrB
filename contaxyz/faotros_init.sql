--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `faotros` (
  `facnume` int(11) NOT NULL COMMENT 'Número de factura NC o ND',
  `facnd` int(11) NOT NULL COMMENT 'Indica si es factura, NC o ND (ver tabla faencabe)',
  `WMNumeroVendedor` varchar(15) NOT NULL COMMENT 'Número de vendedor',
  `WMNumeroOrden` varchar(15) NOT NULL COMMENT 'Número de orden',
  `WMEnviarGLN` varchar(20) NOT NULL,
  `WMNumeroReclamo` varchar(15) NOT NULL COMMENT 'Número de reclamo',
  `WMFechaReclamo` varchar(10) NOT NULL COMMENT 'Fecha del reclamo',
  PRIMARY KEY (`facnume`,`facnd`),
  CONSTRAINT `fk_faotros_faencabe` FOREIGN KEY (`facnume`, `facnd`) REFERENCES `faencabe` (`facnume`, `facnd`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
