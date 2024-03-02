--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `canton` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idProvincia` int(11) NOT NULL,
  `codigo` int(2) unsigned zerofill NOT NULL,
  `canton` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_canton_1_idx` (`idProvincia`),
  CONSTRAINT `fk_canton_1` FOREIGN KEY (`idProvincia`) REFERENCES `provincia` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:49
--
