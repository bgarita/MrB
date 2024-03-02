--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `configcuentas` (
  `ventas_g` varchar(12) NOT NULL DEFAULT '' COMMENT 'Cuenta de ventas gravadas',
  `ventas_e` varchar(12) NOT NULL DEFAULT '' COMMENT 'Ventas exentas',
  `descuento_vg` varchar(12) NOT NULL DEFAULT '' COMMENT 'Descuento de ventas gravadas',
  `descuento_ve` varchar(12) NOT NULL DEFAULT '' COMMENT 'Descuento de ventas exentas',
  `transitoria` varchar(12) NOT NULL DEFAULT '' COMMENT 'Cuenta transitoria',
  `compras_g` varchar(12) NOT NULL DEFAULT '' COMMENT 'Compras gravadas',
  `compras_e` varchar(12) NOT NULL DEFAULT '' COMMENT 'Compras exentas',
  `ctaCierre` varchar(12) NOT NULL DEFAULT '' COMMENT 'Cuenta de cierre anual',
  `precierre` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Define si el sistema se encuentra en pre-cierre (1=Si, 0=no)',
  `mesactual` tinyint(1) NOT NULL DEFAULT 12 COMMENT 'Define el mes actual de proceco (1=Enero,2=Febrero...12=Diciembre)',
  `mesCierreA` tinyint(1) NOT NULL DEFAULT 12 COMMENT 'Define el mes de cierre fiscal  (1=Enero, 2=Febrero...12=Diciembre9',
  `añoactual` smallint(6) NOT NULL DEFAULT 2010 COMMENT 'Define el año del ejercicio contable en curso',
  `mostrarfechaRep` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Define si se muestra la fecha de generación en los reportes o no (1=Si, 0=No)',
  `tipo_comp_V` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento para ventas',
  `tipo_comp_C` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento para compras',
  `tipo_comp_P` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento para pagos CXC',
  `tipo_comp_PP` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Tipo de asiento para pagos CXP'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
