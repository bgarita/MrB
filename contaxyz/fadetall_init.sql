--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `fadetall` (
  `facnume` int(11) NOT NULL COMMENT 'Número de factura, ND, NC',
  `artcode` varchar(20) NOT NULL COMMENT 'Código del artículo',
  `bodega` varchar(3) NOT NULL COMMENT 'Código de bodega',
  `faccant` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad ',
  `artprec` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Precio unitario',
  `facimve` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Monto del impuesto de ventas',
  `facpive` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje del impuesto de ventas',
  `facdesc` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Descuento',
  `facmont` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Monto bruto',
  `artcosp` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo promedio en moneda local',
  `facnd` int(11) NOT NULL DEFAULT 0 COMMENT 'Estado de la factura',
  `facpdesc` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje de descuento',
  `artcost` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo estándar en moneda local',
  `codigoTarifa` varchar(3) NOT NULL DEFAULT '01' COMMENT 'Código de tarifa según Hacienda',
  `codigocabys` varchar(20) NOT NULL DEFAULT ' ' COMMENT 'Código del catálogo de bienes y servicios de Hacienda',
  KEY `FK_bodexis` (`artcode`,`bodega`),
  KEY `Index_artcode` (`artcode`),
  KEY `Index_bodega` (`bodega`),
  KEY `Index_facnume+facnd` (`facnume`,`facnd`),
  KEY `FK_fadetall_tarifa_iva` (`codigoTarifa`),
  KEY `FK_fadetall_cabys` (`codigocabys`),
  CONSTRAINT `FK_fadetall_bodexis` FOREIGN KEY (`artcode`, `bodega`) REFERENCES `bodexis` (`artcode`, `bodega`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_fadetall_cabys` FOREIGN KEY (`codigocabys`) REFERENCES `cabys` (`codigocabys`),
  CONSTRAINT `FK_fadetall_faencabe` FOREIGN KEY (`facnume`, `facnd`) REFERENCES `faencabe` (`facnume`, `facnd`) ON UPDATE CASCADE,
  CONSTRAINT `FK_fadetall_tarifa_iva` FOREIGN KEY (`codigoTarifa`) REFERENCES `tarifa_iva` (`codigoTarifa`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Detalle de facturas';
--
-- Dump completed on: 2024/03/02 09:05:02
--
