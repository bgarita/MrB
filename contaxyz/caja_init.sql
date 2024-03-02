--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `caja` (
  `idcaja` int(11) NOT NULL COMMENT 'Número de caja',
  `descripcion` varchar(60) NOT NULL,
  `saldoinicial` double NOT NULL DEFAULT 0,
  `depositos` double NOT NULL DEFAULT 0 COMMENT 'Depósitos del día',
  `retiros` double NOT NULL DEFAULT 0 COMMENT 'Retiros del día',
  `saldoactual` double NOT NULL DEFAULT 0,
  `fechainicio` date DEFAULT NULL COMMENT 'Fecha de inicio de operación de esta caja',
  `fechafinal` date DEFAULT NULL COMMENT 'Fecha en que cerró esta caja',
  `fisico` double NOT NULL DEFAULT 0 COMMENT 'Monto físico en caja',
  `user` char(16) NOT NULL COMMENT 'Cajero asignado - solo el cierre de caja debe limpiar este campo',
  `bloqueada` char(1) NOT NULL DEFAULT 'N' COMMENT 'S=Si, N=No.  Permanece bloqueada hasta el cierre de caja.',
  `cerrada` char(1) NOT NULL DEFAULT 'N' COMMENT 'S/N. Cuando está cerrada no permite registrar transacciones',
  `efectivo` double NOT NULL DEFAULT 0 COMMENT 'Saldo en efectivo',
  PRIMARY KEY (`idcaja`),
  KEY `fk_caja_cajero` (`user`),
  CONSTRAINT `fk_caja_cajero` FOREIGN KEY (`user`) REFERENCES `cajero` (`user`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:49
--
