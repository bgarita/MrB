--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cocuentaser` (
  `parametro` int(11) NOT NULL COMMENT 'Viene de la tabla coparametroser',
  `mayor` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Cuenta de mayor',
  `sub_cta` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Sub cuenta',
  `sub_sub` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Sub sub cuenta',
  `colect` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Colectiva',
  `monto` decimal(14,0) NOT NULL DEFAULT 0 COMMENT 'Ultimo monto calculado para esta cuenta',
  PRIMARY KEY (`parametro`,`mayor`,`sub_cta`,`sub_sub`,`colect`),
  KEY `FK_cocatalogo` (`mayor`,`sub_cta`,`sub_sub`,`colect`),
  CONSTRAINT `FK_cocatalogo` FOREIGN KEY (`mayor`, `sub_cta`, `sub_sub`, `colect`) REFERENCES `cocatalogo` (`mayor`, `sub_cta`, `sub_sub`, `colect`) ON UPDATE CASCADE,
  CONSTRAINT `FK_coparametroser` FOREIGN KEY (`parametro`) REFERENCES `coparametroser` (`parametro`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='Cuentas incluidas en el estado de resultados';
--
-- Dump completed on: 2024/03/02 09:05:01
--
