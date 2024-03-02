--
-- Dump created on: 2024/03/02 09:04:26
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cabys` (
  `codigocabys` varchar(20) NOT NULL COMMENT 'Código según MH',
  `descrip` varchar(1000) NOT NULL COMMENT 'Descripción del bien o servicio',
  `impuesto` float NOT NULL DEFAULT 0 COMMENT 'Porcentaje IVA',
  PRIMARY KEY (`codigocabys`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Catálogo de bienes y servicios según el Ministerio de Hacienda';
--
-- Dump completed on: 2024/03/02 09:04:26
--
