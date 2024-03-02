--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `wrk_fadetall` (
  `id` int(11) NOT NULL DEFAULT 0 COMMENT 'Se usa para relacionar los registros con la tabla Wrk_faencabe',
  `facnume` int(11) NOT NULL DEFAULT 0 COMMENT 'Número de factura, ND, NC',
  `artcode` varchar(20) NOT NULL COMMENT 'Código del artículo',
  `bodega` varchar(3) NOT NULL COMMENT 'Código de bodega',
  `faccant` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad ',
  `artprec` double NOT NULL DEFAULT 0 COMMENT 'Precio unitario',
  `facimve` double NOT NULL DEFAULT 0 COMMENT 'Monto del impuesto de ventas',
  `facpive` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje del impuesto de ventas',
  `facdesc` double NOT NULL DEFAULT 0 COMMENT 'Descuento',
  `facmont` double NOT NULL DEFAULT 0 COMMENT 'Monto bruto',
  `artcosp` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo promedio en moneda local',
  `facnd` int(11) NOT NULL DEFAULT 0 COMMENT 'Estado de la factura',
  `facpdesc` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje de descuento',
  `artcost` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo estándar en moneda local',
  `codigoTarifa` varchar(3) NOT NULL DEFAULT '01' COMMENT 'Código de tarifa según Hacienda',
  `codigocabys` varchar(20) NOT NULL DEFAULT ' ' COMMENT 'Código del catálogo de bienes y servicios de Hacienda',
  PRIMARY KEY (`id`,`artcode`,`bodega`),
  KEY `FK_wrk_fadetall_bodexis` (`artcode`,`bodega`),
  KEY `fk_wrk_fadetall_bodegas_idx` (`bodega`),
  KEY `FK_wrk_fadetall_tarifa_iva` (`codigoTarifa`),
  CONSTRAINT `FK_wrk_fadetall_tarifa_iva` FOREIGN KEY (`codigoTarifa`) REFERENCES `tarifa_iva` (`codigoTarifa`) ON UPDATE CASCADE,
  CONSTRAINT `FK_wrk_fadetall_wrk_faencabe` FOREIGN KEY (`id`) REFERENCES `wrk_faencabe` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_wrk_fadetall_bodegas` FOREIGN KEY (`bodega`) REFERENCES `bodegas` (`bodega`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_wrk_fadetall_inarticu` FOREIGN KEY (`artcode`) REFERENCES `inarticu` (`artcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Detalle de facturas';
--
-- Dump completed on: 2024/03/02 09:10:59
--
