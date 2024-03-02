--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `etapascierre` (
  `mes` smallint(5) unsigned NOT NULL COMMENT 'Mes del cierre',
  `ano` smallint(5) unsigned NOT NULL COMMENT 'Año del cierre',
  `usuario` varchar(50) NOT NULL DEFAULT user() COMMENT 'Usuario que ejecuta el proceso de cierre',
  `etapaconfirmada` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Número de etapa confirmada',
  `fecha` datetime NOT NULL DEFAULT sysdate() COMMENT 'Fecha y hora de finalizada la etapa',
  PRIMARY KEY (`mes`,`ano`,`etapaconfirmada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='Información sobre las etapas del cierre mensual';
--
-- Dump completed on: 2024/03/02 09:05:02
--
