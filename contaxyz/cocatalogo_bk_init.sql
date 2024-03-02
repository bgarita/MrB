--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cocatalogo_bk` (
  `mayor` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Cuenta mayor',
  `sub_cta` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Sub cuenta',
  `sub_sub` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Sub subcuenta',
  `colect` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Colectiva',
  `nom_cta` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Nombre de la cuenta',
  `nivel` smallint(6) NOT NULL DEFAULT 0 COMMENT '0=Cuenta de mayor, 1=Cuenta de movimientos',
  `tipo_cta` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Tipo de cuenta (1=Activo, 2=Pasivo, 3=Capital, 4=Ingresos, 5=Gastos)',
  `fecha_upd` datetime NOT NULL DEFAULT '2013-08-10 00:00:00' COMMENT 'Fecha de actualización',
  `ano_anter` decimal(24,4) NOT NULL DEFAULT 0.0000 COMMENT 'Saldo del periodo anterior',
  `db_fecha` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Débitos del periodo actual',
  `cr_fecha` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Créditos del periodo actual',
  `db_mes` decimal(18,4) NOT NULL DEFAULT 0.0000 COMMENT 'Débitos del mes actual',
  `cr_mes` decimal(18,4) NOT NULL DEFAULT 0.0000 COMMENT 'Créditos del mes actual',
  `nivelc` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Nivel de cuenta',
  `nombre` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Formatear como nombre? (1=Si, 0=No)',
  `fecha_c` datetime NOT NULL DEFAULT '2013-08-10 00:00:00' COMMENT 'Fecha de creación de la cuenta',
  `activa` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Indica si la cueta está activa o no (1=SI,0=No).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
