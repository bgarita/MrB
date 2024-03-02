--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `pagos` (
  `Recnume` int(10) unsigned NOT NULL COMMENT 'Número de recibo',
  `clicode` int(10) unsigned NOT NULL COMMENT 'Código de cliente',
  `fecha` datetime NOT NULL COMMENT 'Fecha del recibo',
  `concepto` varchar(80) DEFAULT NULL COMMENT 'Concepto o detalle del recibo',
  `monto` double NOT NULL COMMENT 'Monto del recibo',
  `estado` char(1) DEFAULT NULL COMMENT 'Blanco = normal, A = Anulado',
  `user` varchar(40) NOT NULL COMMENT 'Usuario',
  `cheque` varchar(12) DEFAULT NULL COMMENT 'Número de chque',
  `banco` varchar(45) DEFAULT NULL COMMENT 'Nombre del banco',
  `fechac` datetime NOT NULL COMMENT 'Fecha calendario',
  `codigoTC` varchar(3) NOT NULL COMMENT 'Código de tipo de cambio (tabla monedas)',
  `tipoca` float NOT NULL COMMENT 'Tipo de cambio',
  `userAnula` varchar(40) DEFAULT NULL COMMENT 'Usuario que anula',
  `fechaAnula` datetime DEFAULT NULL COMMENT 'Fecha de anulación',
  `cerrado` char(1) NOT NULL DEFAULT 'N' COMMENT 'Determina si el registro pertenece a un período cerrado (S/N).',
  `no_comprob` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Número de asiento',
  `tipo_comp` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento',
  `reccaja` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Número de recibo de caja',
  `idtarjeta` int(11) NOT NULL DEFAULT 0 COMMENT 'Código de tarjeta',
  `idbanco` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Código de la institución bancaria',
  `tipopago` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT 'Tipo de pago (0 = Desconocido, 1 = Efectivo, 2 = cheque, 3 = tarjeta, 4 = Transferencia)',
  PRIMARY KEY (`Recnume`),
  KEY `FK_pagos_monedas` (`codigoTC`),
  KEY `idx_pagos_clicode` (`clicode`),
  KEY `idx_pagos_fecha` (`fecha`),
  KEY `idx_pagos_reccaja` (`reccaja`),
  KEY `FK_pagos_babanco_idx` (`idbanco`),
  KEY `FK_pagos_tarjeta_idx` (`idtarjeta`),
  CONSTRAINT `FK_pagos_babanco` FOREIGN KEY (`idbanco`) REFERENCES `babanco` (`idbanco`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pagos_inclient` FOREIGN KEY (`clicode`) REFERENCES `inclient` (`clicode`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pagos_monedas` FOREIGN KEY (`codigoTC`) REFERENCES `monedas` (`codigo`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pagos_tarjeta` FOREIGN KEY (`idtarjeta`) REFERENCES `tarjeta` (`idtarjeta`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Encabezado de pagos';
--
-- Dump completed on: 2024/03/02 09:10:59
--
