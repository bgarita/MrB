--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `catransa` (
  `recnume` int(11) NOT NULL COMMENT 'Consecutivo de recibos de caja.',
  `documento` varchar(20) NOT NULL COMMENT 'Número de documento (factura, recibo de cxc o cxp, cheque, etc.)',
  `tipomov` varchar(1) NOT NULL COMMENT 'D=Depósito, R=Retiro',
  `monto` double NOT NULL DEFAULT 0 COMMENT 'Monto del movimiento',
  `fecha` datetime NOT NULL COMMENT 'Fecha y hora del movimiento',
  `cedula` varchar(20) NOT NULL COMMENT 'Número de cédula de la persona que recibe/deposita',
  `nombre` varchar(60) NOT NULL COMMENT 'Nombre de la persona que deposita/retira',
  `tipopago` tinyint(2) NOT NULL COMMENT 'Tipo de pago (0 = Desconocido, 1 = Efectivo, 2 = cheque, 3 = tarjeta, 4 = Transferencia)',
  `referencia` varchar(45) NOT NULL DEFAULT '' COMMENT 'Referencia al documento de pago (número de cheque, tarjeta, transferencia, et.)',
  `idcaja` int(11) NOT NULL COMMENT 'Número de caja',
  `cajero` char(16) NOT NULL COMMENT 'Código del cajero que realizó la transacción',
  `modulo` varchar(3) NOT NULL DEFAULT '' COMMENT 'Indica el origen del documento CXC o CXP (blanco=otros)',
  `tipodoc` varchar(3) NOT NULL DEFAULT '' COMMENT 'FAC=Factura, NDC=Nota de crédito, NDB=Nota de débito, REC=Recibo, Blanco=Otros',
  `idbanco` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Número de banco',
  `idtarjeta` int(11) NOT NULL DEFAULT 0 COMMENT 'Código de tarjeta',
  PRIMARY KEY (`recnume`),
  KEY `fk_catransa_caja_idx` (`idcaja`,`cajero`),
  KEY `documento_idx` (`documento`),
  KEY `fk_catransa_cajero_idx` (`cajero`),
  KEY `fk_catransa_babanco_idx` (`idbanco`),
  KEY `fk_catransa_tarjeta_idx` (`idtarjeta`),
  CONSTRAINT `fk_catransa_babanco` FOREIGN KEY (`idbanco`) REFERENCES `babanco` (`idbanco`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_catransa_caja` FOREIGN KEY (`idcaja`) REFERENCES `caja` (`idcaja`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_catransa_cajero` FOREIGN KEY (`cajero`) REFERENCES `cajero` (`user`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_catransa_tarjeta` FOREIGN KEY (`idtarjeta`) REFERENCES `tarjeta` (`idtarjeta`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:49
--
