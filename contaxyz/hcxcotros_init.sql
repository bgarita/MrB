--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `hcxcotros` (
  `id` int(11) NOT NULL COMMENT 'Identificador único',
  `fechacrea` datetime NOT NULL COMMENT 'Fecha de creación del registro',
  `user` varchar(50) NOT NULL COMMENT 'Usuario que registra la cxc',
  `montocxc` double NOT NULL DEFAULT 0 COMMENT 'Monto por cobrar',
  `fechapago` datetime DEFAULT NULL COMMENT 'Fecha en que se registró el pago',
  `recibidopor` varchar(50) NOT NULL COMMENT 'Nombre de la persona que recibió el pago',
  `montorecibido` double NOT NULL DEFAULT 0 COMMENT 'Monto recibido',
  `fechacierre` datetime NOT NULL COMMENT 'Fecha de creación del registro'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:10:59
--
