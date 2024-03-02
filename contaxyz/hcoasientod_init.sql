--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hcoasientod` (
  `no_comprob` varchar(10) NOT NULL COMMENT 'Número de comprobante',
  `tipo_comp` tinyint(2) NOT NULL COMMENT 'Tipo de asiento',
  `descrip` varchar(60) NOT NULL COMMENT 'Descripción de esta línea',
  `db_cr` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=débito, 0=Crédito',
  `monto` decimal(24,4) NOT NULL COMMENT 'Monto de esta cuenta',
  `mayor` varchar(3) NOT NULL,
  `sub_cta` varchar(3) NOT NULL,
  `sub_sub` varchar(3) NOT NULL,
  `colect` varchar(3) NOT NULL,
  `idReg` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificado único del registro',
  PRIMARY KEY (`idReg`),
  KEY `fk_hcoasientod_hcoasientoe_idx` (`no_comprob`,`tipo_comp`),
  KEY `fk_hcoasientod_cocatalogo_idx` (`mayor`,`sub_cta`,`sub_sub`,`colect`),
  CONSTRAINT `FK_hcoasientod_hcocatalogo` FOREIGN KEY (`mayor`, `sub_cta`, `sub_sub`, `colect`) REFERENCES `hcocatalogo` (`mayor`, `sub_cta`, `sub_sub`, `colect`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43002 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
