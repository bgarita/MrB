--
-- Dump created on: 2024/03/02 09:07:00
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hcoasientod_bk` (
  `no_comprob` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Número de comprobante',
  `tipo_comp` tinyint(2) NOT NULL COMMENT 'Tipo de asiento',
  `descrip` varchar(60) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Descripción de esta línea',
  `db_cr` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=débito, 1=Crédito',
  `monto` decimal(24,4) NOT NULL COMMENT 'Monto de esta cuenta',
  `mayor` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `sub_cta` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `sub_sub` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `colect` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `idReg` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Identificado único del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
--
-- Dump completed on: 2024/03/02 09:07:00
--
