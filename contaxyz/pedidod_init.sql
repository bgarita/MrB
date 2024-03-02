--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `pedidod` (
  `facnume` int(10) unsigned NOT NULL COMMENT 'Número de pedido',
  `artcode` varchar(20) NOT NULL COMMENT 'Artículo',
  `bodega` varchar(3) NOT NULL COMMENT 'Bodega',
  `faccant` decimal(12,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad',
  `reservado` decimal(12,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad reservada',
  `fechares` datetime DEFAULT NULL COMMENT 'Fecha de reservado',
  `artprec` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Precio unitario',
  `facimve` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Monto (total) del impuesto de ventas',
  `facpive` float unsigned NOT NULL DEFAULT 0 COMMENT 'Porcentaje del impuesto de ventas',
  `facdesc` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Monto (total) del descuento',
  `facmont` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Monto bruto del pedido',
  `artcosp` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Costo promedio en moneda local',
  `facestado` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Estado del pedido (1=Activo, 0=Nulo)',
  `facpdesc` float unsigned NOT NULL DEFAULT 0 COMMENT 'Porcentaje de descuento',
  `fechaped` datetime DEFAULT NULL COMMENT 'Fecha de pedido',
  `codigoTarifa` varchar(3) NOT NULL DEFAULT '01' COMMENT 'Código de tarifa según Hacienda',
  KEY `FK_pedidod_artcode` (`artcode`),
  KEY `FK_pedidod_bodega` (`bodega`),
  KEY `FK_pedidod_bodexis` (`artcode`,`bodega`),
  KEY `Index_facnume` (`facnume`),
  KEY `FK_pedidod_tarifa_iva` (`codigoTarifa`),
  CONSTRAINT `FK_pedidod_bodexis` FOREIGN KEY (`artcode`, `bodega`) REFERENCES `bodexis` (`artcode`, `bodega`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_pedidod_facnume` FOREIGN KEY (`facnume`) REFERENCES `pedidoe` (`facnume`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pedidod_tarifa_iva` FOREIGN KEY (`codigoTarifa`) REFERENCES `tarifa_iva` (`codigoTarifa`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Pedidos de venta (detalle)';
--
-- Dump completed on: 2024/03/02 09:10:59
--
