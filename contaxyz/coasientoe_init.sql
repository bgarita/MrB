--
-- Dump created on: 2024/03/02 09:04:58
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `coasientoe` (
  `no_comprob` varchar(10) NOT NULL COMMENT 'Número de comprobante',
  `fecha_comp` datetime NOT NULL COMMENT 'Fecha del comprobante',
  `no_refer` int(9) NOT NULL DEFAULT 0 COMMENT 'Número de referencia',
  `tipo_comp` tinyint(2) NOT NULL DEFAULT 0 COMMENT 'Tipo de comprobante',
  `descrip` varchar(60) NOT NULL COMMENT 'Descripción del asiento',
  `usuario` varchar(40) NOT NULL COMMENT 'Usuario que registra el movimiento',
  `periodo` tinyint(2) NOT NULL COMMENT 'Número de mes en proceso',
  `modulo` varchar(3) NOT NULL COMMENT 'Código del módulo que genera el movimiento (origen).',
  `documento` varchar(10) NOT NULL DEFAULT '' COMMENT 'Número de documento en auxiliar (factura, nd, nc, etc.)',
  `movtido` smallint(3) unsigned NOT NULL COMMENT 'Tipo de documento (ver campo movtido en la tabal intiposdoc)',
  `enviado` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Enviado a contabilida (0=No, 1=Si)',
  `asientoAnulado` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Contiene el número de asiento al cual está anulando',
  PRIMARY KEY (`no_comprob`,`tipo_comp`),
  KEY `fk_coasientoe_modulo_idx` (`modulo`),
  KEY `fk_coasientoe_intiposdoc_idx` (`movtido`),
  KEY `fk_coasientoe_cotipasient_idx` (`tipo_comp`),
  CONSTRAINT `fk_coasientoe_cotipasient` FOREIGN KEY (`tipo_comp`) REFERENCES `cotipasient` (`tipo_comp`) ON UPDATE CASCADE,
  CONSTRAINT `fk_coasientoe_intiposdoc` FOREIGN KEY (`movtido`) REFERENCES `intiposdoc` (`Movtido`) ON UPDATE CASCADE,
  CONSTRAINT `fk_coasientoe_modulo` FOREIGN KEY (`modulo`) REFERENCES `modulo` (`modulo`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:58
--
