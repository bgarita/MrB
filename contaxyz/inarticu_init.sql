--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `inarticu` (
  `artcode` varchar(20) NOT NULL COMMENT 'Código de artículo',
  `artdesc` varchar(50) NOT NULL COMMENT 'Descripción',
  `barcode` varchar(20) NOT NULL COMMENT 'Codigo de barras',
  `artfam` char(4) NOT NULL COMMENT 'Código de familia',
  `artcosd` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo en dolares',
  `artcost` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo estándar en moneda local',
  `artcosp` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo promedio en moneda local',
  `artcosa` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo de almacenamiento en moneda local',
  `artcosfob` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Costo FOB en moneda local',
  `artpre1` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Precio 1',
  `artgan1` double NOT NULL DEFAULT 0 COMMENT 'Porcentaje de utilidad para el precio 1',
  `artpre2` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Precio 2',
  `artgan2` double NOT NULL DEFAULT 0 COMMENT 'Porcentaje de utilidad para el precio 2',
  `artpre3` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Precio 3',
  `artgan3` double NOT NULL DEFAULT 0 COMMENT 'Porcentaje de utilidad para el precio 3',
  `artpre4` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Precio 4',
  `artgan4` double NOT NULL DEFAULT 0 COMMENT 'Porcentaje de utilidad para el precio 4',
  `artpre5` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Precio 5',
  `artgan5` double NOT NULL DEFAULT 0 COMMENT 'Porcentaje de utilidad para el precio 5',
  `procode` varchar(15) NOT NULL DEFAULT ' ' COMMENT 'Código del proveedore predeterminado',
  `artmaxi` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT 'Máximo',
  `artmini` decimal(10,4) NOT NULL DEFAULT 0.0000 COMMENT 'Mínimo',
  `artiseg` decimal(10,4) NOT NULL DEFAULT 0.0000 COMMENT 'Inventario de seguridad',
  `artdurp` decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT 'Duración en días del pedido',
  `artfech` datetime NOT NULL COMMENT 'Fecha de creación del registro',
  `artfeuc` datetime DEFAULT NULL COMMENT 'Fecha de la última compra',
  `artfeus` datetime DEFAULT NULL COMMENT 'Fecha de la última salida',
  `artexis` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Existencia total (la suma de todas las bodegas)',
  `artreserv` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad total reservada (todas las bodegas)',
  `transito` decimal(14,4) NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad en tránsito',
  `otroc` varchar(10) DEFAULT NULL COMMENT 'Código corto',
  `altarot` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=Es de alta rotación, 0=No es de alta rotación',
  `vinternet` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=De venta en Internet, 0=No está en venta en Internet',
  `artObse` varchar(1500) DEFAULT NULL COMMENT 'Observaciones',
  `artFoto` varchar(250) DEFAULT NULL COMMENT 'Ruta de la foto',
  `aplicaOferta` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Aplica precio de oferta (1=Si, 0=No).',
  `codigoTarifa` varchar(3) NOT NULL DEFAULT '01' COMMENT 'Código de tarifa según Hacienda',
  `codigocabys` varchar(20) NOT NULL DEFAULT ' ' COMMENT 'Código del catálogo de bienes y servicios de Hacienda',
  PRIMARY KEY (`artcode`),
  KEY `FK_infamily` (`artfam`),
  KEY `FK_inproved` (`procode`),
  KEY `Index_barcode` (`barcode`),
  KEY `Index_otroc` (`otroc`),
  KEY `FK_inarticu_tarifa_iva` (`codigoTarifa`),
  KEY `FK_inarticu_cabys` (`codigocabys`),
  CONSTRAINT `FK_inarticu_cabys` FOREIGN KEY (`codigocabys`) REFERENCES `cabys` (`codigocabys`),
  CONSTRAINT `FK_inarticu_infamily` FOREIGN KEY (`artfam`) REFERENCES `infamily` (`artfam`) ON UPDATE CASCADE,
  CONSTRAINT `FK_inarticu_inproved` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON UPDATE CASCADE,
  CONSTRAINT `FK_inarticu_tarifa_iva` FOREIGN KEY (`codigoTarifa`) REFERENCES `tarifa_iva` (`codigoTarifa`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Maestro de artículos de inventario';
--
-- Dump completed on: 2024/03/02 09:10:59
--
