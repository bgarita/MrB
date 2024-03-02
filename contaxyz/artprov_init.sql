--
-- Dump created on: 2024/03/02 09:04:18
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `artprov` (
  `artcode` varchar(20) NOT NULL COMMENT 'Código de artículo',
  `procode` varchar(15) NOT NULL COMMENT 'Código de proveedor',
  PRIMARY KEY (`artcode`,`procode`),
  KEY `Index_2` (`procode`),
  CONSTRAINT `FK_artprov_inarticu` FOREIGN KEY (`artcode`) REFERENCES `inarticu` (`artcode`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_artprov_inproved` FOREIGN KEY (`procode`) REFERENCES `inproved` (`procode`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Proveedores por artículo';
--
-- Dump completed on: 2024/03/02 09:04:18
--
