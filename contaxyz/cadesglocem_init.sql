--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cadesglocem` (
  `dFecha1` date NOT NULL COMMENT 'Rango inicial',
  `dFecha2` date NOT NULL COMMENT 'Rango final',
  `b50000` int(11) NOT NULL DEFAULT 0 COMMENT 'Billetes de 50 000',
  `b20000` int(11) NOT NULL DEFAULT 0 COMMENT 'Billetes de  20 000',
  `b10000` int(11) NOT NULL DEFAULT 0 COMMENT 'Billetes de 10 000',
  `b5000` int(11) NOT NULL DEFAULT 0 COMMENT 'Billetes de 5 000',
  `b2000` int(11) NOT NULL DEFAULT 0 COMMENT 'Billetes de 2 000',
  `b1000` int(11) NOT NULL DEFAULT 0 COMMENT 'Billetes de 1000',
  `m500` int(11) NOT NULL DEFAULT 0 COMMENT 'Monedas de 500',
  `m100` int(11) NOT NULL DEFAULT 0 COMMENT 'Monedas de 100',
  `m50` int(11) NOT NULL DEFAULT 0 COMMENT 'Monedas de 50',
  `m25` int(11) NOT NULL DEFAULT 0 COMMENT 'Monedas de 25',
  `m10` int(11) NOT NULL DEFAULT 0 COMMENT 'Monedas de 10',
  `m5` int(11) NOT NULL DEFAULT 0 COMMENT 'Monedas de 5',
  `formula` varchar(1500) NOT NULL DEFAULT ' ' COMMENT 'Fórmula ',
  `total` decimal(24,4) NOT NULL DEFAULT 0.0000 COMMENT 'Total de monedas billetes y fórmula',
  PRIMARY KEY (`dFecha1`,`dFecha2`),
  KEY `fk_cadesglocem_casaldo` (`dFecha1`,`dFecha2`),
  CONSTRAINT `fk_cadesglocem_casaldo` FOREIGN KEY (`dFecha1`, `dFecha2`) REFERENCES `casaldo` (`dFecha1`, `dFecha2`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Desgloce de monedas y billetes para el cierre de caja';
--
-- Dump completed on: 2024/03/02 09:04:49
--
