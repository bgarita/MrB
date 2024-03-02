--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `usuario` (
  `user` char(16) NOT NULL,
  `nivel` smallint(5) unsigned NOT NULL DEFAULT 0,
  `n1` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n2` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n3` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n4` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n5` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n6` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n7` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n8` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `n9` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `precios` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'El usuario que tenga esta autorización puede cambiar precios y costos',
  `devoluciones` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Puede apicar devoluciones',
  `descuentos` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Puede aplicar descuentos',
  `maxdesc` decimal(10,0) NOT NULL DEFAULT 0 COMMENT 'Porcentaje máximo de descuento permitido',
  `firmas` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Puede registrar firmas',
  `facturas` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Puede autorizar facturas',
  `notifcompra` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Notificar sobre mínimos (en inventario)',
  `intervalo1` smallint(5) unsigned NOT NULL DEFAULT 60 COMMENT 'Intervalo en minutos para notificar sobre mínimos (notifcompra)',
  `notifFactcxc` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Notificar sobre facturas por vencer (cxc)',
  `intervalo2` smallint(5) unsigned NOT NULL DEFAULT 60 COMMENT 'Intervalo en minutos para notificar sobre facturas de venta (notifFactcxc)',
  `notifFactcxp` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Notificar sobre facturas por vencer (cxp)',
  `intervalo3` smallint(5) unsigned NOT NULL DEFAULT 60 COMMENT 'Intervalo en minutos para notificar sobre facturas de compra (notifFactcxp)',
  `activo` char(1) NOT NULL DEFAULT 'S' COMMENT 'Estatus del usuario',
  `ultimaClave` datetime DEFAULT NULL COMMENT 'Último cambio de clave.',
  `notifxmlfe` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Notificar sobre los estados de los xmls enviados a Hacienda.',
  `intervalo4` smallint(5) NOT NULL DEFAULT 15 COMMENT 'Intervalo de notificaciones sobre los estados de los xmls enviados a Hacienda.',
  PRIMARY KEY (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
