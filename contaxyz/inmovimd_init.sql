--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `inmovimd` (
  `movdocu` varchar(10) NOT NULL COMMENT 'Número de documento',
  `movtimo` char(1) NOT NULL COMMENT 'E = Entrada, S=Salida',
  `artcode` varchar(20) NOT NULL,
  `bodega` varchar(3) NOT NULL,
  `procode` varchar(15) DEFAULT NULL,
  `movcant` decimal(14,4) unsigned NOT NULL DEFAULT 0.0000 COMMENT 'Cantidad',
  `movcoun` decimal(16,6) unsigned NOT NULL DEFAULT 0.000000 COMMENT 'Costo unitario',
  `artcosfob` decimal(14,4) unsigned NOT NULL DEFAULT 0.0000,
  `artprec` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Precio unitario',
  `facimve` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Impuesto de ventas',
  `facdesc` decimal(12,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Descuento',
  `movtido` smallint(3) unsigned NOT NULL COMMENT 'Tipo de documento (ver tabla INTIPOSDOC)',
  `centroc` char(3) DEFAULT NULL COMMENT 'Centro de costo',
  `fechaven` date DEFAULT NULL COMMENT 'Fecha de vencimiento',
  KEY `FK_inmovimd_bodexis` (`bodega`,`artcode`),
  KEY `FK_inmovimd_inmovime` (`movdocu`,`movtimo`,`movtido`),
  KEY `Index_Artcode` (`artcode`,`bodega`),
  KEY `Index_Artcode_H` (`artcode`),
  KEY `Index_Movdocu` (`movdocu`),
  CONSTRAINT `FK_inmovimd_bodegas` FOREIGN KEY (`bodega`) REFERENCES `bodegas` (`bodega`) ON UPDATE CASCADE,
  CONSTRAINT `FK_inmovimd_bodexis` FOREIGN KEY (`bodega`, `artcode`) REFERENCES `bodexis` (`bodega`, `artcode`) ON UPDATE CASCADE,
  CONSTRAINT `FK_inmovimd_inmovime` FOREIGN KEY (`movdocu`, `movtimo`, `movtido`) REFERENCES `inmovime` (`movdocu`, `movtimo`, `movtido`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Detalle Movimientos de inventario ';
--
-- Dump completed on: 2024/03/02 09:10:59
--
