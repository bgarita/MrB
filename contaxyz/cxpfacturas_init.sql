--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cxpfacturas` (
  `Factura` varchar(10) NOT NULL COMMENT 'Número de documento.',
  `tipo` varchar(3) NOT NULL COMMENT 'Tipo de documento (FAC, NCR, NDB).',
  `procode` varchar(15) NOT NULL COMMENT 'Código de proveedor.',
  `fecha_fac` date NOT NULL COMMENT 'Fecha del documento',
  `vence_en` smallint(4) NOT NULL DEFAULT 0 COMMENT 'Plazo en días',
  `fecha_pag` date NOT NULL COMMENT 'Fecha de pago.',
  `total_fac` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Total = monto gravado + monto exento',
  `monto_gra` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Monto gravado',
  `monto_exe` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Monto exento',
  `codigoTC` char(3) NOT NULL COMMENT 'Código de moneda',
  `tipoca` float NOT NULL DEFAULT 1 COMMENT 'Tipo de cambio.',
  `val_ult_ab` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Valor del último abono',
  `fec_ult_ab` date DEFAULT NULL COMMENT 'Fecha del último abono',
  `abono_acum` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Abono acumulado',
  `descuento` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT 'Descuento',
  `impuesto` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT 'Impuesto',
  `user` varchar(40) NOT NULL COMMENT 'Usuario que creó el registro',
  `refinv` varchar(10) NOT NULL COMMENT 'Documento de referencia en inventarios (INMOVIME)',
  `saldo` decimal(14,4) NOT NULL COMMENT 'Saldo del documento.',
  `fechac` datetime NOT NULL COMMENT 'Fecha de creación del registro',
  `cerrado` char(1) NOT NULL DEFAULT 'N' COMMENT 'Indica si el registro se encuentra cerrado o no.',
  `observaciones` varchar(150) NOT NULL DEFAULT '',
  `reccaja` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Número de recibo de caja',
  `idtarjeta` int(11) NOT NULL DEFAULT 0,
  `idbanco` int(10) unsigned NOT NULL DEFAULT 0,
  `medioPago` tinyint(2) NOT NULL DEFAULT 0 COMMENT 'Medio de pago (0 = Desconocido, 1 = Efectivo, 2 = cheque, 3 = tarjeta, 4 = Transferencia)',
  `chequeotar` varchar(45) NOT NULL DEFAULT '' COMMENT 'Número de referencia para cheque, tarjeta, transferencia, etc.',
  `claveHacienda` varchar(50) NOT NULL DEFAULT '' COMMENT 'Número de referencia enviado a Hacienda',
  `consHacienda` varchar(20) NOT NULL DEFAULT '' COMMENT 'Consecutivo generado para Hacienda',
  `tipo_comp` tinyint(2) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento',
  `no_comprob` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Número de asiento',
  PRIMARY KEY (`Factura`,`tipo`,`procode`),
  KEY `fk_procode` (`procode`),
  KEY `Index_reccaja` (`reccaja`),
  KEY `fk_cxpfacturas_banco_idx` (`idbanco`),
  KEY `fk_cxpfacturas_tarjeta_idx` (`idtarjeta`),
  CONSTRAINT `fk_cxpfacturas_banco` FOREIGN KEY (`idbanco`) REFERENCES `babanco` (`idbanco`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cxpfacturas_tarjeta` FOREIGN KEY (`idtarjeta`) REFERENCES `tarjeta` (`idtarjeta`) ON UPDATE CASCADE,
  CONSTRAINT `fk_procode` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Facturas, ND y NC de cuentas por cobrar.';
--
-- Dump completed on: 2024/03/02 09:05:01
--
