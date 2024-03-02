--
-- Dump created on: 2024/03/02 09:04:49
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
CREATE TABLE `casaldo` (
  `dFecha1` date NOT NULL COMMENT 'Fecha Rango inicial',
  `dFecha2` date NOT NULL COMMENT 'Fecha Rango final',
  `nSaldoIn` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Saldo inicial de la caja',
  `nVentasCr` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Ventas de crédito (no afecta la caja)',
  `nVentasCo` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Ventas de contado',
  `nDevoluc` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Devoluciones (notas de crédito - resta a las ventas)',
  `nRecibosCXC` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Recibos (pagos de los clientes)',
  `nComprasCr` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Compras de crédito (no afecta la caja)',
  `nComprasCo` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Compras de contado',
  `nNotasDsc` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Notas de débito sobre compras de contado',
  `nPagosProv` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Pagos a proveedores',
  `nSaldoFin` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Saldo final calculado',
  `nSaldoFis` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Saldo físico en caja',
  `nDiferencia` decimal(20,4) NOT NULL DEFAULT 0.0000 COMMENT 'Diferencia entre el saldo calculado y el saldo físico en caja',
  PRIMARY KEY (`dFecha1`,`dFecha2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
--
-- Dump completed on: 2024/03/02 09:04:49
--
