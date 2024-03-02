--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hinclient` (
  `clicode` int(10) unsigned NOT NULL COMMENT 'Código de cliente',
  `clidesc` varchar(50) NOT NULL COMMENT 'Nombre o descripción del cliente',
  `clidir` varchar(200) DEFAULT NULL COMMENT 'Dirección',
  `clitel1` varchar(11) DEFAULT NULL COMMENT 'Teléfono principal',
  `clitel2` varchar(11) DEFAULT NULL,
  `clitel3` varchar(11) DEFAULT NULL,
  `clifax` varchar(11) DEFAULT NULL COMMENT 'Fax',
  `cliapar` varchar(10) DEFAULT NULL COMMENT 'Apartado',
  `clinaci` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Nacional o Extranjero',
  `clisald` double NOT NULL DEFAULT 0 COMMENT 'Saldo',
  `cliprec` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT 'Categoría de precio',
  `clilimit` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Límite',
  `terr` tinyint(3) unsigned DEFAULT NULL COMMENT 'Zona o territorio',
  `vend` tinyint(3) unsigned DEFAULT NULL COMMENT 'Vendedor predeterminado',
  `clasif` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT 'Clasificación',
  `cliplaz` smallint(4) unsigned NOT NULL DEFAULT 0 COMMENT 'Plazo en días',
  `exento` tinyint(1) unsigned NOT NULL COMMENT 'Excento',
  `clifeuc` datetime DEFAULT NULL COMMENT 'Fecha de la última compra',
  `encomienda` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Enviar por encomienda',
  `direncom` varchar(200) DEFAULT NULL COMMENT 'Dirección para envíos por encomienda',
  `facconiv` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Facturar con impuesto de ventas separado',
  `clinpag` tinyint(2) unsigned NOT NULL DEFAULT 1 COMMENT 'Número de pagos',
  `clicelu` varchar(11) NOT NULL COMMENT 'Celular',
  `cliemail` varchar(100) DEFAULT NULL COMMENT 'Correo electrónico',
  `clireor` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Requiere orden de compra',
  `igsitcred` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Ignorar situación crediticia',
  `credcerrado` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Crédito cerrado',
  `diatramite` tinyint(2) unsigned NOT NULL DEFAULT 0 COMMENT 'Día de trámite',
  `horatramite` varchar(5) DEFAULT NULL COMMENT 'Hora de trámite',
  `diapago` tinyint(2) unsigned NOT NULL DEFAULT 30 COMMENT 'Día de pago',
  `horapago` varchar(5) NOT NULL COMMENT 'Hora de pago',
  `clicueba` varchar(20) NOT NULL COMMENT 'Cuenta bancaria',
  `cligenerico` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Cliente genérico para usar en ventas de contado.',
  `mayor` varchar(3) NOT NULL DEFAULT '',
  `sub_cta` varchar(3) NOT NULL DEFAULT '',
  `sub_sub` varchar(3) NOT NULL DEFAULT '',
  `colect` varchar(3) NOT NULL DEFAULT '',
  `idcliente` varchar(20) NOT NULL COMMENT 'Identificación del cliente; puede ser cédula, pasaporte o cualquier otro documento oficial.',
  `cliperi` datetime NOT NULL COMMENT 'Periodo de cierre',
  `idtipo` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Tipo de identificación: 1=Céd. Física, 2=Céd. Jurídica, 3=Documento de Identificación Migratorio para Extranjeros (DIMEX), 4=Número de Identificación Tributario Especial (NITE)',
  PRIMARY KEY (`clicode`,`cliperi`),
  KEY `FK_hinclient_inclient` (`clicode`),
  KEY `FK_territorio` (`terr`),
  KEY `FK_vendedor` (`vend`),
  KEY `Index_clidesc` (`clidir`),
  CONSTRAINT `FK_hinclient_inclient` FOREIGN KEY (`clicode`) REFERENCES `inclient` (`clicode`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_hinclient_territorio` FOREIGN KEY (`terr`) REFERENCES `territor` (`terr`) ON UPDATE CASCADE,
  CONSTRAINT `FK_hinclient_vendedor` FOREIGN KEY (`vend`) REFERENCES `vendedor` (`vend`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Histórico de clientes';
--
-- Dump completed on: 2024/03/02 09:10:59
--
