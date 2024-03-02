--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hcatransa` (
  `recnume` int(11) NOT NULL COMMENT 'Consecutivo de recibos de caja.',
  `documento` varchar(20) NOT NULL COMMENT 'Número de documento (factura, recibo de cxc o cxp, cheque, etc.)',
  `tipomov` varchar(1) NOT NULL COMMENT 'D=Depósito, R=Retiro',
  `monto` double NOT NULL DEFAULT 0 COMMENT 'Monto del movimiento',
  `fecha` datetime NOT NULL COMMENT 'Fecha y hora del movimiento',
  `cedula` varchar(20) NOT NULL COMMENT 'Número de cédula de la persona que recibe/deposita',
  `nombre` varchar(60) NOT NULL COMMENT 'Nombre de la persona que deposita/retira',
  `tipopago` tinyint(2) NOT NULL COMMENT 'Tipo de pago (0 = Desconocido, 1 = Efectivo, 2 = cheque, 3 = tarjeta, 4 = Transferencia)',
  `referencia` varchar(20) NOT NULL DEFAULT '' COMMENT 'Referencia al documento de pago (número de cheque, tarjeta, transferencia, et.)',
  `idcaja` int(11) NOT NULL COMMENT 'Número de caja',
  `cajero` char(16) NOT NULL COMMENT 'Código del cajero que realizó la transacción',
  `modulo` varchar(3) NOT NULL DEFAULT '' COMMENT 'Indica el origen del documento CXC o CXP (blanco=otros)',
  `tipodoc` varchar(3) NOT NULL DEFAULT '' COMMENT 'FAC=Factura, NDC=Nota de crédito, NDB=Nota de débito, REC=Recibo, Blanco=Otros',
  `idtarjeta` int(11) NOT NULL DEFAULT 0 COMMENT 'Código de tarjeta',
  PRIMARY KEY (`recnume`),
  KEY `fk_hcatransa_caja_idx` (`idcaja`,`cajero`),
  KEY `doc_idx` (`documento`),
  KEY `fecha_idx` (`fecha`),
  KEY `cedula_idx` (`cedula`),
  KEY `fk_hcatransa_cajero_idx` (`cajero`),
  CONSTRAINT `fk_hcatransa_cajero` FOREIGN KEY (`cajero`) REFERENCES `cajero` (`user`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
