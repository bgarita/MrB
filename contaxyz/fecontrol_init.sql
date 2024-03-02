--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `fecontrol` (
  `cantidad` int(11) NOT NULL COMMENT 'Conteo de documentos enviados',
  `permitidos` int(11) NOT NULL DEFAULT -1 COMMENT '-1 = Sin límite de envíos',
  `tolerancia` int(11) NOT NULL DEFAULT 5 COMMENT 'Envíos permitidos después del límite'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='Control de documentos electrónicos enviados';
--
-- Dump completed on: 2024/03/02 09:05:02
--
