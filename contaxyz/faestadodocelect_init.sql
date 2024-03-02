--
-- Dump created on: 2024/03/02 09:05:02
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `faestadodocelect` (
  `facnume` int(11) NOT NULL COMMENT 'Número de documento (FAC, NCR, NDB)',
  `facnd` int(11) NOT NULL COMMENT 'Número de NC o ND (las facturas aparecerán con un cero, las NC con un número positivo y las ND con un número negativo)',
  `tipoxml` varchar(1) NOT NULL COMMENT 'Tipo de xml. C=Compras (regimen simplificado), V=Ventas (regimen normal)',
  `xmlFile` varchar(70) NOT NULL DEFAULT ' ' COMMENT 'Nombre del archivo xml (solo el nombre, no la ruta)',
  `estado` tinyint(4) NOT NULL COMMENT 'Código de estado reportado por el Ministerio de Hacienda para los documentos electrónicos',
  `descrip` varchar(5000) NOT NULL DEFAULT ' ' COMMENT 'Texto que describe el estado de documento electrónico según el Ministerio de Hacienda',
  `informado` char(1) NOT NULL DEFAULT 'N' COMMENT '(S/N) indica que el estado fue informado al usuario o no.',
  `correo` varchar(100) NOT NULL DEFAULT ' ' COMMENT 'Dirección de correo electrónico a la que fue enviada la notificación.',
  `fecha` datetime NOT NULL COMMENT 'Fecha y hora en que fue enviada la notificación.',
  `referencia` int(11) NOT NULL DEFAULT 0 COMMENT 'Número de referencia en Hacienda',
  `xmlFirmado` varchar(70) NOT NULL DEFAULT ' ' COMMENT 'Nombre del archivo xml firmado',
  `xmlEnviado` char(1) NOT NULL DEFAULT 'N' COMMENT 'Indica si el xml fue enviado o no (S/N)',
  `fechaEnviado` datetime DEFAULT NULL COMMENT 'Fecha y hora en que se envió (al destinatario)',
  `emailDestino` varchar(100) NOT NULL DEFAULT ' ' COMMENT 'Correo electrónico al que se envió el xml',
  PRIMARY KEY (`facnume`,`facnd`,`tipoxml`),
  KEY `Idx_estado` (`estado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
--
-- Dump completed on: 2024/03/02 09:05:02
--
