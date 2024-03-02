--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `inservice` (
  `artcode` varchar(20) NOT NULL,
  PRIMARY KEY (`artcode`),
  CONSTRAINT `fk_inservice_inarticu` FOREIGN KEY (`artcode`) REFERENCES `inarticu` (`artcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
