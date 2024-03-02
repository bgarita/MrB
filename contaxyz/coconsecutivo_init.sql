--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `coconsecutivo` (
  `no_comprobv` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Consecutivo de asientos de ventas',
  `tipo_compv` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento para el asiento de ventas',
  `no_comprobc` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Consecutivo de asientos de compra',
  `tipo_compc` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento para el asiento de compras',
  `no_comprobrv` varchar(10) NOT NULL DEFAULT ' ' COMMENT 'Consecutivo de asientos de recibos (CXC)',
  `tipo_comprv` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Tipo para el asiento de recibos (CXC)'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
