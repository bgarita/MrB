--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cabys_audit` (
  `codigocabys_old` varchar(20) NOT NULL COMMENT 'Código según MH',
  `codigocabys_new` varchar(20) NOT NULL COMMENT 'Código según MH',
  `descrip_old` varchar(1000) NOT NULL COMMENT 'Descripción del bien o servicio',
  `descrip_new` varchar(1000) NOT NULL COMMENT 'Descripción del bien o servicio',
  `impuesto_old` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje IVA',
  `impuesto_new` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje IVA',
  `fecha` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de la acción',
  `accion` varchar(10) NOT NULL DEFAULT '' COMMENT 'Update, Delete'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Tabla de auditoría para cabys';
--
-- Dump completed on: 2024/03/02 09:04:49
--
