--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `distrito` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idCanton` int(11) NOT NULL DEFAULT 1,
  `codigo` int(2) unsigned zerofill DEFAULT NULL,
  `distrito` varchar(70) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_distrito_canton_idx` (`idCanton`),
  CONSTRAINT `fk_distrito_canton` FOREIGN KEY (`idCanton`) REFERENCES `canton` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=476 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:05:01
--
