--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hcaja` (
  `idcaja` int(11) NOT NULL COMMENT 'Número de caja',
  `descripcion` varchar(60) NOT NULL,
  `saldoinicial` double NOT NULL DEFAULT 0,
  `depositos` double NOT NULL DEFAULT 0 COMMENT 'Depósitos del día',
  `retiros` double NOT NULL DEFAULT 0 COMMENT 'Retiros del día',
  `saldoactual` double NOT NULL DEFAULT 0,
  `fechainicio` date NOT NULL COMMENT 'Fecha de inicio de operación de esta caja',
  `fechafinal` date NOT NULL COMMENT 'Fecha en que cerró esta caja',
  `fisico` double NOT NULL DEFAULT 0 COMMENT 'Monto físico en caja',
  `user` char(16) NOT NULL COMMENT 'Cajero responsable',
  `efectivo` double NOT NULL DEFAULT 0 COMMENT 'Saldo en efectivo',
  PRIMARY KEY (`idcaja`,`fechainicio`,`fechafinal`),
  KEY `fk_hcaja_cajero_idx` (`user`),
  CONSTRAINT `fk_hcaja_caja` FOREIGN KEY (`idcaja`) REFERENCES `caja` (`idcaja`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_hcaja_cajero` FOREIGN KEY (`user`) REFERENCES `cajero` (`user`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
