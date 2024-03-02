--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `intiposdoc` (
  `Movtido` smallint(3) unsigned NOT NULL COMMENT 'Tipo de documento',
  `Descrip` varchar(45) NOT NULL COMMENT 'Descripción del tipo de documento',
  `EntradaSalida` char(1) NOT NULL DEFAULT 'E' COMMENT 'E = Entrada, S = Salida',
  `Modulo` varchar(3) NOT NULL DEFAULT 'INV' COMMENT 'Módulo que lo utiliza',
  `ReqProveed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'El movimiento requiere proveedor (1=Si, 0=No) ',
  `afectaMinimos` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Afecta mínimos de inventario  (1=Si, 0=No) ',
  PRIMARY KEY (`Movtido`),
  KEY `fk_intiposdoc_modulo_idx` (`Modulo`),
  CONSTRAINT `fk_intiposdoc_modulo` FOREIGN KEY (`Modulo`) REFERENCES `modulo` (`modulo`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Tipos de documento';
--
-- Dump completed on: 2024/03/02 09:10:59
--
