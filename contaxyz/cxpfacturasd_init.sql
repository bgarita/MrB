--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cxpfacturasd` (
  `factura` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Número de factura, NC o ND',
  `tipo` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Tipo de documento (FAC, NCR, NDB)',
  `procode` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Código de proveedor',
  `codigoTarifa` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Código de tarifa o impuesto según Ministerio de Hacienda',
  `facpive` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje de impuesto',
  `facimve` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Monto del impuesto',
  KEY `FK_cxpfacturasd_tarifa_iva` (`codigoTarifa`),
  KEY `FK_cxpfacturasd_cxpfacturas` (`factura`,`tipo`,`procode`),
  CONSTRAINT `FK_cxpfacturasd_cxpfacturas` FOREIGN KEY (`factura`, `tipo`, `procode`) REFERENCES `cxpfacturas` (`Factura`, `tipo`, `procode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_cxpfacturasd_tarifa_iva` FOREIGN KEY (`codigoTarifa`) REFERENCES `tarifa_iva` (`codigoTarifa`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='Detalle de impuestos de los documentos de compras';
--
-- Dump completed on: 2024/03/02 09:05:01
--
