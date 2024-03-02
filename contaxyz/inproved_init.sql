--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `inproved` (
  `procode` varchar(15) NOT NULL COMMENT 'Código de proveedor',
  `prodesc` varchar(40) NOT NULL COMMENT 'Nombre del proveedor',
  `prodir` varchar(200) DEFAULT NULL COMMENT 'Dirección',
  `protel1` varchar(11) DEFAULT NULL COMMENT 'Teléfono principal',
  `protel2` varchar(11) DEFAULT NULL COMMENT 'Teléfono secundario',
  `profax` varchar(11) DEFAULT NULL COMMENT 'Fax',
  `proapar` varchar(15) DEFAULT NULL COMMENT 'Apartado posta',
  `pronac` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Nacional = 1',
  `profeuc` datetime DEFAULT NULL COMMENT 'Fecha de la última compra',
  `promouc` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto de la última compra',
  `prosald` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Saldo actual',
  `proplaz` smallint(5) unsigned NOT NULL DEFAULT 0 COMMENT 'Plazo en días',
  `procueba` varchar(20) DEFAULT NULL COMMENT 'Cuenta bancaria',
  `mayor` varchar(3) NOT NULL DEFAULT '',
  `sub_cta` varchar(3) NOT NULL DEFAULT '',
  `sub_sub` varchar(3) NOT NULL DEFAULT '',
  `colect` varchar(45) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '' COMMENT 'Correo electrónico',
  `idProv` varchar(20) NOT NULL DEFAULT '' COMMENT 'Identificación del proveedor (cédula, pasaporte, etc.)',
  `idTipo` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Tipo de identificación: 1=Céd. Física, 2=Céd. Jurídica, 3=Documento de Identificación Migratorio para Extranjeros (DIMEX), 4=Número de Identificación Tributario Especial (NITE)',
  `provincia` tinyint(4) NOT NULL DEFAULT 0,
  `canton` int(11) NOT NULL DEFAULT 0,
  `distrito` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`procode`),
  KEY `Index_prodesc` (`prodesc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Tabla de proveedores';
--
-- Dump completed on: 2024/03/02 09:10:59
--
