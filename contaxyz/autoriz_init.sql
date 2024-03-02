--
-- Dump created on: 2024/03/02 09:04:18
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `autoriz` (
  `user` char(16) NOT NULL,
  `programa` varchar(40) NOT NULL,
  PRIMARY KEY (`user`,`programa`),
  KEY `FK_programa` (`programa`),
  KEY `FK_usuario` (`user`),
  CONSTRAINT `FK_programa` FOREIGN KEY (`programa`) REFERENCES `programa` (`programa`) ON UPDATE CASCADE,
  CONSTRAINT `FK_usuario` FOREIGN KEY (`user`) REFERENCES `usuario` (`user`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:18
--
