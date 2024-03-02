--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `pedidoe` (
  `facnume` int(10) unsigned NOT NULL COMMENT 'Número de pedido',
  `clicode` int(10) unsigned NOT NULL COMMENT 'Código de cliente',
  `factipo` smallint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Tipo de pago (1=Efectivo, 2= cheque, 3=Tarjeta)',
  `chequeotar` varchar(45) DEFAULT NULL COMMENT 'Número de cheque o tarjeta',
  `vend` tinyint(3) unsigned NOT NULL COMMENT 'Número de vendedor',
  `terr` tinyint(3) unsigned NOT NULL COMMENT 'Código de zona o territorio',
  `facfech` datetime NOT NULL COMMENT 'Fecha del pedido',
  `facplazo` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Plazo en días',
  `facimve` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto del impuesto de ventas',
  `facdesc` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto de descuento',
  `facmont` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto del pedido',
  `user` varchar(40) NOT NULL COMMENT 'Usuario que registró el pedido',
  `precio` tinyint(3) unsigned NOT NULL COMMENT 'Categoría de precio usada en el momento de registrar el pedido',
  `facivi` tinyint(1) unsigned NOT NULL COMMENT 'Indica si el pedido lleva el impuesto incluido',
  `observa` varchar(5000) DEFAULT NULL COMMENT 'Observaciones.  Máximo 5000 caracteres.',
  `Updatingbyuser` varchar(40) NOT NULL COMMENT 'Usuario que está modificando actualmente',
  PRIMARY KEY (`facnume`),
  KEY `FK_pedidoe_clicode` (`clicode`),
  KEY `FK_pedidoe_terr` (`terr`),
  KEY `FK_pedidoe_vend` (`vend`),
  CONSTRAINT `FK_pedidoe_clicode` FOREIGN KEY (`clicode`) REFERENCES `inclient` (`clicode`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pedidoe_terr` FOREIGN KEY (`terr`) REFERENCES `territor` (`terr`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pedidoe_vend` FOREIGN KEY (`vend`) REFERENCES `vendedor` (`vend`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Pedidos de venta (encabezado)';
--
-- Dump completed on: 2024/03/02 09:10:59
--
