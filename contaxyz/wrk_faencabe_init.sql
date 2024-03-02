--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `wrk_faencabe` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificar como registro único',
  `facnume` int(11) NOT NULL COMMENT 'Número de factura, NC o ND (las facturas y las ND tendrán un numero positivo, las NC negativo)',
  `clicode` int(10) unsigned NOT NULL COMMENT 'Código de cliente',
  `factipo` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT 'Tipo de pago (1 = Efectivo, 2 = cheque, 3 = tarjeta)',
  `chequeotar` varchar(45) DEFAULT NULL COMMENT 'Número de cheque o tarjeta',
  `vend` tinyint(3) unsigned NOT NULL COMMENT 'Código de vendedor',
  `terr` tinyint(3) unsigned NOT NULL COMMENT 'Código de zona o territorio',
  `facfech` datetime NOT NULL COMMENT 'Fecha del documento (factura, NC, ND)',
  `facplazo` smallint(3) unsigned NOT NULL COMMENT 'Plazo en días',
  `facimve` double NOT NULL DEFAULT 0 COMMENT 'Monto del impuesto (de ventas)',
  `facdesc` double NOT NULL DEFAULT 0 COMMENT 'Monto de descuento',
  `facmont` double NOT NULL DEFAULT 0 COMMENT 'Monto neto de la factura',
  `facfepa` datetime NOT NULL COMMENT 'Fecha de cancelación de la factura',
  `facpago` double NOT NULL DEFAULT 0,
  `facsald` double NOT NULL DEFAULT 0 COMMENT 'Saldo de la factura',
  `facnpag` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT 'Número de pagos',
  `facmpag` double DEFAULT NULL COMMENT 'Monto de cada pago',
  `facdpago` smallint(5) unsigned DEFAULT NULL COMMENT 'Días entre pago y pago',
  `facfppago` datetime DEFAULT NULL COMMENT 'Fecha del próximo pago',
  `facestado` char(1) NOT NULL COMMENT 'Estado de la factura (Blanco = Activa, A = Anulada)',
  `facnd` int(11) NOT NULL DEFAULT 0 COMMENT 'Número de NC o ND (las facturas aparecerán con un cero, las NC con un número positivo y las ND con un número negativo)',
  `user` varchar(40) NOT NULL COMMENT 'Usuario que registró el documento',
  `referencia` varchar(10) DEFAULT NULL COMMENT 'Referencia para relacionar algún documento de otro módulo como solicitud de taller, etc.',
  `precio` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT 'Categoría de precio',
  `facfechac` datetime NOT NULL COMMENT 'Fecha calendario (fecha del sistema)',
  `ordenc` varchar(10) DEFAULT NULL COMMENT 'Orden de compra',
  `formulario` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Número de formulario pre-impreso',
  `codigoTC` char(3) NOT NULL COMMENT 'Código del tipo del cambio',
  `tipoca` double NOT NULL DEFAULT 1 COMMENT 'Tipo de cambio',
  `faccsfc` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Crédito sobre facturas de contado',
  `facmonexp` double NOT NULL DEFAULT 0 COMMENT 'Monto Express',
  `CodExpress` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Código de Tarifa Express',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27094 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Encabezado de facturas';
--
-- Dump completed on: 2024/03/02 09:10:59
--
