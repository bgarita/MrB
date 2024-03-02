--
-- Dump created on: 2024/03/02 09:04:18
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `barrio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idDistrito` int(11) DEFAULT NULL,
  `codigo` int(2) unsigned zerofill DEFAULT NULL,
  `barrio` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_barrio_distrito_idx` (`idDistrito`),
  CONSTRAINT `fk_barrio_distrito` FOREIGN KEY (`idDistrito`) REFERENCES `distrito` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6604 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:18
--
