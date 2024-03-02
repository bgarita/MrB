--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `paramusuario` (
  `longitudClave` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Longitud mínima para la clave del usuario.',
  `numeros` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Cantidad mínima de números en una clave.',
  `mayusculas` smallint(6) NOT NULL DEFAULT 1 COMMENT 'Cantidad mínima de mayúsculas en una clave.',
  `intervalo` smallint(6) NOT NULL DEFAULT 30 COMMENT 'Vencimiento de clave.'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
