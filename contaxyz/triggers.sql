--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
DROP TRIGGER IF EXISTS bodexis_after_update;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `bodexis_after_update` AFTER UPDATE ON `bodexis` FOR EACH ROW BEGIN

	Declare vArtexis decimal(14,4);

  	Declare vArtreserv decimal(14,4);

  	Declare vMinimo decimal(14,4);



  	Set vArtexis   = (Select sum(artexis)   from bodexis where artcode = NEW.artcode);

  	Set vArtreserv = (Select sum(Artreserv) from bodexis where artcode = NEW.artcode);

  	Set vMinimo    = (Select sum(Minimo)    from bodexis where artcode = NEW.artcode);



  	Update inarticu

  	Set artexis = vArtexis, artreserv = vArtreserv, artmini = vMinimo

  	where artcode = NEW.artcode;

END$
delimiter ;
--
DROP TRIGGER IF EXISTS trg_cabys_afeterdelete;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `trg_cabys_afeterdelete` AFTER UPDATE ON `cabys` FOR EACH ROW BEGIN

	INSERT INTO cabys_audit (

		codigocabys_old,

		codigocabys_new,

		descrip_old,

		descrip_new,

		impuesto_old,

		impuesto_new,

		fecha,

		accion

		)

		VALUES (

		OLD.codigocabys,

		'',

		OLD.descrip,

		'',

		OLD.impuesto,

		0,

		NOW(),

		'Delete'

		);

END$
delimiter ;
--
DROP TRIGGER IF EXISTS trg_cabys_afeterupdate;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `trg_cabys_afeterupdate` AFTER UPDATE ON `cabys` FOR EACH ROW BEGIN

	INSERT INTO cabys_audit (

		codigocabys_old,

		codigocabys_new,

		descrip_old,

		descrip_new,

		impuesto_old,

		impuesto_new,

		fecha,

		accion

		)

		VALUES (

		OLD.codigocabys,

		NEW.codigocabys,

		OLD.descrip,

		NEW.descrip,

		OLD.impuesto,

		NEW.impuesto,

		NOW(),

		'Update'

		);

END$
delimiter ;
--
DROP TRIGGER IF EXISTS trg_catransa_tipopago;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `trg_catransa_tipopago` BEFORE INSERT ON `catransa` FOR EACH ROW BEGIN

	-- Aún cuando existe un tipo de pago cero, éste no se puede

	-- aceptar en cajas pues cero indica tipo de pago no definido.

	

	If NEW.`tipopago` = 0 THEN

		# Genero un error para cancelar la ejecución (esta tabla no existe)

		Insert into valor_nopermitido Select 1;

	End if;

END$
delimiter ;
--
DROP TRIGGER IF EXISTS CambiarMascaraTelefonica;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `CambiarMascaraTelefonica` AFTER UPDATE ON `config` FOR EACH ROW BEGIN

	If OLD.Mascaratel <> NEW.Mascaratel then

		Call CambiarMascaraTelefonica(NEW.Mascaratel);

	End if;

END$
delimiter ;
--
DROP TRIGGER IF EXISTS cxpfacturas_faestadoDocElect;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `cxpfacturas_faestadoDocElect` AFTER INSERT ON `cxpfacturas` FOR EACH ROW BEGIN

	if new.tipo = 'FAC' and exists(Select idProv from inproved Where procode = new.procode and idProv > '') then

	

		Insert into faestadoDocElect (

			facnume,

			facnd,

			tipoxml,

			xmlFile,

			estado,

			descrip,

			informado,

			correo,

			fecha,

			referencia)

		VALUES(

			new.factura,

			0,				-- Se clasifica como las facturas de venta.

			'C',

			concat(new.factura, '_C.xml'),

			100, -- Indica que aún no ha sido enviado a Hacienda

			'Pendiente envío al Ministerio de Hacienda',

			'N',

			' ',

			now(),

			0	-- Indica que aún no existe la referencia de Hacienda

		);

	end if;

END$
delimiter ;
--
DROP TRIGGER IF EXISTS ActualizaCliente2;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `ActualizaCliente2` BEFORE INSERT ON `faencabe` FOR EACH ROW BEGIN

	Call RecalcularSaldoClientes(new.clicode);

END$
delimiter ;
--
DROP TRIGGER IF EXISTS faencabe_faestadoDocElect;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `faencabe_faestadoDocElect` AFTER INSERT ON `faencabe` FOR EACH ROW BEGIN

	Insert into faestadoDocElect (

		facnume,

		facnd,

		tipoxml,

		xmlFile,

		estado,

		descrip,

		informado,

		correo,

		fecha,

		referencia)

	VALUES(

		new.facnume,

		new.facnd,

		'V',

		concat(new.facnume, '.xml'),

		100, -- Indica que aún no ha sido enviado a Hacienda

		'Pendiente envío al Ministerio de Hacienda',

		'N',

		' ',

		now(),

		0	-- Indica que aún no existe la referencia de Hacienda

	);

END$
delimiter ;
--
DROP TRIGGER IF EXISTS ValidarMontoReciboCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `ValidarMontoReciboCXC` BEFORE INSERT ON `pagos` FOR EACH ROW BEGIN

	If NEW.`monto` <= 0 THEN

     	# Genero un error para cancelar la ejecución

     	Insert into valor_nopermitido Select 1;

  	End if;

END$
delimiter ;
--
DROP TRIGGER IF EXISTS actualizarCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` TRIGGER `actualizarCliente` AFTER INSERT ON `pagos` FOR EACH ROW BEGIN

	Update inclient Set

         clisald = clisald - NEW.monto * NEW.tipoca

  	Where clicode = NEW.clicode;

END$
delimiter ;
--
--
-- Dump completed on: 2024/03/02 09:10:59
--
