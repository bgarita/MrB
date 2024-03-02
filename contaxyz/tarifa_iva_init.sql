--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `tarifa_iva` (
  `codigoTarifa` varchar(3) NOT NULL COMMENT 'Código de tarifa',
  `descrip` varchar(30) NOT NULL COMMENT 'Descripción de la tarifa',
  `porcentaje` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje de la tarifa',
  `cuenta` varchar(12) NOT NULL DEFAULT ' ' COMMENT 'Cuenta contable IVA ventas',
  `cuenta_c` varchar(12) NOT NULL DEFAULT ' ' COMMENT 'Cuenta contable IVA compras',
  PRIMARY KEY (`codigoTarifa`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Catálogo de impuestos según el Ministerio de Hacienda';
--
-- Dump completed on: 2024/03/02 09:10:59
--
