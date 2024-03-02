--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `faexpress` (
  `CodExpress` smallint(5) unsigned NOT NULL DEFAULT 0 COMMENT 'Código de tarifa',
  `tarifa` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto fijo hasta el mínimo',
  `minimo` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto mínimo para tarifa fija',
  `porcentaje` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje a cobrar después del mínimo',
  PRIMARY KEY (`CodExpress`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Tarifas para el envío a domicilio';
--
-- Dump completed on: 2024/03/02 09:05:02
--
