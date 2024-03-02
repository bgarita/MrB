--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
DROP VIEW IF EXISTS vistacocatalogo;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistacocatalogo` AS select concat(`cocatalogo`.`mayor`,`cocatalogo`.`sub_cta`,`cocatalogo`.`sub_sub`,`cocatalogo`.`colect`) AS `cuenta`,`cocatalogo`.`mayor` AS `mayor`,`cocatalogo`.`sub_cta` AS `sub_cta`,`cocatalogo`.`sub_sub` AS `sub_sub`,`cocatalogo`.`colect` AS `colect`,`cocatalogo`.`nom_cta` AS `nom_cta`,`cocatalogo`.`nivel` AS `nivel`,`cocatalogo`.`tipo_cta` AS `tipo_cta`,`cocatalogo`.`fecha_upd` AS `fecha_upd`,`cocatalogo`.`ano_anter` AS `ano_anter`,`cocatalogo`.`db_fecha` AS `db_fecha`,`cocatalogo`.`cr_fecha` AS `cr_fecha`,`cocatalogo`.`db_mes` AS `db_mes`,`cocatalogo`.`cr_mes` AS `cr_mes`,`cocatalogo`.`nivelc` AS `nivelc`,`cocatalogo`.`nombre` AS `nombre`,`cocatalogo`.`fecha_c` AS `fecha_c` from `cocatalogo`;
--
DROP VIEW IF EXISTS vistaconsecutivoasientos;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaconsecutivoasientos` AS select `coasientoe`.`no_comprob` AS `no_comprob`,`coasientoe`.`tipo_comp` AS `tipo_comp` from `coasientoe` union select `hcoasientoe`.`no_comprob` AS `no_comprob`,`hcoasientoe`.`tipo_comp` AS `tipo_comp` from `hcoasientoe`;
--
DROP VIEW IF EXISTS vistaconteo;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaconteo` AS select `c`.`bodega` AS `bodega`,`c`.`artcode` AS `artcode`,`a`.`artdesc` AS `artdesc`,`c`.`artexis` AS `artexis`,`c`.`cantidad` AS `cantidad`,`c`.`cantidad` - `c`.`artexis` AS `diferencia` from (`conteo` `c` join `inarticu` `a` on(`c`.`artcode` = `a`.`artcode`)) order by `a`.`artdesc`,`c`.`bodega`;
--
DROP VIEW IF EXISTS vistaintiposdocent;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaintiposdocent` AS select `intiposdoc`.`Movtido` AS `Movtido`,`intiposdoc`.`Descrip` AS `Descrip`,`intiposdoc`.`EntradaSalida` AS `EntradaSalida`,`intiposdoc`.`Modulo` AS `Modulo` from `intiposdoc` where `intiposdoc`.`EntradaSalida` = 'E' and `intiposdoc`.`Modulo` = 'INV';
--
DROP VIEW IF EXISTS vistaintiposdocsal;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaintiposdocsal` AS select `intiposdoc`.`Movtido` AS `Movtido`,`intiposdoc`.`Descrip` AS `Descrip`,`intiposdoc`.`EntradaSalida` AS `EntradaSalida`,`intiposdoc`.`Modulo` AS `Modulo` from `intiposdoc` where `intiposdoc`.`EntradaSalida` = 'S' and `intiposdoc`.`Modulo` = 'INV';
--
DROP VIEW IF EXISTS vistausuarios;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistausuarios` AS select distinct `user`.`User` AS `User` from `mysql`.`user`;
--
--
-- Dump completed on: 2024/03/02 09:10:59
--
