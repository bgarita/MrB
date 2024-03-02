--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cajero` (
  `user` char(16) NOT NULL,
  `activo` char(1) NOT NULL DEFAULT 'S' COMMENT 'Indica si el cajero está activo o no.',
  PRIMARY KEY (`user`),
  CONSTRAINT `fk_cajero_usuario` FOREIGN KEY (`user`) REFERENCES `usuario` (`user`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:49
--
