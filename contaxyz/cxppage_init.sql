--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cxppage` (
  `recnume` int(11) NOT NULL COMMENT 'Número de recibo.',
  `procode` varchar(15) NOT NULL COMMENT 'Código de proveedor.',
  `fecha` datetime NOT NULL COMMENT 'Fecha del recibo.',
  `cheque` varchar(12) NOT NULL COMMENT 'Número de cheque.',
  `monto` double NOT NULL COMMENT 'Monto pagado.',
  `estado` char(1) NOT NULL COMMENT 'Blanco = normal, A = Anulado',
  `concepto` varchar(80) NOT NULL COMMENT 'Concepto',
  `fechac` datetime NOT NULL COMMENT 'Fecha calendario',
  `codigoTC` varchar(3) NOT NULL COMMENT 'Código de tipo de cambio (tabla monedas)',
  `tipoca` float NOT NULL COMMENT 'Tipo de cambio',
  `userAnula` varchar(40) DEFAULT NULL COMMENT 'Usuario que anula',
  `fechaAnula` datetime DEFAULT NULL COMMENT 'Fecha de anulación',
  `cerrado` char(1) NOT NULL DEFAULT 'N' COMMENT 'Determina si el registro pertenece a un período cerrado (S/N).',
  `user` varchar(40) DEFAULT NULL,
  `reccaja` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Número de recibo de caja',
  `idtarjeta` int(11) NOT NULL DEFAULT 0 COMMENT 'Código de tarjeta',
  `idbanco` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Código de la institución bancaria',
  `tipopago` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT 'Tipo de pago (0 = Desconocido, 1 = Efectivo, 2 = cheque, 3 = tarjeta, 4 = Transferencia)',
  `no_comprob` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Número de asiento',
  `tipo_comp` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento',
  PRIMARY KEY (`recnume`),
  KEY `procode` (`procode`),
  KEY `Index_reccaja` (`reccaja`),
  KEY `fk_cxppage_babanco_idx` (`idbanco`),
  KEY `fk_cxppage_tarjeta_idx` (`idtarjeta`),
  CONSTRAINT `fk_cxppage_babanco` FOREIGN KEY (`idbanco`) REFERENCES `babanco` (`idbanco`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cxppage_tarjeta` FOREIGN KEY (`idtarjeta`) REFERENCES `tarjeta` (`idtarjeta`) ON UPDATE CASCADE,
  CONSTRAINT `procode` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Encabezado de pagos (recibos) de cuentas por pagar.';
--
-- Dump completed on: 2024/03/02 09:05:01
--
