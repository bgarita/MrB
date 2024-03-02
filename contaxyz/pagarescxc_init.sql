--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `pagarescxc` (
  `Pagare` int(10) unsigned NOT NULL COMMENT 'Número de pagaré',
  `clicode` int(10) unsigned NOT NULL COMMENT 'Código de cliente',
  `Monto` double NOT NULL,
  `Emision` datetime NOT NULL,
  `Vencimiento` datetime NOT NULL,
  `Observaciones` varchar(1000) DEFAULT NULL,
  `CodigoTC` varchar(3) NOT NULL DEFAULT '001' COMMENT 'Código de moneda',
  `Tipoca` float NOT NULL DEFAULT 1 COMMENT 'Tipo de cambio',
  `FechaReg` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Fecha y hora de registros',
  PRIMARY KEY (`Pagare`),
  KEY `FK_PagaresCXC_Inclient` (`clicode`),
  KEY `FK_pagarescxc_monedas` (`CodigoTC`),
  CONSTRAINT `FK_PagaresCXC_Inclient` FOREIGN KEY (`clicode`) REFERENCES `inclient` (`clicode`) ON UPDATE CASCADE,
  CONSTRAINT `FK_pagarescxc_monedas` FOREIGN KEY (`CodigoTC`) REFERENCES `monedas` (`codigo`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Pagarés';
--
-- Dump completed on: 2024/03/02 09:10:59
--
