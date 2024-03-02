--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `pedidofd` (
  `facnume` int(10) unsigned NOT NULL COMMENT 'Número de pedido',
  `artcode` varchar(20) NOT NULL COMMENT 'Artículo',
  `bodega` varchar(3) NOT NULL COMMENT 'Bodega',
  `faccant` decimal(12,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad',
  `reservado` decimal(12,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad reservada',
  `fechares` datetime DEFAULT NULL COMMENT 'Fecha de reservado',
  `tempres` decimal(12,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad reservada temporalmente (campo de trabajo)',
  `artprec` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Precio unitario',
  `facimve` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Monto (total) del impuesto de ventas',
  `facpive` float unsigned NOT NULL DEFAULT 0 COMMENT 'Porcentaje del impuesto de ventas',
  `facdesc` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Monto (total) del descuento',
  `facmont` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Monto bruto del pedido',
  `artcosp` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Costo promedio en moneda local',
  `facestado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado del pedido (1=Activo, 0=Nulo)',
  `fechaped` datetime DEFAULT NULL COMMENT 'Fecha de pedido',
  `codigoTarifa` varchar(3) NOT NULL DEFAULT '01' COMMENT 'Código de tarifa según Hacienda',
  KEY `FK_pedidofd_Bodega` (`bodega`),
  KEY `FK_pedidofd_bodexis` (`artcode`,`bodega`),
  KEY `FK_pedidofd_Inarticu` (`artcode`),
  KEY `FK_pedidofd_tarifa_iva` (`codigoTarifa`),
  CONSTRAINT `FK_pedidofd_bodexis` FOREIGN KEY (`artcode`, `bodega`) REFERENCES `bodexis` (`artcode`, `bodega`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_pedidofd_tarifa_iva` FOREIGN KEY (`codigoTarifa`) REFERENCES `tarifa_iva` (`codigoTarifa`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Pedidos de venta (detalle)';
--
-- Dump completed on: 2024/03/02 09:10:59
--
