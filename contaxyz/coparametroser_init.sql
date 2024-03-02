--
-- Dump created on: 2024/03/02 09:05:01
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `coparametroser` (
  `parametro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Código de parámetro',
  `descrip` varchar(60) NOT NULL COMMENT 'Descripción que se usará en el reporte',
  PRIMARY KEY (`parametro`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='Parámetros para el estado de resultados';
--
-- Dump completed on: 2024/03/02 09:05:01
--
