--
-- Dump created on: 2024/03/02 09:07:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hcocatalogo` (
  `mayor` varchar(3) NOT NULL COMMENT 'Cuenta mayor',
  `sub_cta` varchar(3) NOT NULL COMMENT 'Sub cuenta',
  `sub_sub` varchar(3) NOT NULL COMMENT 'Sub subcuenta',
  `colect` varchar(3) NOT NULL COMMENT 'Colectiva',
  `nom_cta` varchar(40) NOT NULL COMMENT 'Nombre de la cuenta',
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
  `activa` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Indica si la cueta está activa o no (1=SI,0=No).',
  `fecha_cierre` date NOT NULL COMMENT 'Fecha de cierre',
  PRIMARY KEY (`mayor`,`sub_cta`,`sub_sub`,`colect`,`fecha_cierre`),
  KEY `nom_cta_idx` (`nom_cta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:07:02
--
