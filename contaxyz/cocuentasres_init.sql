--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `cocuentasres` (
  `cuenta` varchar(12) NOT NULL,
  `user` char(16) NOT NULL DEFAULT '',
  `recno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id único del registro',
  PRIMARY KEY (`recno`) USING BTREE,
  KEY `FK_cocuentasres_usuario` (`user`),
  CONSTRAINT `FK_cocuentasres_usuario` FOREIGN KEY (`user`) REFERENCES `usuario` (`user`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Cuentas restringidas';
--
-- Dump completed on: 2024/03/02 09:05:01
--
