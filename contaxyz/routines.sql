--
-- Dump created on: 2024/03/02 09:10:59
-- Application: mariadb.org binary distribution
-- Host: DESKTOP-T8NBJH5
-- Engine version: 11.0.2-MariaDB
--
USE contaxyz;
DROP FUNCTION IF EXISTS AplicadoANotaC_Hasta;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `AplicadoANotaC_Hasta`(`pNotanume`  int,


  `pFacnd`     int,


  `pFecha`     datetime


) RETURNS double
BEGIN


    


    


    


    Declare vNotasC  Double;


    Declare vCodigoTC varchar(3);





    Set vCodigoTC = (Select CodigoTC from config);





    


    Set vNotasC = IfNull(


      (Select 


			Sum(If(a.CodigoTC = vCodigoTC,notasd.monto * a.tipoca, notasd.monto))


       From notasd


       Inner join faencabe a on notasd.Notanume = a.facnume


       Where notasd.Notanume = pNotanume 


       and a.facnd = pFacnd


       and fechaAp <= pFecha),0);





    Return vNotasC;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsecutivoReciboCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsecutivoReciboCXC`() RETURNS int(10)
BEGIN


	


    Declare vRecnume int;





    


    Set vRecnume = (Select recnume + 1 from config);





    Set vRecnume = If(vRecnume is null or vRecnume = 0, 1, vRecnume);





    


    If Exists(Select recnume from pagos Where recnume = vRecnume) then


        Set vRecnume = (Select max(recnume) from pagos) + 1;


    End if;





    Return vRecnume;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarBodega;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarBodega`(`pBodega` char(3)


) RETURNS varchar(40) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(descrip) as descrip FROM bodegas where bodega = pBodega);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarCliente`(`pClicode` int(10)


) RETURNS varchar(50) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(clidesc) as clidesc FROM inclient where Clicode = pClicode);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarDocumento;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarDocumento`(`pcMovdocu`  varchar(10),


  `pcMovtimo`  char(20),


  `pnMovtido`  smallint(3)


) RETURNS tinyint(1)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    


  


    Declare vnExiste TinyInt(1);





    Set vnExiste = 


        If(Exists(  Select movdocu from inmovime


                    Where movdocu = pcMovdocu and movtimo = pcMovtimo


                    and movtido = pnMovtido), 1, 0);





    Return vnExiste;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarExistencia;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarExistencia`(`pCodigo`  varchar(20),


  `pBodega`  varchar(3)


) RETURNS decimal(14,4)
BEGIN


  Declare vArtexis Decimal(14,4);





  Set vArtexis =


      (Select artexis from bodexis where artcode = pCodigo and bodega = pBodega);





  If vArtexis is null then


    Set vArtexis = 0;


  End if;





  Return vArtexis;





END$
delimiter ;
--
DROP FUNCTION IF EXISTS AplicadoAFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `AplicadoAFactura`(`pFacnume`  int,


  `pFacnd`    int


) RETURNS double
BEGIN


    


    


    


    Declare vRecibos Double;


    Declare vNotasC  Double;


    Declare vCodigoTC varchar(3);





    Set vCodigoTC = (Select CodigoTC from config);





    


    Set vRecibos = IfNull(


      (Select Sum(If(a.CodigoTC = vCodigoTC,pagosd.monto * a.tipoca, pagosd.monto))


       From pagosd


       Inner join faencabe a on a.facnume = pagosd.facnume


       and a.facnd = pagosd.facnd


       Inner join pagos on pagosd.recnume = pagos.recnume


       Where pagosd.facnume = pFacnume


       and pagosd.facnd = pFacnd


       and pagos.estado = ''),0);





    


    Set vNotasC = IfNull(


      (Select Sum(If(a.CodigoTC = vCodigoTC,notasd.monto * a.tipoca, notasd.monto))


       From notasd


       Inner join faencabe a on a.facnume = notasd.notanume


       and a.facnd = abs(notasd.notanume)


       Where notasd.facnume = pFacnume 


       and notasd.facnd = pFacnd),0);





    Return vRecibos + vNotasC;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS AplicadoAFacturaCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `AplicadoAFacturaCXP`(`pFactura`  varchar(10),

  `pTipo`     varchar(3),

  `pProcode`  varchar(15)

) RETURNS double
BEGIN

    # Autor:    Bosco Garita 05/05/2012

    # Objet:    Obtener el monto aplicado a una factura/NC (Cuentas por pagar)

    #           El resultado siempre ser_ en moneda local.



    Declare vRecibos Double;

    Declare vNotasD  Double;



    # Sumar el monto de los recibos

    Set vRecibos = 

        IfNull((Select sum(cxppagd.monto * cxppage.tipoca) 

                from cxppagd, cxppage

                Where cxppagd.factura = pFactura and cxppagd.tipo = pTipo 

                and cxppagd.recnume = cxppage.recnume

                and cxppage.estado = ''),0);



    # Sumar el monto de las notas de débito

	/* 

	Bosco modificado 28/04/2013. 

	Utilizo el campo procode para identificar los registros.  Esto se debe a que

	en la tabla facturas la llave está compuesta por factura, tipo, procode.



    Set vNotasD = 

        IfNull((Select sum(cxpnotasd.monto * cxpfacturas.tipoca) 

                from cxpnotasd, cxpfacturas

                Where cxpnotasd.factura = pFactura and cxpnotasd.tipo = pTipo 

                and cxpnotasd.notanume = cxpfacturas.factura

                and cxpnotasd.NotaTipo = cxpfacturas.tipo),0);

	*/



	# Está pendiente localizar el tipo de cambio de la Nota de débito en la tabla facturas 28/04/2013

	# y pasar esta función a Windows

	/*Set vNotasD = 

        IfNull((Select sum(cxpnotasd.monto * cxpfacturas.tipoca) 

                from cxpnotasd, cxpfacturas

                Where cxpnotasd.factura = pFactura and cxpnotasd.tipo = pTipo 

				and cxpfacturas.factura = pFactura and cxpfacturas.tipo = pTipo

                and cxpnotasd.procode = cxpfacturas.procode),0);*/

	Set vNotasD =

		IfNull((Select 

				sum(cxpnotasd.monto * c.tipoca) 

			from cxpnotasd

			-- Este primer join es para la factura aplicada

			Inner join cxpfacturas on cxpnotasd.factura = cxpfacturas.factura

								  and cxpnotasd.tipo = cxpfacturas.tipo

								  and cxpnotasd.procode = cxpfacturas.procode

			-- Este segundo join es para la nota a aplicar, para el tipo de cambio

			Inner join cxpfacturas c on cxpnotasd.notanume = c.factura

								  and cxpnotasd.notatipo = c.tipo

								  and cxpnotasd.procode = c.procode

			Where cxpnotasd.factura = pFactura

			and cxpnotasd.tipo = pTipo 

			and cxpnotasd.procode = pProcode),0);

	/* Fin Bosco modificado 28/04/2013 */



    Return vRecibos + vNotasD;

END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarExistenciaDisponible;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarExistenciaDisponible`(`pCodigo`  varchar(20),


  `pBodega`  varchar(3)


) RETURNS decimal(14,4)
BEGIN


  Declare vDisponible Decimal(14,4);





  Set vDisponible =


      (Select artexis - artreserv from bodexis where artcode = pCodigo and bodega = pBodega);





  If vDisponible is null then


    Set vDisponible = 0;


  End if;





  Return vDisponible;





END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarFamilia;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarFamilia`(`pArtfam` char(4)


) RETURNS varchar(25) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(familia) as familia FROM infamily where artfam = pArtfam);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarMoneda;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarMoneda`(`pCodigo` char(3)


) RETURNS varchar(25) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(descrip) as descrip FROM monedas where codigo = pCodigo);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS AplicadoAFactura_Hasta;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `AplicadoAFactura_Hasta`(`pFacnume`  int,


  `pFacnd`    int,


  `pFecha`    datetime


) RETURNS double
BEGIN


    


    


    


    Declare vRecibos Double;


    Declare vNotasC  Double;


    Declare vCodigoTC varchar(3);





    Set vCodigoTC = (Select CodigoTC from config);





    


    Set vRecibos = IfNull(


      (Select 


			Sum(If(a.CodigoTC = vCodigoTC,pagosd.monto * a.tipoca, pagosd.monto))


       From pagosd


       Inner join faencabe a on a.facnume = pagosd.facnume


       and a.facnd = pagosd.facnd


       Inner join pagos on pagosd.recnume = pagos.recnume


       Where pagosd.facnume = pFacnume


       and pagosd.facnd = pFacnd


       and pagos.estado = ''


       and pagos.fecha <= pFecha),0);





    


    Set vNotasC = IfNull(


      (Select 


			Sum(If(a.CodigoTC = vCodigoTC,notasd.monto * a.tipoca, notasd.monto))


       From notasd


       Inner join faencabe a on a.facnume = notasd.notanume


       and a.facnd = abs(notasd.notanume)


       Where notasd.facnume = pFacnume 


       and notasd.facnd = pFacnd


       and notasd.fechaAp <= pFecha),0);





    Return vRecibos + vNotasC;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarProveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarProveedor`(`pProcode` varchar(15)


) RETURNS varchar(40) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(prodesc) as prodesc FROM inproved where Procode = pProcode);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarTerritorio;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarTerritorio`(`pTerr` tinyint(3)


) RETURNS varchar(50) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(descrip) as descrip FROM territor where terr = pTerr);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarTipoca;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarTipoca`(`pCodigo`  char(3),


  `pFecha`   datetime


) RETURNS float
BEGIN


	-- Autor: Bosco Garita.


	-- Monto del tipo de cambio para una fecha y moneda específicas.


	Return (SELECT max(tipoca) as tipoca


			FROM tipocambio


			WHERE nConsecutivo = (Select max(nConsecutivo) from tipocambio where codigo = pCodigo and fecha = pFecha));


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarUltimoTCDolar;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarUltimoTCDolar`() RETURNS float
BEGIN


	-- Autor: Bosco Garita.


	-- Traer el último tipo de cambio registrado para el dólar (si está registrado en config).


	Declare vCodigoDolar char(3);


	Declare vNconsecutivo SmallInt;


	Declare vTipoca float;





	Set vCodigoDolar   = (Select CodigoDolar from config);





	Set vNconsecutivo  =


	  (Select max(nConsecutivo) from tipocambio where codigo = vCodigoDolar);





	Set vTipoca =


	  (Select tipoca from tipocambio where Nconsecutivo = vNconsecutivo);





	Return vTipoca;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarUltimoTipocambio;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarUltimoTipocambio`(`pCodigo` varchar(3)

) RETURNS float
    COMMENT 'Obtener el último tipo de cambio para una moneda específica'
BEGIN

	-- Autor: Bosco Garita.

	-- Monto del tipo de cambio para moneda específica.

RETURN (

	SELECT tipoca

	FROM tipocambio

	WHERE nConsecutivo = (

		SELECT MAX(nConsecutivo)

		FROM tipocambio

		WHERE codigo = pCodigo)

	); 

END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarVendedor;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarVendedor`(`pVend` tinyint(3)


) RETURNS varchar(50) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Return (SELECT max(nombre) as nombre FROM vendedor where vend = pVend);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ClienteBloqueado;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ClienteBloqueado`(`pClicode` int


) RETURNS tinyint(1)
BEGIN


  


  Declare vBloqueado tinyInt(1); 


  Declare vBloqDias  smallInt;   


  Declare vClifeuc   Datetime;   


  Declare vCliplaz   smallInt;   


  Declare vDiasUC    int;        





  Select bloqdias from config into vBloqDias;





  Select clifeuc,cliplaz


  from inclient


  Where clicode = pClicode into vClifeuc,vCliplaz;





  Set vDiasUC = IfNull(datediff(curdate(), vClifeuc),0);





  Set vBloqueado = If(vDiasUC < vBloqDias,0,1);





  


  If vBloqueado and vCliplaz = 0 then


    Set vBloqueado = 0;


  End if;





  Return vBloqueado;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS dtoc;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `dtoc`(`pdFecha` datetime


) RETURNS char(10) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Declare vcDia   char(2);


  Declare vcMes   char(2);


  Declare vcAno   char(4);


  Declare vcFecha char(10);





  Set vcDia = Cast(day(pdFecha) as char(2));


  Set vcDia = Lpad(Trim(vcDia),2,'0');


  Set vcMes = Cast(month(pdFecha) as char(2));


  Set vcMes = Lpad(Trim(vcMes),2,'0');


  Set vcAno = Cast(year(pdFecha) as char(4));





  Set vcFecha = Concat(vcDia,'/',vcMes,'/',vcAno);





  Return vcFecha;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsecutivoFacturaCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsecutivoFacturaCXC`(`pNtipo` tinyint(1)


) RETURNS int(10)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    


    Declare vFacnume int;





    


    Set vFacnume = Case When pNtipo = 1 then (Select facnume from config)


                        When pNtipo = 2 then (Select ncred   from config)


                        When pNtipo = 3 then (Select ndeb    from config)


                   End;





    Set vFacnume = If(vFacnume is null or vFacnume = 0, 1, vFacnume);





    Set vFacnume = If(pNtipo = 2, vFacnume * -1, vFacnume);





    


    CASE pNtipo


      WHEN 1 THEN 


         If Exists(Select facnume from faencabe Where facnume = vFacnume and facnd = 0) then


           Set vFacnume = (Select max(facnume) from faencabe Where facnd = 0) + 1;


         End if;


      WHEN 2 THEN 


         If Exists(Select facnume from faencabe Where facnume = vFacnume and facnd > 0) then


           Set vFacnume = (Select min(facnume) from faencabe Where facnd > 0) - 1;


         End if;


      WHEN 3 THEN 


         If Exists(Select facnume from faencabe Where facnume = vFacnume and facnd = vFacnume * -1) then


           Set vFacnume = (Select max(facnume) from faencabe Where facnd < 0) + 1;


         End if;





    END CASE;








    Return vFacnume;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS FacturacionServiciosF;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `FacturacionServiciosF`(pFacnume Int,	


	pFacnd Int) RETURNS double
BEGIN


	-- Autor: Bosco Garita Azofeifa


    


	


    





	Declare vMonto Double;





	Select 


		Sum(fadetall.facmont * faencabe.tipoca) as monto


	from fadetall 


	Inner join inservice on fadetall.artcode = inservice.artcode


	Inner join faencabe on fadetall.facnume = faencabe.facnume and fadetall.facnd = faencabe.facnd


	Where faencabe.facnume = pFacnume


	and faencabe.facnd = pFacnd


	and faencabe.facestado = ''


	Into vMonto;





	Set vMonto = IfNull(vMonto,0);





	RETURN vMonto;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS GetDBUser;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `GetDBUser`() RETURNS varchar(50) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  


  


  Declare vcUser varchar(50);





  Set vcUser = trim(user());





  


  If not Exists(Select user from usuario Where user = vcUser) then


     Set vcUser = Substring(user() FROM 1 FOR position('@' in user())-1);


     If not Exists(Select user from usuario Where user = vcUser) then


        Set vcUser = '';


     End if;


  End if;








  Return vcUser;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsecutivoReciboCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsecutivoReciboCXP`() RETURNS int(11)
BEGIN


    # Autor     Bosco Garita 25/04/2012.


    # Objetivo  Otener el siguiente consecuvito de recibos de cuentas por pagar.


    


    Declare vRecnume int;





    # Obtengo el siguiente consecutivo


    Set vRecnume = (Select recnume1 + 1 from config);





    Set vRecnume = If(vRecnume is null or vRecnume = 0, 1, vRecnume);





    # Si el recibo ya existe entonces tomo el último número y le sumo uno


    If Exists(Select recnume from cxppage Where recnume = vRecnume and estado = '') then


        Set vRecnume = (Select max(recnume) from cxppage) + 1;


    End if;





    Return vRecnume;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarArticulo;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarArticulo`(`pCodigo`  varchar(20),


  `pCampo`   int


) RETURNS varchar(50) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Declare vArtdesc varchar(50);


  Declare vArtcode varchar(20);


  


  Set vArtdesc = (Select artdesc from inarticu where artcode = pCodigo);


  Set vArtcode = pCodigo;





  


  If vArtdesc is null then


    Set vArtcode = (Select max(artcode) from inarticu where barcode = pCodigo);


    Set vArtdesc = (Select artdesc from inarticu where artcode = vArtcode);


  End if;





  


  If vArtdesc is null then


    Set vArtcode = (Select max(artcode) from inarticu where otroc = pCodigo);


    Set vArtdesc = (Select artdesc from inarticu where artcode = vArtcode);


  End if;





  If pCampo = 1 then


    Return vArtcode;


  Else


    Return vArtdesc;


  End if;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarAutPrecios;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarAutPrecios`() RETURNS tinyint(1)
BEGIN


  Declare vUserMySQL varchar(76);


  Declare vUserToFind varchar(16);


  Declare vPos smallInt;


  Declare vLong smallInt;


  Declare vPrecios tinyInt(1);





  Set vUserMySQL = (Select user());


  Set vUserToFind = '';


  Set vPos = 0;


  Set vLong = Char_length(Trim(vUserMySQL));





  While vPos < vLong Do


    If substring(vUserMySQL,vPos,1) <> '@' then


       Set vUserToFind = Concat(vUserToFind,substring(vUserMySQL,vPos,1));


    Else


       Set vPos = vLong;


    End if;


    Set vPos = vPos + 1;


  End While;





  Set vPrecios = (Select precios from usuario where user = vUserToFind);





  If vPrecios is null then


    Set vPrecios = 0;


  End if;





  Return vPrecios;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS NC_Vigente;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `NC_Vigente`(`pNotanume` int


) RETURNS tinyint(1)
BEGIN


  


  Declare vVigente tinyInt(1);





  


  Set pNotanume = If(pNotanume > 0, pNotanume * -1, pNotanume);





  Set vVigente = If(Exists(Select facnume from faencabe


                            where facnume = pNotanume


                            and facnd > 0


                            and facsald < 0


                            and facestado = ''), 1, 0);





  Return vVigente;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ND_Vigente;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ND_Vigente`(`pFactura` varchar(10)


) RETURNS tinyint(1)
BEGIN


  # Autor:  Bosco Garita 05/05/2012


  # Objet:  Verificar si una ND todav?a existe y tiene saldo.


  Declare vVigente tinyInt(1);





  Set vVigente = If(Exists(Select factura from cxpfacturas


                            where factura = pFactura


                            and tipo = 'NDB'


                            and saldo < 0), 1, 0);





  Return vVigente;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS SiguientePagareCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `SiguientePagareCXC`() RETURNS int(11)
BEGIN


  Return (Select max(pagare) from pagaresCXC) + 1;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS UltimoDiaDelMes;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `UltimoDiaDelMes`(`pMes`  tinyint,


  `pAno`  int


) RETURNS datetime
BEGIN


    # Autor:        Bosco Garita 28/02/2011


    # Descrip:      Determinar cuál es el último día del mes


    


    Declare vPrimerDia datetime;


    Declare vUltimodia datetime;


    


    Set vPrimerDia = Concat(Cast(pAno as char(4)),'-',Cast(pMes as char(2)),'-','01 23:59:59');


    


    Set vUltimodia = vPrimerDia + interval 1 month - interval 1 day;


    Return vUltimodia;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarMontoVencidoCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarMontoVencidoCXC`(`pClicode`   int,


  `pInCluiDG`  tinyint


) RETURNS double
BEGIN


    Declare vMontoVencido double;


    Declare vDiasG        smallInt(3);  





    # Bosco agregado 28/01/2012


    Set vDiasG = 0;


    If pInCluiDG = 1 then


        Select diasG from config into vDiasG; -- Cargar los días de gracia.


    End if;


    # Fin Bosco agregado 28/01/2012








    # Obtener la sumatoria de los saldos vencidos.


    Set vMontoVencido = 


        IfNull((Select sum(facsald * tipoca)


                From faencabe


                Where clicode = pClicode


                  and facsald <> 0


                  and facestado <> 'A' 


                  and (facfepa + INTERVAL vDiasG DAY < date(now()) OR (facnume < 0 and facsald < 0)) ),0);








    Return If(vMontoVencido < 0, 0, vMontoVencido);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarPrecio;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarPrecio`(`pArtcode`  char(20),


  `pNprecio`  tinyint(2)


) RETURNS float
BEGIN


  Declare vPrecio float;


  CASE pNprecio


      WHEN 1 THEN


        Set vPrecio = (Select artpre1 from inarticu Where artcode = pArtcode);


      WHEN 2 THEN


        Set vPrecio = (Select artpre2 from inarticu Where artcode = pArtcode);


      WHEN 3 THEN


        Set vPrecio = (Select artpre3 from inarticu Where artcode = pArtcode);


      WHEN 4 THEN


        Set vPrecio = (Select artpre4 from inarticu Where artcode = pArtcode);


      WHEN 5 THEN


        Set vPrecio = (Select artpre5 from inarticu Where artcode = pArtcode);


      ELSE


        Set vPrecio = 0.00;


  END CASE;





  Return vPrecio;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS ConsultarVentaExenta;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `ConsultarVentaExenta`(`pFacnume` int


) RETURNS double
BEGIN


  Declare vExento Double;


  Declare vCodigoTC varchar(3);


  Declare vRedond5 tinyInt(1);





  Set vCodigoTC = (Select codigoTC from config);


  Set vRedond5  = (Select Redond5 from config);





  Set vExento = IfNull((


    Select


      If(b.codigoTC = vCodigoTC and vRedond5 = 1,


         RedondearA5(SUM(a.facmont - a.facdesc)),


         SUM(a.facmont - a.facdesc))


    From fadetall a


    Inner Join faencabe b ON a.facnume = b.facnume and


                             a.facnd   = b.facnd


    Where a.facnume = pFacnume AND


	        a.facimve = 0 AND


          a.facnd  >= 0 AND 


          b.facestado = ''),0);





  Return vExento;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS FacturacionServicios;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `FacturacionServicios`(pFecha1 Date,	-- Fecha inicial


	pFecha2 Date) RETURNS double
BEGIN


	# Autor:    Bosco Garita 07/01/2015


    # Objet:    Obtener el monto facturado de todos los artículos configurados


	#			como servicios para un rango de fechas.


    #           El resultado siempre será en moneda local.





	Declare vMonto Double;





	Select 


		Sum(fadetall.facmont * faencabe.tipoca) as monto


	from fadetall 


	Inner join inservice on fadetall.artcode = inservice.artcode


	Inner join faencabe on fadetall.facnume = faencabe.facnume and fadetall.facnd = faencabe.facnd


	Where Date(faencabe.facfech) between pFecha1 and pFecha2


	and faencabe.facestado = ''


	Into vMonto;





	Set vMonto = IfNull(vMonto,0);





	RETURN vMonto;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS FechaUltAbFacturaCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `FechaUltAbFacturaCXP`(`pFactura`  varchar(10),


  `pTipo`     varchar(3)


) RETURNS datetime
BEGIN


    # Autor:    Bosco Garita 06/05/2012


    # Objet:    Obtener la fecha del _ltimo abono para una factura/NC (Cuentas por pagar)


    #           Si no hay abonos devolver_ null.


    


    Declare vRecibos Datetime;


    Declare vNotasD  Datetime;


    Declare vMaxFec  Datetime;





    # Fecha m_xima en recibos


    Select max(fecha) from cxppage, cxppagd


    Where cxppagd.factura = pFactura and cxppagd.tipo = pTipo


    and cxppage.recnume = cxppagd.recnume


    Into vRecibos;





    # Fecha m_xima en notas de d_bito


    Select max(fechaAp) from cxpnotasd 


    Where factura = pFactura and tipo = pTipo


    Into vNotasD;


    


    # Determinar la fecha mayor


    Set vMaxFec = null;


    If vRecibos is not null then


        Set vMaxFec = vRecibos;


    End if;


    


    If vNotasD is not null and vMaxFec is not null then


        if vNotasD > vMaxFec then


            Set vMaxFec = vNotasD;


        End if;


    End if;





    Return Date(vMaxFec); -- La hora no es importante.


END$
delimiter ;
--
DROP FUNCTION IF EXISTS formatCta;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `formatCta`(nomCta varchar(500), 	-- Nombre de la cuenta o texto a formatear

	nivel int, 				-- Nivel de cuenta

	formatoNombre tinyInt(1), -- ¿Debe tratarse como un nombre personal? 1=Si, 0=No

	indent INT) RETURNS varchar(500) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN

	-- Autor Bosco Garita, 11/09/2016

	/*

	* Tiene como objetivo poner en mayúscula las cuentas de mayor y en minúscula

	* las cuentas de movimiento.  Además crea una indentación de n caracteres

	* para las cuentas de movimientos.

	* Si la cuenta tiene formato de nombre entonces no se toca.

	*/



	if formatoNombre = 1 THEN

		return nomCta;

	end if ;



	if nivel = 0 THEN

		Set nomCta = Upper(nomCta);

    else 

		Set nomCta = Concat(upper(substring(nomCta,1,1)), Lower(substring(nomCta,2)));

		Set nomCta = Concat(lpad('',indent, ' '),nomCta);

	end if;



	RETURN nomCta;

END$
delimiter ;
--
DROP FUNCTION IF EXISTS MascaraTelefonica;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `MascaraTelefonica`(`pcTelefono`  varchar(20),


  `pcMascara`   varchar(15)


) RETURNS varchar(20) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN


  Declare vcTelefono varchar(20);


  Declare vnPos      smallInt;  


  Declare vnLong     smallInt;  


  Declare vnLongM    smallInt;  


  Declare vnPosM     smallInt;  





  Set vnPos      = 1;


  Set vnLong     = Char_length(Trim(pcTelefono));


  Set vnLongM    = Char_length(Trim(pcMascara));


  Set vcTelefono = '';





  


  While vnPos <= vnLong Do


    If substring(pcTelefono,vnPos,1) in ('0','1','2','3','4','5','6','7','8','9') then


       Set vcTelefono = Concat(vcTelefono,substring(pcTelefono,vnPos,1));


    End if;


    Set vnPos = vnPos + 1;


  End While;





  


  Set vnPos      = 1;


  Set vnPosM     = 1;


  Set vnLong     = Char_length(Trim(vcTelefono));


  Set pcTelefono = vcTelefono;


  Set vcTelefono = '';





  While vnPosM <= vnLongM Do


    If substring(pcMascara,vnPosM,1) <> '#' then


       Set vcTelefono = Concat(vcTelefono,substring(pcMascara,vnPosM,1));


    Else


       Set vcTelefono = Concat(vcTelefono,substring(pcTelefono,vnPos,1));


       Set vnPos  = vnPos  + 1;


    End if;


    Set vnPosM = vnPosM + 1;


  End While;


  


  


  If vnLongM < vnLong then


     Set vcTelefono = Concat(vcTelefono,substring(pcTelefono,vnPos));


  End if;





  Return Trim(vcTelefono);


END$
delimiter ;
--
DROP FUNCTION IF EXISTS PermitirFecha;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `PermitirFecha`(`pdFecha` datetime

) RETURNS tinyint(1)
    COMMENT 'Determinar que la fecha no esté en un periodo cerrado'
BEGIN

    -- Autor:    Bosco Garita A. 09/02/2011.

    -- Objet:    Validar que la fecha no esté en un período cerrado.

    --           Este SP devuelve un Result Set con dos campos que indican si hubo error o no.

    

    Declare vcMes      char(2);

    Declare vcAno      char(4);

    Declare vcFecha    char(10);

    Declare vdFecha    datetime;

    Declare vnPermitir TinyInt(1);



    Set vnPermitir = 0;



    -- Obtener el mes y año cerrado

    Set vcMes = (Select Cast(MesCerrado as char(2)) from config);

    Set vcAno = (Select Cast(AnoCerrado as char(4)) from config);



    -- Si alguno de estos valores está nulo se asume que nunca se ha hecho un cierre

    If vcMes is null or vcAno is null then

        Set vnPermitir = 1;

    Else

        -- Concateno los valores del período cerrado para establecer el último día como día de cierre

        -- y luego verificar si la fecha recibida es mayor y de ser así esa fecha sería aceptada.

        Set vcFecha = Concat(vcAno,'-', vcMes, '-', '01');

        

        Set vdFecha = last_day(vcFecha);



        If pdFecha > vdFecha then

            Set vnPermitir = 1;

        End if;

    End if;



    Return vnPermitir;

END$
delimiter ;
--
DROP FUNCTION IF EXISTS RedondearA5;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `RedondearA5`(`pnNumero` double


) RETURNS double
BEGIN


  Declare vEsNegativo   bit;


  Declare vDevolver     Double;


  Declare vUltimoDigito tinyInt;


  Declare vNumero       Char(20);


  








  Set vEsNegativo = 0;


  Set vDevolver = pnNumero;





  If pnNumero < 0 then


     Set vEsNegativo = 1;


     Set pnNumero = Abs(pnNumero);


  End if;





  


  If pnNumero > 5 then


    Set vNumero = Trim(Cast(Truncate(pnNumero,0) as char(20)));


    Set vUltimoDigito = Right(vNumero,1);


    





    If vUltimoDigito > 5 then


       if (10 - vUltimoDigito) <= 2.5 then


          Set vDevolver = pnNumero + (10-vUltimoDigito);


       else


          Set vDevolver = pnNumero - vUltimoDigito + 5;


       end if;


    Else


       if (5 - vUltimoDigito) <= 2.5 then


          Set vDevolver = pnNumero + (5-vUltimoDigito);


       else


          Set vDevolver = pnNumero - vUltimoDigito;


       end if;


    End if;





    


    Set vDevolver = Truncate(vDevolver,0);


  End if;





  If vEsnegativo = 1 then


     Set vDevolver = vDevolver * -1;


  End if;





  Return vDevolver;


END$
delimiter ;
--
DROP FUNCTION IF EXISTS SaldoFacturaNDCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `SaldoFacturaNDCXC`(`pFacnume`  int,


  `pFacnd`    int


) RETURNS float
BEGIN


    # Autor     : Bosco Garita 05/03/2012


    # Objetivo  : Calcular el saldo de una factura o nota de débito.


    


    Declare vnRecibos float;    -- Monto aplicado en recibos


    Declare vnNotascr float;    -- Monto aplicado en notas de crédito


    Declare vnFacmont float;    -- Monto original de la factura o ND


    


    # Calcular el monto aplicado en recibos.


    Select sum(a.monto) from pagosd A


    Inner join pagos B on a.recnume = b.recnume


    Where a.facnume = pFacnume and a.facnd = pFacnd and b.estado = ''


    Into vnRecibos;


    


    # Calcular el monto aplicado en notas de crédito.


    Select sum(a.monto) from notasd A


    Inner join faencabe B on a.notanume = b.facnume


    Where a.facnume = pFacnume and a.facnd = pFacnd and b.facestado = ''


    Into vnNotascr;


    


    # Obtener el monto original de la factura o ND


    Select facmont from faencabe


    Where facnume = pFacnume and facnd = pFacnd


    Into vnFacmont;


    


    # Si algún monto es nulo, lo cambio por cero.


    Set vnRecibos = IfNull(vnRecibos,0);


    Set vnNotascr = IfNull(vnNotascr,0);


    


    # Retornar el saldo.


    Return (vnFacmont - (vnRecibos + vnNotascr));


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ActualizarCatContaFechaAnterior;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarCatContaFechaAnterior`(

	IN `dFecha` DATETIME 

)
BEGIN

  	/*

  	Traer los saldos de un mes cerrado al mes actual.

  	Autor: Bosco Garita, 17/10/2020

  	*/

	UPDATE cocatalogo, hcocatalogo

		SET cocatalogo.ano_anter = hcocatalogo.ano_anter,

		    cocatalogo.cr_fecha  = hcocatalogo.cr_fecha,

		    cocatalogo.db_fecha  = hcocatalogo.db_fecha,

		    cocatalogo.cr_mes    = hcocatalogo.cr_mes,

		    cocatalogo.db_mes    = hcocatalogo.db_mes

	WHERE cocatalogo.mayor = hcocatalogo.mayor 

	AND cocatalogo.sub_cta = hcocatalogo.sub_cta

	AND cocatalogo.sub_sub = hcocatalogo.sub_sub 

	AND cocatalogo.colect  = hcocatalogo.colect

	AND hcocatalogo.fecha_cierre = dFecha;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ActualizarCostos;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarCostos`(


  IN  `pArtcode`    varchar(20),


  IN  `pCantidad`   decimal(12,4),


  IN  `pCostoU`     decimal(16,6),


  IN  `pArtcosfob`  decimal(14,4),


  IN  `pMoneda`     char(3),


  IN  `pFecha`      datetime


)
BEGIN





    Declare vContinuar tinyint(1);    


    Declare vCostoAnt decimal(16,6);  -- Costo anterior


    Declare vTCx      float;          


    Declare vTCDolar  float;          


    Declare vCostoML  decimal(16,6);  -- Costo en moneda local


    Declare vCostoD   decimal(16,6);  -- Costo en dólares


    Declare vArtexis  decimal(14,4);  


    Declare vCostoEx  decimal(16,6);  


    Declare vCostoEn  decimal(16,6);  


    Declare vReason   varchar(100);   -- Descripción del error


    Declare vCodigoDolar char(3);     





    Set vContinuar = 1;





    Set pFecha = Date(pFecha);


    


    Set vTCx = ConsultarTipoca(pMoneda,pFecha);





    Set vTCDolar = ConsultarTipoca(vCodigoDolar,pFecha);





    If vTCDolar is null then


        Set vTCDolar = ConsultarUltimoTCDolar();


    End if;





    If vTCx is null or vTCx = 0 or vTCDolar is null or vTCDolar = 0 then


        Set vContinuar = 0;


        Set vReason = '[BD] No se pudo realizar la conversión de monedas';


    End if;








    If ConsultarArticulo(pArtcode,1) is null then


        Set vContinuar = 0;


        Set vReason = Concat('[BD] Artículo ', pArtcode, ' no existe');


    End if;





    If vContinuar = 1 then


        Set vCostoML = pCostoU * vTCx;      -- Costo en moneda local


        Set vCostoD  = vCostoML / vTCDolar; -- Costo en dólares


        


        Set vArtexis  = (Select artexis from inarticu Where artcode = pArtcode);


        Set vCostoAnt = (Select artcosp from inarticu Where artcode = pArtcode);





        


        # Si no hay existencia se asumen los nuevos costos como los oficiales


        # no se promedia.


        If vArtexis <= 0 then


            Update inarticu


                Set artcost = vCostoML,   artcosd = vCostoD,


                artcosfob = pArtcosfob, artcosp = vCostoML


            Where artcode = pArtcode;


        else


            # Se promedia el costo.


            # El costo estándar asume el útimo costo más alto.


            # El costo FOB siempre asume el último costo.


            Set vCostoEx = vArtexis  * vCostoAnt;


            Set vCostoEn = pCantidad * vCostoML;


            Update inarticu


            Set artcost = Case When artcost < vCostoML then vCostoML Else artcost End,


                artcosd = Case When artcosd < vCostoD  then vCostoD  Else artcosd End,


                artcosfob = pArtcosfob,


                artcosp = (vCostoEx + vCostoEn) / (vArtexis + pCantidad)


            Where artcode = pArtcode;


        End if;





        Set vContinuar = ROW_COUNT();





        if vContinuar = 0 then


            Set vReason = '[BD]No se pudieron actualizar los costos';


        End if;





    End if;


  


    Select vContinuar, vReason;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AgregarFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AgregarFactura`(

	IN `pId` int

)
BEGIN

  

  INSERT INTO faencabe

    (facnume,  clicode,

    factipo,   chequeotar,

    vend,      terr,

    facfech,   facplazo,

    facdesc,   facmont, facimve,

    facfepa,   facpago,

    facsald,   facnpag,

    facmpag,   facdpago,

    facfppago, facestado,

    facnd,     user,

    referencia,precio,

    facfechac, ordenc,

    formulario,codigoTC,

    tipoca,    faccsfc,

    codExpress,facmonexp)

  Select

    facnume,  clicode,

    factipo,  IfNull(chequeotar,''),

    vend,     terr,

    facfech,  facplazo,

    facdesc,  facmont, facimve,

    facfepa,  facpago,

    facsald,  facnpag,

    facmpag,  facdpago,

    facfppago,facestado,

    facnd,    user,

    referencia,precio,

    facfechac, Case When ordenc is null then ' ' else ordenc end,

    formulario,codigoTC,

    tipoca,   faccsfc,

    codExpress,facmonexp

  From wrk_faencabe

  Where id = pid;





  INSERT INTO fadetall

	(facnume, artcode, bodega,

	faccant, artprec, facimve,

	facpive, facdesc, facmont,

	artcosp, facnd, facpdesc, 

	artcost, codigoTarifa, codigoCabys)

	Select

		facnume, artcode, bodega,

		faccant, artprec, facimve,

		facpive, facdesc, facmont,

		artcosp, facnd, facpdesc, 

		artcost, codigoTarifa, codigoCabys

	From wrk_fadetall

	Where id = pid;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AnularDocInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AnularDocInv`(


  IN  `pcMovodocu`  varchar(10),


  IN  `pcMovtimo`   char(1),


  IN  `pnMovtido`   smallint(3),


  IN  `pcModulo`    varchar(3)


)
BEGIN





    # Autor:    Bosco Garita A.


    # Objet:    Anular un documento de inventario


    # Modif:    Bosco Garita A. 07/05/2012


    #           Agrego revisión de la tabla de facturas de proveedor para quitar la referencia si existe.


    #           Tambi_n incluyo la revisi_n del campo movCerrado (no se permite anular un documento que


    #           se encuentra en un periodo cerrado.


    #           Bosco Garita A. 23/02/2013


    #           Agrego control para anulación de ajustes de inventario.





    Declare vError tinyInt(1);


    Declare vMensajeError varchar(300);


    Declare vMovtido SMALLINT(3);


    Declare vMovtimo CHAR(1);


	Declare vRegistros smallint; -- Bosco agregado 23/02/2013








    # Definir los tipos de movimiento cuando se anula un movimiento inter-bodega


    # o un cuando se anula un ajuste.


    Case 


        -- Movimiento Inter-bodega (5=Entrada, 10=Salida)


        When pnMovtido = 5 then


          Set vMovtido = 10;


          Set vMovtimo = 'S';





        When pnMovtido = 10 then


          Set vMovtido = 5;


          Set vMovtimo = 'E';





        -- Movimiento por ajuste (11=Entrada, 12=Salida)


        When pnMovtido = 11 then


          Set vMovtido = 12;


          Set vMovtimo = 'S';





        When pnMovtido = 12 then


          Set vMovtido = 11;


          Set vMovtimo = 'E';





        -- Si no se trata de un movimiento doble entonces vMovtido debe ser 0


        Else


          Set vMovtido = 0;


    End Case;





    Set vError = 0;


    Set vMensajeError = '';





    # Bosco modificado 10/05/2012.


    # Cambio la sintaxis para una mejor comprensi?n.


    #Set vError = If((Select modulo from intiposdoc where movtido = pnMovtido) = pcModulo,0,1);


    #set vMensajeError = If(vError = 1,Concat('[BD] (Inv) No puede anular este documento desde ',pcModulo),'');





    


    # Validar si se puede anular este documento desde el m?dulo que lo ejecuta.


    If not Exists(Select modulo from intiposdoc where movtido = pnMovtido) then


        Set vError = 1;


        Set vMensajeError = Concat('[BD] (Inv) No puede anular este documento desde ',pcModulo);


    End if;





    # Fin Bosco modificado 10/05/2012.








	# Bosco agregado 23/02/2013


	# Se usa para controlar el row_count cuando se trata de anular un ajuste.


	Set vRegistros = 0;





	# Fin Bosco agregado 23/02/2013


    If vError = 0 then


        Update inmovime Set


            estado = 'A', userAnula = user(), fechaAnula = now()


        Where movdocu = pcMovodocu


        and movtimo = pcMovtimo


        and movtido = pnMovtido


        and (estado is null or estado = '')


        and movCerrado = 'N'; -- Bosco agregado 07/05/2012.





		Set vRegistros = row_count();





        if vRegistros = 0 then


			/*


			Bosco 05/07/2015.


			Al incluir este Warning en el mensaje es para que algunos procesos


			sigan adelante aun cuando este proceso de error, como por ejemplo


			cuando se anula una factura.  Esto se permite porque puede suceder


			que la factura se anule justamente porque no aparece en inventarios.


			*/


            Set vError = 1;


			Set vMensajeError = 


				'[BD] (Inv) (Warning) Documento no existe, ya está anulado o se encuentra en un período cerrado';





			if pcMovtimo in (11,12) then


				Set vError = 0;


				Set vMensajeError = '';


			End if;


        End if;


    End if;








    # Si se trata de algún movimiento doble (Inter-bodega o ajuste) entonces correrá este if


    If vError = 0 and vMovtido > 0 then


        Update inmovime Set


            estado = 'A', userAnula = user(), fechaAnula = now()


        Where movdocu = pcMovodocu


        and movtimo = vMovtimo


        and movtido = vMovtido


        and (estado is null or estado = '')


        and movCerrado = 'N'; -- Bosco agregado 07/05/2012.





		Set vRegistros = vRegistros + row_count();





        if vRegistros = 0 then


            Set vError = 1;


            Set vMensajeError = 


				'[BD1] (Inv) (Warning) Documento no existe, ya está anulado o se encuentra en un período cerrado';


        End if;


    End if;








    If vError = 0 then


        Update bodexis,inmovimd Set


            artexis = artexis + If(inmovimd.movtimo = 'E', -inmovimd.movcant, inmovimd.movcant)


        Where inmovimd.movdocu = pcMovodocu


        and inmovimd.movtimo = pcMovtimo


        and inmovimd.movtido = pnMovtido


        and bodexis.artcode  = inmovimd.artcode


        and bodexis.bodega   = inmovimd.bodega;





		Set vRegistros = row_count();





        If vRegistros = 0 then


            Set vError = 1;


            Set vMensajeError = '[BD] (Inv) No se pudieron actualizar las existencias';


        End if;


    End if;








    # Si se trata de algún movimiento doble (Inter-bodega o ajuste) entonces correrá este if


    If vError = 0 and vMovtido > 0 then


        Update bodexis,inmovimd Set


            artexis = artexis + If(inmovimd.movtimo = 'E', -inmovimd.movcant, inmovimd.movcant)


        Where inmovimd.movdocu = pcMovodocu


        and inmovimd.movtimo = vMovtimo


        and inmovimd.movtido = vMovtido


        and bodexis.artcode  = inmovimd.artcode


        and bodexis.bodega   = inmovimd.bodega;





		Set vRegistros = vRegistros + row_count();





        If vRegistros = 0 then


            Set vError = 1;


            Set vMensajeError = '[BD1] (Inv) No se pudieron actualizar las existencias';


        End if;


    End if;





    


    # Bosco comenta 10/05/2012.


    # Aqu_ no se hace ning_n update sobre la tabla INARTICU debido a que existe un TRIGGER


    # en la tabla BODEXIS que se encarga de hacerlo.  Ya est_ comprobado que lo hace bien.








    # Bosco agregado 25/12/2011.


    # Si el documento anulado es una entrada entonces es preciso recalcular el costo promedio.


    If vError = 0 and pcMovtimo = 'E' then


        # Inicializar la variable para el contador de registros


        SET @Recno := 0;





        # Cargo los artículos del documento anulado para recalcular el costo promedio.


        Create temporary table tmp_anularDoc


            Select artcode, ( @Recno := ( @Recno + 1 ) ) as Recno 


            from inmovimd


            Inner join inmovime on inmovimd.movdocu = inmovime.movdocu 


                               and inmovimd.movtido = inmovime.movtido


                               and inmovimd.movtimo = inmovime.movtimo


            Where inmovimd.movdocu = pcMovodocu


            and inmovimd.movtimo = pcMovtimo


            and inmovimd.movtido = pnMovtido


            and inmovime.estado = 'A';


            


        # Inicializo las variables para el recorrido.


        SET @UltReg := @Recno;


        SET @Recno := 1;


        # Recorro la tabla temporal recalculando los costos.


        While @Recno <= @UltReg Do


            Call CalcularCostosInv((Select artcode from tmp_anularDoc Where Recno = @Recno));


            Set @Recno := @Recno + 1;


        End While;





		# Bosco agregado 26/03/2013


		-- Elimino la tabla temporal.


		Drop table tmp_anularDoc;


		# Fin Bosco agregado 26/03/2013


    End if;


    # Fin Bosco agregado 25/12/2011.








    # Bosco agregado 07/05/2012.


    # Si existe una referencia en la tabla de facturas de compra entonces la elimino.


    Update cxpfacturas Set refinv = '' Where refinv = pcMovodocu;


    # No hago la revisi_n de los registros afectados porque podr_a no haber ninguno.


    # Fin Bosco agregado 07/05/2012.


    Select vError as vError, vMensajeError as vMensajeError;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AplicarAjusteInventario;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AplicarAjusteInventario`(


  IN  `pBodega`   varchar(3),


  IN  `pMovdocu`  varchar(10),


  IN  `pMovfech`  datetime


)
BEGIN


    # Autor:    Bosco Garita A. 09/02/2011.


    # Objet:    Aplicar ajuste de inventarios.


    #           Este SP devuelve un Result Set con dos campos que indican si hubo error o no.


    # IMPORTANTE:   Este SP debe correr dentro de una transacción


    


    Declare vError tinyInt(1);          -- 1=Hubo error, 0=No hubo error


    Declare vMensajeErr varchar(200);   -- Mensaje de error o blanco si no hay error.


    Declare vHayEntradas tinyInt(1);    -- Determina si hay entradas por ajuste.


    Declare vHaySalidas  tinyInt(1);    -- Determina si hay salidas por ajuste.


    Declare vMovdesc varchar(150);      -- Descripción del movimiento.


    Declare vCodigoTC varchar(3);       -- Código de moneda local.


    


    


    Set vError       = 0;


    Set vMensajeErr  = '';


    Set vHayEntradas = 0;


    Set vHaySalidas  = 0;


    Set vMovdesc     = Concat('Ajuste de inventario al ',dtoc(pMovfech));


    Select CodigoTC from config into vCodigoTC;


    


    # Validaciones


    If pBodega is null or pBodega = '' then


        Set vError = 1;


        Set vMensajeErr = '[BD] El código de bodega es incorrecto.';


    End if;


    


    If vError = 0 and (pMovdocu is null or pMovdocu = '') then


        Set vError = 1;


        Set vMensajeErr = '[BD] El número de documento es incorrecto.';


    End if;


    


    #  Los valores del último parámetro se basan en la tabla INTIPOSDOC


    If vError = 0 and (ConsultarDocumento(pMovdocu,'E',11) or ConsultarDocumento(pMovdocu,'S',12)) then


        Set vError = 1;


        Set vMensajeErr = '[BD] El número de documento ya existe, use otro.';


    End if;


    


    If vError = 0 and not PermitirFecha(pMovfech) then


        Set vError = 1;


        Set vMensajeErr = '[BD] No puede aplicar ajustes a un período cerrado, use una fecha moyor.';


    End if;


    # Fin de validaciones


    


    # Comentario para el programador


    # Esta consulta sirve para ver cuál será el resultado del ajuste


    /*


        Select b.*, a.artexis,(b.cantidad - b.artexis) as Dif, (a.artexis + (b.cantidad - b.artexis)) as aj


        from bodexis A, conteo B


        Where a.bodega = b.bodega and a.artcode = b.artcode;


    


    */


    # Inicia proceso de aplicación del ajuste


    If vError = 0 then


        


        # Actualizar tabla de existencias por bodega


        Update bodexis A, conteo B Set a.artexis = a.artexis + (b.cantidad - b.artexis)


        Where a.bodega = b.bodega and a.artcode = b.artcode


        and b.bodega = pBodega;


        





        # Deben procesarse por separado las entradas por ajuste de las salidas por ajuste.


        If Exists(Select 1 from conteo Where bodega = pBodega and (cantidad - artexis) > 0 limit 1) then


            Set vHayEntradas = 1;


        End if;


        


        If Exists(Select 1 from conteo Where bodega = pBodega and (cantidad - artexis) < 0 limit 1) then


            Set vHaySalidas = 1;


        End if;


    End if;


    


        


    # Insertar el encabezado para las entradas (si las hay) -- movtido = 11


    If vError = 0 and vHayEntradas then


        CALL InsertarEncabezadoDocInv(


            pMovdocu, -- Documento


            'E'     , -- Tipo de movimiento (E o S)


            'Ajuste', -- Orden de compra


            vMovdesc, -- Descripción del movimiento


            pMovfech, -- Fecha del movimiento


            1       , -- Tipo de cambio


            11      , -- Tipo de documento


            ' '     , -- Persona que solicita (se usa en salidas)


            vCodigoTC); -- Código de moneda


            -- Select 'Terminó de con el encaezado';


        If row_count() = 0 then


            Set vError = 1;


            Set vMensajeErr = '[BD] No se pudo insertar el encabezado de entradas por ajuste.';


        End if;


    End if;


    


    


    #Insertar el detalle de las entradas (si las hay) -- movtido = 11


    If vError = 0 and vHayEntradas then


        Insert into Inmovimd (


            Movdocu,


            Movtimo,


            Artcode,


            Bodega ,


            Procode,


            Movcant,


            Movcoun,


            Artcosfob,


            Artprec,


            Facimve,


            Facdesc,


            Movtido,


            Centroc,


            Fechaven )


        Select


            pMovdocu,   -- Documento


            'E',        -- Tipo de movimiento


            a.artcode,  -- Artículo


            a.bodega,   -- Bodega


            '',         -- Proveedor


            (a.cantidad - a.artexis), -- Cantidad


            a.artcosp,  -- Costo.  Por lo general es el costo promedio pero también puede ser precio de venta n.


            b.artcosFOB, -- Costo FOB


            b.artpre1,  -- Precio de venta # 1


            0,          -- Impuesto de ventas


            0,          -- Descuento


            11,         -- Tipo de documento


            '',         -- Centro de costo


            null        -- Fecha de vencimiento


        From conteo A


        Inner join inarticu B on a.artcode = b.artcode


        Where a.bodega = pBodega and (a.cantidad - a.artexis) > 0;


        


        If row_count() = 0 then


            Set vError = 1;


            Set vMensajeErr = '[BD] No se pudo insertar el detalle de entradas por ajuste.';


        End if;


    End if;


        


    


    # Insertar el encabezado para las salidas (si las hay) -- movtido = 12


    If vError = 0 and vHaySalidas then


        CALL InsertarEncabezadoDocInv(


            pMovdocu, -- Documento


            'S'     , -- Tipo de movimiento (E o S)


            'Ajuste', -- Orden de compra


            vMovdesc, -- Descripción del movimiento


            pMovfech, -- Fecha del movimiento


            1       , -- Tipo de cambio


            12      , -- Tipo de documento


            ' '     , -- Persona que solicita (se usa en salidas)


            vCodigoTC); -- Código de moneda


            


        If row_count() = 0 then


            Set vError = 1;


            Set vMensajeErr = '[BD] No se pudo insertar el encabezado de salidas por ajuste.';


        End if;


    End if;


    


    


    #Insertar el detalle de las salidas (si las hay) -- movtido = 12


    If vError = 0 and vHaySalidas then


        Insert into Inmovimd (


            Movdocu,


            Movtimo,


            Artcode,


            Bodega ,


            Procode,


            Movcant,


            Movcoun,


            Artcosfob,


            Artprec,


            Facimve,


            Facdesc,


            Movtido,


            Centroc,


            Fechaven )


        Select


            pMovdocu,   -- Documento


            'S',        -- Tipo de movimiento


            a.artcode,  -- Artículo


            a.bodega,   -- Bodega


            '',         -- Proveedor


            Abs(a.cantidad - a.artexis), -- Cantidad


            a.artcosp,  -- Costo.  Por lo general es el costo promedio pero también puede ser precio de venta n.


            b.artcosFOB, -- Costo FOB


            b.artpre1,  -- Precio de venta # 1


            0,          -- Impuesto de ventas


            0,          -- Descuento


            12,         -- Tipo de documento


            '',         -- Centro de costo


            null        -- Fecha de vencimiento


        From conteo A


        Inner join inarticu B on a.artcode = b.artcode


        Where a.bodega = pBodega and (a.cantidad - a.artexis) < 0;


        


        If row_count() = 0 then


            Set vError = 1;


            Set vMensajeErr = '[BD] No se pudo insertar el detalle de salidas por ajuste.';


        End if;


    End if;


    


    


    # Actualizar los campos userAplica y movdocu


    If vError = 0 then


        Update conteo Set userAplica = user(), movdocu = pMovdocu


        where bodega = pBodega;


        


        If row_count() = 0 then


            Set vError = 1;


            Set vMensajeErr = '[BD] No se pudo actualizar la tabla de conteo físico.';


        End if;


    End if;


    


    


    # Trasladar los datos aplicados al histórico


    If vError = 0 then


        INSERT INTO `hconteo`


            (`bodega`,


            `artcode`,


            `cantidad`,


            `artexis`,


            `artcosp`,


            `fecha`,


            `userDigita`,


            `userAplica`,


            `movdocu`,


            `pordesc`)


        Select 


            `bodega`,


            `artcode`,


            `cantidad`,


            `artexis`,


            `artcosp`,


            `fecha`,


            `userDigita`,


            `userAplica`,


            `movdocu`,


            `pordesc`


        From Conteo


        Where bodega = pBodega;


        


        If row_count() = 0 then


            Set vError = 1;


            Set vMensajeErr = '[BD] No se pudo trasladar la tabla de conteo físico al histórico.';


        End if;


    End if;


    


    # Eliminar los registros trasladados


    Delete from conteo where bodega = pBodega;


    


    If row_count() = 0 then


        Set vError = 1;


        Set vMensajeErr = '[BD] No se pudieron eliminar los registros del conteo.';


    End if;


    


    Select vError as Error, vMensajeErr as MensajeErr;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS CambiarMascaraTelefonica;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `CambiarMascaraTelefonica`(


  IN `pcNuevaMascara` varchar(20)


)
BEGIN


  


  UPDATE inproved SET


    protel1 = MascaraTelefonica(protel1,pcNuevaMascara),


    protel2 = MascaraTelefonica(protel2,pcNuevaMascara),


    profax  = MascaraTelefonica(profax,pcNuevaMascara);





  


  UPDATE inclient SET


    clitel1 = MascaraTelefonica(clitel1,pcNuevaMascara),


    clitel2 = MascaraTelefonica(clitel2,pcNuevaMascara),


    clitel3 = MascaraTelefonica(clitel3,pcNuevaMascara),


    clicelu = MascaraTelefonica(clicelu,pcNuevaMascara),


    clifax  = MascaraTelefonica(clifax,pcNuevaMascara);


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AnularFacNCNDCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AnularFacNCNDCXC`(


  IN  `pnFacnume`  int,


  IN  `pnFacnd`    int


)
BEGIN


    





    Declare vError tinyInt(1);


    Declare vMensajeError varchar(200);


    Declare vClicode int;





    Set vError = 0;


    Set vMensajeError = '';





    


    


    Set vClicode =


          (Select clicode from faencabe


           Where facnume = pnFacnume and facnd = pnFacnd and facestado = '');





    If vClicode is null then


      Set vError = 1;


      Set vMensajeError =


        '[DB]El registro no existe en el periodo actual o ya está anulado';


    End if;





    


    


    If vError = 0 and pnFacnume > 0


                  and Exists(


                      Select pagosd.facnume


                      from pagosd


                      Inner join pagos on pagosd.recnume = pagos.recnume


                      Where pagosd.facnume = pnFacnume


                      and facnd = pnFacnd


                      and pagos.estado = '') then


      Set vError = 1;


      Set vMensajeError =


        '[DB]Hay recibos aplicados a esta Fact/ND.  Debe anularlos primero.';


    End if;





    If vError = 0 and pnFacnume > 0


                  and Exists(Select facnume from notasd


                      Where facnume = pnFacnume


                      and facnd = pnFacnd) Then


      Set vError = 1;


      Set vMensajeError =


        '[DB]Hay NCs aplicadas a esta Fact/ND.  Debe anularlas primero.';


    End if;


    





    


    


    If pnFacnume < 0 then


      


      Update faencabe,notasd


        Set faencabe.facsald = faencabe.facsald + IfNull(notasd.monto,0)


      Where faencabe.facnume = notasd.facnume


      and faencabe.facnd = notasd.facnd


      and notasd.notanume = pnFacnume;





      


      Update faencabe


        Set facsald = facsald - IfNull((Select sum(monto)


                                 from notasd


                                 Where notanume = faencabe.facnume),0)


      Where facnume = pnFacnume and facnd = Abs(pnFacnume);


      


      Delete from notasd Where notanume = pnFacnume;


    End if;





    


    








    


    Update faencabe Set


      facestado  = 'A',


      userAnula  = user(),


      fechaAnula = now()


    Where facnume = pnFacnume


    and facnd = pnFacnd;





    


    


    If Row_count() <> 1 then


      Set vError = 1;


      Set vMensajeError =


        '[DB]Hay una incongruencia en la tabla de encabezados de facturas.';


    End if;








    If vError = 0 then


      


      Call RecalcularSaldoClientes(vClicode);


    End if;





    


    


    If vError = 0 and pnFacnd >= 0 then


      Call AnularDocInv(


             Abs(pnFacnume),


             If(pnFacnd = 0, 'S','E'),


             If(pnFacnd = 0, 8, 4),


             'CXC');   


    End if;





    


    


    


    


    


    


    


    


    If vError = 1 or pnFacnd < 0 then


      Select vError as vError, vMensajeError as vMensajeError;


    End if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AnularPagoCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AnularPagoCXC`(


  IN `pnRecnume` int


)
BEGIN


    





    Declare vError tinyInt(1);


    Declare vMensajeError varchar(200);


    Declare vClicode int;





    Set vError = 0;


    Set vMensajeError = '';





    


    Update pagos


    Set estado = 'A', userAnula = user(), fechaAnula = now()


    Where recnume = pnRecnume and estado = '';





    If Row_count() = 0 then


      Set vError = 1;


      Set vMensajeError = '[DB] Recibo no se encuentra o ya estaba anulado.';


    End if;





    


    


    


    


    If vError = 0 then


      Update faencabe,pagosd


      Set faencabe.facsald = faencabe.facsald + pagosd.monto


      Where pagosd.recnume = pnRecnume


      and faencabe.facnume = pagosd.facnume


      and faencabe.facnd = pagosd.facnd;





      If Row_count() = 0 then


        Set vError = 1;


        Set vMensajeError = '[DB] Las facturas referidas por este recibo no pudieron ser encontradas.';


      End if;


    End if;





    If vError = 0 then


      


      Set vClicode =


          (Select clicode from pagos


           Where recnume = pnRecnume


           Limit 1);


      


      Call RecalcularSaldoClientes(vClicode);


    End if;





    Select vError as vError, vMensajeError as vMensajeError;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AnularPagoCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AnularPagoCXP`(


  IN `pnRecnume` int


)
BEGIN


    # Autor :    Bosco Garita Azofeifa 28/05/2012


    # Objet :    Anular un recibo de cuentas por pagar.


    # Result:    Devuelve un RS con dos campos vError y VmensajeError para indicar si hubo error o no.


    


    Declare vError tinyInt(1);


    Declare vMensajeError varchar(200);


    Declare vProcode varchar(15);





    Set vError = 0;


    Set vMensajeError = '';





    # Actualizar el estatus del recibo


    Update cxppage


    Set estado = 'A', userAnula = user(), fechaAnula = now()


    Where recnume = pnRecnume and estado = '';





    If Row_count() = 0 then


      Set vError = 1;


      Set vMensajeError = '[DB] Recibo no se encuentra o ya estaba anulado.';


    End if;





    


    # Revertir el proceso de aplicaci_n del recibo.


    # Las facturas y/o NC afectadas vuelven a su estado antes de ser afectadas por el recibo.


    If vError = 0 then 


      Update cxpfacturas,cxppagd


        Set cxpfacturas.saldo = cxpfacturas.saldo + cxppagd.monto, 


            cxpfacturas.abono_acum = cxpfacturas.abono_acum - cxppagd.monto


      Where cxppagd.recnume = pnRecnume


      and cxppagd.factura = cxpfacturas.Factura


      and cxppagd.tipo = cxpfacturas.tipo;


       


      # Verificar los registros afectados


      If Row_count() = 0 then


        Set vError = 1;


        Set vMensajeError = '[DB] Las facturas referidas por este recibo no pudieron ser encontradas.';


      End if;


    End if;





    If vError = 0 then


      # Si no hubo error actualizo el saldo del proveedor


      Set vProcode =


          (Select procode from cxppage Where recnume = pnRecnume Limit 1);


      


      Call RecalcularSaldoProveedores(vProcode);


    End if;





    Select vError as vError, vMensajeError as vMensajeError;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AplicarDescuentoAFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AplicarDescuentoAFactura`(


  IN  `pID`       int(10),


  IN  `pArtcode`  varchar(20),


  IN  `pBodega`   varchar(3),


  IN  `pFacpdes`  float


)
BEGIN





  Declare vFacimve decimal(12,2);  -- Impuesto de ventas


  Declare vFacdesc decimal(12,2);  -- Descuento


  Declare vFacmont decimal(12,2);  -- Monto


  Declare vRegAfec smallInt;       -- Número de registros afectados


  Declare vRedondear         bit;  -- Redondear


  Declare vRedondearA5       bit;  -- Redondear a 5


  Declare vCodigoTC      char(3);  -- Código de moneda





  Set vCodigoTC = (Select codigoTC from wrk_faencabe where id = pID);


  


  Set vRedondear =


         Case When vCodigoTC = (Select codigoTC from config) then (Select redondear from config) else 0 End;


  Set vRedondearA5 =


         Case When vCodigoTC = (Select codigoTC from config) then (Select redond5 from config) else 0 End;





  


  # Si el artículo viene nulo o con el valor null entonces se aplica el descuento para toda la factura


  If pArtcode is null or pArtcode = 'null' then


     Update wrk_fadetall Set


       facpdesc = pFacpdes,


       facdesc  = faccant * artprec * (pFacpdes/100)


     Where id = pID;


  Else


	# Caso contrario se aplica solo para una línea


     Update wrk_fadetall Set


       facpdesc = pFacpdes,


       facdesc  = faccant * artprec * (pFacpdes/100)


     Where id = pID and artcode = pArtcode and bodega = pBodega;


  End if;





  # Bosco modificado 02/03/2013


  -- Independientemente de si se afectan registros o no en el update anterior


  -- recalculo el impuesto.


  Set vRegAfec = row_count();





  -- if vRegAfec > 0 then


    Update wrk_fadetall Set facimve = (facmont - facdesc) * (facpive/100)


    Where id = pID;


  -- End if;





  # Si hay datos en la tabla entonces sumo cada rubro para calcular el encabezado


  # de la factura.


  if row_count() > 0 then


    


    Set vFacimve = (Select sum(facimve) from wrk_fadetall Where id = pID);


    Set vFacdesc = (Select sum(facdesc) from wrk_fadetall Where id = pID);


    Set vFacmont = (Select sum(facmont) from wrk_fadetall Where id = pID);





    


    Set vFacmont = RedondearA5(vFacmont - vFacdesc + vFacimve);


    # Redondear a 5 y 10


    If vRedondearA5 = 1 then


       Set vFacmont = RedondearA5(vFacmont);


    End if;





	# Actualizar el encabezado de la factura


    Update wrk_faencabe Set


      facimve = vFacimve,


      facdesc = vFacdesc,


      facmont = vFacmont,


      facmpag = facmont / facnpag


    Where id = pID;


  End if;





  


  Select vRegAfec;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS AplicarDescuentoAPedido;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `AplicarDescuentoAPedido`(


  IN  `pFacnume`  int(10),


  IN  `pArtcode`  varchar(20),


  IN  `pBodega`   varchar(3),


  IN  `pFacpdes`  float


)
BEGIN





  Declare vFacimve decimal(12,2);  


  Declare vFacdesc decimal(12,2);  


  Declare vFacmont decimal(12,2);  


  Declare vRegAfec smallInt;       








  If pArtcode is null or pArtcode = 'null' then


    Update pedidod Set


      facpdesc = pFacpdes,


      facdesc  = Round(Reservado * artprec * (pFacpdes/100),2)


    Where facnume = pFacnume;


  Else


    Update pedidod Set


      facpdesc = pFacpdes,


      facdesc  = Round(Reservado * artprec * (pFacpdes/100),2)


    Where facnume = pFacnume and artcode = pArtcode and bodega = pBodega;


  End if;





  Set vRegAfec = row_count();





  if vRegAfec > 0 then


    


    


    


    


    Update pedidod Set


      facimve = Round((facmont - facdesc) * (facpive/100),2)


    Where facnume = pFacnume;


  End if;





  if row_count() > 0 then


    


    Set vFacimve = (Select sum(facimve) from pedidod Where facnume = pFacnume);


    Set vFacdesc = (Select sum(facdesc) from pedidod Where facnume = pFacnume);


    Set vFacmont = (Select sum(facmont) from pedidod Where facnume = pFacnume);





    Update pedidoe Set


      facimve = vFacimve,


      facdesc = vFacdesc,


      facmont = vFacmont - vFacdesc + vFacimve


    Where facnume = pFacnume;


  End if;





  


  Select vRegAfec;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS CalcularCostosInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalcularCostosInv`(


  IN `pArtcode` varchar(20)


)
BEGIN


    # Autor:    Bosco Garita 24/12/2011


    # Objet:    Recalcular el costo promedio de los artículos de inventario.


    #           Este proceso lleva implícito el cálculo de las existencias por lo que también podría usarse con 


    #           ese fin.  Por otra parte, si se agrega el campo de fecha del movimiento, también podría usarse


    #           para calcular la fecha del último movimiento.


    #           El único problema, y por eso se diseño para trabajar con un artículo a la vez, es porque es lento


    #           y dependiendo de la cantidad de artículos que se procesen puede tardar mucho tiempo.


    #           Este SP fue diseñado para usarse desde la pantalla de anulación de documentos, entradas específicamente.


    





    Declare vMesCerrado smallInt; -- Último mes cerrado


    Declare vAnoCerrado int;      -- Último año cerrado


    Declare vUltimoCierre datetime;


    


    # Establecer el punto de partida


    Select IfNull(mescerrado,1),IfNull(anocerrado,1900) from config into vMesCerrado, vAnoCerrado;


    Set vUltimoCierre = UltimoDiaDelMes(vMesCerrado,vAnoCerrado);


    


    # Inicializar la variable para el contador de registros


    SET @i := 0;





    # NOTA: habrá que valorar en el futuro si esta tabla mejor se convierte en una tabla permamente y solamente se eliminan los datos


    #       cada vez que se ocupa.  En ese caso habría que cambiar Recno por un campo auto incremental y revisar el proceso para trabajar


    #       por mínimos y no por secuencia.


    # Crear la tabla temporal


    CREATE TEMPORARY TABLE tmp_costos


        SELECT 


            inmovime.movfechac,


            inmovimd.movcoun * inmovime.tipoca as Costo,


            inmovimd.movtimo,


            -- inmovimd.movtido,


            inmovimd.artcode,


            inmovimd.movcant,


            inmovimd.movcant * 0 AS Existencia,


            inmovimd.movcoun * 0 AS CostoProm,


            ( @i := ( @i +1 ) )  AS Recno


        FROM inmovimd, inmovime


        WHERE inmovimd.movdocu = inmovime.movdocu AND inmovimd.movtido = inmovime.movtido -- JOIN


        AND inmovimd.artcode = pArtcode


        AND inmovime.movfech > vUltimoCierre                    -- Solo movimientos del período actual


        AND (inmovime.estado = '' OR inmovime.estado IS NULL)   -- Solo documentos activos


        AND inmovimd.movcant > 0


        ORDER BY movfechac;





    # Crear el índice para el acceso


    Create index Recno_idx on tmp_costos (Recno);





    # Crear proceso (ciclo while) para calcular la existencia y el costo promedio.


    # Este nuevo costo se basa en las reglas de los movimientos de inventario para


    # determinar el momento de incrementar o decrementar el costo promedio.





    # Variables para el recorrido y cálculo


    Select min(recno), max(recno), min(Existencia), min(CostoProm) 


    from tmp_costos into @minRecno, @maxRecno, @ExistAcum, @CostoPromAnt;





    Set @vAnterior = 0;


    Set @ExistAcum = 0;


    Set @CostoPromAnt = 0;





    # Obtener el saldo y el costo al último cierre.


    SELECT artexis, artcosp FROM hinarticu


    WHERE artcode = (Select artcode from tmp_costos Where Recno = @minRecno) AND artperi = vUltimoCierre 


    INTO @vAnterior, @CostoPromAnt;


    


    Set @vAnterior    = IfNull(@vAnterior,0);


    Set @CostoPromAnt = IfNull(@CostoPromAnt,0);


    Set @ExistAcum    = IfNull(@ExistAcum,0);


    


        


    # La primera fila tendrá los valores iniciales.


    -- Update tmp_costos Set Existencia = movcant, CostoProm = Costo Where Recno = @minRecno;


    Update tmp_costos 


        Set Existencia = @vAnterior + If(movtimo = 'E',movcant,movcant *-1) 


    Where Recno = @minRecno;


    


    # Calcular el costo promedio.


    Update tmp_costos


        Set CostoProm = 


        If(Existencia > 0, If(movtimo = 'E', ((@CostoPromAnt * @vAnterior) + (Costo * movcant)) / Existencia, @CostoPromAnt), Costo)


    Where Recno = @minRecno;





    # Cargar las variables para calcular el costo del siguiente registro


    Select Existencia, CostoProm From tmp_costos Where Recno = @minRecno into @ExistAcum, @CostoPromAnt;


    Set @minRecno := @minRecno +1;





    WHILE @minRecno <= @maxRecno Do


        # Calcular la existencia.


        Update tmp_costos 


            Set Existencia = @ExistAcum + If(movtimo = 'E',movcant,movcant*-1) 


        Where Recno = @minRecno;





        # Calcular el costo promedio.


        Update tmp_costos


            Set CostoProm = 


            If(Existencia > 0, If(movtimo = 'E', ((@CostoPromAnt * @ExistAcum) + (Costo * movcant)) / Existencia, @CostoPromAnt), Costo)


        Where Recno = @minRecno;





        # Cargar las variables para calcular el costo del siguiente registro


        Select Existencia, CostoProm From tmp_costos Where Recno = @minRecno into @ExistAcum, @CostoPromAnt;


        Set @minRecno := @minRecno +1;


    END WHILE;





    -- Select * from tmp_costos;


    # Retorno solo el último registro que tiene los datos finales calculados.


    # Select * from tmp_costos Where Recno = @maxRecno;


    Update inarticu, tmp_costos


        Set inarticu.artcosp = tmp_costos.CostoProm


    Where tmp_costos.artcode = inarticu.artcode and tmp_costos.Recno = @maxRecno;





    -- Select * from tmp_costos;


    # Eliminar el índice y luego la tabla


    Alter table tmp_costos Drop index Recno_idx;


    Drop table tmp_costos;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConteoSelectivo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConteoSelectivo`(


  IN `pBodega` varchar(3)


)
BEGIN


    # Autor:    Bosco Garita 05/02/2011.


    # Objet:    Preparar un conteo selectivo. Respeta cantidades digitadas previamente.


    # Devuelve: Número de registros afectados.


    


    Update conteo Set


        InUseByUser = user(), 


        cantidad = If(cantidad = 0, artexis, cantidad)


    Where bodega = pBodega;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS CalcularCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalcularCXC`(

	IN `pFecha` datetime

)
BEGIN

    -- Autor: Bosco Garita Azofeifa



    Declare vMonto double;

    



    Drop temporary table If Exists tmp_faencabe;



    CREATE TEMPORARY TABLE tmp_faencabe

        SELECT

            `faencabe`.`facnume`,

            `faencabe`.`clicode`,

            `faencabe`.`facfech`,

            `faencabe`.`facplazo`,

            `faencabe`.`facimve`,

            `faencabe`.`facdesc`,

            `faencabe`.`facmont`,

            `faencabe`.`facpago`,

            `faencabe`.`facsald`,

            `faencabe`.`facestado`,

            `faencabe`.`facnd`,

            `faencabe`.`user`,

            `faencabe`.`facfechac`,

            `faencabe`.`codigoTC`,

            `faencabe`.`tipoca`,

            `faencabe`.`facCerrado`

        FROM faencabe

        WHERE facfech <= pFecha AND facplazo > 0 AND facestado = '';

        

    Update tmp_faencabe Set Facsald = Facmont, facpago = 0;



    Update tmp_faencabe 

    Set facpago = AplicadoAFactura_Hasta(facnume,facnd,pFecha), facsald = facmont - facpago

    Where facnume > 0;



    Update tmp_faencabe 

    Set facpago = AplicadoANotaC_Hasta(facnume,facnd,pFecha), facsald = facmont + facpago

    Where facnume < 0;



    Delete from tmp_faencabe Where abs(facsald) = 0;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS calcularNivelDeCuenta;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `calcularNivelDeCuenta`()
    COMMENT 'Calcular el campo nivelc en base al contenido de los campos de la cuenta'
BEGIN

	/*

	Creado por Bosco Garita, 26/12/2016

	Hasta ahora solo se usa manualmente para recalcular el valor del campo Nivelc end la tabla cocatalogo.

	*/

	

	UPDATE cocatalogo

	SET nivelC =

		If(sub_cta  = '000' AND sub_sub  = '000' AND colect  = '000', 1,

		If(sub_cta != '000' AND sub_sub  = '000' AND colect  = '000', 2,

		If(sub_cta != '000' AND sub_sub != '000' AND colect  = '000', 3,

		If(sub_cta != '000' AND sub_sub != '000' AND colect != '000', 4, 0))));

		

	UPDATE hcocatalogo

	SET nivelC =

		If(sub_cta  = '000' AND sub_sub  = '000' AND colect  = '000', 1,

		If(sub_cta != '000' AND sub_sub  = '000' AND colect  = '000', 2,

		If(sub_cta != '000' AND sub_sub != '000' AND colect  = '000', 3,

		If(sub_cta != '000' AND sub_sub != '000' AND colect != '000', 4, 0))));

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS CompradoPor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `CompradoPor`(

	IN `pClicode` integer,

	IN `pArtcode` varchar(20)

)
BEGIN

	Declare vComprado  TinyInt(1);

	Declare vMensajeEr varchar(1000);

	

	-- Traer los datos más recientes

	Create Temporary Table Datos as

		Select

			fadetall.facnume,

			faencabe.facfech,

			fadetall.Faccant,

			fadetall.Artprec,

			fadetall.Facpdesc,

			fadetall.Facpive,

			fadetall.codigoTarifa,

			faencabe.codigoTC,

			faencabe.tipoca

		From fadetall

		Inner join faencabe on faencabe.facnume = fadetall.facnume

		             and faencabe.facnd   = fadetall.facnd

		Where clicode = pClicode

		and artcode = pArtcode

		and fadetall.facnd = 0

		and facestado = ''

		Order by facfech Desc

		Limit 1;



	Set vComprado  = If(IfNull((Select count(facnume) from Datos),0) > 0, 1, 0);

	Set vMensajeEr = If(IfNull((Select count(facnume) from Datos),0) = 0, 'El artículo no fue comprado por este cliente','');

	

	If vComprado = 1 and (DATEDIFF(Now(),(Select facfech from Datos)) > (Select DiasDevol from config)) then

		Set vMensajeEr =

		    '[DB] Este artículo sobrepasa el tiempo establecido para aceptar devoluciones.';

	End if;



	If vComprado > 0 then

		Select

		   vComprado  as Comprado,

		   vMensajeEr as MensajeEr,

		   DATEDIFF(Now(),facfech) as Dias,

		   Datos.*

		From Datos;

	Else

		Select

		   vComprado  as Comprado,

		   vMensajeEr as MensajeEr;

	End if;

		

	Drop table Datos;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EjecutarCierreMensual;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EjecutarCierreMensual`(

	IN `pMes` tinyint(2),

	IN `pAno` SMALLINT(4),

	OUT `pError` TINYINT(1),

	OUT `pMensajeErr` VARCHAR(1000),

	IN `pEtapa` INT

)
BEGIN

	/*

    	Autor:    Bosco Garita 23/02/2011.

    	Descrip:  Ejecutar el cierre mensual.

    	       Este proceso copia los maestros de:

	    	  - ARTÍCULOS (hinarticu)

		  - EXISTENCIAS (hbodexis)

		  - CLIENTES (hinclient) 

    	       - PROVEEDORES (hinproved)

	    	  - IMPUESTOS (HTARIFA_IVA)

		  a las tablas históricas.  De esa forma se conservan los saldos y los estados

    	       de las tablas más importantes.

    	       Además de copiar los registros de las tablas maestras también establece el mes cerrado para

    	       que no se puedan registrar más movimientos en ese período.

    	Devuelve: Dos variables; una que indica si hubo error (pError) y la otra con el mensaje del error (pMensajeErr)

    	NOTA:     1. Este SP debe correr dentro de una transacción.

    	          2. Antes de correr el proceso debe asegurarse de que los saldos están calculados al período que se va a cerrar.

	Bosco modificado 31/10/2013. Cambio el campo procueco por mayor, sub_cta, sub_sub y colect

	en las tabla históricas de clientes y proveedores.

	Bosco modificado 01/07/2015. Quito el campo divisita de las tablas de proveedores.

	Bosco modificado 10/07/2015. Agrego el control por etapas.

	Bosco modificado 17/07/2018. Agrego el traslado del campo idcliente en las tablas inclient - hinclient

	Bosco modificado 26/06/2019. Agrego el traslado de varios campos nuevos desde inproved hacia hinproved

	Bosco modificaro 25/06/2020. Agrego la tabla de histórico de impuestos y el control de etapas del cierre.

    */

    

    	

	

    	Declare vMesCerrado tinyInt;

    	Declare vAnoCerrado int;

    	Declare vPrimerDiaCerrado datetime;

    	Declare vPrimerDiaaCerrar datetime;

    	Declare vUltimoDiaMes datetime;

	Declare vRegistrosAf int; -- Bosco agregado 24/02/2013

	DECLARE vEtapaConfirmada SMALLINT;

	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION

	BEGIN

		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;

		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);

	    	ROLLBACK;

		SET pError = 1;

		SET pMensajeErr = 

		    		CONCAT('[BD] Ocurrió un error en la etapa ', pEtapa, ' del cierre. La etapa fue revertida. ' , @full_error);

	END;

	

	-- Determino cuál fue la última etapa confirmada para este cierre

	SELECT etapaconfirmada FROM etapascierre WHERE mes = pMes AND ano = pAno INTO vEtapaConfirmada;

	

	

	-- Si la etapa no existe...

	if vEtapaConfirmada IS NULL then

		SET vEtapaConfirmada = 0;

	END if;

	    

    	-- Establezco el valor default para el control de errores

    	Set pError = 0;

    	Set pMensajeErr = '';

    	

	-- Las etapas van de uno a donce por ahora 10/07/2015

	If pEtapa is null or pEtapa not between 1 and 15 then

		Set pError = 1;

   		Set pMensajeErr = '[BD] El número de etapas debe ir entre 1-15. Proceso cancelado.';

	End if;

	

	

    	# Validar el mes y el año de cierre

    	# El mes debe estar entre 1-12.  El período de cierre no puede ser inferior al que ya está registrado

    	# en la tabla config.

    	If not pError and (pMes is null or pMes not between 1 and 12) then

		Set pError = 1;

		Set pMensajeErr = '[BD] El mes a cerrar debe ser entre 1-12. Proceso cancelado.';

    	End if;

    	

    	# Se toma el mes y año del último período cerrado y se concatenan para formar una fecha, el último día.

    	# Luego se hace lo mismo con el mes y año que se intenta cerrar y se realizan las siguientes validaciones:

    	# 1) La fecha de cierre no puede ser inferior a la del último cierre.

    	# 2) Entre el período cerrado y el que se va a cerrar no puede haber más de 360 días.

    	If not pError then

    	

    		Select IfNull(mescerrado,1), IfNull(anocerrado,1900) from config into vMesCerrado, vAnoCerrado;

		

		

		If vAnoCerrado = 1900 then

			Select vAnoCerrado = min(year(movfech)) from inmovime;

		End if;

         

        	Set vPrimerDiaCerrado = Concat(Cast(vAnoCerrado as char(4)),'-',Cast(vMesCerrado as char(2)),'-01 00:00:00');

        	Set vPrimerDiaaCerrar = Concat(Cast(pAno        as char(4)),'-',Cast(pMes        as char(2)),'-01 00:00:00');

        

        	If not pError and vPrimerDiaaCerrar <= vPrimerDiaCerrado then

            	Set pError = 1;

            	Set pMensajeErr = '[BD] El mes a cerrar ya está cerrado. Proceso cancelado.';

        	End if;

        

        	If not pError && DateDiff(vPrimerDiaaCerrar,vPrimerDiaCerrado) > 360 and vAnoCerrado <> 1900 then

	     	Set pError = 1;

	          Set pMensajeErr = '[BD] No se permite períodos de más de 360 días. Proceso cancelado.';

        	End if;

    	End if;

	

	Set vRegistrosAf = 0; -- Bosco agregado 24/02/2013



	# Verifico que todas las facturas hayan pasado a inventarios.

	If not pError then

		Call FacturacionVsInventario (vRegistrosAf);

		Set pError = If(vRegistrosAf > 0, 1, 0);

		

		If pError then

			Set pMensajeErr = '[BD] Hay registros de facturación que no están en inventarios. Proceso cancelado.';

		End if;

	End if;

    

	# ------------------ PRIMERA ETAPA ------------------

	-- Bosco agregado 24/02/2013.Bosco agregado 24/02/2013.

	# Verifico que todas las facturas tengan su respectivo detalle.

	If not pError and pEtapa = 1 and vEtapaConfirmada = 0 then

		

		Call EncabezadoFacturasVsDetalle (vRegistrosAf);

		Set pError = If(vRegistrosAf > 0, 1, 0);

		If pError then

			Set pMensajeErr = '[BD] Hay facturas sin detalle. Proceso cancelado.';

		End if;

		

		If NOT pError then

			START TRANSACTION;

			INSERT INTO etapascierre (mes, ano, etapaconfirmada, usuario)

			VALUES(pMes, pAno, vEtapaConfirmada + 1, USER());

			COMMIT;

		END if;

		

	End if;

    



	# ------------------ SEGUNDA ETAPA ------------------

	# Verifico que todos los documentos de inventario tengan su respectivo detalle.

	If not pError and pEtapa = 2 and vEtapaConfirmada = 1 then

	

		Call EncabezadoInvVsDetalle (vRegistrosAf);

		Set pError = If(vRegistrosAf > 0, 1, 0);

		If pError then

			Set pMensajeErr = '[BD] Hay documentos de inventario sin detalle. Proceso cancelado.';

		End if;

		

		If NOT pError then

			START TRANSACTION;

			UPDATE etapascierre

				SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

			WHERE mes = pMes AND ano = pAno;

			COMMIT;

		END if;

		

	End if;

	-- Fin Bosco agregado 24/02/2013.





	# Fecha para el cierre (incluye hora :23:59:59)

	Set vUltimoDiaMes = UltimoDiaDelMes(pMes, pAno);





    	# Incia proceso revisión de datos

    	If not pError then

    	

		# ------------------ TERCERA ETAPA ------------------

		If pEtapa = 3 and vEtapaConfirmada = 2 then

		

			START TRANSACTION;

			Call EliminarInconsistencias();

				UPDATE etapascierre

				SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

			WHERE mes = pMes AND ano = pAno;

			COMMIT;

			

		End if;

        

		

		# ------------------ CUARTA ETAPA ------------------

		If pEtapa = 4 and vEtapaConfirmada = 3 then

		

			START TRANSACTION;

			# Por ahora el reservado será actual, no es a la fecha de cierre necesariamente.

			Call RecalcularReservado(null);

				UPDATE etapascierre

				SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

			WHERE mes = pMes AND ano = pAno;

			COMMIT;

			

		End if;

        

	

		# ------------------ QUINTA ETAPA ------------------

		If pEtapa = 5 and vEtapaConfirmada = 4 then

		

			START TRANSACTION;

			# Establecer el saldo de los registros de CXC (fact, nc, nd) a la fecha de cierre.

			# Este proceso genera una tabla temporal (tmp_faencabe) con el estado (saldo) de las fact, NC y ND

			# a la fecha que se le indique.  En este caso la fecha de cierre.

			Call CalcularCXC(vUltimoDiaMes);

				UPDATE etapascierre

				SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

			WHERE mes = pMes AND ano = pAno;

			COMMIT;

			

        	End if;

	

	

		# ------------------ SEXTA ETAPA ------------------

		If pEtapa = 6 and vEtapaConfirmada = 5 then

		

			START TRANSACTION;

			# Establecer el saldo de los clientes a la fecha de cierre. Este proceso usa la tabla creada por el 

			# SP CalcularCXC() para establecer el saldo de los clientes a la fecha que se le pida.

			Call RecalcularSaldoClientes_Cierre();

				UPDATE etapascierre

				SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

			WHERE mes = pMes AND ano = pAno;

			COMMIT;

			

		End if;

        



		# ------------------ SEPTIMA ETAPA ------------------

		If pEtapa = 7 and vEtapaConfirmada = 6 then

		

			START TRANSACTION;

			# Recalcular las existencias a la fecha de cierre. El segundo parámetro indica que es cierre.

			Call RecalcularExistencias(vUltimoDiaMes,1);

			

			# Elimino la tabla temporal

			Drop temporary table If Exists tmp_faencabe;

				UPDATE etapascierre

				SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

			WHERE mes = pMes AND ano = pAno;

			COMMIT;

			

		End if;

    	End if;

    	# Fin de revisión de datos

    	

	

	

    	# ==========================================================================================================

	# ------------------ OCTAVA ETAPA ------------------

    	# Inicia proceso de copiado a las tablas históricas

    	

    	If not pError AND pEtapa = 8 and vEtapaConfirmada = 7 then

        

        START TRANSACTION;

        

        # Guardo las existencias y el estado de los artículos de inventario

        INSERT INTO `hinarticu`(

            `artcode`, `artdesc`, `barcode`,

            `artfam`,  `artcosd`, `artcost`,

            `artcosp`, `artcosa`, `artcosfob`,

            `artpre1`, `artgan1`, `artpre2`,

            `artgan2`, `artpre3`, `artgan3`,

            `artpre4`, `artgan4`, `artpre5`,

            `artgan5`, `procode`, `artmaxi`,

            `artmini`, `artiseg`, `artdurp`,

            `artfech`, `artfeuc`, `artfeus`,

            `artexis`, `artreserv`,

            `transito`,`otroc`,   `altarot`,

            `vinternet`,`artObse`,

            `artFoto`,`artperi`,`codigoTarifa`)

        SELECT

            artcode,   artdesc,   barcode,   

            artfam,    artcosd,   artcost,

            artcosp,   artcosa,   artcosfob,

            artpre1,   artgan1,   artpre2,

            artgan2,   artpre3,   artgan3,

            artpre4,   artgan4,   artpre5,

            artgan5,   procode,   artmaxi,

            artmini,   artiseg,   artdurp,

            artfech,   artfeuc,   artfeus,

            artexis,   artreserv,

            transito,  otroc,     altarot,

            vinternet, artObse,

            artFoto,   vUltimoDiaMes, codigoTarifa

        FROM inarticu;

        

        # Guardo las existencias por bodega

        INSERT INTO `hbodexis`(

            `bodega`,

            `artcode`,

            `artexis`,

            `artreserv`,

            `minimo`,

            `artperi`)

        Select 

            bodega,

            artcode,

            artexis,

            artreserv,

            minimo,

            vUltimoDiaMes

        From bodexis;



        # Guardo los clientes, sus saldos y demás características

        INSERT INTO `hinclient`(

          	`clicode`,   `clidesc`,    `clidir`,

			`clitel1`,   `clitel2`,    `clitel3`,

			`clifax`,    `cliapar`,    `clinaci`,

			`clisald`,   `cliprec`,    `clilimit`,

			`terr`,      `vend`,       `clasif`,

			`cliplaz`,   `exento`,     `clifeuc`,

			`encomienda`,`direncom`,   `facconiv`,

			`clinpag`,   `clicelu`,    `cliemail`,

			`clireor`,   `igsitcred`,  `credcerrado`,

			`diatramite`,`horatramite`,`diapago`,

			`horapago`,  `clicueba`,   `cligenerico`,

			`cliperi`,   `mayor`,  	`sub_cta`,

			`sub_sub`, `colect`, 	`idcliente`,

			`idtipo`)

        Select 

			clicode,    clidesc,    clidir,

			clitel1,    clitel2,    clitel3,

			clifax,     cliapar,    clinaci,

			clisald,    cliprec,    clilimit,

			terr,       vend,       clasif,

			cliplaz,    exento,     clifeuc,

			encomienda, direncom,   facconiv,

			clinpag,    clicelu,    cliemail,

			clireor,    igsitcred,  credcerrado,

			diatramite, horatramite,diapago,

			horapago,   clicueba,   cligenerico,

			vUltimoDiaMes,mayor, 	sub_cta,    

			sub_sub, 	colect,		idcliente,

			idtipo

        From inclient;



        # Guardo los datos de los proveedores

        INSERT INTO `hinproved`(

			`procode`,

			`prodesc`,

			`prodir` ,

			`protel1`,

			`protel2`,

			`profax` ,

			`proapar`,

			`pronac` ,

			`profeuc`,

			`promouc`,

			`prosald`,

			`proplaz`,

			`procueba`,

			`mayor`  , 	   

			`sub_cta`,

			`sub_sub`, 	 

			`colect` ,

			`email`  ,

			`idProv` ,

			`idTipo` ,

			`provincia`,

			`canton`  ,

			`distrito`,

			`properi`

			)

        Select

			procode,

			prodesc,

			prodir ,

			protel1,

			protel2,

			profax ,

			proapar,

			pronac ,

			profeuc,

			promouc,

			prosald,

			proplaz,

			procueba,

			mayor  , 	   

			sub_cta,

			sub_sub, 	 

			colect ,

			email  ,

			idProv ,

			idTipo ,

			provincia,

			canton ,

			distrito,

			vUltimoDiaMes

        From inproved;

        

        -- Histórico de tarifas según el Ministerio de Hacienda

        INSERT INTO htarifa_iva (codigoTarifa, descrip, porcentaje, periodo)

        		SELECT codigoTarifa, descrip, porcentaje, vUltimoDiaMes

        		FROM tarifa_iva;

        	

	   UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = NOW()

	   WHERE mes = pMes AND ano = pAno;

	   COMMIT;

        	

    End if; -- If not pError AND  pEtapa = 8

    

    # ==========================================================================================================

    # Finaliza proceso de copiado a las tablas históricas

    

    

    # Inicia proceso de marcar los registros como cerrados y cálculo de saldos

    If not pError then



		# ------------------ NOVENA ETAPA ------------------

		If pEtapa = 9 and vEtapaConfirmada = 8 then

		

			START TRANSACTION;

			

			# Marcar las facturas, NC y ND con saldo cero como cerradas.

			# Estos registros tienen el saldo actual, no el de la fecha de cierre necesariamente.

			# Habrá que considerar si es necesario tomar el valor de tmp_faencabe y de esa forma 

			# afectar faencabe con los valores de cierre.

			Update faencabe

			Set facCerrado = 'S'

			Where facsald = 0 and facCerrado = 'N' and facfech <= vUltimoDiaMes ;

			

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

			

		End if;



		# ------------------ DÉCIMA ETAPA ------------------

		If pEtapa = 10 and vEtapaConfirmada = 9 then

		

			START TRANSACTION;

			

			# Podría contar aquí los registros que no sean de ND para luego compararlos contra los que 

			# se actualizan en INMOVIME pero parece no ser necesario porque hay un proceso previo que

			# verifica la integridad de los documentos de CXC contra inventarios se llama FacturacionVsInventario()

			# Select count(facnume) from faencabe where facCerrado = 'S' and facnd >= 0;

			

			# Marcar todos los registros de CXC en inventarios como cerrados

			Update inmovime

			Inner join intiposdoc on intiposdoc.Movtido = inmovime.Movtido

				Set movCerrado = 'S'

			Where movCerrado = 'N' 

			and movfech <= vUltimoDiaMes and intiposdoc.Modulo = 'CXC'

			# Verificar que las facturas existan en faencabe.  Las ND no forman parte de los movimientos de inv.

			and Exists(Select facnume from faencabe

					   Where cast(facnume AS char(10)) = inmovime.movdocu

					   and facnd = 0 -- Facturas

					   and facCerrado = 'S'

					   and facfech <= vUltimoDiaMes);



			Update inmovime

			Inner join intiposdoc on intiposdoc.Movtido = inmovime.Movtido

				Set movCerrado = 'S'

			Where movCerrado = 'N' 

			and movfech <= vUltimoDiaMes and intiposdoc.Modulo = 'CXC'

			# Verificar que las NC existan en faencabe.  Las ND no forman parte de los movimientos de inv.

			and Exists(Select facnume from faencabe

					   Where facnume < 0

					   and facnd > 0 -- Notas de crédito

					   and facCerrado = 'S' 

					   and Cast(Abs(facnume) as char(10)) = inmovime.movdocu

					   and facfech <= vUltimoDiaMes);

					   

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

		     

		End if;



		# ------------------ ONCEAVA ETAPA ------------------

		If pEtapa = 11 and vEtapaConfirmada = 10 then

		

			START TRANSACTION;

			

			# Marcar todos los movimientos de inventarios como cerrados.

			Update inmovime

			Inner join intiposdoc on intiposdoc.Movtido = inmovime.Movtido

				Set movCerrado = 'S'

			Where movCerrado = 'N'

			and intiposdoc.Modulo = 'INV'

			and movfech <= vUltimoDiaMes;

			

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

			

		End if;



		# ------------------ DOCEAVA ETAPA ------------------

		If pEtapa = 12 and vEtapaConfirmada = 11 then

		

			START TRANSACTION;

			

			# Marcar los recibos de CXC como cerrados

			Update pagos

			Set cerrado = 'S' 

			Where cerrado = 'N' and fecha <= vUltimoDiaMes;

			

			-- Bosco agregado 14/03/2013

			# Marcar los recibos de CXC como cerrados

			Update cxppage

			Set cerrado = 'S' 

			Where cerrado = 'N' and fecha <= vUltimoDiaMes;



			# Marcar las facturas, NC y ND con saldo cero como cerradas.

			# Estos registros tienen el saldo actual.

			Update cxpfacturas

			Set Cerrado = 'S'

			Where Cerrado = 'N' and fecha_fac <= vUltimoDiaMes and saldo = 0;

			-- Fin Bosco agregado 14/03/2013

			

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

			

		End if; -- if pEtapa = 12





		# ------------------ TRECEAVA ETAPA ------------------

        	IF pEtapa = 13 and vEtapaConfirmada = 12 then

        	

        		START TRANSACTION;

			# Recalcular el saldo de las facturas. Este proceso no es indispensable pero preferible.

			Call RecalcularSaldoFacturas();

			

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

			

		End if;





        	# ------------------ CATORCEAVA ETAPA ------------------

		IF pEtapa = 14 and vEtapaConfirmada = 13 then

		

			START TRANSACTION;

			# Recalcular el saldo de todos los clientes.  Este proceso SI es indispensable.

			Call RecalcularSaldoClientes(null); -- El saldo de los clientes depende del saldo de las facturas

			

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

			

		End if;





		# ------------------ QUINCEAVA ETAPA ------------------

		IF pEtapa = 15 and vEtapaConfirmada = 14 then

		

			START TRANSACTION;

			# Recalcular las existencias a hoy.

			Call RecalcularExistencias(now(),1);

			# Establecer la fecha de cierre en bodegas

			Update bodegas Set cerrada = vUltimoDiaMes Where cerrada is null or cerrada < vUltimoDiaMes;

			

			# Establecer el período cerrado en la tabla config.  También se guarda la fecha y hora actual.

			Update config Set mescerrado = pMes, anocerrado = pAno, cierre = now();

			

			UPDATE etapascierre

			SET etapaconfirmada = vEtapaConfirmada + 1, usuario = USER(), fecha = SYSDATE()

		     WHERE mes = pMes AND ano = pAno;

		     COMMIT;

			

		End if;

    End if;  -- If not pError

    

    -- Si hubo error se revierte la etapa

    If pError then

    		ROLLBACK;

    END if;

    

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarArticulo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarArticulo`(


  IN `pArtcode` varchar(20)


)
BEGIN


	# Autor: Bosco Garita 25/12/2013


	


	-- Si hay este artículo está asignado a alguna bodega


	-- pero no tiene existencia se eliminará.


	Delete from bodexis  Where artcode = pArtcode and artexis = 0;


	Delete from artprov  Where artcode = pArtcode;


	Delete from conteo   Where artcode = pArtcode;


	Delete from inarticu Where artcode = pArtcode;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarArtprov;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarArtprov`(


  IN  `pArtcode`  varchar(20),


  IN  `pProcode`  varchar(15)


)
BEGIN


  


  Delete from Artprov Where artcode = pArtcode and procode = pProcode;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarBodega;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarBodega`(


  IN `pBodega` char(3)


)
BEGIN


  Delete from bodegas Where bodega = pBodega;


  


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarBodexis;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarBodexis`(


  IN  `pBodega`   char(3),


  IN  `pArtcode`  varchar(20)


)
BEGIN


  Declare vArtexis decimal(10,0);


  Declare vArtreserv decimal(10,0);





  Select vArtexis = artexis, vArtreserv = artreserv


  from bodexis


  where bodega = pBodega and artcode = pArtcode;





  If vArtexis = 0 and vArtreserv = 0 then


    Delete from bodexis Where bodega = pBodega and artcode = pArtcode;


  else


    Select 'Artículo con existencia o cantidad reservada';


  end if;


   


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS CambiarConsecutivo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `CambiarConsecutivo`(


	in numero int, 		-- Nuevo consecutivo


	in tipo tinyInt)
BEGIN


	# Autor:    Bosco Garita A. 03/03/2013.


    # Objet:    Cambiar los consecutivos de facturas, ND, NC, recibos, etc.


    # Modif:    Bosco Garita A. 13/06/2014, Consecutivo de órdenes de compra.


    # Modif:    Bosco Garita A. 19/04/2015, Consecutivo de recibos de caja.


	


	Declare HayError tinyInt;


	Declare ErrorMessage varchar(200);





	Declare vFacnd int;


	Declare vDescripTipo varchar(25);





	Set HayError = 0;


	Set ErrorMessage = '';


	Set numero = ABS(numero) + 1;


	/*


	Hago una revisión para determinar si el número existe. El número que se debe


	establecer es el último número utilizado, por esa razón se suma uno para


	verificar si ya existe.  Después de la verificación se vuelve a restar uno


	para dejar el número original.


	*/


	Case 


		When tipo In(1,2,4,5) then -- Facturas, formularios, ND, NC


		


			Case 


				When tipo = 2 then


				Set vFacnd = 0;


				Set vDescripTipo = 'formularios';


				


				When tipo = 4 then


					Set vFacnd = numero;


					Set numero = numero *-1;


					Set vDescripTipo = 'notas de crédito';


				When tipo = 5 then


					Set vFacnd = numero *-1;


					Set vDescripTipo = 'notas de débito';


				Else


					Set vFacnd = 0;


					Set vDescripTipo = 'facturas';


			End Case;


		


			If Exists(	Select facnume 


						from faencabe 


						Where if(tipo = 2, formulario = numero, facnume = numero) 


						and facnd = vFacnd) then


				Set HayError = 1;


				Set ErrorMessage = 


					Concat('[BD CambiarConsecutivo] El consecutivo de ', vDescripTipo, ' ya existe.');


			End If;





		When tipo = 3 then -- Recibos CXC


			Set vDescripTipo = 'recibos de CXC';


			If Exists(	Select recnume 


						from pagos 


						Where recnume = numero) then


				Set HayError = 1;


				Set ErrorMessage = 


					Concat('[BD CambiarConsecutivo] El consecutivo de ', vDescripTipo, ' ya existe.');


			End If;





		When tipo = 6 then -- Recibos CXP


			Set vDescripTipo = 'recibos de CXP';


			If Exists(	Select recnume 


						from cxppage 


						Where recnume = numero) then


				Set HayError = 1;


				Set ErrorMessage = 


					Concat('[BD CambiarConsecutivo] El consecutivo de ', vDescripTipo, ' ya existe.');


			End If;





		When tipo = 7 then -- Proformas -- Aún no ha sido implementado 16/02/2013


			Set vDescripTipo = 'proformas';


			Set HayError = 0;


			Set ErrorMessage = '';





		When tipo = 8 then -- Documentos de inventario


			Set vDescripTipo = 'documentos de inventario';


			If Exists(	Select movdocu from inmovime


						Where movdocu = numero + ''


						and exists(	Select movtido 


									from intiposdoc 


									Where movtido = inmovime.movtido 


									and modulo = 'INV')) then


				Set HayError = 1;


				Set ErrorMessage = 


					Concat('[BD CambiarConsecutivo] El consecutivo de ', vDescripTipo, ' ya existe.');


			End If;





		-- Bosco agregado 13/06/2014


		When tipo = 9 then -- Órdenes de compra


			Set vDescripTipo = 'órdenes de compra';


			If Exists(	Select movorco 


						from comOrdenCompraE 


						Where movorco = numero + '') then


				Set HayError = 1;


				Set ErrorMessage = 


					Concat('[BD CambiarConsecutivo] El consecutivo de ', vDescripTipo, ' ya existe.');


			End If;


		-- Fin Bosco agregado 13/06/2014





		-- Bosco agregado 19/04/2015


		When tipo = 10 then -- Recibos ded caja


			Set vDescripTipo = 'recibos ded caja';


			If Exists(	Select recnume from catransa


						Union


						Select recnume from hcatransa


						Where recnume = numero + '') then


				Set HayError = 1;


				Set ErrorMessage = 


					Concat('[BD CambiarConsecutivo] El consecutivo de ', vDescripTipo, ' ya existe.');


			End If;


		-- Fin Bosco agregado 13/06/2014





		Else 


			Set HayError = 1;


			Set ErrorMessage = '[BD CambiarConsecutivo] tipo no adecuado';


	End Case;





	/*


		Si no hubo error entonces vuelvo adejar el número como venía


		originalmente  e inicio el proceso decambiar el consecutivo


		que corresponda.


	*/


	If HayError = 0 then


		Set numero = ABS(numero) - 1;


		Case 


			When tipo = 1 then -- Facturas


				Update config set facnume = numero;





			When tipo = 2 then -- Formularios


				Update config set formulario = numero;


	


			When tipo = 3 then -- Recibos CXC


				Update config set recnume = numero;





			When tipo = 4 then -- NC


				Update config set ncred = numero;





			When tipo = 5 then -- ND


				Update config set ndeb = numero;





			When tipo = 6 then -- Recibos CXP


				Update config set recnume1 = numero;


			


			When tipo = 7 then -- Proformas


				Update config set pronume = numero;





			When tipo = 8 then -- Documentos de inventario


				Update config set docinv = numero;





			When tipo = 9 then -- Ordenes de compra


				Update config set ultOrdenC = numero;





			When tipo = 10 then -- Recibos de caja


				Update config set recnumeca = numero;


		End Case;


	End if;





	Select HayError as HayError, ErrorMessage as ErrorMessage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarCliente`(


  IN `pClicode` int(10)


)
BEGIN


  


  Delete from inclient Where clicode = pClicode;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarFamilia;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarFamilia`(


  IN `pArtfam` char(4)


)
BEGIN


  Delete from infamily Where artfam = pArtfam;


  


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarInconsistencias;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarInconsistencias`()
BEGIN


  


  


  Declare vDiasFactTemp smallInt;





  Set vDiasFactTemp = (Select diasFactTemp from config);





  


  Delete from wrk_faencabe


  Where datediff(now(),facfechac) > vDiasFactTemp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarMoneda;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarMoneda`(


  IN `pCodigo` char(3)


)
BEGIN


  Delete from monedas Where codigo = pCodigo;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarProveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarProveedor`(


  IN `pProcode` varchar(15)


)
BEGIN


  


  Delete from inproved Where procode = pProcode;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarTipoca;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarTipoca`(


  IN  `pCodigo`  char(3),


  IN  `pFecha`   datetime


)
BEGIN


  


  Delete from Tipocambio Where codigo = pCodigo and fecha = pFecha;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS CambiarDatosFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `CambiarDatosFactura`(


  IN  `pFacnumeAnterior`  int,


  IN  `pFacnumeNuevo`     int,


  IN  `pFacfechNuevo`     datetime,


  IN  `pVendNuevo`        int,


  IN  `pClicodeNuevo`     int


)
BEGIN


    # Autor     : Bosco Garita 18/04/2011


    # Objetivo  : Modificar agunos datos de inventario


    # Observ.   : Este SP controla las foráneas


    # Devuelve  : Un ResultSet con dos campos; vHayError SmallInt(1) y vErrorMessage varchar(1000)


    # Modificado: Bosco Garita 19/04/2011.


    #             Ya no desactivo la revisión de llaves foráneas.  Controlo la transacción.


	#			  La integridad referencia se encargar de actualizar en cascada todas


	#			  las tablas relacionadas.


    


    


    Declare vHayError SmallInt(1);


    Declare vErrorMessage varchar(1000);


    Declare vTabla varchar(20);


	Declare vClicode int;


    


    


    DECLARE EXIT HANDLER FOR SQLEXCEPTION


    BEGIN


        RollBack;


        #SET FOREIGN_KEY_CHECKS=1;        


        Set vHayError = 1;


        Set vErrorMessage = 


            Concat('[BD] No se pudo modificar la factura ',


            Trim(Cast(pFacnumeAnterior as char(10))), ' tabla ', vTabla);


        Select vHayError,vErrorMessage;


    END;


    


    Set vHayError = 0;


    Set vErrorMessage = '';


    


    # Deshabilito la integridad referencial para evitar errores


    -- SET FOREIGN_KEY_CHECKS=0;


    


    START TRANSACTION;


    Set vTabla = "FAENCABE";


    


	# Bosco agregado 30/10/2014.


	# Cargo el código del cliente para recalcular al final.


	Select clicode from faencabe  


	Where facnume = pFacnumeAnterior and facnd = 0 into vClicode;





    Update faencabe 


		Set facfech = pFacfechNuevo, vend = pVendNuevo, clicode = pClicodeNuevo, 


		facnume = pFacnumeNuevo


    Where facnume = pFacnumeAnterior and facnd = 0;





	# Bosco agregado 30/10/2014


	# Si hay cambio de cliente debo recalcular ambos.


	If vClicode != pClicodeNuevo then


		Call RecalcularSaldoClientes(vClicode);


		Call RecalcularSaldoClientes(pClicodeNuevo);


    End if;


    --     Set vTabla = "FADETALL";


    --     Update fadetall 


    --     Set facnume = pFacnumeNuevo


    --     Where facnume = pFacnumeAnterior and facnd = 0;


    --     


    --     Set vTabla = "PAGOSD";


    --     Update pagosd 


    --     Set facnume = pFacnumeNuevo


    --     Where facnume = pFacnumeAnterior and facnd = 0;


    --     


    --     Set vTabla = "NOTASD";


    --     Update notasd 


    --     Set facnume = pFacnumeNuevo


    --     Where facnume = pFacnumeAnterior and facnd = 0;


    


    Set vTabla = "INMOVIME";


    Update inmovime 


		Set movdocu = Cast(pFacnumeNuevo as char(10)), movfech = pFacfechNuevo


    Where movdocu = Cast(pFacnumeAnterior as char(10)) 


	and movtimo = 'S' and movtido = 8;


    


    --     Set vTabla = "INMOVIMD";


    --     Update inmovimd 


    --     Set movdocu = Cast(pFacnumeNuevo as char(10))


    --     Where movdocu = Cast(pFacnumeAnterior as char(10)) and movtimo = 'S' and movtido = 8;


    


    # Habilito de nuevo las llaves foráneas


    -- SET FOREIGN_KEY_CHECKS=1;


    


    COMMIT;


    


    # Devolver el resultado


    Select vHayError,vErrorMessage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarUsuario;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarUsuario`(


  IN `pUser` char(16)


)
BEGIN


  


  Delete from usuario Where user = pUser;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarBodexis;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarBodexis`(


  IN  `pBodega`   char(3),


  IN  `pArtcode`  varchar(20)


)
BEGIN


    Insert into bodexis (bodega, artcode)


    values(pBodega, pArtcode);


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDetalleOrdenCompra;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDetalleOrdenCompra`(


  IN  `pMovorco`    varchar(10), 


  IN  `pArtcode`    varchar(20),


  IN  `pBodega`     varchar(3),


  IN  `pMovcant`    decimal(12,4),


  IN  `pArtcost`    decimal(16,6),


  IN  `pArtcosfob`  decimal(14,4)


)
BEGIN


	# Autor: Bosco Garita Azofeifa 01/06/2014





	-- Ver la configuración


	Insert into comOrdenCompraD (


		Movorco,


		Artcode,


		Bodega ,


		Movcant,


		Artcost,


		Artcosfob )


	Values (


		pMovorco,


		pArtcode,


		pBodega ,


		pMovcant,


		pArtcost,


		pArtcosfob );


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarDatosCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarDatosCliente`(

	IN `pClicode` int(10)

)
BEGIN



    /*



    Autor: Bosco Garita



    Consultar los datos más relevantes de un cliente para efectos de



    validación.



	*/



    Declare vMontoVencido  decimal(12,2); 

    Declare vMontoUltComp  decimal(12,2); 

    Declare vContadoMes    decimal(12,2); 

    Declare vFacsald       decimal(12,2);

    Declare vSaldoOtrasCXC decimal(12,2);



    Set vMontoVencido = ConsultarMontoVencidoCXC(pClicode,0);



    Set vMontoUltComp = IfNull((

        Select facmont * tipoca

        From faencabe

        Where clicode = pClicode and facnume > 0 and facnd = 0 and facestado <> 'A'

        Order by facfech desc

        Limit 1),0);



    Select sum(facsald * tipoca) from faencabe 

    Where clicode = pClicode 

    and facnume > 0

    and facestado <> 'A' and facsald > 0

    into vFacsald;



    Set vFacsald = IfNull(vFacsald,0);



	-- Calcular el monto en otras cuentas por cobrar

	Select 

		sum(o.montocxc - o.montorecibido) as saldoOtros

	from cxcotros o

	Inner join faencabe f on o.facnume = f.facnume and f.facnd = 0

	Inner join inclient i on f.clicode = i.clicode

	Where f.clicode = pClicode

	into vSaldoOtrasCXC;



	Set vSaldoOtrasCXC = IfNull(vSaldoOtrasCXC,0);



    Select

        clidesc,  

        clifeuc,  

        clitel1,  

        clicelu,  

        clilimit, 

        cliprec,  

        clisald,  

        exento,   

        vend,     

        terr,     

        cliplaz,  

        clireor,  

        clinpag,  

        vMontoVencido as Vencido,  

        vMontoUltComp as MontoUC,  

        IgSitCred,   

        CredCerrado, 

        IfNull(DateDiff(now(),clifeuc),0) as DiasUC, 

	   cligenerico, 

        -- (Select count(clicode) from pedidoe where facnume = inclient.clicode) as pedidos,

        (SELECT count(artcode) from pedidod where facnume = inclient.clicode AND faccant > 0) as pedidos,

        vFacsald as facsald,

	   vSaldoOtrasCXC as saldoOtros

    from inclient

    Where clicode = pClicode;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarFamilia;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarFamilia`(


  IN  `pArtfam`   char(4),


  IN  `pFamilia`  varchar(25)


)
BEGIN


  


  If (ConsultarFamilia(pArtfam) is null) then


    Insert into infamily (artfam, familia)


    values(pArtfam, pFamilia);


  else


    Select '[BD] El registro ya existe';


  end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarMoneda;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarMoneda`(


  IN  `pCodigo`   varchar(3),


  IN  `pDescrip`  varchar(25),


  IN  `pSimbolo`  char(1),


  IN  `pCodigoH`  varchar(3)


)
BEGIN


	-- Autor: Bosco Garita Azofeifa


	If (ConsultarMoneda(pCodigo) is null) then


		Insert into monedas (Codigo, Descrip, Simbolo, codigoHacienda)


		values(pCodigo, pDescrip, pSimbolo, pCodigoH);


	end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarTarifa;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarTarifa`(


  IN  `pCodExpress`  smallint,


  IN  `pTarifa`      decimal(12,2),


  IN  `pMinimo`      decimal(12,2),


  IN  `pPorcentaje`  float


)
BEGIN


  


  If not Exists(Select CodExpress from faexpress Where CodExpress = pCodExpress) then


    Insert into faexpress (CodExpress, Tarifa, Minimo, Porcentaje)


    values(pCodExpress, pTarifa, pMinimo, pPorcentaje);


  else


    Select '[BD] El registro ya existe';


  end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarTerritorio;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarTerritorio`(


  IN  `pTerr`     tinyint(3),


  IN  `pDescrip`  varchar(50)


)
BEGIN


  


  If (ConsultarTerritorio(pTerr) is null) then


    Insert into Territor (terr, descrip)


    values(pTerr, pDescrip);


  else


    Select '[BD] El registro ya existe';


  end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarTipoca;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarTipoca`(


  IN  `pCodigo`  varchar(3),


  IN  `pFecha`   datetime,


  IN  `pTipoca`  float


)
BEGIN


	-- Autor: Bosco Garita Azofeifa


	Declare vnConsecutivo int;


  


	If (ConsultarTipoca(pCodigo, pFecha) is null) then


		Set vnConsecutivo = (Select max(nConsecutivo) from tipocambio) + 1; 


		Set vnConsecutivo = IfNull(vnConsecutivo,1);


		Insert into tipocambio (codigo, fecha, tipoca, nConsecutivo)


		values(pCodigo, pFecha, pTipoca, vnConsecutivo);


	end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarDatosProveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarDatosProveedor`(


  IN `pcProcode` varchar(15)


)
BEGIN


    # Autor     : Bosco Garita 23/04/2012


    # Descrip.  : Obtener los datos más relevantes de un proveedor.


  


    Declare vMontoVencido  decimal(12,2); 


    Declare vMontoUltComp  decimal(12,2); 


    Declare vContadoMes    decimal(12,2); 


    Declare vSaldo         decimal(12,2);   -- Saldo de facturas y NC





    # Calcular el saldo de las facturas y NC (no necesariamente es igual al saldo del proveedor).


    Select sum(saldo * tipoca)


    from cxpfacturas


    Where procode = pcProcode


    and saldo > 0


    INTO vSaldo;


    


    Set vSaldo = IfNull(vSaldo,0);


    


    # Calcular el saldo vencido.


    Select sum(saldo * tipoca)


    from cxpfacturas


    Where procode = pcProcode


    and saldo > 0 and fecha_pag < date(now())


    INTO vMontoVencido;


    


    Set vMontoVencido = IfNull(vMontoVencido,0);


    


    Set vMontoUltComp = IfNull((


        Select total_fac * tipoca


        From cxpfacturas


        Where procode = pcProcode and tipo = 'FAC' 


        Order by fecha_fac desc


        Limit 1),0);





    Select


        prodesc,  


        profeuc,  


        protel1,  


        prosald,  


        proplaz,  


        vMontoVencido as Vencido,  


        vMontoUltComp as MontoUC,


        vSaldo as SaldoF,


        IfNull(DateDiff(now(),profeuc),0) as DiasUC


    from inproved


    Where procode = pcProcode;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarDetalleFacturaNDNCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarDetalleFacturaNDNCXC`(


  IN  `pFacnume`  int,


  IN  `pTipo`     tinyint


)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    


    


    


    If pTipo is null or pTipo not between 1 and 3 then


        Set pTipo = 1;


    End if;


    


    Select 


        a.artcode,


        c.artdesc,


        a.bodega,


        a.faccant,


        a.artprec * b.tipoca as artprec,


        a.facmont * b.tipoca as facmont


    From fadetall a


    Inner join faencabe b on a.facnume = b.facnume and a.facnd = b.facnd


    Inner join inarticu c on a.artcode = c.artcode


    Where a.facnume = pFacnume and If(pTipo = 1, a.facnd <= 0, a.facnd > 0);


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarDocumentosCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarDocumentosCliente`(


  IN `pClicode` int(10)


)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    Select


        facnume,


        dtoc(facfech) as fecha,


        facplazo,


        facmont * tipoca as MontoML,            


        facsald,


        codigoTC,


        Trim(descrip) as Moneda,


        tipoca,


        If(facnd = 0, 'FC',If(facnd > 0,'NC','ND')) as TipoDoc,


        facfech,       


        facsald * tipoca as SaldoML             


    from faencabe


    Inner Join monedas on faencabe.codigoTC = monedas.codigo


    where clicode = pClicode


    and facestado = '' 


    Order by facfech,facnume;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarDocumentosProveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarDocumentosProveedor`(


  IN  `pProcode`   varchar(15)


)
BEGIN


    # Autor: Bosco Garita 20/04/2014


    # Consultar todas FAC, NC y ND (no nulas) de un proveedor.


    


    Select


        factura,


        dtoc(fecha_fac) as fecha,


        vence_en,


        total_fac * tipoca as MontoML, -- Monto moneda local


        saldo,


        codigoTC,


        Trim(descrip) as Moneda,


        tipoca,


        tipo as TipoDoc,


        fecha_fac,       


        saldo * tipoca as SaldoML    -- Saldo moneda local


    from cxpfacturas


    Inner Join monedas on cxpfacturas.codigoTC = monedas.codigo


    where procode = pProcode


    Order by fecha_fac,factura;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarExistencias;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarExistencias`(


  IN  `pArtcode`  varchar(20),


  IN  `pBodega`   varchar(3)


)
BEGIN


	# Bosco modificado 20/12/2015.  Dejo de usar las consultas individuales


	# y cargo todo en un solo select agregando la localización.





	Declare vArtexis    Decimal(14,4);


	Declare vDisponible Decimal(14,4);


	Declare vLocaliz    Varchar(7);


	





	#Set vArtexis    = ConsultarExistencia(pArtcode,pBodega);


	#Set vDisponible = ConsultarExistenciaDisponible(pArtcode,pBodega);


	Select 


		artexis,


		artexis - artreserv,


		localiz


	From bodexis 


	Where artcode = pArtcode and bodega = pBodega


	Into vArtexis, vDisponible, vLocaliz;


  


	Select vArtexis as artexis, vDisponible as disponible, vLocaliz as localizacion;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarVendedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarVendedor`(


  IN  `pVend`    tinyint(3),


  IN  `pNombre`  varchar(50)


)
BEGIN


  


  If (ConsultarVendedor(pVend) is null) then


    Insert into Vendedor (vend, nombre)


    values(pVend, pNombre);


  else


    Select '[BD] El registro ya existe';


  end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ObservacionesPedidos;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObservacionesPedidos`(


  IN  `pClicode`    int,


  IN  `pObserva`    varchar(5000),


  IN  `pModificar`  tinyint(1)


)
BEGIN


    # Autor:    Bosco Garita 01/05/2011


    # Objetivo: Modificar el campo de observaciones de pedidos de venta


    # Devuelve: Un RS con las observaciones del pedido


    


    If pModificar then


        Update pedidoe Set observa = pObserva Where clicode = pClicode;


    End if;


    


    Select observa from pedidoe Where clicode = pClicode;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarFactNDNC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarFactNDNC`(


  IN  `pFacnume`  int,


  IN  `pTipoDoc`  tinyint


)
BEGIN


    # Autor:    Bosco Garita 13/01/2011


    # Objetivo: Generar un listado con los datos más relevantes de una factura, ND o NC


	# Modifiado:Bosco Garita 02/03/2015


	#			Agrego el texto de la factura (left join)


	#			Agrego el medio de pago (18/07/2015)


    


    # Declaro la variable que tendrá el valor que defina si es factura, NC o ND


    Declare vFacnd int;


    


    # Valido el tipo de documento, asumo un valor default en caso de error (factura).


    # pTipoDoc: 1=Factura, 2=ND, 3=NC


    Set pTipoDoc = If(pTipoDoc is null or pTipoDoc not between 1 and 3, 1, pTipoDoc);


    


    # Establezco los valores del Where


    Case When pTipoDoc = 1 then -- factura


        Set pFacnume = Abs(pFacnume);


        Set vFacnd = 0;


        


        When pTipoDoc = 2 then -- ND


        Set pFacnume = Abs(pFacnume);


        Set vFacnd = Abs(pFacnume)*-1;


        


        When pTipoDoc = 3 then -- NC


        Set pFacnume = Abs(pFacnume)*-1;


        Set vFacnd = Abs(pFacnume);


    End Case;


    


    Select 


        a.artcode,


        a.bodega,


        b.artdesc,


        a.faccant,


        a.artprec,


        a.facmont,


        dtoc(c.facfech) as facfech,


        c.facplazo,


        IF(pTipoDoc < 3,IF(c.facplazo > 0, Concat('Crédito ',  Cast(c.facplazo as character), ' días'), 'Contado'), '') as tipo,


        IF(c.facestado = 'A', 'A N U L A D A','') as facestado,


        c.user,


        c.clicode,


        d.clidesc,


        c.facimve,


        c.facdesc,


        c.facmont as Total,


        c.facmonexp,


        c.facsald,


        e.simbolo,


        e.descrip as moneda,


        c.vend,


        f.nombre as vendedor,


		g.factext as texto,


		case c.factipo


			When 0 then 'Desconocido'


			When 1 then 'Efectivo'


			When 2 then 'Cheque'


			When 3 then 'Tarjeta'


			When 4 then 'Transferencia'


		End as medioPago


    from fadetall a


    Inner join inarticu b on a.artcode = b.artcode


    Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd


    Inner join inclient d on c.clicode = d.clicode


    Inner join monedas  e on c.codigoTC= e.codigo


    Inner join vendedor f on c.vend    = f.vend


	Left  join fatext   g on a.facnume = g.facnume and a.facnd = g.facnd


    Where a.facnume = pFacnume and a.facnd = vFacnd;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarFacturasCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarFacturasCliente`(


  IN  `pClicode`   int(10),


  IN  `pConSaldo`  tinyint(1)


)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    Select


        facnume,


        dtoc(facfech) as fecha,


        facplazo,


        facmont * tipoca as MontoML,            


        facsald,


        codigoTC,


        Trim(descrip) as Moneda,


        tipoca,


        If(facnd = 0, 'FC','ND') as TipoDoc,    


        facfech,       


        facsald * tipoca as SaldoML             


    from faencabe


    Inner Join monedas on faencabe.codigoTC = monedas.codigo


    where clicode = pClicode


    and facnd <= 0     


    and If(pConSaldo, facsald > 0, facsald = facsald)


    and facestado = '' 


    Order by facfech,facnume;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarFacturasCliente2;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarFacturasCliente2`(


  IN  `pClicode`   int(10)


)
BEGIN


    -- Autor: Bosco Garita Azofeifa, 16/12/2018


    -- Traer todas las facturas de contado que ya fueron enviadas a Hacienda





    Select


        facnume,


        dtoc(facfech) as fecha,


        facplazo,


        facmont * tipoca as MontoML,            


        facsald,


        codigoTC,


        Trim(descrip) as Moneda,


        tipoca,


        'FC' as TipoDoc,    


        facfech,       


        facsald * tipoca as SaldoML             


    from faencabe


    Inner Join monedas on faencabe.codigoTC = monedas.codigo


    where clicode = pClicode


    and facnd = 0     


    and facsald = 0


	and facplazo = 0


    and facestado = '' 


	and claveHacienda > ''


    Order by facfech,facnume;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarFacturasProveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarFacturasProveedor`(


  IN  `pProcode`   varchar(15),


  IN  `pConSaldo`  tinyint(1)


)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    


    


    Select


        factura,


        dtoc(fecha_fac) as fecha,


        vence_en,


        total_fac * tipoca as MontoML, 


        saldo,


        codigoTC,


        Trim(descrip) as Moneda,


        tipoca,


        tipo as TipoDoc,


        fecha_fac,       


        saldo * tipoca as SaldoML    


    from cxpfacturas


    Inner Join monedas on cxpfacturas.codigoTC = monedas.codigo


    where procode = pProcode


    and tipo in('FAC','NCR')    


    and If(pConSaldo, saldo > 0, saldo = saldo)


    Order by fecha_fac,factura;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_DirEncom;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_DirEncom`(


  IN `pOrden` tinyint(1)


)
BEGIN


  


  





  Declare vEmpresa varchar(60);





  Set vEmpresa = (Select empresa from config);





  


  


  If pOrden is null or pOrden not between 0 and 1 then


    Set pOrden = 0;


  End if;





  


  Case When pOrden = 0 Then


       Select clidesc,clicode,direncom,vEmpresa as Empresa


       from inclient Where encomienda = 1 order by clidesc;





       When pOrden = 1 Then


       Select clidesc,clicode,direncom,vEmpresa as Empresa


       from inclient Where encomienda = 1 order by clicode;


  End Case;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_EstadoCtaCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_EstadoCtaCXP`(


  IN  `pProcode`  varchar(15),


  IN  `pMeses`    smallint,


  IN  `pFCancel`  bit,


  IN  `pOrden`    tinyint


)
BEGIN





    Declare vEmpresa varchar(60);


    Declare vDesde date;


    Declare vNconsecutivo  int; 


    Declare vFacturas smallInt; 


    Declare vRecibos  smallInt; 


    Declare vRecnume  int;      


    Declare vFecha    datetime; 


    Declare vMonto    double;   


    Declare vRecond   char(1);  


    Declare vTotalCom double;  -- Total compras


    Declare vTotalSal double;  -- Suma del saldo en este reporte


    Declare vProsald  double;  -- Saldo del proveedor


    Declare vProdesc  varchar(50); 


    Declare vMoneda   varchar(25);  








    If pFCancel is null or pFCancel not between 0 and 1 then


        Set pFCancel = 1;


    end if;





    -- Establecer los meses


    If pMeses is null or pMeses not between 0 and 36  then


        Set pMeses = 0;


    End if;








    If pOrden is null or pOrden not between 0 and 3  then


        Set pOrden = 3;


    End if;





    # Recalculo el saldo del proveedor para garantizar la integridad de los datos.


    Call RecalcularSaldoProveedores(pProcode);





    # Cargo el saldo y el nombre del proveedor en variables


    Select


        prosald,


        prodesc


    from inproved Where procode = pProcode 


    into vProsald, vProdesc;





    # Cargo la empresa y la moneda en variables


    Select empresa,descrip from config


    Inner Join monedas on config.codigoTC = monedas.codigo


    into vEmpresa,vMoneda;





    # Calculo la fecha inicial del reporte basado en los meses que el usuario eligi_


    Set vDesde = date(now()) - interval pMeses month;





    # Creo una tabla temporal que tendr_ todos los datos del estados de cuenta.


    CREATE TEMPORARY TABLE EstadoCTA


        (factura   varchar(10) not null default '0',


        tipo       char(1),      -- Factura o nota de cr_bito


        fecha_fac  datetime,


        vence_en   smallint,


        CredCont   char(2),      


        fecha_pag  datetime,     


        vencida    char(1),      


        total_fac  double,


        saldo      double,      -- Saldo de la factura o nota de cr_dito


        recnume    int not null default 0,


        recond     char(1),     -- Recibo o nota de d_dito


        fecha      datetime,


        monto      double,


        nConsecutivo int AUTO_INCREMENT primary key);








    # Cargo las facturas y notas de cr_bito


    Insert into EstadoCTA (


        factura,


        fecha_fac,


        vence_en,


        CredCont,


        total_fac,


        saldo,


        tipo,


        fecha_pag,


        vencida)


        Select


            factura,


            fecha_fac,


            vence_en,


            If(vence_en = 0,'CO','CR'),


            total_fac*tipoca,


            saldo*tipoca,


            Substring(tipo,1,1),


            fecha_pag,


            If(saldo > 0 and date(fecha_pag) < date(now()),'*','')


        From cxpfacturas


        Where procode = pProcode


        and (fecha_fac >= vDesde or saldo > 0)


        and tipo in ('FAC','NCR');





    # Totalizo los montos por pagar y las compras


    Select sum(saldo), sum(total_fac) From EstadoCTA into vTotalSal, vTotalCom;








    # Si el usuario no quiere facturas canceladas entonces las elimino de la tabla temporal


    If pFCancel = 0 then


        Delete from EstadoCTA Where tipo = 'F' and saldo <= 0;


    End if;





    # Cuento los registros para saber m_s adelante si se necesitan m_s registros en esta tabla


    Select count(factura) from EstadoCTA into vFacturas;


    Set vFacturas = IfNull(vFacturas,0);





    # Creo la estructura temporal de los pagos y las notas de cr_dito


    CREATE TEMPORARY TABLE tmpPagos


        (recnume  varchar(10),


        fecha     datetime,


        monto     double,


        recond    char(1),      -- Recibo o nota de cr_dito


        procesado char(1) not null default 'N');





    # Cargo los recibos y las notas de d_dito


    Insert into tmpPagos (recnume,fecha,monto,recond)


        Select Concat(recnume,''),fecha,monto*tipoca,'R'


        From cxppage


        Where procode = pProcode and fecha >= vDesde and estado = ''


        Union all


        Select factura,fecha_fac,abs(total_fac*tipoca),'N'


        From cxpfacturas


        Where procode = pProcode and fecha_fac >= vDesde


        and tipo = 'NDB';





    # Cuento los registros de pagos y ND para comparar contra facturas y NC


    Select count(recnume) from tmpPagos into vRecibos;


    


    Set vRecibos = IfNull(vRecibos,0);








    # Agrego los registros que sean necesarios para colocar tanto facturas y NC como recibos y ND.


    While vFacturas < vRecibos Do


        Insert into EstadoCTA (recnume) values('0');


        Set vFacturas = vFacturas + 1;


    End While;





    # Proceso los recibos


    While vRecibos > 0 Do


        


        Select


            recnume,


            fecha,


            monto,


            recond


        from tmpPagos


        Where procesado = 'N' limit 1


        into vRecnume,vFecha,vMonto,vRecond;





        # Encuentro el n_mero de registro que se usar_ para el recibo en cuesti_n


        Select nConsecutivo from EstadoCTA


        Where recnume = '0' limit 1 into vNconsecutivo;





        # Ya el registro est_ en variables, ahora lo guardo en la estructura temporal principal


        Update EstadoCTA


        Set recnume = vRecnume, fecha = vFecha, monto = vMonto, recond = vRecond


        Where nConsecutivo = vNconsecutivo;





        # Marco el registro como procesado


        Update tmpPagos


        Set procesado = 'S'


        Where recnume = vRecnume and procesado = 'N';





        # Control de registros procesados


        Set vRecibos = vRecibos - 1;





    End While;








    # Genero un ResultSet ordenado de la forma que el usuario lo solicit_


    Case pOrden


        When 0 then


            Select


                vEmpresa  as Empresa,


                vTotalSal as SaldoRep,


                vTotalCom as Ventas,


                vDesde    as Desde,


                vProsald  as SaldoProv,


                vProdesc  as prodesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by fecha;





        When 1 then


            Select


                vEmpresa  as Empresa,


                vTotalSal as SaldoRep,


                vTotalCom as Ventas,


                vDesde    as Desde,


                vProsald  as SaldoProv,


                vProdesc  as prodesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by fecha_fac;





        When 2 then


            Select


                vEmpresa  as Empresa,


                vTotalSal as SaldoRep,


                vTotalCom as Ventas,


                vDesde    as Desde,


                vProsald  as SaldoProv,


                vProdesc  as prodesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by recnume;





        When 3 then


            Select


                vEmpresa  as Empresa,


                vTotalSal as SaldoRep,


                vTotalCom as Ventas,


                vDesde    as Desde,


                vProsald  as SaldoProv,


                vProdesc  as prodesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by factura;


    End Case;





    Drop table EstadoCTA;


    Drop table tmpPagos;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ReservarFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ReservarFactura`(

	IN `pID` int(10),

	IN `pBodega` varchar(3),

	IN `pArtcode` varchar(20),

	IN `pReservado` decimal(12,4),

	IN `pArtprec` decimal(12,2),

	IN `pFacpive` float,

	IN `pFacfech` datetime,

	IN `pFacplazo` tinyint(3),

	IN `pVend` tinyint(3),

	IN `pTerr` tinyint(3),

	IN `pFactipo` tinyint(2),

	IN `pChequeoTar` varchar(45),

	IN `pFacnpag` smallint,

	IN `pPrecio` tinyint(2),

	IN `pCodigoTC` char(3),

	IN `pTipoca` float,

	IN `pAfectarRes` char(20)

)
BEGIN

	-- Autor: Bosco Garita Azofeifa

	-- Este sp suma o resta (según sea el valor recibido) a Faccant y a reservado en

	-- la tabla wrk_fadetall (detalle de la factura) y realiza la suma o resta en el

	-- campo artreserv de la tabla bodexis.  Esta tabla a su vez dispara un trigger

	-- que actualiza el campo artreserv en la tabla principal INARTICU.



	-- El precio unitario debe venir libre de impuesto y descuento porque así se

	-- debe guardar en la tabla fadetall.





	Declare vReservadoAnterior decimal(12,4);  

	Declare vReservadoActual   decimal(12,4);  

	Declare vDisponible        decimal(12,4);  

	Declare vArtcosp           decimal(14,4);  -- Costo promedio (moneda local)

	Declare vArtcost           decimal(14,4);  -- Costo standard (moneda local)

	Declare vResultado         tinyInt(1);     -- 1=Todo salió bien, 0=No se pudo reservar

	Declare vErrorMessage      varchar(100);   -- Contiene el mensaje de error cuando vResultado = 0

	Declare vFacimve           decimal(12,2);  -- Total impuestos

	Declare vFacdesc           decimal(12,2);  -- Total descuento

	Declare vFacmont           decimal(12,2);  -- Total monto bruto

	Declare vFacfepa           datetime;       

	Declare vFacdpago          smallInt;       

	Declare vFacfppago         datetime;       

	Declare vRedondear         bit;            

	Declare vRedondearA5       bit;            

	Declare vExist0            bit;            

	Declare vDispCompras       decimal(12,2);  

	DECLARE vCodigotarifa	  VARCHAR(3);

	DECLARE vCodigoCabys	  VARCHAR(20);





	Set vResultado    = 1;

	Set vErrorMessage = '';



	Set pFacfech     = IfNull(pFacfech,now());

	Set vFacfepa     = AddDate(pFacfech, interval pFacplazo day);

	Set vFacdpago    = 1;

	Set vFacfppago   = pFacfech;

	Set vDispCompras = 0;



  

	-- Determinar los redondeos.  Solo se redondea para la moneda local.

	Set vRedondear =

		 Case When pCodigoTC = (Select codigoTC

								from config) then (Select redondear from config)

			  else 0

		 End;

	Set vRedondearA5 =

		 Case When pCodigoTC = (Select codigoTC

								from config) then (Select redond5 from config)

			  else 0

		 End;



	Set vExist0 = (Select Exist0 from config); 



	If pFacplazo > 0 then

		If pFacnpag <= 0 then

			Set pFacnpag  = 1;

			Set vFacdpago = 1;

		Else

			Set vFacdpago = Round(pFacplazo / pFacnpag,0);



			Set vFacfppago = AddDate(pFacfech, interval vFacdpago day);

		End if;

	End if;



	-- Obtengo los costos estándard y promedio aplicando el tipo de cambio de la transacción.

	-- Set vArtcosp = (Select artcosp / pTipoca from inarticu where artcode = pArtcode);

	/*Select 

		artcosp / pTipoca,

		artcost / pTipoca

	From inarticu

	where artcode = pArtcode

	into vArtcosp, vArtcost;*/

	

	Select 

		artcosp / pTipoca,

		artcost / pTipoca,

		codigoTarifa,

		codigoCabys

	into vArtcosp, vArtcost, vCodigoTarifa, vCodigoCabys

	From inarticu

	where artcode = pArtcode;



	-- Obtengo la cantidad reservada anterior (si hay)

	Set vReservadoAnterior =

		(Select sum(faccant)

		 from wrk_fadetall

		 Where id = pID and Bodega = pBodega and artcode = pArtcode);



	Set vReservadoAnterior = ifnull(vReservadoAnterior,0);

	Set vReservadoActual   = vReservadoAnterior + pReservado;



	If vExist0 = 0 then

		Set vDisponible    = ConsultarExistenciaDisponible(pArtcode,pBodega);

	End if;



	-- Si la cantidad reservada viene negativa es porque el usuario decidió

	-- quitar algunas unidades del reservado en cuyo caso hay que verificar

	-- que el nuevo reservado no quede negativo.

	-- Si el registro no existe en la tabla pedidod entonces lo agrega.

	If vReservadoActual < 0 then

		Set vResultado    = 0;

		Set vErrorMessage = '[BD] La cantidad no puede quedar negativa';

	End if;



	# Bosco modificado 25/09/2011.

	# El artículo _NOINV no valida existencia.

	#If vResultado = 1 then

	If vResultado = 1 and pArtcode != '_NOINV' then

		-- Valido si el disponible cubre el nuevo reservado

		If vDisponible - pReservado < 0 and vExist0 = 0 and pAfectarRes = 'S' then

			Set vResultado    = 0;

			Set vErrorMessage = '[BD] El disponible para este artículo es insuficiente';

		end if;

	End if;



	If vResultado = 1 and pAfectarRes = 'S' then

		Update bodexis

		Set Artreserv = Artreserv + pReservado

		Where Artcode = pArtcode and Bodega = pBodega;



		if row_count() = 0 then

			Set vResultado = 0;

			Set vErrorMessage = '[BD] Ocurrió un error al intentar reservar la cantidad en bodega';

		End if;

	End if;



	-- Actualizo la tabla de facturas (detalle)

	If vResultado = 1 then

		If (Select count(*) from wrk_fadetall

				Where id = pID and Bodega = pBodega and artcode = pArtcode) > 0 then

			Update wrk_fadetall Set

			   faccant   	= vReservadoActual,

			   artprec   	= pArtprec,

			   facmont   	= vReservadoActual * pArtprec,

			   facpive   	= pFacpive,

			   codigoTarifa = vCodigoTarifa,

			   codigocabys = vCodigoCabys,

			   artcosp   	= vArtcosp,

			   artcost	= vArtcost

			Where id = pID and Bodega = pBodega and artcode = pArtcode;

		Else

			Insert into wrk_fadetall (

			  id,

			  artcode,

			  bodega,

			  faccant,

			  artprec,

			  facmont,

			  facpive,

			  codigoTarifa,

			  codigoCabys,

			  artcosp,

			  artcost)

			Values (

			  pID,

			  pArtcode,

			  pBodega,

			  pReservado,

			  pArtprec,

			  pReservado * pArtprec,

			  pFacpive,

			  vCodigoTarifa,

			  vCodigoCabys,

			  vArtcosp,

			  vArtcost);

		End if ; -- if-else



		if row_count() = 0 then

			Set vResultado    = 0;

			Set vErrorMessage = '[BD] No se pudo actualizar la tabla de facturas';

		End if;



		if vResultado > 0 then

			-- Recalcular el impuesto.

			-- Podría aplicarlo condicionado como está arriba pero de todas formas un pedido

			-- no llega a ser muy grande y es más seguro si se recalcula todo el pedido y no

			-- solo la línea que se solicita.

			Update wrk_fadetall Set

				facimve = (facmont - facdesc) * (facpive/100)

			Where id = pID;



			-- Recalcular el encabezado de la factura

			Set vFacimve = (Select sum(facimve) from wrk_fadetall Where id = pID);

			Set vFacdesc = (Select sum(facdesc) from wrk_fadetall Where id = pID);

			Set vFacmont = (Select sum(facmont) from wrk_fadetall Where id = pID);



			Set vFacmont = vFacmont - vFacdesc + vFacimve;



			If vRedondearA5 = 1 then

				Set vFacmont = RedondearA5(vFacmont);

			End if;



			Update wrk_faencabe Set

			  facimve    = vFacimve,

			  facdesc    = vFacdesc,

			  facmont    = vFacmont,

			  facfech    = pFacfech,

			  facplazo   = pFacplazo,

			  facfepa    = vFacfepa,

			  vend       = pVend,

			  terr       = pTerr,

			  factipo    = pFactipo,

			  chequeotar = pChequeotar,

			  facnpag    = pFacnpag,

			  facdpago   = vFacdpago,

			  facfppago  = vFacfppago,

			  facmpag    = facmont / facnpag,

			  facsald    = If(facplazo > 0, facmont, 0),

			  precio     = pPrecio,

			  codigoTC   = pCodigoTC,

			  tipoca     = pTipoca

			Where id = pID;

		End if; 



     

		If pFacplazo > 0 then

			Set vDispCompras =

				  (Select inclient.clilimit - inclient.clisald - wrk_faencabe.facsald

				   from wrk_faencabe

				   Inner Join inclient on wrk_faencabe.clicode = inclient.clicode

				   Where id = pID);



			If (vDispCompras) < 0 then

				Set vResultado    = 0;

				Set vErrorMessage = '[BD] Este artículo sobrepasa el disponible de compras del cliente';

			End if;

		End if; 

	End if;  -- if vResultado = 1



  -- Envío el resultado del proceso como un ResultSet

  Select vResultado, vErrorMessage;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarNotasCCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarNotasCCXC`(


  IN `pFacnume` int(10)


)
BEGIN


  -- Autor: Bosco Garita Azofeifa


  


	Select


		ABS(faencabe.facnume)  as facnume,


		inclient.clidesc,


		Dtoc(faencabe.facfech) as fecha,


		ABS(faencabe.facsald)  as facsald,


		faencabe.codigoTC,


		Trim(monedas.descrip)  as Moneda,


		faencabe.tipoca,


		faencabe.facfech,       


		ABS(faencabe.facsald) * faencabe.tipoca as SaldoML,


		faencabe.clicode


	from faencabe


	Inner Join monedas  on faencabe.codigoTC = monedas.codigo


	Inner join inclient on faencabe.clicode  = inclient.clicode


	where faencabe.facnume = If(Abs(pFacnume) = 0, faencabe.facnume, pFacnume)


	and facnd > 0     


	and facsald < 0


	and facestado = '' 


	Order by facfech,facnume;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarNotasCCXC_FSC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarNotasCCXC_FSC`(


  IN `pFacnume` int(10)


)
BEGIN


	-- Autor: Bosco Garita Azofeifa, 16/12/2018


	-- Obtener todas las notas de crédito sobre facturas de contado que aún no han sido


	-- enviadas a Hacienda.


	Select


		ABS(faencabe.facnume)  as facnume,


		inclient.clidesc,


		Dtoc(faencabe.facfech) as fecha,


		ABS(faencabe.facsald)  as facsald,


		faencabe.codigoTC,


		Trim(monedas.descrip)  as Moneda,


		faencabe.tipoca,


		faencabe.facfech,       


		ABS(faencabe.facsald) * faencabe.tipoca as SaldoML,


		faencabe.clicode


	from faencabe


	Inner Join monedas  on faencabe.codigoTC = monedas.codigo


	Inner join inclient on faencabe.clicode  = inclient.clicode


	where faencabe.facnume = If(Abs(pFacnume) = 0, faencabe.facnume, pFacnume)


	and facnd > 0  


	and facestado = '' 


	and claveHacienda = ''


	and facsald = 0


	and faccsfc = 1


	and not exists(	Select notanume 


					from notasd 


					Where Notanume = faencabe.facnume 


					and facnd = faencabe.facnd)


	Order by facfech,facnume;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS consultarNotasDCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarNotasDCXP`(


  IN `pFactura` varchar(10)


)
BEGIN


     -- Autor: Bosco Garita Azofeifa


     


  


     Select


           cxpfacturas.factura,


           inproved.prodesc,


           Dtoc(cxpfacturas.fecha_fac) as fecha,


           ABS(cxpfacturas.saldo) as saldo,


           cxpfacturas.codigoTC,


           Trim(monedas.descrip) as Moneda,


           cxpfacturas.tipoca,


           cxpfacturas.fecha_fac,       


           ABS(cxpfacturas.saldo) * cxpfacturas.tipoca as SaldoML,


           cxpfacturas.procode


     from cxpfacturas


     Inner Join monedas on cxpfacturas.codigoTC = monedas.codigo


     Inner join inproved on cxpfacturas.procode = inproved.procode


     where cxpfacturas.factura = If(pFactura is null, cxpfacturas.factura, pFactura)


     and tipo = 'NDB'     


     and saldo < 0


     Order by fecha_fac,factura;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarReciboCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarReciboCXC`(


  IN `pRecnume` int


)
BEGIN


  





  Declare vcEmpresa  varchar(60);


  Declare vcTelefono varchar(30);


  Declare vcCedulaJu varchar(50);


  Declare vcDireccio varchar(200);


  Declare vcTimbre   varchar(40);


  Declare vnRedond   tinyInt(1);





  Set vcEmpresa  = (Select empresa from config);


  Set vcTelefono = (Select Concat('TELÉFONO: ', telefono1) from config);


  Set vcCedulaJu = (Select Concat('CÉDULA JURÍDICA : ', cedulajur) from config);


  Set vcDireccio = (Select Direccion from config);








  Select


    vcEmpresa  as empresa,


    vcTelefono as telefono,


    vcCedulaJu as cedulajur,


    vcDireccio as Direccion,


    pagos.recnume,


    pagos.fecha,


    pagos.cheque,


    pagos.banco,


    pagos.codigoTC,


    pagos.monto,


    pagos.tipoca,


    monedas.descrip,


    monedas.simbolo,


    pagos.clicode,


    inclient.clidesc,


    pagosd.facnume,


    pagosd.facnd,


    If(pagosd.facnd = 0, 'Factura','Nota débito') as TipoDoc,


    pagosd.monto as MontoAp,


    B.simbolo as simboloF,


    inclient.clisald,


    inclient.clisald + pagos.monto as SaldoAnt,


    pagos.concepto


  From pagosd


  Inner Join pagos    on pagosd.recnume = pagos.recnume


  Inner Join inclient on pagos.clicode  = inclient.clicode


  Inner Join monedas  on pagos.codigoTC = monedas.codigo


  Inner join faencabe on pagosd.facnume = faencabe.facnume and pagosd.facnd = faencabe.facnd


  Inner join monedas B on faencabe.codigoTC = B.codigo


  Where pagosd.recnume = pRecnume;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarReciboCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarReciboCXP`(


  IN `pRecnume` int


)
BEGIN


	/*


	Información del pago aplicado a proveedores.


	Autor: Bosco Garita, 25/07/2015


	*/





	Declare vcEmpresa  varchar(60);


	Declare vcTelefono varchar(30);


	Declare vcCedulaJu varchar(50);


	Declare vcDireccio varchar(200);


	Declare vcTimbre   varchar(40);


	Declare vnRedond   tinyInt(1);





	Set vcEmpresa  = (Select empresa from config);


	Set vcTelefono = (Select Concat('TELÉFONO: ', telefono1) from config);


	Set vcCedulaJu = (Select Concat('CÉDULA JURÍDICA : ', cedulajur) from config);


	Set vcDireccio = (Select Direccion from config);








	Select


		vcEmpresa  as empresa,


		vcTelefono as telefono,


		vcCedulaJu as cedulajur,


		vcDireccio as Direccion,


		pagos.recnume,


		pagos.fecha,


		pagos.cheque,


		pagos.codigoTC,


		pagos.monto,


		pagos.tipoca,


		monedas.descrip,


		monedas.simbolo,


		pagos.procode,


		inproved.prodesc,


		pagosd.factura,


		pagosd.tipo,


		If(pagosd.tipo = 'FAC', 'Factura',If(pagosd.tipo = 'NCR', 'Nota de Crédito','Nota débito')) as TipoDoc,


		pagosd.monto as MontoAp,


		B.simbolo as simboloF,


		inproved.prosald,


		inproved.prosald + pagos.monto as SaldoAnt,


		pagos.concepto


	From cxppagd pagosd


	Inner Join cxppage pagos on pagosd.recnume = pagos.recnume


	Inner Join inproved 	 on pagos.procode  = inproved.procode


	Inner Join monedas  	 on pagos.codigoTC = monedas.codigo


	Inner join cxpfacturas   on pagosd.factura = cxpfacturas.factura 


	and pagos.procode = cxpfacturas.procode and pagosd.tipo = cxpfacturas.tipo


	Inner join monedas B 	 on cxpfacturas.codigoTC = B.codigo


	Where pagosd.recnume = pRecnume;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS DuplicarOrdenCompra;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `DuplicarOrdenCompra`(


  IN  `pMovorco`  varchar(10)


)
BEGIN


	# Autor: Bosco Garita Azofeifa, 09/12/2014


	# 		 Duplicar una orden de compra.


	# IMPORTANTE: El programa que invoque este SP debe controlar las transacciones.





	Set @ultordenc := (Select ultordenc + 1 from config);


	Set @movorco := pMovorco;





	Insert into comOrdenCompraE


		SELECT @ultordenc,


			`comOrdenCompraE`.`Movdesc`,


			`comOrdenCompraE`.`movfech`,


			`comOrdenCompraE`.`tipoca`,


			`comOrdenCompraE`.`user`,


			`comOrdenCompraE`.`movtido`,


			`comOrdenCompraE`.`movfechac`,


			`comOrdenCompraE`.`codigoTC`,


			`comOrdenCompraE`.`procode`,


			`comOrdenCompraE`.`movcerr`,


			`comOrdenCompraE`.`movdocu`


		FROM `comOrdenCompraE`


		Where movorco = @movorco;





	Insert into comOrdenCompraD


		SELECT @ultordenc,


			`comOrdenCompraD`.`artcode`,


			`comOrdenCompraD`.`bodega`,


			`comOrdenCompraD`.`movcant`,


			`comOrdenCompraD`.`artcosfob`,


			`comOrdenCompraD`.`artcost`,


			`comOrdenCompraD`.`movreci`


		FROM `comOrdenCompraD`


		Where movorco = @movorco;





	Update config


		set ultordenc = @ultordenc


	limit 1;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ConsultarRegistrosCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarRegistrosCXC`(

	IN `pDocumento` int,

	IN `pTipoDoc` tinyint

)
BEGIN

    # Autor:	Bosco Garita 16/01/2011

    # Objetivo:	Generar un detalle de los registros afectados por el (o que afectan al)  

    #           documento que recibe por parámetro (Recibo, factura, ND,NC) 

    # Modif.:	Bosco Garita 18/11/2015, agrego el cliente





    # Valido el tipo de documento, asumo un valor default en caso de error (Recibo).

    # pTipoDoc: 1=Factura, 2=NC, 3=ND, 4=Recibo

    Set pTipoDoc = If(pTipoDoc is null or pTipoDoc not between 1 and 4, 4, pTipoDoc);



    # A manera de "PLUS" reconfiguro el número de documento cuando se trata de una NC

    If pTipodoc = 2 and pDocumento is not null and pDocumento > 0 then

    Set pDocumento = pDocumento *-1;

    End if;



    # Obtengo los datos de acuerdo con el tipo de documento.

    Case pTipoDoc

    When 1 then -- Facturas

        Select 

            'Recibos/NC que afectan a esta factura.' as mensaje,

            a.notanume as documento,

            a.notanume as aplicado,

            'NC' as tipo,

            a.monto * c.tipoca as montoML,

            d.simbolo,

            a.monto,

            dtoc(b.facfech) as fecha,

            c.tipoca,

            c.codigoTC,

            e.clidesc

        from notasd a

        Inner join faencabe b on a.notanume = b.facnume and b.facnd > 0 -- El encabezado de las NC también es faencabe

        Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd

        Inner join monedas  d on c.codigoTC = d.codigo

        Inner join inclient e on c.clicode = e.clicode

        Where a.facnume = pDocumento and a.facnd = 0 and b.facestado = ''

        Union all

        Select 

            'Recibos/NC que afectan a esta factura.' as mensaje,

            a.recnume as documento,

            a.recnume as aplicado,

            'R' as tipo,

            a.monto * c.tipoca as montoML,

            d.simbolo,

            a.monto,

            dtoc(b.fecha) as fecha,

            c.tipoca,

            c.codigoTC,

            e.clidesc

        from pagosd a

        Inner join pagos    b on a.recnume = b.recnume

        Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd

        Inner join monedas  d on c.codigoTC = d.codigo

        Inner join inclient e on c.clicode = e.clicode

        Where a.facnume = pDocumento and a.facnd = 0 and b.estado = ''

        Order by aplicado,tipo;



    When 2 then -- Notas de crédito.

        Select 

            'Facturas/ND afectadas por esta nota de crédito.' as mensaje,

            a.notanume as documento,

            a.facnume as aplicado,

            If(a.facnd = 0,'FAC','ND') as tipo,

            a.monto * c.tipoca as montoML,

            d.simbolo,

            a.monto,

            dtoc(b.facfech) as fecha,

            c.tipoca,

            c.codigoTC,

            e.clidesc

        from notasd a

        Inner join faencabe b on a.notanume = b.facnume and b.facnd > 0 -- El encabezado de las NC también es faencabe

        Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd

        Inner join monedas  d on c.codigoTC = d.codigo

        Inner join inclient e on c.clicode = e.clicode

        Where a.notanume = pDocumento and b.facestado = ''

        Order by aplicado,tipo;



    When 3 then -- Notas de débito

        Select 

            'Recibos/NC que afectan a esta nota de débito.' as mensaje,

            a.notanume as documento,

            a.notanume as aplicado,

            'NC' as tipo,

            a.monto * c.tipoca as montoML,

            d.simbolo,

            a.monto,

            dtoc(b.facfech) as fecha,

            c.tipoca,

            c.codigoTC,

            e.clidesc

        from notasd a

        Inner join faencabe b on a.notanume = b.facnume and b.facnd > 0 -- El encabezado de las NC también es faencabe

        Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd

        Inner join monedas  d on c.codigoTC = d.codigo

        Inner join inclient e on b.clicode = e.clicode

        Where a.facnume = pDocumento and a.facnd < 0 and b.facestado = ''

        Union all

        Select 

            'Recibos/NC que afectan a esta nota de débito.' as mensaje,

            a.recnume as documento,

            a.recnume as aplicado,

            'R' as tipo,

            a.monto * c.tipoca as montoML,

            d.simbolo,

            a.monto,

            dtoc(b.fecha) as fecha,

            c.tipoca,

            c.codigoTC,

            e.clidesc

        from pagosd a

        Inner join pagos    b on a.recnume = b.recnume

        Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd

        Inner join monedas  d on c.codigoTC = d.codigo

        Inner join inclient e on c.clicode = e.clicode

        Where a.facnume = pDocumento and a.facnd < 0 and b.estado = ''

        Order by aplicado,tipo;



    When 4 then -- Recibos

        Select 

            'Facturas/ND afectadas por este recibo.' as mensaje,

            a.recnume as documento,

            a.facnume as aplicado,

            If(c.facnd = 0,'FAC','ND') as tipo,

            a.monto * c.tipoca as montoML,

            d.simbolo,

            a.monto,

            dtoc(b.fecha) as fecha,

            c.tipoca,

            c.codigoTC,

            e.clidesc

        from pagosd a

        Inner join pagos    b on a.recnume = b.recnume

        Inner join faencabe c on a.facnume = c.facnume and a.facnd = c.facnd

        Inner join monedas  d on c.codigoTC = d.codigo

        Inner join inclient e on c.clicode = e.clicode

        Where a.recnume = pDocumento and b.estado = ''

        Order by aplicado,tipo;

    End Case;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarLineaFaccantFact;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarLineaFaccantFact`(


  IN  `pID`         int(10),


  IN  `pBodega`     varchar(3),


  IN  `pArtcode`    varchar(20),


  IN  `pEsFactura`  tinyint(1)


)
BEGIN


  


  Declare vFaccant      decimal(12,2);  


  Declare vResultado    tinyInt(1);  


  Declare vErrorMessage varchar(50); 





  Set vResultado    = 1;


  Set vErrorMessage = '';





  If (Select Count(*) from wrk_fadetall


      Where id = pID and bodega = pBodega and artcode = pArtcode) = 0 then


     Set vResultado    = 0;


     Set vErrorMessage = '[BD] Registro no existe';


  End if;








  


  Set vFaccant =


    (Select sum(Faccant) from wrk_fadetall


     Where id = pID and bodega = pBodega and artcode = pArtcode);





  


  Delete from wrk_fadetall


  Where id = pID and Bodega = pBodega and artcode = pArtcode;





  if row_count() = 0 then


     Set vResultado = 0;


     Set vErrorMessage = '[BD] Ocurrió un error al intentar eliminar la línea';


  End if;





  


  If vResultado = 1 and pEsFactura = 1 then


     Update bodexis Set Artreserv = Artreserv - vFaccant


     Where Artcode = pArtcode and Bodega = pBodega;





     if row_count() = 0 then


        Set vResultado = 0;


        Set vErrorMessage = '[BD] Ocurrió un error al intentar liberar la cantidad reservada';


     End if;


  End if;





  


  Select vResultado, vErrorMessage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarLineaReservado;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarLineaReservado`(


  IN  `pFacnume`  int(10),


  IN  `pBodega`   varchar(3),


  IN  `pArtcode`  varchar(20)


)
BEGIN


    Declare vReservado     decimal(12,2);  


    Declare vResultado     tinyInt(1); 


    Declare vErrorMessage  varchar(100);  -- Bosco 25/10/2011. Aumento el tamaño de 50 a 100





    Set vResultado    = 1;


    Set vErrorMessage = '';





    If (Select Count(*) from pedidod


        Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode) = 0 then


        Set vResultado    = 0;


        Set vErrorMessage = '[BD] Registro no existe';


    End if;





    # Bosco modificado 02/01/2012.


    # Este código ya no es necesario.  Para eso se modificó el SP que recalcula el reservado


    # de manera que se pueda usar para un solo artículo.


    --     Set vReservado =


    --         (Select sum(Reservado) from pedidod


    --          Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode);


    # Fin Bosco modificado 02/01/2012.





    Delete from pedidod


    Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode;





    if row_count() = 0 then


        Set vResultado = 0;


        -- Bosco 25/10/2011. Agrego el pArtcode en el mensaje.


        Set vErrorMessage = Concat('[BD] Ocurrió un error al intentar eliminar la línea','[',pArtcode,']');


    End if;





    # Bosco modificado 02/01/2012.


    # Este código ya no es necesario.  Para eso se modificó el SP que recalcula el reservado


    --     If vResultado = 1 then


    --         Update Bodexis


    --             Set Artreserv = Artreserv - vReservado


    --         Where Artcode = pArtcode and Bodega = pBodega;


    -- 


    --         if row_count() = 0 then


    --             Set vResultado = 0;


    --             Set vErrorMessage = '[BD] Ocurrió un error al intentar liberar la cantidad reservada';


    --         End if;


    --     End if;


    Call RecalcularReservado(pArtcode);


    


    Select vResultado, vErrorMessage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EliminarPagareCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarPagareCXC`(


  IN `pPagare` int(10)


)
BEGIN


 


  


  Declare vError   tinyInt(1);


  Declare vMensaje varchar(200);


  Declare vRegistros int;





  Set vError = 0;


  Set vMensaje = '';





  


  Select count(clicode) from PagaresCXC


  Where Pagare = pPagare into vRegistros;





  Set vRegistros = IfNull(vRegistros,0);





  If vRegistros = 0 then


    Set vError = 1;


    Set vMensaje = '[BD] El pagaré no existe';


  End if;





  If vError = 0 then


    Delete from PagaresCXC Where pagare = pPagare;


  End if;





  


  Select vError as Error, vMensaje as MensajeErr;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EncabezadoFacturasVsDetalle;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EncabezadoFacturasVsDetalle`(





  OUT `pHayIncongruencias` tinyint(1)





)
BEGIN


    # Autor:    Bosco Garita 18/02/2013.


    # Descrip:  Verificar si existen facturas sin detalle.


    #           Esto no debería suceder pero si por alguna razón sucede el sistema advertirá.


    #           Este SP también se usa como condición para realizar el cierre mensual.


    # Devuelve: Un Result Set con los documentos que no tienen detalle. Dentro del RS también


    #           irá una columna llamada rownum con el número consecutivo de los registros que puede


    #           servir para ver cuántos registros fueron procesados.  Pero además este SP también


    #           retorna este número de registros mediante el parámetro de salida pHayIncongruencias





    # Acción:   El usuario deberá anular y borrar las facturas que aparezcan y volver a hacerlas.





    SELECT @rownum:=@rownum+1 rownum, t.* FROM (SELECT @rownum:=0) r, (





		# Revisar las facturas del periodo actual


		SELECT distinct


			facnume,


			dtoc(facfech) AS facfech,


			facmont,


			facplazo,


			'Factura' AS tipo


		FROM faencabe A


		Where A.facnume > 0


		and A.facnd = 0


		and A.facCerrado = 'N' 


		and A.facestado <> 'A'


		and not exists(


			Select facnume from fadetall B


			Where A.facnume = B.facnume and A.facnd = B.facnd)


	) t;





    # Verificar si se procesaron registros


    SET pHayIncongruencias = @rownum > 0;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS EncabezadoInvVsDetalle;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `EncabezadoInvVsDetalle`(


  OUT `pHayIncongruencias` tinyint(1)


)
BEGIN


    # Autor:    Bosco Garita 24/02/2013.


    # Descrip:  Verificar si existen documentos de inventario que no estén en la tabla de detalle.


    #           Esto no debería suceder pero si por alguna razón sucede el sistema advertirá.


    #           Este SP también se usa como condición para realizar el cierre mensual.


    # Devuelve: Un Result Set con los documentos que no tienen detalle. Dentro del RS también


    #           irá una columna llamada rownum con el número consecutivo de los registros que puede


    #           servir para ver cuántos registros fueron procesados.  Pero además este SP también


    #           retorna este número de registros mediante el parámetro de salida pHayIncongruencias


    # Acción:   El DBA deberá crear un Script que actualice la tabla INMOVIMD


    


    # 


    


    


    SELECT @rownum:=@rownum+1 rownum, t.* FROM (SELECT @rownum:=0) r, (


    # Revisar los documentos del periodo actual


    SELECT 


        inmovime.movdocu,


        dtoc(inmovime.movfech) AS fecha,


        0 as monto,


        1 as plazo,


        intiposdoc.Descrip AS tipo


    FROM inmovime


	INNER JOIN intiposdoc on inmovime.movtido = intiposdoc.movtido


    WHERE inmovime.estado = ''


    AND inmovime.movCerrado = 'N'


    AND NOT EXISTS( SELECT movdocu FROM inmovimd 


                    WHERE movdocu = inmovime.movdocu 


                    AND movtido = inmovime.movtido)


    ) t;


                    


    # Verificar si se procesaron registros


    SET pHayIncongruencias = @rownum > 0;


    


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS FacturacionVsInventario;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `FacturacionVsInventario`(


  OUT `pHayIncongruencias` tinyint(1)


)
BEGIN


    # Autor:    Bosco Garita 17/02/2011.


    # Descrip:  Verificar si existen facturas o NC que no estén en la tabla de movimientos de inventario.


    #           Esto no debería suceder pero si por alguna razón sucede el sistema advertirá.


    #           Este SP también se usa como condición para realizar el cierre mensual.


    # Devuelve: Un Result Set con los documentos que no existen en inventarios. Dentro del RS también


    #           irá una columna llamada rownum con el número consecutivo de los registros que puede


    #           servir para ver cuántos registros fueron procesados.  Pero además este SP también


    #           retorna este número de registros mediante el parámetro de salida pHayIncongruencias


    # Acción:   El DBA deberá crear un Script que actualice las tablas INMOVIME e INMOVIMD


    


    # 


    


    # Las notas de débito no juegan en esta revisión porque no son documentos de inventario.





	# Modificado por: Bosco Garita Azofeifa 14/04/2013.  


	# Agrego código para que no se revisen los registros anulados.





	# Modificado por: Bosco Garita Azofeifa 05/07/2015


	# Creo un tabla temporal con los registros que se necesitan únicamente.


	# Luego esta tabla la uso en vez de faencabe.


	Create temporary table mov(


	SELECT movdocu + 0 as movdocu FROM inmovime 


                    INNER JOIN intiposdoc ON inmovime.movtido = intiposdoc.movtido


                    WHERE movtimo = 'S'


					AND movCerrado = 'N'


                    AND intiposdoc.modulo = 'CXC' AND EntradaSalida = 'S');


	CREATE INDEX ix_mov ON mov (movdocu);


    


    SELECT @rownum:=@rownum+1 rownum, t.* FROM (SELECT @rownum:=0) r, (


    # Revisar las facturas del periodo actual


    /*


	SELECT 


        facnume,


        dtoc(facfech) AS facfech,


        facmont,


        facplazo,


        'Factura' AS tipo


    FROM faencabe


    WHERE facnume > 0 AND facnd = 0


    AND facCerrado = 'N'


	and facestado = ''	-- Bosco agregado 14/04/2013


    AND NOT EXISTS( SELECT movdocu FROM inmovime 


                    INNER JOIN intiposdoc ON inmovime.movtido = intiposdoc.movtido


                    WHERE movdocu = faencabe.facnume 


                    AND intiposdoc.modulo = 'CXC' AND EntradaSalida = 'S')


	*/


	SELECT 


        facnume,


        dtoc(facfech) AS facfech,


        facmont,


        facplazo,


        'Factura' AS tipo


    FROM faencabe


    WHERE facnume > 0 AND facnd = 0


    AND facCerrado = 'N'


	and facestado = ''


    AND NOT EXISTS( SELECT movdocu FROM mov 


                    WHERE movdocu = faencabe.facnume 


					)


    UNION ALL


    # Revisar las notas de crédito del periodo actual


    SELECT 


        facnume,


        dtoc(facfech) AS facfech,


        facmont,


        facplazo,


        'Nota C' AS tipo 


    FROM faencabe


    WHERE facnume < 0 AND facnd > 0


    AND facCerrado = 'N'


	and facestado = ''	-- Bosco agregado 14/04/2013


    AND NOT EXISTS( SELECT movdocu FROM inmovime 


                    INNER JOIN intiposdoc ON inmovime.movtido = intiposdoc.movtido


                    WHERE movdocu = ABS(faencabe.facnume)


                    AND intiposdoc.modulo = 'CXC' and EntradaSalida = 'E')) t;


                    


    # Verificar si se procesaron registros


    SET pHayIncongruencias = @rownum > 0;


	Drop table mov;


    


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS GenerarMinimosPorBodega;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerarMinimosPorBodega`(


	IN pBodega varchar(3),	-- Bodega a procesar


	IN pPromDias   int,		-- Promedio en días


	IN pDiasProc   int		-- Días a procesar


)
BEGIN


	# Autor: Bosco Garita Azofeifa 27/12/2013


	# Este SP realiza una consulta de movimientos de inventario partiendo desde 


	# la fecha actual hasta el número de días que indique el parámetro pDiasProc


	# con el fin de determinar la cantidad de salidas que el artículo ha tenido.


	# Luego divide esa cantidad entre la cantidad de días que indique el mismo


	# parámetro pDiasProc con la finalidad de obtener un promedio de movimientos


	# por día. Después de esto multiplica ese resultado por el valor que tenga el


	# parámetro pPromDias.  Ese sería el valor que se establezca como mínimo para


	# cada artículo de inventario.


	# NOTAS importantes:


	# 1.	En el caso de no tener salidas el mínimo será cero.


	# 2.	No se toman en cuenta las salidas por devolución y las salidas por ajuste.


	# 3.	Si el número de días que el usuario solicitó es inferior a la duración del pedido 


	#		entonces el sistema asumirá la duración de pedido.





	-- Creo una tabla temporal con el código y la duración del pedido.  Esto se hace debido a


	-- que MySQL no permite incluir tablas dentro de un update que ya están incluidas dentro


	-- de un trigger.


	Drop table if exists durp;





	Create temporary table durp


		Select artcode, artdurp from inarticu;





	Update bodexis, durp


		Set minimo = IfNull((


			Select Sum(movcant)


			from inmovimd a, inmovime b, intiposdoc c


			Where a.movdocu = b.movdocu


			and a.movtimo = b.movtimo


			and a.movtido = b.movtido


			and a.movtido = c.movtido


			and a.artcode = bodexis.artcode


			and a.bodega  = bodexis.bodega


			and b.movfech between (now() - interval pDiasProc day) and now()


			and b.movtimo = 'S'


			and (b.estado is null or b.estado = '')


			-- and a.movtido not in(7,12)


			and c.afectaMinimos = 1


			) / pDiasProc * If(pPromDias > durp.artdurp, pPromDias, durp.artdurp),0)


	Where bodexis.artcode = durp.artcode


	and bodexis.bodega = pBodega;





	Drop table durp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS GenerarInteresMoratorio;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerarInteresMoratorio`()
BEGIN


    Declare vMora      float;        


    Declare vIntervalo smallInt(3);  


    Declare vDiasG     smallInt(3);  


    Declare vError     tinyInt(1);   


    Declare vMensaje   varchar(800); 


    Declare vClicode1  Integer;      


    Declare vClicode2  Integer;      


    Declare vClisald   double;       


    Declare vVencido   double;       


    Declare vSuccess   tinyInt(1);   


    Declare vCodigoTC  char(3);





    Set vError   = 0;


    Set vMensaje = '';








    SELECT


        IfNull(mora,0),


        IfNull(intervalo,0),


        IfNull(diasG,0),


        CodigoTC


    FROM config


    INTO


        vMora,


        vIntervalo,


        vDiasG,


        vCodigoTC;





    If vMora <= 0 then


        Set vError = 1;


        Set vMensaje = '[DB] La tasa de interés moratorio no está configurada';


    End if;





    If vError = 0 and vIntervalo <= 0 then


        Set vError = 1;


        Set vMensaje = '[DB] El invtervalo en días para el interés moratorio no está configurado';


    End if;








    If ConsultarTipoca(vCodigoTC,date(now())) is null then


        Set vError = 1;


        Set vMensaje = '[DB] El tipo de cambio de la moneda default para hoy no se ha definido ';


    End if;








    If vError = 0 then


        Select min(clicode),max(clicode) from inclient into vclicode1,vClicode2;


    End if;





    # Recalcular el saldo de todos los clientes.


    Call RecalcularSaldoClientes(null);





    # Recorrer toda la tabla de clientes.  Primero se recalcula el saldo del cliente y luego se genera la ND.


    While vError = 0 and vClicode1 <= vClicode2 Do


        Set vSuccess = 1;





        # Inicia la transacción


        Start transaction;





        Set vClisald = 0;


        Set vVencido = 0;





        Select clisald from inclient where clicode = vClicode1 into vClisald;





        If vClisald > 0 then


            # Bosco modificado 28/01/2012


            -- Set vVencido = ConsultarMontoVencidoCXC(vClicode1);


            Set vVencido = ConsultarMontoVencidoCXC(vClicode1,1);


            # Fin Bosco modificado 28/01/2012


        End if;





        # Si hay monto vencido entonces le genero una ND.


        If vVencido > 0 then


            Set vSuccess = 0;





            # Generar la nota de débido por morosidad con el monto correspondiente.


            Call GenerarNotaDBCXC(vClicode1,vSuccess,vMensaje,vVencido);


        End if;





        If vSuccess = 1 then


            Commit;


        Else


            RollBack;


            Set vError = 1;


        End if;








        Select SQL_CALC_FOUND_ROWS Min(clicode) from inclient Where clicode > vClicode1 into vClicode1;


        If FOUND_ROWS() = 0 then


            #Set vClicode1 = null;


            Set vClicode1 = vClicode2 + 1;


        End if;


    End While;





    Select vError, trim(vMensaje); # Select con el resultado del SP


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarArticulo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarArticulo`(

	IN `pArtcode` varchar(20),

	IN `pArtdesc` varchar(50),

	IN `pBarcode` varchar(20),

	IN `pArtfam` char(4),

	IN `pArtcosd` decimal(14,4),

	IN `pArtcost` decimal(14,4),

	IN `pArtcosp` decimal(14,4),

	IN `pArtcosa` decimal(14,4),

	IN `pArtcosfob` decimal(14,4),

	IN `pArtpre1` decimal(12,2),

	IN `pArtgan1` decimal(7,4),

	IN `pArtpre2` decimal(12,2),

	IN `pArtgan2` decimal(7,4),

	IN `pArtpre3` decimal(12,2),

	IN `pArtgan3` decimal(7,4),

	IN `pArtpre4` decimal(12,2),

	IN `pArtgan4` decimal(7,4),

	IN `pArtpre5` decimal(12,2),

	IN `pArtgan5` decimal(7,4),

	IN `pProcode` varchar(15),

	IN `pArtmaxi` decimal(12,4),

	IN `pArtiseg` decimal(10,4),

	IN `pArtdurp` decimal(8,2),

	IN `pArtfech` datetime,

	IN `pCodigoTarifa` VARCHAR(3),

	IN `pCodigoCabys` VARCHAR(20),

	IN `pOtroc` varchar(10),

	IN `pAltarot` tinyint(1),

	IN `pAplicaOferta` tinyInt(1),

	IN `pVinternet` tinyInt(1),

	IN `pArtObse` varchar(1500),

	IN `pArtFoto` varchar(250)

)
BEGIN

  # Autor: Bosco Garita Azofeifa



  If (ConsultarArticulo(pArtcode, 1) is null) then

    Insert into inarticu (

      Artcode ,

      Artdesc ,

      Barcode ,

      Artfam  ,

      Artcosd ,

      Artcost ,

      Artcosp ,

      Artcosa ,

      Artcosfob,

      Artpre1 ,

      Artgan1 ,

      Artpre2 ,

      Artgan2 ,

      Artpre3 ,

      Artgan3 ,

      Artpre4 ,

      Artgan4 ,

      Artpre5 ,

      Artgan5 ,

      Procode ,

      Artmaxi ,

      Artiseg ,

      Artdurp ,

      Artfech ,

      CodigoTarifa,

      CodigoCabys ,

      Otroc   ,

      Altarot ,

	 aplicaOferta, -- Bosco agregado 09/03/2014

      Vinternet,

      ArtObse,

      ArtFoto )

    Values (

      pArtcode ,

      pArtdesc ,

      pBarcode ,

      pArtfam  ,

      pArtcosd ,

      pArtcost ,

      pArtcosp ,

      pArtcosa ,

      pArtcosfob,

      pArtpre1 ,

      pArtgan1 ,

      pArtpre2 ,

      pArtgan2 ,

      pArtpre3 ,

      pArtgan3 ,

      pArtpre4 ,

      pArtgan4 ,

      pArtpre5 ,

      pArtgan5 ,

      pProcode ,

      pArtmaxi ,

      pArtiseg ,

      pArtdurp ,

      pArtfech ,

      pCodigoTarifa,

      pCodigoCabys,

      pOtroc   ,

      pAltarot ,

      pAplicaOferta, -- Bosco agregado 09/03/2014

      pVinternet,

      pArtObse,

      pArtFoto );

  Else

    Select '[BD] El artículo ya existe';

  End if;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS GenerarNotaDBCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerarNotaDBCXC`(


  IN   `pClicode`  int,


  OUT  `pSuccess`  tinyint(1),


  OUT  `pMensaje`  varchar(800),


  IN   `pVencido`  double


)
BEGIN


    Declare vPrim_fecha  datetime;  


    Declare vUlt_fecha   datetime;  


    Declare vFacnume     int;       


    Declare vIntervalo  smallInt(3);


    Declare vDiasG      smallInt(3);


    Declare vMora       float;


    Declare vIncrementoM float;


    Declare vVend       smallInt(3);


    Declare vTerr       smallInt(3);


    Declare vBodega     char(3);


    Declare vCodigoTC   char(3);


    Declare vTipoca     float;      


    Declare vFacmont    double;


    Declare vNmeses     smallInt;   


    Declare vPrecio     tinyInt(2); 








    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN


        SHOW ERRORS;


        SET pMensaje = Concat('[DB] No se pudo generar ND para el cliente ',pClicode);


        SET pSuccess = 0;


    END;





    # Obtener los parámetros para los cálculos.


    SELECT


        ndeb+1,         -- Consecutivo de NDs


        intervalo,      -- Intervalo de cálculo (se calcula cada n días)


        diasG,          -- Días de gracia.


        bodega,         -- Bodega predeterminada


        codigoTC,       -- Código de tipo de cambio de la moneda local.


        mora,           -- Tasa de interés moratorio.


        incrementoM     -- Tasa de interés incremental.


    FROM config


    INTO


        vFacnume,


        vIntervalo,


        vDiasG,


        vBodega,


        vCodigoTC,


        vMora,


        vIncrementoM;





    # Obtener el TC de hoy.


    Set vTipoca = ConsultarTipoca(vCodigoTC,date(now()));





    # Obtener los parámetros predeterminados para el cliente.


    SELECT vend,terr,cliprec FROM inclient


    WHERE clicode = pClicode INTO vVend,vTerr,vPrecio;





    # Obtener la primer y la última fecha de las NDs por interés moratorio para este cliente.


    SELECT


        Min(facfech), Max(facfech)


    FROM faencabe


    WHERE clicode = pClicode


    AND facnd < 0


    AND facestado = ''


    AND chequeotar = 'INTERESES MORATORIOS'


    INTO vPrim_fecha, vUlt_fecha;





    # Si no hay ninguna ND por interés moratorio o si el tiempo desde la última ND por Int. Morat hasta hoy


    # considerando los días de gracia y el intervalo de cálculo dicen que ya se debe generar...


    IF vUlt_fecha is null OR


            (vUlt_fecha + INTERVAL vIntervalo + vDiasG DAY) <= DATE(now()) then





        Update config Set ndeb = vFacnume; # ... actualizar el consecutivo








        # ...calcular el monto de la ND


        Case


          When vPrim_fecha is null then


             


             Set vFacmont = pVencido * (vMora/100);





          When vPrim_fecha is not null and vPrim_fecha = vUlt_fecha then


             


             Set vFacmont = pVencido * ((vMora+vIncrementoM)/100);





          When vPrim_fecha is not null and vPrim_fecha < vUlt_fecha then


             


             # ...si el cliente es reincidente entonces se le castigan los meses de la mora.


             Set vNmeses = TIMESTAMPDIFF(MONTH,vPrim_fecha,vUlt_fecha) + 1;


             Set vFacmont = pVencido * ((vIncrementoM*vNmeses+vMora)/100);


        End Case;





            


        # ...insertar el registro de la ND


        INSERT INTO `faencabe`(


            `facnume`,


            `clicode`,


            `chequeotar`,


            `vend`,


            `terr`,


            `facfech`,


            `facplazo`,


            `facmont`,


            `facfepa`,


            `facsald`,


            `facnd`,


            `user`,


            `precio`,


            `facfechac`,


            `codigoTC`,


            `tipoca`)


        VALUES(


            vFacnume,


            pClicode,


            'INTERESES MORATORIOS',


            vVend,


            vTerr,


            now() - INTERVAL 2 DAY, 


            1,


            vFacmont,


            now() - INTERVAL 1 DAY,


            vFacmont,


            vFacnume * -1,


            Trim(user()),


            vPrecio,


            now(),


            vCodigoTC,


            vTipoca);





        # ...insertar el detalle de la ND


        Insert into Fadetall (


             facnume,


             artcode,


             bodega,


             faccant,


             artprec,


             facmont,


             facnd )


        Values (


             vFacnume,


             '_NOINV',  


             vBodega,


             1,


             vFacmont,


             vFacmont,


             vFacnume * -1);








        # ...actualizar el saldo del cliente.


        Update inclient


            Set clisald = clisald + vFacmont


        Where clicode = pClicode;


    End If;








    SET pMensaje = '';


    SET pSuccess = 1;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ImprimirFacturaoND;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ImprimirFacturaoND`(

	IN `pnfacnume` int,

	IN `pnfacnd` int

)
    COMMENT 'Author: Bosco Garita'
BEGIN

	-- Autor: Bosco Garita Azofeifa

  	Declare vcEmpresa  VARCHAR(150);

	Declare vcTelefono varchar(30);

	Declare vcCedulaJu varchar(50);

	Declare vcDireccio varchar(200);

	Declare vcTimbre   varchar(40);

	Declare vnRedond   tinyInt(1);

	Declare vcFactext  varchar(1000);

	Declare vnFacligenerico tinyInt(1); 	-- Bosco agregado 28/05/2013.

	Declare vcClidesc  varchar(50);	  	-- Bosco agregado 28/05/2013.

	

	Set vcEmpresa  = (Select empresa from config);

	Set vcTelefono = (Select Concat('TELÉFONO: ', telefono1) from config);

	Set vcCedulaJu = (Select Concat('CÉDULA JURÍDICA : ', cedulajur) from config);

	Set vcDireccio = (Select Direccion from config);

	Set vnRedond   = (Select redondear from config);

	Set vcFactext  = IfNull((Select factext from fatext where facnume = pnfacnume),'');

	

	# Si se trata de un cliente genérico entonces el nombre hay que tomarlo de

	# la tabla faclientescontado.

	SET vnFacligenerico = (

		SELECT vnFacligenerico

		FROM inclient, faencabe

		Where inclient.clicode = faencabe.clicode 

		and facnume = pnfacnume and facnd = pnfacnd);

	

	If vnFacligenerico = 1 then

		SET vcClidesc = (

			SELECT clidesc

			from faclientescontado 

			Where facnume = pnFacnume and facnd = pnFacnd);

	End if;

	

	-- Agrego los campos (de Hacienda), consecutivo y clave numérica.

	-- Tipo de pago (0 = Desconocido, 1 = Efectivo, 2 = cheque, 3 = tarjeta, 4 = Transferencia)

	Select

		vcEmpresa  as empresa,

		vcTelefono as telefono,

		vcCedulaJu as cedulajur,

		vcDireccio as Direccion,

		monedas.simbolo,

		faencabe.facplazo,

		If(faencabe.facplazo = 0,'CONTADO',Concat('CREDITO A ',Cast(faencabe.facplazo as char(3)),' DIAS')) as condiciones,

		CASE faencabe.factipo

			When 2 then Concat('Cheque # ' ,faencabe.chequeotar,' ',(Select descrip from babanco where idbanco   = faencabe.idbanco)) 

			When 3 then Concat('Tarjeta # ',faencabe.chequeotar,' ',(Select descrip from tarjeta where idtarjeta = faencabe.idtarjeta))

			When 4 then Concat('Transf.#'  ,faencabe.chequeotar,' ',(Select descrip from babanco where idbanco   = faencabe.idbanco))

			Else ''

		End as chequeotar,

		If(vnRedond = 1,Round(fadetall.artprec,0),fadetall.artprec) as artprec,

		If(vnRedond = 1,Round(fadetall.facmont,0),fadetall.facmont) as totalB,

		Cast(If(vnRedond = 1,

		               Round((fadetall.facmont + (fadetall.facmont * fadetall.facpive / 100 ))/fadetall.faccant,0),

		               (fadetall.facmont + (fadetall.facmont * fadetall.facpive / 100 )) / fadetall.faccant) as decimal(14,2)) as facmont,

		Cast(If(vnRedond = 1,

		               Round(fadetall.facmont + (fadetall.facmont * fadetall.facpive / 100 ),0),

		               fadetall.facmont + (fadetall.facmont * fadetall.facpive / 100 )) as decimal(14,2)) as total,

		Cast(If(fadetall.facpive > 0,  If(vnRedond = 1, Round(fadetall.facmont,0), fadetall.facmont), 0) as Decimal(14,2)) as totalGrav, -- Bosco 01/02/2020

		Cast(If(fadetall.facpive <= 0, If(vnRedond = 1, Round(fadetall.facmont,0), fadetall.facmont), 0) as Decimal(14,2)) as totalExen, -- Bosco 01/02/2020

		faencabe.facfech,

		faencabe.clicode,

		If(vnRedond = 1,Round(faencabe.facdesc,0),faencabe.facdesc) as facdesc,

		If(vnRedond = 1,Round(faencabe.facimve,0),faencabe.facimve) as facimve,

		fadetall.facpive,

		fadetall.facpdesc,

		faencabe.facmont as Totalf,

		fadetall.facnume,

		fadetall.faccant,

		If(Trim(inarticu.barcode) = '', inarticu.artcode, inarticu.barcode) as codigo,

		Trim(inarticu.artdesc) as artdesc,

		Trim(If(vnFacligenerico = 1, vcClidesc, inclient.clidesc)) as clidesc,

		inclient.clitel1,

		Trim(inclient.clidir) as clidir,

		Trim(vendedor.nombre) as nombre,

		vcFactext as factext,

		If(faencabe.facnpag >  1,Concat('1er fecha/venc.: ',Dtoc(faencabe.facfech + INTERVAL faencabe.facdpago     DAY)),' ') as PrimerPago,

		If(faencabe.facnpag >= 2,Concat('2da fecha/venc.: ',Dtoc(faencabe.facfech + INTERVAL faencabe.facdpago * 2 DAY)),' ') as SegundoPago,

		If(faencabe.facnpag >= 3,Concat('3ra fecha/venc.: ',Dtoc(faencabe.facfech + INTERVAL faencabe.facdpago * 3 DAY)),' ') as TercerPago,

		faencabe.facnpag,

		faencabe.facmont/faencabe.facnpag as MontoCadaPago,

		vcTimbre as timbre,

		faencabe.facMonExp,

		faencabe.consHacienda,

		faencabe.claveHacienda

	from fadetall

	inner join faencabe on fadetall.facnume = faencabe.facnume and fadetall.facnd = faencabe.facnd

	Inner join inarticu on fadetall.artcode = inarticu.artcode

	Inner join inclient on faencabe.clicode = inclient.clicode

	Inner join vendedor on faencabe.vend    = vendedor.vend

	Inner join monedas  on faencabe.codigoTC = monedas.codigo

	Where fadetall.facnume = pnfacnume and fadetall.facnd = pnfacnd;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ImprimirNotaCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ImprimirNotaCXC`(


  IN `pNotanume` int


)
BEGIN


    # Autor:    Bosco Garita 11/02/2012.


    # Descrip.: Genera la información necesaria para imprimir una nota de crédito.


    


    Declare vcEmpresa  varchar(60);


    Declare vcTelefono varchar(30);


    Declare vcCedulaJu varchar(50);


    Declare vcDireccio varchar(200);


    Declare vcTimbre   varchar(40);


    Declare vnRedond   tinyInt(1);


    


    # Bosco agregado 12/03/2012.


    # Determinar si la nota de crédito aplica sobre facturas de contado.


    Declare vnSobreC   tinyInt(1);


    If Exists(Select 1 from faencabe 


              Where facnume = pNotanume and facnd = ABS(pNotanume)


              and faccsfc = 1) then


        Set vnSobreC = 1;


    End if;


    


    Set vnSobreC = IfNull(vnSobreC,0);


    # Fin Bosco agregado 12/03/2012.





    Set vcEmpresa  = (Select empresa from config);


    Set vcTelefono = (Select Concat('TELÉFONO: ', telefono1) from config);


    Set vcCedulaJu = (Select Concat('CÉDULA JURÍDICA : ', cedulajur) from config);


    Set vcDireccio = (Select Direccion from config);


    


    # Bosco modificado 12/03/2012.


    # Ahora se manda el select a una tabla temporal.


    # Pero también hay que decidir de donde vienen los datos.  Si es una nota de crédito


    # normal los datos vendrán del detalle de notas aplicadas.  Si se trata de una nota


    # de crédito sobre facturas de contado entonces viene del encabezado nada más.





	-- Bosco modificado 17/12/2018


	-- Debido a que la facturación electrónica exige una referencia en las NC


	-- el proceso se modificó en el sistema de manera que las NC sobre contado


	-- también se muestren en la tabla notasd (con saldo cero). Esto hace que


	-- tanto las NC normales como las NC sobre facturas de contado sigan el mismo


	-- proceso de impresión.


    -- If vnSobreC = 0 then


        Create temporary table Notacredito


            Select


                vcEmpresa  as empresa,


                vcTelefono as telefono,


                vcCedulaJu as cedulajur,


                vcDireccio as Direccion,


                notasd.notanume,


                faencabe.facfech,


                faencabe.codigoTC,


                faencabe.facmont,


                faencabe.tipoca,


                monedas.descrip,


                monedas.simbolo,


                faencabe.clicode,


                inclient.clidesc,


                notasd.facnume,


                notasd.facnd,


                If(notasd.facnd = 0, 'Factura','Nota débito') as TipoDoc,


                notasd.monto as MontoAp,


                monedas.simbolo as simboloF,


                inclient.clisald,


                inclient.clisald + ABS(faencabe.facmont) as SaldoAnt,


				If(vnSobreC = 1,'S','N') as SobreContado,	-- Bosco agregado 17/12/2018


				faencabe.claveHacienda,


				faencabe.consHacienda,


				inclient.clitel1,


				inclient.clidir


            From notasd


            Inner Join faencabe on notasd.notanume   = faencabe.facnume


            Inner Join inclient on faencabe.clicode  = inclient.clicode


            Inner Join monedas  on faencabe.codigoTC = monedas.codigo


            Where notasd.notanume = pNotanume and faencabe.facnd = abs(pNotanume);


    /*Else


        Create temporary table Notacredito


            Select


                vcEmpresa  as empresa,


                vcTelefono as telefono,


                vcCedulaJu as cedulajur,


                vcDireccio as Direccion,


                pNotanume as notanume,


                faencabe.facfech,


                faencabe.codigoTC,


                faencabe.facmont,


                faencabe.tipoca,


                monedas.descrip,


                monedas.simbolo,


                faencabe.clicode,


                inclient.clidesc,


                0 as facnume,


                0 as facnd,


                'Factura' as TipoDoc,


                faencabe.facmont as MontoAp,


                monedas.simbolo as simboloF,


                inclient.clisald,


                inclient.clisald + ABS(faencabe.facmont) as SaldoAnt


            From faencabe


            Inner Join inclient on faencabe.clicode  = inclient.clicode


            Inner Join monedas  on faencabe.codigoTC = monedas.codigo


            Where faencabe.facnume = pNotanume and faencabe.facnd = abs(pNotanume);


    End if; */


    


    Select * from Notacredito;


    Drop table Notacredito;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarBodega;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarBodega`(


  IN  `pBodega`   char(3),


  IN  `pDescrip`  varchar(40)


)
BEGIN


  


  


  


  


  





  


  Declare vError tinyInt(1);


  Declare vMensajeErr varchar(200);





  Set pBodega  = IfNull(pBodega,'');


  Set pDescrip = IfNull(pDescrip,'');





  Set vError = If(pBodega = '' or pDescrip = '',1,0);





  If vError then


     Set vMensajeErr = If(pBodega = '',


                         '[BD] Código de bodega incorrecto',


                         '[BD] La descripción no es válida');


  End if;





  If vError = 0 and ConsultarBodega(pBodega) is not null then


    Set vError = 1;


    Set vMensajeErr = '[BD] El registro ya existe';


  End if;





  


  If vError = 0 then


    Insert into bodegas (bodega, descrip)


    values(pBodega, pDescrip);


  End if;





  Select vError as Error, vMensajeErr as MensajeErr;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarCliente;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarCliente`(


	IN  `pClicode`      int(10),


	IN  `pClidesc`      varchar(50),


	IN  `pClidir`       varchar(200),


	IN  `pClitel1`      varchar(11),


	IN  `pClitel2`      varchar(11),


	IN  `pClitel3`      varchar(11),


	IN  `pClifax`       varchar(11),


	IN  `pCliapar`      varchar(10),


	IN  `pClinaci`      tinyint(1),


	IN  `pCliprec`      tinyint(2),


	IN  `pClilimit`     decimal(12,2),


	IN  `pTerr`         tinyint(3),


	IN  `pVend`         tinyint(3),


	IN  `pClasif`       tinyint(2),


	IN  `pCliplaz`      smallint(4),


	IN  `pExento`       tinyint(1),


	IN  `pEncomienda`   tinyint(1),


	IN  `pDirencom`     varchar(200),


	IN  `pFacconiv`     tinyint(1),


	IN  `pClinpag`      tinyint(2),


	IN  `pClicelu`      varchar(11),


	IN  `pCliemail`     varchar(50),


	IN  `pClireor`      tinyint(1),


	IN  `pIgsitcred`    tinyint(1),


	IN  `pCredcerrado`  tinyint(1),


	IN  `pdiatramite`   tinyint(2),


	IN  `pHoratramite`  varchar(5),


	IN  `pDiapago`      tinyint(2),


	IN  `pHorapago`     varchar(5),





	IN  `pmayor`        varchar(3),


	IN  `psub_cta`      varchar(3),


	IN  `psub_sub`      varchar(3),


	IN  `pcolect`       varchar(3),





	IN  `pClicueba`     varchar(20),


	IN  `pCligenerico`  tinyint(1),





	IN  `pidcliente`     varchar(20),


	IN  `pidtipo`     tinyInt(4)


)
BEGIN


  


  If (ConsultarCliente(pClicode) is null) then


    Insert into inclient (


      clicode    ,


      clidesc    ,


      clidir     ,


      clitel1    ,


      clitel2    ,


      clitel3    ,


      clifax     ,


      cliapar    ,


      clinaci    ,


      cliprec    ,


      clilimit   ,


      terr       ,


      vend       ,


      clasif     ,


      cliplaz    ,


      exento     ,


      encomienda ,


      direncom   ,


      facconiv   ,


      clinpag    ,


      clicelu    ,


      cliemail   ,


      clireor    ,


      igsitcred  ,


      credcerrado,


      diatramite ,


      horatramite,


      diapago    ,


      horapago   ,


      


	  mayor,sub_cta,sub_sub,colect,


	  


      clicueba   ,


	  cligenerico,


	  idcliente,


	  idtipo)


    Values (


      pClicode   ,


      pClidesc   ,


      pClidir    ,


      pClitel1   ,


      pClitel2   ,


      pClitel3   ,


      pClifax    ,


      pCliapar   ,


      pClinaci   ,


      pCliprec   ,


      pClilimit  ,


      pTerr      ,


      pVend      ,


      pClasif    ,


      pCliplaz   ,


      pExento    ,


      pEncomienda,


      pDirencom  ,


      pFacconiv  ,


      pClinpag   ,


      pClicelu   ,


      pCliemail  ,


      pClireor   ,


      pIgsitcred ,


      pCredcerrado,


      pdiatramite ,


      pHoratramite,


      pDiapago    ,


      pHorapago   ,


      


	  pMayor,pSub_cta,pSub_sub,pColect,


	  


      pClicueba   ,


	  pCligenerico,


	  pIDcliente,


	  pidtipo);


  Else


    Select '[BD] El registro ya existe';


  End if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDetalleDocInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDetalleDocInv`(


  IN  `pMovdocu`    varchar(10), 


  IN  `pMovtimo`    char(20),


  IN  `pArtcode`    varchar(20),


  IN  `pBodega`     varchar(3),


  IN  `pProcode`    varchar(15),


  IN  `pMovcant`    decimal(12,4),


  IN  `pMovcoun`    decimal(16,6),


  IN  `pArtcosfob`  decimal(14,4),


  IN  `pArtprec`    decimal(12,2),


  IN  `pFacimve`    decimal(12,2),


  IN  `pFacdesc`    decimal(12,2),


  IN  `pMovtido`    smallint(3),


  IN  `pCentroc`    char(3),


  IN  `pFechaven`   date


)
BEGIN


	# Autor: Bosco Garita Azofeifa





	-- Bosco modificado 30/12/2013


	-- Si la configuración indica actualizar el proveedor default entonces


	-- agrego esta característica después de insertar el registro.


	Declare vAsignarprovaut tinyInt(1);


	Select asignarprovaut from config into vAsignarprovaut;





	-- Ver la configuración


	Insert into inmovimd (


		Movdocu,


		Movtimo,


		Artcode,


		Bodega ,


		Procode,


		Movcant,


		Movcoun,


		Artcosfob,


		Artprec,


		Facimve,


		Facdesc,


		Movtido,


		Centroc,


		Fechaven )


	Values (


		pMovdocu,


		pMovtimo,


		pArtcode,


		pBodega ,


		pProcode,


		pMovcant,


		pMovcoun,


		pArtcosfob,


		pArtprec,


		pFacimve,


		pFacdesc,


		pMovtido,


		pCentroc,


		pFechaven );





	-- Si la configuración indica, asignar proveedor automáticamente.


	if vAsignarprovaut = 1 and 


			Exists(Select procode from inproved Where procode = pProcode) then


		Update inarticu


			Set procode = 


				If(pMovcoun < artcost and pProcode <> procode, pProcode, procode)


		Where artcode = pArtcode;


	End if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDetalleNCCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDetalleNCCXC`(


  IN  `pNotanume`  int,


  IN  `pFacnume`   int,


  IN  `pFacnd`     int,


  IN  `pMonto`     decimal(12,2),


  IN  `pFacsald`   decimal(12,2)


)
BEGIN





  Declare vError tinyInt;


  Declare vErrorMesage varchar(500);


  Declare vFacsald Decimal(12,2);


  Declare vFacestado char(1);





  Set vError = 0;


  Set vErrorMesage = '';





  


  Set pNotanume = If(pNotanume > 0, pNotanume * -1, pNotanume);





  


  Set vFacsald   = (Select facsald From faencabe where facnume = pFacnume and facnd = pFacnd);


  Set vFacestado = (Select facestado From faencabe where facnume = pFacnume and facnd = pFacnd);





  If vFacestado <> '' then


      Set vError = 1;


      Set vErrorMesage = Concat('[DB] La factura/ND # ',pFacnume, '  Está anulada.');


  End if;





  If vError = 0 and vFacsald <> pFacsald then


      Set vError = 1;


      Set vErrorMesage =


        Concat('[DB] La factura/ND # ',pFacnume, '  ya no tiene el mismo saldo. Este es ahora ', vFacsald);


  End if;





  


  If vError = 0 then


      Insert into notasd(


        notanume,


        facnume,


        facnd,


        monto,


        user,


        fechaAp)


      Values(


        pNotanume,


        pFacnume,


        pFacnd,


        pMonto,


        user(),


        now());


  End if;





  


  Update faencabe Set


    facsald = facsald - pMonto


  Where facnume = pFacnume and facnd = pFacnd;





  


  If Row_count() <> 1 then


     Set vError = 1;


     Set vErrorMesage = Concat('[DB]Se produjo un error al intentar aplicar la factura # ',


         pFacnume, '. Se espera afectar 1 registro y se afectó ', Row_count());


  End if;





  If vError = 0 then


    


    Update faencabe Set


      facsald = facsald + pMonto


    Where facnume = pNotanume and facnd = Abs(pNotanume);





    


    If Row_count() <> 1 then


       Set vError = 1;


       Set vErrorMesage =


         Concat('[DB]Se produjo un error al intentar aplicar la nota',


         pNotanume, '. Se espera afectar 1 registro y se afectó ', Row_count());


    End if;


  End if;





  


  Select vError as vError,vErrorMesage as vErrorMesage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDetalleNDCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDetalleNDCXP`(


  IN  `pNotanume`  varchar(10),


  IN  `pFactura`   varchar(10),


  IN  `pTipo`      varchar(3),


  IN  `pMonto`     decimal(12,2),


  IN  `pSaldo`     decimal(12,2),


  IN  `pFecha`     datetime,


  IN  `pProcode`   varchar(15)


)
BEGIN


  # Autor:  Bosco Garita 05/05/2012.


  # Objet:  Guardar el detalle de aplicación de una nota de débito de cuentas por pagar.


  #         Devuelve un ResultSet indicando si hubo error y caso de haberlo el mensaje de error.


  #         Hasta hoy no se guardan registros anulados en la tabla de cxpfacturas y por lo tanto 


  #         no se hace ninguna revisión.


  


  Declare vError tinyInt;


  Declare vErrorMesage varchar(500);


  Declare vSaldo Decimal(12,2); -- Saldo de la factura o nota de cr_dito.


  Declare vNotaTipo varchar(3);


  Declare vRegistros int;		-- Número de registros afectados.





  Set vError = 0;


  Set vErrorMesage = '';


  Set vNotaTipo = 'NDB';


  


  # Validar el saldo de la factura o nota de crédito que se afectar_.


  Set vSaldo = (Select saldo From cxpfacturas where factura = pFactura and tipo = pTipo);


  


  If vSaldo <> pSaldo then


      Set vError = 1;


      Set vErrorMesage =


        Concat('[DB] La factura/NC # ',pFactura, '  ya no tiene el mismo saldo. Este es ahora ', vSaldo);


  End if;





  # Insertar el registro en la tabla de detalle de notas aplicadas.


  If vError = 0 then


      Insert into cxpnotasd(


        Notanume,


        factura,


        tipo,


        monto,


        user,


        fechaAp,


        NotaTipo,


		procode)	-- Se usa para identificar la llave en facturas


      Values(


        pNotanume,


        pFactura,


        pTipo,


        pMonto,


        user(),


        now(),


        vNotaTipo,


		pProcode);


  End if;


  # No se hace una revisión para determinar si se insertó o no porque si no se inserta es porque


  # ocurrió un error y de ser así la ejecución no continúa.


  





  # Actualizar la factura.


  Update cxpfacturas Set


    saldo = saldo - pMonto,


    abono_acum = abono_acum + pMonto,


    fec_ult_ab = If(fec_ult_ab is null or Date(fec_ult_ab) < Date(pFecha), Date(pFecha),fec_ult_ab)


  Where factura = pFactura and tipo = pTipo and procode = pProcode;





  Set vRegistros = Row_count();





  # Verificar si el registro fue afectado o no.


  If vRegistros <> 1 then


     Set vError = 1;


     Set vErrorMesage = Concat('[DB]Se produjo un error al intentar aplicar la factura (NC) N. ',


         pFactura, '. Se espera afectar 1 registro y se afectó ', vRegistros);


  End if;





  If vError = 0 then


    # Actualizar la nota de débito.


    Update cxpfacturas Set


      saldo = saldo + pMonto


    Where factura = pNotanume and tipo = vNotaTipo and procode = pProcode;





	Set vRegistros = Row_count();





    # Verificar si el registro fue afectado o no.


    If vRegistros <> 1 then


       Set vError = 1;


       Set vErrorMesage =


         Concat('[DB] Se produjo un error al intentar aplicar la nota N. ',


         pNotanume, '. Se espera afectar 1 registro y se afectó ', vRegistros);


    End if;


  End if;





  # Enviar al cliente el resultado de la corrida.


  Select vError as vError,vErrorMesage as vErrorMesage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDetalleReciboCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDetalleReciboCXC`(


  IN  `pRecnume`  int,


  IN  `pFacnume`  int,


  IN  `pFacnd`    int,


  IN  `pMonto`    double,


  IN  `pFacsald`  double


)
BEGIN





    Declare vError tinyInt;


    Declare vErrorMesage varchar(500);


    Declare vFacsald Double;


    Declare vFacestado char(1);





    Set vError = 0;


    Set vErrorMesage = '';


    


    -- Depuración 21/08/2011


    -- If pFacsald - pMonto <> 0 then


--         Set vError = 1;


--         Set vErrorMesage =  Concat('El saldo queda negativo ',pFacsald - pMonto);


--     End if;





    Select facsald, facestado From faencabe where facnume = pFacnume and facnd = pFacnd Into vFacsald, vFacestado;





    If vFacestado <> '' then


        Set vError = 1;


        Set vErrorMesage = Concat('[BD] La factura/ND # ',pFacnume, '  Está anulada.');


    End if;


    


    


    # Bosco modificado 20/03/2011


    #If vError = 0 and vFacsald <> pFacsald then 


    If vError = 0 and vFacsald <> pFacsald and Abs(vFacsald - pFacsald) > 0.009 then


        Set vError = 1;


        Set vErrorMesage =


            Concat('[BD] La factura/ND # ',pFacnume, 


                   '  ya no tiene el mismo saldo. Este es ahora ', 


                   vFacsald, ' y viene ', pFacsald, ' (Dif ',Abs(vFacsald - pFacsald), ')');


    End if;








    If vError = 0 then


        Insert into pagosd(


            recnume,


            facnume,


            facnd,


            monto)


        Values(


            pRecnume,


            pFacnume,


            pFacnd,


            pMonto);


    End if;








    Update faencabe Set


    facsald = facsald - pMonto


    Where facnume = pFacnume and facnd = pFacnd;








    If Row_count() <> 1 then


        Set vError = 1;


        Set vErrorMesage = Concat('Se produjo un error al intentar aplicar la factura # ',


            pFacnume, '. Se espera afectar 1 registro y se afectó ', Row_count());


    End if;





    Select vError as vError,vErrorMesage as vErrorMesage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDetalleReciboCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDetalleReciboCXP`(

  IN  `pRecnume`  int,

  IN  `pFactura`  varchar(10),

  IN  `pTipo`     varchar(3),

  IN  `pMonto`    double,

  IN  `pSaldo`    double,

  IN  `pFecha`    datetime,

  IN  `pProcode`  varchar(15)

)
BEGIN

    Declare vError tinyInt;

    Declare vErrorMessage varchar(500);

    Declare vSaldo Double;



    # Este SP siempre devolver_ un Select con el resultado de la corrida.

    # Si hubo error la variable vError valdr_ 1 y vErrorMessage tendrá la descripción

    # del error.



    Set vError = 0;

    Set vErrorMessage = '';



    -- Select * From cxpfacturas 

	-- where factura = pfactura and tipo = pTipo ;



    # Determinar si el saldo de la factura es el mismo que viene por par_metro.

	Select saldo From cxpfacturas 

	where factura = pfactura and tipo = pTipo and procode = pProcode

	Into vSaldo;



    # Se usa 0.009 como rango de tolerancia fijo pero habr_ que ponerlo en una

    # tabla de par_metros.

    If vSaldo <> pSaldo and Abs(vSaldo - pSaldo) > 0.009 then

        Set vError = 1;

        Set vErrorMessage =

            Concat('[BD] La factura/NC # ',pFactura, 

                   '  ya no tiene el mismo saldo. Este es ahora ', 

                   vSaldo, ' y viene ', pSaldo, ' (Dif ',Abs(vSaldo - pSaldo), ')');

    End if;



    # Agregar el registro en el detalle de recibos.

    If vError = 0 then

        Insert into cxppagd(

            recnume,

            factura,

            tipo,

            monto)

        Values(

            pRecnume,

            pFactura,

            pTipo,

            pMonto);

    End if;



   # Actualizar el registro en cxpfacturas.

    Update cxpfacturas Set

      saldo = saldo - pMonto,

      abono_acum = abono_acum + pMonto,

      fec_ult_ab = If(fec_ult_ab is null or Date(fec_ult_ab) < Date(pFecha), Date(pFecha),fec_ult_ab)

    Where factura = pFactura and tipo = pTipo and procode = pProcode;



    # Si no se afect_ ning_n registro...

    If Row_count() <> 1 then

        # ... seteo el error.

        Set vError = 1;

        Set vErrorMessage = 

            Concat('[BD] Se produjo un error al intentar aplicar la factura # ',

            pFactura, '. Se espera afectar 1 registro y se afectó ', Row_count());

    End if;



    Select vError as vError,vErrorMessage as vErrorMessage;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDocInvDesdeFact;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDocInvDesdeFact`(


  IN `pFacnume` int(10)


)
BEGIN





  


  Declare vContinuar tinyint(1);


  Declare vMensajeEr varchar(500);





  Set vContinuar = 1;


  Set vMensajeEr = '';








  If (vContinuar = 1 and ConsultarDocumento(pFacnume, 'S', 5) = 1) then


      Set vContinuar = 0;


      Set vMensajeEr = Concat('[BD] La factura # ',pFacnume, ' ya existe en inventarios.');


  End if;








  If vContinuar = 1 then


    Insert into inmovime (


      movdocu  ,


      movtimo  ,


      movorco  ,


      Movdesc  ,


      movfech  ,


      tipoca   ,


      user     ,


      movtido  ,


      movsolic ,


      movfechac,


      codigoTC  )


    Select


      Trim(Cast(faencabe.facnume as char(10))) as movdocu,


      'S'       as movtimo,


      'FACTURA' as movorco,


      Concat('Facturación -- ',dtoc(facfech)) as movdesc,


      facfech   as movfech,


      tipoca,


      user,


      8         as movtido,


      ' '       as movsolic,


      now(),


      codigoTC


    From faencabe


    Where facnume = pFacnume and facnd = 0;





    If Row_count() = 0 then


       Set vContinuar = 0;


       Set vMensajeEr = '[BD] No se pudo crear el encabezado del documento';


    End if;


  End if;





  If vContinuar = 1 then


     Insert into inmovimd (


            movdocu,


            movtimo,


            artcode,


            bodega,


            movcant,


            movcoun,


            artprec,


            facimve,


            facdesc,


            movtido)


       Select


            Trim(Cast(facnume as char(10))) as movdocu,


            'S' as movtimo,


            artcode,


            bodega,


            faccant as movcant,


            artcosp as movcoun,


            artprec,


            facimve,


            facdesc,


            8 as movtido


       From fadetall


       Where facnume = pFacnume and facnd = 0;





     If Row_count() = 0 then


        Set vContinuar = 0;


        Set vMensajeEr = '[BD] No se pudo crear el detalle del documento';


     End if;


  End if;





  Select vContinuar,vMensajeEr;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarDocInvDesdeNC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarDocInvDesdeNC`(


  IN `pFacnume` int(10)


)
BEGIN


  


  


  Declare vContinuar tinyint(1);


  Declare vMensajeEr varchar(500);





  Set vContinuar = 1;


  Set vMensajeEr = '';





  


  If pFacnume > 0 then


      Set pFacnume = pFacnume * -1;


  End if;








  If (vContinuar = 1 and ConsultarDocumento(pFacnume, 'E', 6) = 1) then


      Set vContinuar = 0;


      Set vMensajeEr = Concat('[BD] La NC # ',pFacnume, ' ya existe en inventarios.');


  End if;








  If vContinuar = 1 then


    Insert into inmovime (


      movdocu  ,


      movtimo  ,


      movorco  ,


      Movdesc  ,


      movfech  ,


      tipoca   ,


      user     ,


      movtido  ,


      movsolic ,


      movfechac,


      codigoTC  )


    Select


      Trim(Cast(Abs(facnume) as char(10))) as movdocu,


      'E'     as movtimo,


      'NC'    as movorco,


      Concat('Notas de crédito -- ',dtoc(facfech)) as movdesc,


      facfech as movfech,


      tipoca,


      user,


      4       as movtido,


      ' '     as movsolic,


      now(),


      codigoTC


    From faencabe


    Where facnume = pFacnume and facnd > 0;








    If Row_count() = 0 then


       Set vContinuar = 0;


       Set vMensajeEr = '[BD] No se pudo crear el encabezado del documento';


    End if;


  End if;





  If vContinuar = 1 then


    Insert into inmovimd (


           movdocu,


           movtimo,


           artcode,


           bodega,


           movcant,


           movcoun,


           artprec,


           facimve,


           facdesc,


           movtido)


      Select


           Trim(Cast(Abs(facnume) as char(10))) as movdocu,


           'E' as movtimo,


           artcode,


           bodega,


           Abs(faccant) as movcant,


           Abs(artcosp) as movcoun,


           Abs(artprec),


           Abs(facimve),


           Abs(facdesc),


           4 as movtido


      From fadetall


      Where facnume = pFacnume and facnd > 0;





      If Row_count() = 0 then


         Set vContinuar = 0;


         Set vMensajeEr = '[BD] No se pudo crear el detalle del documento';


      End if;


    End if;





  Select vContinuar,vMensajeEr;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarEncabezadoDocInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEncabezadoDocInv`(


  IN  `pMovdocu`   varchar(10),


  IN  `pMovtimo`   char(20),


  IN  `pMovorco`   varchar(10),


  IN  `pMovdesc`   varchar(150),


  IN  `pMovfech`   date,


  IN  `pTipoca`    float,


  IN  `pMovtido`   smallint(3),


  IN  `pMovsolic`  varchar(30),


  IN  `pCodigoTC`  varchar(3)


)
BEGIN


  Declare vContinuar tinyint(1);





  Set vContinuar = 1;





  


  If (PermitirFecha(pMovfech) = 0) then


      Set vContinuar = 0;


  End if;





  


  If (vContinuar = 1 and ConsultarDocumento(pMovdocu, pMovtimo, pMovtido) = 1) then


      Set vContinuar = 0;


  End if;





  If vContinuar = 1 then


    Insert into inmovime (


      movdocu  ,


      movtimo  ,


      movorco  ,


      Movdesc  ,


      movfech  ,


      tipoca   ,


      user     ,


      movtido  ,


      movsolic ,


      movfechac,


      codigoTC  )


    Values (


      pMovdocu ,


      pMovtimo ,


      pmovorco ,


      pMovdesc ,


      pMovfech ,


      pTipoca  ,


      Trim(user()),


      pMovtido ,


      pMovsolic,


      now()    ,


      pCodigoTC );


  End if;


	


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarEncabezadoFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEncabezadoFactura`(

	IN `pFacnume` int(10),

	IN `pClicode` int(10),

	IN `pVend` tinyint(3),

	IN `pTerr` tinyint(3),

	IN `pFacfech` datetime,

	IN `pFacplazo` tinyint(3),

	IN `pPrecio` tinyint(3)

)
BEGIN



	-- Autor: Bosco Garita Azofeifa



	Declare vUser     varchar(40); 

	Declare vCodigoTC char(3);     

	Declare vTipoca   float;       

	Declare vFacfepa  datetime;    





	Set pVend     = IfNull(pVend,(Select vend from inclient where clicode = pClicode));

	Set pTerr     = IfNull(pTerr,(Select terr from inclient where clicode = pClicode));

	Set pFacfech  = IfNull(pFacfech,now());

	Set pPrecio   = IfNull(pPrecio,(Select cliprec from inclient where clicode = pClicode));

	Set pFacplazo = IfNull(pFacplazo,(Select cliplaz from inclient where clicode = pClicode));



	Set vFacfepa  = AddDate(pFacfech, interval pFacplazo day);

	Set vUser     = Trim(user());

	Set vCodigoTC = (Select CodigoTC from config);

	Set vTipoca   = ConsultarTipoca(vCodigoTC,pFacfech);



	if vTipoca is null then

		Set vTipoca = 1;

	End if;



	Insert into wrk_faencabe (

		facnume,

		clicode,

		vend,

		terr,

		facfech,

		facplazo,

		precio,

		user,

		codigoTC,

		tipoca,

		facfepa,

		facfechaC,

		facestado) 

	Values (

		pFacnume,

		pClicode,

		pVend,

		pTerr,

		pFacfech,

		pFacplazo,

		pPrecio,

		vUser,

		vCodigoTC,

		vTipoca,

		vFacfepa,

		now(),

		'');

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarEncabezadoNC_CXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEncabezadoNC_CXC`(

	IN `pFacnume` int(10),

	IN `pClicode` int(10),

	IN `pVend` tinyint(3),

	IN `pTerr` tinyint(3),

	IN `pFacfech` datetime,

	IN `pFacplazo` tinyint(3),

	IN `pPrecio` tinyint(3)

)
BEGIN

  Declare vUser     varchar(40); 

  Declare vCodigoTC char(3);     

  Declare vTipoca   float;       

  Declare vFacfepa  datetime;    



  If pFacnume > 0 then

    Set pFacnume = (pFacnume * -1);

  End if;



  Set pVend     = IfNull(pVend,(Select vend from inclient where clicode = pClicode));

  Set pTerr     = IfNull(pTerr,(Select terr from inclient where clicode = pClicode));

  Set pFacfech  = IfNull(pFacfech,now());

  Set pPrecio   = IfNull(pPrecio,(Select cliprec from inclient where clicode = pClicode));

  Set pFacplazo = IfNull(pFacplazo,(Select cliplaz from inclient where clicode = pClicode));

  Set vFacfepa  = AddDate(pFacfech, interval pFacplazo day);

  Set vUser     = Trim(user());

  Set vCodigoTC = (Select CodigoTC from config);

  Set vTipoca   = ConsultarTipoca(vCodigoTC,curdate());



  Insert into wrk_faencabe (

    facnume,

    clicode,

    vend,

    terr,

    facfech,

    facplazo,

    precio,

    facestado,

    user,

    codigoTC,

    tipoca,

    facfepa,

    facfechaC,

    facnd)

  Values (

    pFacnume,

    pClicode,

    pVend,

    pTerr,

    pFacfech,

    pFacplazo,

    pPrecio,

    ' ',

    vUser,

    vCodigoTC,

    vTipoca,

    vFacfepa,

    now(),

    pFacnume * -1);

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarEncabezadoOrdenC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEncabezadoOrdenC`(


  IN  `pMovorco`   varchar(10),


  IN  `pMovdesc`   varchar(150),


  IN  `pMovfech`   date,


  IN  `pTipoca`    float,


  IN  `pMovtido`   smallint(3),


  IN  `pCodigoTC`  varchar(3),


  IN  `pProcode`   varchar(15)


)
BEGIN


	Declare vContinuar tinyint(1);





	Set vContinuar = 1;





  


	If (PermitirFecha(pMovfech) = 0) then


		Set vContinuar = 0;


	End if;





	-- Validar si el documento ya existe.


	If (Select count(movorco) from comOrdenCompraE Where movorco = pMovorco) > 0 then


		Set vContinuar = 0;


	End if;





	If vContinuar = 1 then


		Insert into comOrdenCompraE (


			movorco  ,


			Movdesc  ,


			movfech  ,


			tipoca   ,


			user     ,


			movtido  ,


			movfechac,


			codigoTC,


			procode )


		Values (


			pMovorco ,


			pMovdesc ,


			pMovfech ,


			pTipoca  ,


			Trim(user()),


			pMovtido ,


			now()    ,


			pCodigoTC,


			pProcode );


	End if;


	


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarEncabezadoPedido;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEncabezadoPedido`(


  IN  `pFacnume`  int(10),


  IN  `pClicode`  int(10)


)
BEGIN


  


  Declare vVend     tinyint(3);  


  Declare vTerr     tinyInt(3);  


  Declare vFacfech  datetime;    


  Declare vFacplazo tinyint(3);  


  Declare vPrecio   tinyint(3);  


  Declare vUser     varchar(40); 


  Declare vFacivi   tinyint(1);  





  Set vVend     = (Select vend    from inclient where clicode = pClicode);


  Set vTerr     = (Select terr    from inclient where clicode = pClicode);


  Set vFacfech  = now();


  Set vPrecio   = (Select cliprec from inclient where clicode = pClicode);


  Set vFacplazo = (Select cliplaz from inclient where clicode = pClicode);





  Set vUser     = Trim(user());


  Set vFacivi   = (Select usarivi from config);





  


  Insert into pedidoe (


    facnume,


    clicode,


    vend,


    terr,


    facfech,


    facplazo,


    precio,


    user,


    facivi)


  Values (


    pFacnume,


    pClicode,


    vVend,


    vTerr,


    vFacfech,


    vFacplazo,


    vPrecio,


    vUser,


    vFacivi);





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarNDCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarNDCXC`(


  IN  `pfacnume`     int(10),


  IN  `pclicode`     int(10),


  IN  `pfacfech`     datetime,


  IN  `pfacmont`     double,


  IN  `pReferencia`  varchar(10),


  IN  `pcodigoTC`    char(3),


  IN  `ptipoca`      float,


  IN  `pOrdenc`  	 varchar(10) -- Bosco agregado 26/09/2018


)
BEGIN


  


  -- Autor: Bosco Garita Azofeifa


  Declare vHayError tinyInt(1);


  Declare vMensaje  varchar(200);


  Declare vVend     tinyint(3);


  Declare vTerr     tinyint(3);


  Declare vBodega   char(3);





  Set vHayError = 0;


  Set vMensaje  = '';





  


  If Exists(Select facnume from faencabe Where facnume = pFacnume and facnd = (pFacnume * -1)) then


     Set vHayError = 1;


     Set vMensaje  = '[BD] Nota de débito ya existe.';


  End if;





  


  If not Exists(Select artcode from inarticu Where artcode = '_NOINV') THEN


     Set vHayError = 1;


     Set vMensaje  = '[BD] El artículo _NOINV debe estar creado.';


  End if;





  If vHayError = 0 then


     Set vVend   = (Select vend from inclient Where clicode = pClicode);


     Set vTerr   = (Select terr from inclient Where clicode = pClicode);


     Set vBodega = (Select bodega from config);  








     INSERT INTO faencabe (


        facnume,


        clicode,


        vend,


        terr,


        facfech,


        facplazo,


        facmont,


        facfepa,


        facsald,


        facnd,


        user,


        referencia,


        precio,


        facfechac,


        codigoTC,


        tipoca,


		ordenc)


    VALUES (


        pfacnume,


        pclicode,


        vVend,


        vTerr,


        pfacfech,


        1,          


        pfacmont,


        pfacfech,   


        pfacmont,   


        (pfacnume * -1),  


        Trim(user()),


        preferencia,


        1,          


        Now(),


        pcodigoTC,


        ptipoca,


		pOrdenc);





    If Row_Count() <= 0 then


       Set vHayError = 1;


       Set vMensaje  = '[BD] No se pudo guardar el encabezado de la ND';


    End if;





    If vHayError = 0 then


       Insert into fadetall (


         facnume,


         artcode,


         bodega,


         faccant,


         artprec,


         facmont,


         facnd )


       Values (


         pfacnume,


         '_NOINV',  


         vBodega,


         1,


         pfacmont,


         pfacmont,


         pfacnume * -1);





       If Row_Count() <= 0 then


          Set vHayError = 1;


          Set vMensaje  = '[BD] No se pudo guardar el detalle de la ND';


       End if;


    End if;


  end if;





  Select vHayError as vHayError, vMensaje as vMensaje;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarPagareCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPagareCXC`(


  IN  `pPagare`         int(10),


  IN  `pClicode`        int(10),


  IN  `pMonto`          double,


  IN  `pEmision`        datetime,


  IN  `pVencimiento`    datetime,


  IN  `pCodigoTC`       varchar(3),


  IN  `pTipoca`         float,


  IN  `pObservaciones`  varchar(1000)


)
BEGIN


  


  


  


  


  


  


  


  Declare vError   tinyInt(1);


  Declare vMensaje varchar(100);


  Declare vPagare  Int;





  Set vError = 0;


  Set vMensaje = '';





  


  


  If Exists(Select clicode from PagaresCXC Where Pagare = pPagare) then


    Set vError = 1;


    Set vMensaje = '[BD] El pagaré ya existe';


  End if;





  


  If vError = 0 and not Exists(Select codigo


                             from monedas


                             Where codigo = pCodigoTC) then


    Set vError = 1;


    Set vMensaje = '[BD] La moneda no es válida';


  End if;





  


  Set vPagare = SiguientePagareCXC();





  If vError = 0 and pPagare <> vPagare then


    Set vError = 1;


    Set vMensaje = Concat(


      '[BD] El consecutivo es incorrecto, debería ser ',


      Trim(Cast(vPagare as character)));


  End if;





  If vError = 0 then


    Insert into PagaresCXC(


      Pagare,


      Clicode,


      Monto,


      Emision,


      Vencimiento,


      Observaciones,


      CodigoTC,


      Tipoca,


      FechaReg)


    Values(


      pPagare,


      pClicode,


      pMonto,


      pEmision,


      pVencimiento,


      pObservaciones,


      pCodigoTC,


      pTipoca,


      now());


  End if;





  


  Select vError as Error, vMensaje as MensajeErr;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarPagoCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPagoCXC`(


  IN  `pRecnume`   int(10),


  IN  `pClicode`   int(10),


  IN  `pFecha`     datetime,


  IN  `pConcepto`  varchar(80),


  IN  `pMonto`     double,


  IN  `pCheque`    varchar(12),


  IN  `pBanco`     varchar(45),


  IN  `pCodigoTC`  varchar(3),


  IN  `pTipoca`    float


)
BEGIN


  





  Declare vHayError tinyInt(1);


  Declare vMensaje  varchar(200);





  Set vHayError = 0;


  Set vMensaje  = '';





  


  If Exists(Select recnume from pagos Where recnume = pRecnume) then


     Set vHayError = 1;


     Set vMensaje  = '[BD] Recibo ya existe.';


  End if;





  If vHayError = 0 then





     INSERT INTO pagos (


        recnume,


        clicode,


        fecha,


        concepto,


        monto,


        estado,


        user,


        cheque,


        banco,


        fechaC,


        codigoTC,


        tipoca)


    VALUES (


        pRecnume,


        pClicode,


        pFecha,


        pConcepto,


        pMonto,


        ' ',        


        Trim(user()),


        pCheque,


        pBanco,


        Now(),


        pCodigoTC,


        pTipoca);





    If Row_Count() <= 0 then


       Set vHayError = 1;


       Set vMensaje  = '[BD] No se pudo guardar el encabezado del recibo';


    End if;





  end if;





  Select vHayError as vHayError, vMensaje as vMensaje;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarPagoCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPagoCXP`(


  IN  `pRecnume`   int(10),


  IN  `pProcode`   varchar(15),


  IN  `pFecha`     datetime,


  IN  `pConcepto`  varchar(80),


  IN  `pMonto`     double,


  IN  `pCheque`    varchar(12),


  IN  `pCodigoTC`  varchar(3),


  IN  `pTipoca`    float


)
BEGIN


    # Autor     Bosco Garita 28/04/2012.


    # Objetivo  Insertar el encabezado de un recibo de cuentas por pagar.


    #           Este SP siempre devolverá un RS con el resultado de la corrida:


    #           Select vHayError as vHayError, vMensaje as vMensaje


    #           Si vHayError vale 1 vMensaje dirá lo sucedido.


    


    Declare vHayError tinyInt(1);


    Declare vMensaje  varchar(200);





    Set vHayError = 0;


    Set vMensaje  = '';





    If Exists(Select recnume from cxppage Where recnume = pRecnume) then


     Set vHayError = 1;


     Set vMensaje  = '[BD] Recibo ya existe.';


    End if;





    If vHayError = 0 then





     INSERT INTO cxppage (


        recnume,


        procode,


        fecha,


        concepto,


        monto,


        estado,


        user,


        cheque,


        fechaC,


        codigoTC,


        tipoca)


    VALUES (


        pRecnume,


        pProcode,


        pFecha,


        pConcepto,


        pMonto,


        ' ',        


        Trim(user()),


        pCheque,


        Now(),


        pCodigoTC,


        pTipoca);





    If Row_Count() <= 0 then


       Set vHayError = 1;


       Set vMensaje  = '[BD] No se pudo guardar el encabezado del recibo';


    End if;





    end if;





    Select vHayError as vHayError, vMensaje as vMensaje;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarProveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarProveedor`(


	IN  `pProcode`   varchar(15),


	IN  `pProdesc`   varchar(40),


	IN  `pProdir`    varchar(200),


	IN  `pProtel1`   varchar(11),


	IN  `pProtel2`   varchar(11),


	IN  `pProfax`    varchar(11),


	IN  `pProapar`   varchar(15),


	IN  `pPronac`    tinyint(1),


	IN  `pProplaz`   smallint(5),


	-- IN  `pProcueco`  varchar(12), Bosco modificado 02/09/2013


	IN  `pmayor`        varchar(3),


	IN  `psub_cta`      varchar(3),


	IN  `psub_sub`      varchar(3),


	IN  `pcolect`       varchar(3),


	-- Fin Bosco modificado 02/09/2013


	IN  `pProcueba`  	varchar(12),


	IN  `pEmail`       	varchar(50),


	IN  `pProvincia`       	int,


	IN  `pCanton`  			int,


	IN  `pDistrito`       	int,


	IN  `pIdProv`       	varchar(20),


	IN  `pIdTipo`       	int


)
BEGIN


	-- Bosco modificado 22/06/2019, agrego el campo email.


	If (ConsultarProveedor(pProcode) is null) then


		Insert into inproved (


			Procode ,


			Prodesc ,


			Prodir  ,


			Protel1 ,


			Protel2 ,


			Profax  ,


			Proapar ,


			Pronac  ,


			Proplaz ,


			-- Procueco,


			mayor,


			sub_cta,


			sub_sub,


			colect,


			Procueba,


			email,


			provincia,


			canton,


			distrito,


			idProv,


			idTipo)


		Values (


			pProcode ,


			pProdesc ,


			pProdir  ,


			pProtel1 ,


			pProtel2 ,


			pProfax  ,


			pProapar ,


			pPronac  ,


			pProplaz ,


			-- pProcueco,


			pMayor,


			pSub_cta,


			pSub_sub,


			pColect,


			pProcueba,


			pEmail,


			pProvincia,


			pCanton,


			pDistrito,


			pIdProv,


			pIdTipo);


	Else


		Select '[BD] El registro ya existe';


	End if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS InsertarUsuario;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarUsuario`(


  IN  `pUser`          char(16),


  IN  `pNivel`         smallint(5),


  IN  `pN1`            tinyint(1),


  IN  `pN2`            tinyint(1),


  IN  `pN3`            tinyint(1),


  IN  `pFacturas`      tinyint(1),


  IN  `pN5`            tinyint(1),


  IN  `pN6`            tinyint(1),


  IN  `pN7`            tinyint(1),


  IN  `pN8`            tinyint(1),


  IN  `pN9`            tinyint(1),


  IN  `pPrecios`       tinyint(1),


  IN  `pDevoluciones`  tinyint(1),


  IN  `pDescuentos`    tinyint(1),


  IN  `pMaxDesc`       decimal,


  IN  `pNotifCompra`   tinyint(1),


  IN  `pIntervalo1`    smallInt,   -- Bosco agregado 28/07/2013


  IN  `pNotifFactcxc`  tinyint(1), -- Bosco agregado 28/07/2013


  IN  `pIntervalo2`    smallInt,   -- Bosco agregado 28/07/2013


  IN  `pNotifFactcxp`  tinyint(1), -- Bosco agregado 28/07/2013


  IN  `pIntervalo3`    smallInt,   -- Bosco agregado 28/07/2013


  IN  `pNotifxmlfe`    tinyint(1), -- Bosco agregado 23/12/2018


  IN  `pIntervalo4`    smallInt,   -- Bosco agregado 23/12/2018


  IN  `pActivo`        char(1),


  IN  `pUltimaClave`   datetime,


  IN  `pFirmas`        tinyint(1)


)
BEGIN


    Declare vExisteEnBD tinyint(1);


    Declare vExisteEnOSAIS tinyint(1);


    Declare vMensaje varchar(40);





    Set vExisteEnBD    = Exists(Select 1 from vistausuarios where user = pUser);


    Set vExisteEnOSAIS = Exists(Select 1 from usuario where user = pUser);





    If not vExisteEnBD then


       Set vMensaje = '[BD] Usuario no existe en MySQL';


    Else


       if vExisteEnOSAIS then


          Set vMensaje = '[BD] Usuario ya existe';


       End if;


    End if;








    If vMensaje is null then


       Insert into usuario (


          User,


          Nivel,


          N1,


          N2,


          N3,


          Facturas,


          N5,


          N6,


          N7,


          N8,


          N9,


          Precios,


          Devoluciones,


          Descuentos,


          MaxDesc,


          NotifCompra,


		  Intervalo1,   -- Bosco agregado 28/07/2013


		  NotifFactcxc, -- Bosco agregado 28/07/2013


		  Intervalo2,   -- Bosco agregado 28/07/2013


		  NotifFactcxp, -- Bosco agregado 28/07/2013


		  Intervalo3,   -- Bosco agregado 28/07/2013


		  notifxmlfe, 	-- Bosco agregado 23/12/2018


		  Intervalo4,   -- Bosco agregado 23/12/2018


          Firmas )


       values(


          pUser,


          pNivel,


          pN1,


          pN2,


          pN3,


          pFacturas,


          pN5,


          pN6,


          pN7,


          pN8,


          pN9,


          pPrecios,


          pDevoluciones,


          pDescuentos,


          pMaxDesc,


          pNotifCompra,


		  pIntervalo1,   -- Bosco agregado 28/07/2013


		  pNotifFactcxc, -- Bosco agregado 28/07/2013


		  pIntervalo2,   -- Bosco agregado 28/07/2013


		  pNotifFactcxp, -- Bosco agregado 28/07/2013


		  pIntervalo3,   -- Bosco agregado 28/07/2013


		  pNotifxmlfe, 	 -- Bosco agregado 23/12/2018


		  pIntervalo4,   -- Bosco agregado 23/12/2018


          pFirmas );


		


		-- Si el usuario no existe en la base de datos del sistema


		-- lo agrego.


		if not Exists(Select user from saisystem.usuario


					  Where user = pUser) then


			Insert into saisystem.usuario (


			  User,


			  activo,       -- Bosco agregado 06/11/2011


			  ultimaClave)  -- Bosco agregado 06/11/2011


			Values(pUser, pActivo, pUltimaClave);


		End if;


    else


       Select vMensaje;


    end if;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ModificarBodega;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ModificarBodega`(


  IN  `pBodega`   char(3),


  IN  `pDescrip`  varchar(40)


)
BEGIN


  


  


  


  


  


  





  


  Declare vError   tinyInt(1);


  Declare vMensaje varchar(200);


  Declare vRegistros int;





  Set vError = 0;


  Set vMensaje = '';





  


  


  Select count(bodega) from Bodegas


  Where bodega = pBodega into vRegistros;





  Set vRegistros = IfNull(vRegistros,0);





  If vRegistros <> 1 then


    Set vError = 1;


    Set vMensaje =


      If(vRegistros = 0,'[BD] La bodega no existe',


      '[BD] Incongruencia. Esta bodega está más de una vez');


  End if;





  If vError = 0 then


    Update Bodegas Set descrip = pDescrip where bodega = pBodega;


  End if;





  


  Select vError as Error, vMensaje as MensajeErr;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ModificarEncabezadoFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ModificarEncabezadoFactura`(


	IN  `pID`          	int(10),


	IN  `pFacnume`     	int(10),


	IN  `pVend`        	tinyint(3),


	IN  `pTerr`        	tinyint(3),


	IN  `pFacfech`     	datetime,


	IN  `pFacplazo`    	tinyint(3),


	IN  `pCodExpress`  	smallint,


	IN  `pFacmonexp`   	double,


	IN  `pOrdenc`  		varchar(10) -- Bosco agregado 23/09/2018


)
BEGIN





	/*


	Este SP se usa para actualizar los últimos detalles de la factura


	en la tabla temporal justo antes de trasladarla a la tabla definitiva.


	OJO: Si viene algún código de Express inexistente aparecerá un error


	que dice 'valor_nopermitido doesn't exist'


	*/





	Declare vFacfepa  datetime;    -- Se usa para calcular la fecha de vencimiento








	Set pFacfech = IfNull(pFacfech,now());


	Set vFacfepa = AddDate(pFacfech, interval pFacplazo day);





	# Verifico el código Express


	If pFacmonexp <= 0 then


		Set pCodExpress = 0;


	End if;





	If pCodExpress > 0 then


		If not Exists(Select codExpress


					  from faexpress


					  Where codExpress = pCodExpress) then


			-- Provoco el error


			Insert into valor_nopermitido Select 1;


		End if;


	End if;





	If pOrdenc is NULL THEN


		Set pOrdenc = '';


	End if;








	-- No hago ninguna validación, le dejo la tarea a la integridad referencial


	Update wrk_faencabe Set


		facnume    = pFacnume,


		facmont    = facmont + pFacmonexp, -- Agregado 18/10/2010


		vend       = pVend,


		terr       = pTerr,


		facfech    = pFacfech,


		facplazo   = pFacplazo,


		facfepa    = vFacfepa,


		facsald    = If(pFacplazo > 0, facmont, 0),


		facdpago   = Round(pFacplazo / facnpag,0),


		facfppago  = AddDate(pFacfech, interval facdpago day),


		codExpress = pCodExpress,


		facmonexp  = pFacmonexp,


		ordenc	   = pOrdenc


	Where id = pID;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ModificarPagareCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ModificarPagareCXC`(


  IN  `pPagare`         int(10),


  IN  `pClicode`        int(10),


  IN  `pMonto`          double,


  IN  `pEmision`        datetime,


  IN  `pVencimiento`    datetime,


  IN  `pCodigoTC`       varchar(3),


  IN  `pTipoca`         float,


  IN  `pObservaciones`  varchar(1000)


)
BEGIN


  


  


  


  


  


  


  


  Declare vError   tinyInt(1);


  Declare vMensaje varchar(200);


  Declare vRegistros int;





  Set vError = 0;


  Set vMensaje = '';





  


  


  Select count(clicode) from PagaresCXC


  Where Pagare = pPagare into vRegistros;





  Set vRegistros = IfNull(vRegistros,0);





  If vRegistros <> 1 then


    Set vError = 1;


    Set vMensaje =


      If(vRegistros = 0,'[BD] El pagaré no existe',


      '[BD] Incongruencia. Este pagaré está más de una vez');


  End if;





  


  If vError = 0 and not Exists(Select codigo


                             from monedas


                             Where codigo = pCodigoTC) then


    Set vError = 1;


    Set vMensaje = '[BD] La moneda no es válida';


  End if;





  If vError = 0 then


    Update PagaresCXC Set


      Clicode = pClicode,


      Monto   = pMonto,


      Emision = pEmision,


      Vencimiento   = pVencimiento,


      Observaciones = pObservaciones,


      CodigoTC = pCodigoTC,


      Tipoca   = pTipoca


    Where pagare = pPagare;


  End if;





  


  Select vError as Error, vMensaje as MensajeErr;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS PrepararConteo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `PrepararConteo`(


	IN  `pBodega`     varchar(3), -- Bodega


	IN  `pPordesc`    tinyint(1), -- Indica si se ordenará por descripción (1=Si,0=No)


	IN  `pRegenerar`  tinyint(1), -- Indica si la tabla se regenerará o no (1=Si,0=No). Regenerar significa sobreescribir


	IN  `pValorar`    tinyint(1), -- 0=Costo promedio, 1=Precio1, 2=Precio2, 3=Precio3, 4=Precio4, 5=Precio5


	IN  `pLocaliz1`   varchar(7), -- Rango 1 de localizaciones (Bosco agregado 20/12/2015)


	IN  `pLocaliz2`   varchar(7)  -- Rango 2 de localizaciones (Bosco agregado 20/12/2015)


)
BEGIN


    # Autor:    Bosco Garita 22/01/2011.


    # Objet:    Generar la tabla de conteo con las existencias actuales.


    # Devuelve: Un result set con el número de registros generados. 





	# Modificador por: Bosco Garita 20/12/2015. 


	#			Se le agregan los parámetros pLocaliz1 y pLocaliz2 que permitirán realizar


	#			inventarios por localización.


    


    # Establezco los valores por defecto


    Set pPordesc   = IfNull(pPordesc,0);


    Set pRegenerar = Ifnull(pRegenerar,0); -- 0=Actualiza los datos, 1=Los sobreescribe


    


    -- 0=Costo promedio, 1=Precio1, 2=Precio2, 3=Precio3, 4=Precio4, 5=Precio5


    If pValorar is null or pValorar not between 0 and 5 then


        Set pValorar = 0;


    End if;





	Set pLocaliz1 = IfNull(pLocaliz1,'');





	If pLocaliz2 is null or pLocaliz1 = '' Then


		Select max(localiz) from bodexis Where bodega = pBodega into pLocaliz2;


	End if;


    


    If pRegenerar = 1 then  -- Generar conteo nuevo


    


        Delete from conteo Where bodega = pBodega;


        


        INSERT INTO `conteo`


            (`bodega`,


            `artcode`,


            `cantidad`,


            `artexis`,


            `artcosp`,


            `fecha`,


            `userDigita`,


            `userAplica`,


            `movdocu`,


            `pordesc`)


            Select


                a.bodega,


                a.artcode,


                0,


                a.artexis,


                Case pValorar When 0 then b.artcosp


                              When 1 then b.artpre1


                              When 2 then b.artpre2


                              When 3 then b.artpre3


                              When 4 then b.artpre4


                              Else b.artpre5


                End,


                now(),


                user(),


                '',


                '',


                pPordesc


            From bodexis a


            Inner join inarticu b on a.artcode = b.artcode


            Where a.bodega = pBodega


			and a.localiz between pLocaliz1 and pLocaliz2;


    Else -- Actualizar el conteo existente


        Update conteo,bodexis,inarticu b


        Set conteo.artexis = bodexis.artexis,


        conteo.artcosp = 


                Case pValorar When 0 then b.artcosp


                              When 1 then b.artpre1


                              When 2 then b.artpre2


                              When 3 then b.artpre3


                              When 4 then b.artpre4


                              Else b.artpre5


                End


        Where conteo.bodega = pBodega


        and conteo.bodega = bodexis.bodega


        and conteo.artcode = bodexis.artcode


        and conteo.artcode = b.artcode;


        


        # Agregar los registros que no existen


        INSERT INTO `conteo`


            (`bodega`,


            `artcode`,


            `cantidad`,


            `artexis`,


            `artcosp`,


            `fecha`,


            `userDigita`,


            `userAplica`,


            `movdocu`,


            `pordesc`)


            Select


                a.bodega,


                a.artcode,


                0,


                a.artexis,


                Case pValorar When 0 then b.artcosp


                              When 1 then b.artpre1


                              When 2 then b.artpre2


                              When 3 then b.artpre3


                              When 4 then b.artpre4


                              Else b.artpre5


                End,


                now(),


                user(),


                '',


                '',


                pPordesc


            From bodexis a


            Inner join inarticu b on a.artcode = b.artcode


            Where a.bodega = pBodega


			and a.localiz between pLocaliz1 and pLocaliz2


            and not Exists(


                        Select c.artcode from conteo c


                        Where c.bodega = a.bodega and c.artcode = a.artcode);


        


        # Actualizar el campo de orden y el usuario


        Update conteo


			Set pordesc = pPordesc, userDigita = user()


        Where bodega = pBodega;


        


    End if;


    


    # Contar los registros generados


    Select count(*) as registros from conteo Where bodega = pBodega;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ReabrirPeriodos;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ReabrirPeriodos`(

	IN `yearx` INT,

	IN `monthx` INT

)
    COMMENT 'Re-abrir periodos contables'
BEGIN

	/*

	Autor: Bosco Garita Azofeifa, 01/01/2021

	Descrip: Reabrir periodos contables cerrados.

	Importante: Cuando se abre un periodo que está n periodos antes del actual, todos los n periodos quedarán automáticamente abiertos.

			  Es responsabilidad del contador utilizar este proceso ya que se modificarán datos de informes ya emitidos.

	*/

	

	DECLARE vError INT;

	DECLARE vMensajeErr VARCHAR(5000);

	DECLARE vEtapa INT; -- Se usa en el mensaje de error para indicar la etapa en donde se dio el error

	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION

	BEGIN

		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;

		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);

	    	ROLLBACK;

		SET vError = 1;

		SET vMensajeErr = 

		    		CONCAT('[BD] Ocurrió un error en la etapa ', vEtapa, ' del proceso. ' , @full_error);

		SELECT 

			vError AS err,

			vMensajeErr AS msg;

	END;

	

	SET vError = 0;

	SET vMensajeErr = '';

	SET vEtapa = 1;		-- Respaldo de tablas

	

	-- Validar que el periodo solicitado exista.

	if not exists(SELECT descrip FROM coperiodoco WHERE año = YEARx AND mes = MONTHx AND cerrado = 1) then 

		SET vError = 1;

		SET vMensajeErr = '[BD] El periodo solicitado no existe o no está cerrado.';

	END if;

	

	-- Validar que todas las cuentas del catálogo cerrado estén en el catálogo actual.

	if vError = 0 and EXISTS(

				SELECT h.nom_cta

				FROM hcocatalogo h

				LEFT JOIN cocatalogo c ON 

					h.mayor = c.mayor

					AND h.sub_cta = c.sub_cta

					AND h.sub_sub = c.sub_sub

					AND h.colect = c.colect

				WHERE YEAR(h.fecha_cierre) = yearx AND MONTH(h.fecha_cierre) = monthx AND c.mayor IS NULL) then 

		SET vError = 1;

		SET vMensajeErr = '[BD] Existen cuentas que ya no están en el catálogo actual.';

	END if;

	

	-- Crear una copia del periodo actual de varias tablas (eliminar si existe)

	if vError = 0 then

		DROP TABLE if EXISTS cocatalogo_bk;

		CREATE TABLE cocatalogo_bk AS SELECT * FROM cocatalogo;

		

		DROP TABLE if EXISTS coperiodoco_bk;

		CREATE TABLE coperiodoco_bk AS SELECT * FROM coperiodoco;

		

		DROP TABLE if EXISTS coasientoe_bk;

		CREATE TABLE coasientoe_bk AS SELECT * FROM coasientoe;

		

		DROP TABLE if EXISTS coasientod_bk;

		CREATE TABLE coasientod_bk AS SELECT * FROM coasientod;

		

		DROP TABLE if EXISTS hcoasientoe_bk;

		CREATE TABLE hcoasientoe_bk AS SELECT * FROM hcoasientoe;

		

		DROP TABLE if EXISTS hcoasientod_bk;

		CREATE TABLE hcoasientod_bk AS SELECT * FROM hcoasientod;

		

		DROP TABLE if EXISTS cotipasient_bk;

		CREATE TABLE cotipasient_bk AS SELECT * FROM cotipasient;

	END if;

	

	

	START TRANSACTION;

	

	-- Si no hay error continúo con la siguiente etapa

	if vError = 0 then

		SET vEtapa = 2;		-- Marcar los periodos como abiertos

		

		UPDATE coperiodoco 

			SET cerrado = 0

		WHERE (año > YEARx) OR (año = YEARx AND mes >= MONTHx);

	END if;

	

	

	-- Si no hay error continúo con la siguiente etapa

	if vError = 0 then

		SET vEtapa = 3;		-- Trasladar los movimientos de los históricos a las tablas actuales.

		

		-- Se ejecuta este proceso antes que el traslado del catálogo para que el mismo motor determine

		-- si existen cuentas manipuladas, es decir que se hayan cambiado en el histórico arbitrariamente.

		

		/*

		Pasos:

			1. Insertar los registros de hcoasientod a coasientod y de hcoasientoe a coasientoe filtrando las fechas.

			2. Eliminar los registros de hcoasientod y hcoasientoe filtrando las fechas.

		*/

		

		-- Trasladar todos los asientos mayores o iguales al periodo solicitado (exepto los de cierre anual).

		INSERT INTO coasientoe (

			no_comprob,

			fecha_comp,

			no_refer,

			tipo_comp,

			descrip,

			usuario,

			periodo,

			modulo,

			documento,

			movtido,

			enviado,

			asientoAnulado

			)

			SELECT 

				no_comprob,

				fecha_comp,

				no_refer,

				tipo_comp,

				descrip,

				usuario,

				periodo,

				modulo,

				documento,

				movtido,

				enviado,

				asientoAnulado

			FROM hcoasientoe

			WHERE (YEAR(fecha_comp) > YEARx) OR (YEAR(fecha_comp) = yearx and MONTH(fecha_comp) >= MONTHx

			AND no_comprob <> '99999'

			AND tipo_comp <> 99);

			

		INSERT INTO coasientod (	

			 no_comprob,

			 tipo_comp,

			 descrip,

			 db_cr,

			 monto,

			 mayor,

			 sub_cta,

			 sub_sub,

			 colect,

			 idReg

			)

			SELECT 

				 d.no_comprob,

				 d.tipo_comp,

				 d.descrip,

				 d.db_cr,

				 d.monto,

				 d.mayor,

				 d.sub_cta,

				 d.sub_sub,

				 d.colect,

				 d.idReg

			FROM hcoasientod d

			INNER JOIN hcoasientoe e ON d.no_comprob = e.no_comprob AND d.tipo_comp = e.tipo_comp

			WHERE (YEAR(e.fecha_comp) > YEARx) OR (YEAR(e.fecha_comp) = yearx and MONTH(e.fecha_comp) >= MONTHx

			AND e.no_comprob <> '99999'

			AND e.tipo_comp <> 99);

			

		-- Eliminar todos los datos de los registros trasladados y también los que correspnden a cierre anual (si existen).

		DELETE hcoasientod.*, hcoasientoe.*

		FROM hcoasientod, hcoasientoe

		WHERE hcoasientod.no_comprob = hcoasientoe.no_comprob AND hcoasientod.tipo_comp = hcoasientoe.tipo_comp

		AND (YEAR(hcoasientoe.fecha_comp) > YEARx) OR (YEAR(hcoasientoe.fecha_comp) = yearx and MONTH(hcoasientoe.fecha_comp) >= MONTHx);

		

		DELETE FROM hcoasientoe

		WHERE YEAR(fecha_comp) > YEARx OR (YEAR(fecha_comp) = YEARx and MONTH(fecha_comp) >= MONTHx);

		

	END if;

	

	

	-- Si no hay error continúo con la siguiente etapa

	if vError = 0 then

		SET vEtapa = 4;		-- Establecer el catálogo

		/*

		Pasos:

			1. Reemplazar todos los registros del catálogo con la información del histórico (todos los campos exepto las cuentas).

			2. Eliminar del catálogo histórico todos los registros de periodos mayores o iguales al solicitado.

		*/

		UPDATE cocatalogo c, hcocatalogo h

		SET c.nom_cta = h.nom_cta,

			c.nivel = h.nivel,

			c.tipo_cta = h.tipo_cta,

			c.fecha_upd = h.fecha_upd,

			c.ano_anter = h.ano_anter,

			c.db_fecha = h.db_fecha,

			c.cr_fecha = h.cr_fecha,

			c.db_mes = h.db_mes,

			c.cr_mes = h.cr_mes,

			c.nivelc = h.nivelc,

			c.nombre = h.nombre,

			c.fecha_c = h.fecha_c,

			c.activa = h.activa

		WHERE h.mayor = c.mayor

		AND h.sub_cta = c.sub_cta

		AND h.sub_sub = c.sub_sub

		AND h.colect  = c.colect

		AND YEAR(h.fecha_cierre) = yearx

		AND MONTH(h.fecha_cierre) = monthx;

		

		DELETE FROM hcocatalogo

		WHERE YEAR(fecha_cierre) = yearx

		AND MONTH(fecha_cierre) = monthx;

	END if;

	

	

	if vError = 0 then

		SET vEtapa = 5;		-- Establecer el nuevo periodo

		UPDATE configcuentas SET mesactual = monthx, añoactual = yearx;

	END if;

	

	-- Si todo sale bien la variable vError tendrá un cero y la variable vMensajeErr estará vacía

	if vError = 1 then

		ROLLBACK;

	ELSE 

		COMMIT;

	END if;

	

	SELECT 

		vError AS err,

		vMensajeErr AS msg;

	

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularExistenciaArticulo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularExistenciaArticulo`(

	IN `pArtcode` varchar(20),

	IN `pBodega` varchar(3),

	IN `pFecha` datetime

)
BEGIN



    -- Autor: Bosco Garita Azofeifa

    

    -- NOTA: No se recomienda correr este SP contra todo el catálogo de artículos ya que se vuelve muy lento.

    

    

    Declare vPuntoP         datetime;

    Declare vMesCerrado     smallInt;

    Declare vAnoCerrado     int;

    Declare vUltimoCierre   datetime;

    Declare vHayError       SmallInt(1);

    Declare vErrorMessage   varchar(1000);





    DECLARE EXIT HANDLER FOR SQLEXCEPTION

    BEGIN

    

        RollBack;

        Set vHayError = 1;

        Set vErrorMessage = 

            Concat('[BD] No se pudo calcular el artículo ',

            pArtcode, ' para la bodega ', pBodega);

            

        Select vHayError as Error,vErrorMessage as ErrorMessage;



    END;



    

    Set vHayError = 0;

    Set vErrorMessage = '';



    Set pFecha = IfNull(pFecha,now());

    



    Select 

    		IfNull(mescerrado,1),

		IfNull(anocerrado,1900) 

    from config 

    into vMesCerrado, vAnoCerrado;



    Set vUltimoCierre = UltimoDiaDelMes(vMesCerrado,vAnoCerrado);





    Set @vAnterior = 0;



    Select artexis from hbodexis

    Where bodega = pBodega

    and artcode = pArtcode

    and artperi = vUltimoCierre into @vAnterior;



    Set @vEntradas = 0;

    Set @vSalidas  = 0;



    START TRANSACTION;

    

    SELECT

         Sum(If(inmovimd.movtimo = 'E',movcant,0)),

         Sum(If(inmovimd.movtimo = 'S',movcant,0))

    FROM inmovimd

    INNER JOIN inmovime ON inmovimd.movdocu = inmovime.movdocu

        AND inmovimd.movtimo = inmovime.movtimo

        AND inmovimd.movtido = inmovime.movtido

    WHERE artcode = pArtcode

    AND bodega = pBodega

    AND movfech > vUltimoCierre AND movfech <= pFecha

    AND (inmovime.estado IS NULL OR inmovime.estado = '')

    INTO @vEntradas,@vSalidas;



    Set @vAnterior = IfNull(@vAnterior, 0);

    Set @vEntradas = IfNull(@vEntradas, 0);

    Set @vSalidas  = IfNull(@vSalidas , 0);



    Update bodexis Set

        artexis = @vAnterior + @vEntradas - @vSalidas

    Where artcode = pArtcode

    and bodega = pBodega;



    COMMIT;



    Select vHayError as Error,vErrorMessage as ErrorMessage;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularExistenciaArticuloSinPuntoPartid;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularExistenciaArticuloSinPuntoPartid`(


  IN  `pArtcode`  varchar(20),


  IN  `pBodega`   varchar(3)


)
BEGIN


    


    -- Autor: Bosco Garita Azofeifa


    


    


    Set @vEntradas = 0;


    Set @vSalidas  = 0;





    SELECT


         Sum(If(inmovimd.movtimo = 'E',movcant,0)),


         Sum(If(inmovimd.movtimo = 'S',movcant,0))


    FROM inmovimd


    INNER JOIN inmovime ON inmovimd.movdocu = inmovime.movdocu


        AND inmovimd.movtimo = inmovime.movtimo


        AND inmovimd.movtido = inmovime.movtido


    WHERE artcode = pArtcode


    AND bodega = pBodega


    AND movfech <= now()


    AND (inmovime.estado IS NULL OR inmovime.estado = '')


    INTO @vEntradas,@vSalidas;


    


    Set @vEntradas = IfNull(@vEntradas, 0);


    Set @vSalidas  = IfNull(@vSalidas , 0);





    


    Update bodexis Set


        artexis = @vEntradas - @vSalidas


    Where artcode = pArtcode


    and bodega = pBodega;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularFactura;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularFactura`(

	IN `pID` int(10),

	IN `pAplicarIV` tinyint(1)

)
BEGIN



   Declare vResultado    tinyInt(1);     

   Declare vErrorMessage varchar(50);    

   Declare vFacimve      decimal(12,2);  

   Declare vFacdesc      decimal(12,2);  

   Declare vFacmont      decimal(12,2);  

   Declare vRedondear    tinyInt(1);     

   Declare vRedondearA5  tinyInt(1);     

   Declare vHayRegistros tinyInt(1);     



   Set vResultado    = 1;

   Set vErrorMessage = '';

   Set vHayRegistros =

       Case When (Select count(*)

                  from wrk_fadetall

                  Where id = pID) > 0 then 1

            Else 0

       End;



   If vHayRegistros = 1 then

            

      Set vRedondear =

          Case When (Select codigoTC

                     from wrk_faencabe

                     Where id = pID) = (Select codigoTC

                                        from config) then (Select redondear from config)

               else 0

          End;

      Set vRedondearA5 =

          Case When (Select codigoTC

                     from wrk_faencabe

                     Where id = pID) = (Select codigoTC

                                        from config) then (Select redond5 from config)

               Else 0

          End;

   End if;



   

   If vHayRegistros = 1 then

      

      Update wrk_fadetall Set

         facmont = faccant * Artprec,

         facpive = Case When pAplicarIV = 1 then

                             (Select porcentaje

                             from tarifa_iva

                             Where codigoTarifa = wrk_fadetall.codigoTarifa)

                        Else 0

                   End,

         facdesc = facmont * (facpdesc/100),

         facimve = (facmont - facdesc) * (facpive/100)

      Where id = pID;



      if row_count() = 0 then

         Set vResultado    = 0;

         Set vErrorMessage = '[BD] No se pudo actualizar el detalle de facturas';

      End if;



   End if; 





   if vHayRegistros = 1 and vResultado > 0 then

      

      Set vFacimve = (Select sum(facimve) from wrk_fadetall Where id = pID);

      Set vFacdesc = (Select sum(facdesc) from wrk_fadetall Where id = pID);

      Set vFacmont = (Select sum(facmont) from wrk_fadetall Where id = pID);



      

      

      If vRedondearA5 = 1 then

         Set vFacmont = RedondearA5(vFacmont - vFacdesc + vFacimve);

      End if;



      Update wrk_faencabe Set

          facimve = vFacimve,

          facdesc = vFacdesc,

          

          facmont = vFacmont,

          facmpag = facmont / facnpag,

          facsald = Case When facplazo > 0 then facmont else 0 end

      Where id = pID;



      if row_count() = 0 then

         Set vResultado    = 0;

         Set vErrorMessage = '[BD] No se pudo actualizar el encabezado de facturas';

      End if;

   End if; 



   Select vResultado, vErrorMessage;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularExistencias;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularExistencias`(

	IN `pFecha` datetime,

	IN `pCierre` tinyint(1)

)
BEGIN



    # Autor:    Bosco Garita año 2010

    # Objet:    Recalcular las existencias a una fecha dada

    #           Cuando es invocado con un 1 en el parámetro pCierre no se usa el Start transaction ni el commit

    #           ya que el proceso que lo invoca debe hacerlo dentro de una transacción.  Se usa de esta manera

    #           porque cuando no es cierre es necesario que no bloquee por mucho tiempo pero cuando es cierre

    #           es todo lo contrario.  Más bien en ese momento no debe haber nadie emitiendo movimientos.

               



    Declare vRango1   varchar(23);    

    Declare vRango2   varchar(23);

    Declare vPuntoP   datetime;

    Declare vMesCerrado smallInt;

    Declare vAnoCerrado int;

    Declare vUltimoCierre datetime;

    



    # Establecer los valores default para los parámetros

    Set pFecha = IfNull(pFecha,now());

    

    If pCierre is null or pCierre not in (0,1) then

        Set pCierre = 0;

    End if;





    # Establecer el rango de artículos

    Set vRango1 = (Select Min(Concat(artcode,bodega)) from bodexis);

    Set vRango2 = (Select Max(Concat(artcode,bodega)) from bodexis);





    # Establecer el punto de partida

    Select IfNull(mescerrado,1),IfNull(anocerrado,1900) from config into vMesCerrado, vAnoCerrado;

    Set vUltimoCierre = UltimoDiaDelMes(vMesCerrado,vAnoCerrado);



	-- Bosco agregado 05/07/2015

	# Obtener el set de registros de movimientos que será consultado durante el ciclo.

	Create temporary table detMov(

		SELECT

			 inmovimd.movtimo,

			 inmovimd.movtido,

			 inmovimd.movcant,

			 inmovimd.artcode,

			 inmovimd.bodega

		FROM inmovimd

		INNER JOIN inmovime ON inmovimd.movdocu = inmovime.movdocu

			AND inmovimd.movtimo = inmovime.movtimo

			AND inmovimd.movtido = inmovime.movtido

		WHERE movfech > vUltimoCierre AND movfech <= pFecha

		AND (inmovime.estado IS NULL OR inmovime.estado = ''));



	CREATE INDEX ix_detMov ON detMov (artcode,bodega);

	-- Fin Bosco agregado 05/07/2015



    # El recorrido se hace registro por registro para evitar el bloqueo de toda la tabla.

    -- Uso mi técnica personal de recorrido por mínimos (Bosco).

    While vRango1 <= vRango2 Do

    

        If not pCierre then



            START TRANSACTION;



        End if;



        Set @vAnterior = 0;



        # Obtener el saldo al último cierre.

        Select artexis from hbodexis

        Where bodega = substring(vRango1,Length(trim(artcode))+1,3)

        and artcode = substring(vRango1,1,Length(trim(artcode)))

        and artperi = vUltimoCierre into @vAnterior;



        Set @vEntradas = 0;

        Set @vSalidas  = 0;





		# Obtener la suma de entradas y salidas para el período solicitado.

        SELECT

             Sum(If(movtimo = 'E',movcant,0)),

             Sum(If(movtimo = 'S',movcant,0))

        FROM detMov

        WHERE artcode = substring(vRango1,1,Length(trim(artcode)))

        AND bodega = substring(vRango1,Length(trim(artcode))+1,3)

        INTO @vEntradas,@vSalidas;



        Set @vAnterior = IfNull(@vAnterior, 0);

        Set @vEntradas = IfNull(@vEntradas, 0);

        Set @vSalidas  = IfNull(@vSalidas , 0);



        # Actualizar el registro

	   Update bodexis Set

            artexis = @vAnterior + @vEntradas - @vSalidas

        Where bodega = substring(vRango1,Length(trim(artcode))+1,3)

        and artcode = substring(vRango1,1,Length(trim(artcode)));



        If not pCierre then



            COMMIT;



        End if;



        # Siguiente registro

        Set vRango1 = ( Select Min(Concat(artcode,bodega))

                        from bodexis

                        Where Concat(artcode,bodega) > vRango1);



    End While;



	Drop temporary table If Exists detMov;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularNC_CXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularNC_CXC`(

	IN `pID` int(10),

	IN `pAplicarIV` tinyint(1)

)
BEGIN



   Declare vResultado    tinyInt(1);     

   Declare vErrorMessage varchar(50);    

   Declare vFacimve      decimal(12,2);  

   Declare vFacdesc      decimal(12,2);  

   Declare vFacmont      decimal(12,2);  

   Declare vRedondear    tinyInt(1);     

   Declare vRedondearA5  tinyInt(1);     

   Declare vHayRegistros tinyInt(1);     





   Set vResultado    = 1;

   Set vErrorMessage = '';

   Set vHayRegistros =

       Case When (Select count(*)

                  from wrk_fadetall

                  Where id = pID) > 0 then 1

            Else 0

       End;



   If vHayRegistros = 1 then



      Set vRedondear =

          Case When (Select codigoTC

                     from wrk_faencabe

                     Where id = pID) = (Select codigoTC

                                        from config) then (Select redondear from config)

               else 0

          End;



      Set vRedondearA5 =

          Case When (Select codigoTC

                     from wrk_faencabe

                     Where id = pID) = (Select codigoTC

                                        from config) then (Select redond5 from config)

               Else 0

          End;



   End if;



   If vHayRegistros = 1 then



      Update wrk_fadetall Set

         facmont = faccant * Artprec,

         facpive = Case When pAplicarIV = 1 then

                             (Select tarifa_iva.porcentaje

						from inarticu

						INNER JOIN tarifa_iva ON inarticu.codigoTarifa = tarifa_iva.codigoTarifa

						Where artcode = wrk_fadetall.artcode)

                        Else 0

                   End,

         facdesc = facmont * (facpdesc/100),

         facimve = (facmont - facdesc) * (facpive/100)

      Where id = pID;





      if row_count() = 0 then



         Set vResultado    = 0;

         Set vErrorMessage = '[BD] No se pudo actualizar el detalle de Notas de Crédito';



      End if;



   End if; 



   if vHayRegistros = 1 and vResultado > 0 then



      Set vFacimve = (Select sum(facimve) from wrk_fadetall Where id = pID) * -1;

      Set vFacdesc = (Select sum(facdesc) from wrk_fadetall Where id = pID) * -1;

      Set vFacmont = (Select sum(facmont) from wrk_fadetall Where id = pID) * -1;



      Set vFacmont = RedondearA5(vFacmont - vFacdesc + vFacimve);





      Update wrk_faencabe Set

          facimve = vFacimve,

          facdesc = vFacdesc,

          facmont = vFacmont,

          facmpag = facmont / facnpag,

          facsald = facmont

      Where id = pID;



      if row_count() = 0 then

         Set vResultado    = 0;

         Set vErrorMessage = '[BD] No se pudo actualizar el encabezado de Notas de Crédito';

      End if;



   End if; 



   Select vResultado, vErrorMessage;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularReservado;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularReservado`(


  IN `pArtcode` varchar(20)


)
BEGIN


    


    


    


    


    


    Update bodexis


        Set artreserv = IfNull((Select sum(reservado)


                                from pedidod


                                Where artcode = bodexis.artcode


                                and bodega = bodexis.bodega),0)


    Where artcode = If(pArtcode is null, artcode, pArtcode);





    


    Update bodexis


        Set artreserv = artreserv + IfNull((Select sum(faccant)


                                            from wrk_fadetall


                                            Where artcode = bodexis.artcode


                                            and bodega = bodexis.bodega),0)


    Where artcode = If(pArtcode is null, artcode, pArtcode);


    


    


    Update bodexis


        Set artreserv = artreserv + IfNull((Select sum(faccant)


                                            from pedidofd


                                            Where artcode = bodexis.artcode


                                            and bodega = bodexis.bodega),0)


    Where artcode = If(pArtcode is null, artcode, pArtcode);


    


    


    Update bodexis


        Set artreserv = artreserv + IfNull((Select sum(movcant)


                                            from salida


                                            Where artcode = bodexis.artcode


                                            and bodega = bodexis.bodega),0)


    Where artcode = If(pArtcode is null, artcode, pArtcode);


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularSaldoClientes;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularSaldoClientes`(


  IN `pnClicode` int


)
BEGIN


    # Autor:        Bosco Garita año 2010.


    # Descripción:  Recalcular el saldo de los clientes.


    # NOTA:         Debe correr dentro de una transacción.





  If pnClicode is null then # Recalcular todos los clientes


     Update inclient Set clisald = 0, clifeuc = null;


     


     Update inclient


       Set clisald = IfNull((Select sum(facsald * tipoca)


                             from faencabe


                             Where clicode = inclient.clicode 


                             and facsald <> 0


                             and facestado <> 'A'),0);


     


     Update inclient


       Set clifeuc = (Select max(facfech)


                      from faencabe


                      where clicode = inclient.clicode 


                      and facnd = 0 


                      and facestado <> 'A');


  Else # Recalcular un solo cliente


     Update inclient Set clisald = 0, clifeuc = null Where clicode = pnClicode;





     Update inclient


       Set clisald = IfNull((Select sum(facsald * tipoca)


                             from faencabe


                             Where clicode = inclient.clicode 


                             and facsald <> 0


                             and facestado <> 'A'),0)


     Where clicode = pnClicode;





     


     Update inclient


       Set clifeuc = (Select max(facfech)


                      from faencabe


                      where clicode = inclient.clicode 


                      and facnd = 0 


                      and facestado <> 'A')


     Where clicode = pnClicode;


  End if;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularSaldoClientes_Cierre;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularSaldoClientes_Cierre`()
BEGIN


    # Autor:        Bosco Garita 13/03/2011


    # Descripción:  Recalcular el saldo de los clientes para el cierre mensual 


    #               o para cualquier otro proceso que requiera el saldo a otra fecha que no sea la actual.


    #               Este proceso se basa en la tabla temporal tmp_faencabe que genera el SP CalcularCXC()


    #               Esta tabla no tiene nulos ni facturas de contado y viene calculada a una fecha específica


    #               que no es necesario conocer en este SP.





    Update inclient Set clisald = 0;





    Update inclient


    Set clisald = IfNull((Select sum(facsald * tipoca)


                         from tmp_faencabe  # En esta tabla no se consideran los registros nulos porque no los hay.


                         Where clicode = inclient.clicode 


                         and facsald <> 0),0);


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularSaldoFacturas;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularSaldoFacturas`()
BEGIN


    # Autor:        Bosco Garita 2010


    # Descripción:  Recalcular los montos y saldos de las facturas, ND y NC que estén en el período de proceso.


    


    Declare vFechaCorte datetime;   -- Fecha del último cierre mensual


    Declare vMesCerrado tinyInt;    -- Mes cerrado


    Declare vAnoCerrado int;        -- Año cerrado


    Declare vCodigoTC   varchar(3); -- Código de moneda default (local)


    


    # Obtener el mes y año cerrados y el código de moneda local


    Select 


		IfNull(mescerrado,1),IfNull(anocerrado,1900),codigoTC 


	from config into vMesCerrado, vAnoCerrado, vCodigoTC;


    


    # Formar la fecha de corte (cierre mensual incluye hora :23:59:59)


    Set vFechaCorte = UltimoDiaDelMes(vMesCerrado,vAnoCerrado);


	


	# Bosco agregado 03/03/2013.


	/*


	 Recalculo todo el detalle para garantizar que el encabezado estará correcto.


	 Esto permite que si hay un error en los impuestos o los descuentos se pueda


	 corregir con solo cambiar el porcentaje.


	*/


	Update fadetall Set


		facdesc = facmont * facpdesc / 100,


		facimve = (facmont - facmont * facpdesc / 100) * facpive / 100


	Where Exists(Select faencabe.facnume 


				 from faencabe 


				 Where faencabe.facnume = fadetall.facnume 


				 and faencabe.facnd = fadetall.facnd


				 and faencabe.facfech > vFechaCorte


				 and faencabe.facCerrado = 'N'


				 and faencabe.facestado = '');


	# Fin Bosco agregado 03/03/2013.





	# Bosco agregado 05/03/2013.


	/*


	Actualizo los impuestos y los descuentos en el encabezado


	a partir del detalle recién calculado.


	*/


	Update faencabe Set


		facimve = (	Select sum(facimve) 


					from fadetall 


					Where facnume = faencabe.facnume 


					and factipo = faencabe.factipo),


		facdesc = (	Select sum(facdesc) 


					from fadetall 


					Where facnume = faencabe.facnume 


					and factipo = faencabe.factipo)


	Where facfech > vFechaCorte


	and faencabe.facCerrado = 'N'


	and faencabe.facestado = '';


	# Fin Bosco agregado 05/03/2013.





    # Recalcular el monto de las facturas que son del período en proceso únicamente.


    Update faencabe


    Set facmont = If(codigoTC = vCodigoTC, # Si es moneda local...


                     RedondearA5((Select sum(facmont + facimve - facdesc) # ... uso redondeo.


                                  from fadetall


                                  Where facnume = faencabe.facnume


                                  and facnd = faencabe.facnd)),


                    (Select sum(facmont + facimve - facdesc) # Caso contrario no se redondea


                     from fadetall


                     Where facnume = faencabe.facnume


                     and facnd = faencabe.facnd))


    where facfech > vFechaCorte 


    and facCerrado = 'N'


    and facestado = '';





    # Agrego el monto express para las facturas que lo tienen


    Update faencabe


    Set facmont = facmont + facmonexp


    Where facfech > vFechaCorte 


    and facCerrado = 'N'


    and facestado = '' 


    and facnd = 0 


    and facmonexp > 0;





    # Recalcular el saldo de las facturas de crédito y de las ND.


    Update faencabe 


    Set facsald = facmont - AplicadoAFactura(facnume,facnd)


    Where facfech > vFechaCorte 


    and facCerrado = 'N'


    and facnume > 0 


    and facplazo > 0 


    and facestado = '';


    


    # Por la precición de los dígitos es posible que queden saldos por fracciones insignificantes


    # y por esa razón todos los saldos entre 0.5 y -0.5 se truncan a cero. Bosco 20/03/2011.


    Update faencabe


    Set facsald = 0


    where facnume > 0


    and facplazo > 0 


    and facestado = ''


    and abs(facsald*tipoca) > 0 and abs(facsald*tipoca) < 0.5;





    # Recalcular las notas de crédito


    Update faencabe


    Set facsald = facmont +


        IfNull((Select sum(monto)


                from notasd


                Where notanume = faencabe.facnume),0)


    Where facfech > vFechaCorte 


    and facCerrado = 'N'


    and facnume < 0


    and facestado = ''


    and faccsfc = 0;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecalcularSaldoProveedores;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecalcularSaldoProveedores`(

  IN `pcProcode` varchar(15)

)
BEGIN

    # Autor:        Bosco Garita 22/04/2012.

    # Descripci_n:  Recalcular el saldo de los proveedores, el monto acumulado de abonos

    #               y la fecha del último abono.  Este monto y esta fecha aplica únicamente

    #               para los registros de facturas de cr_dito o notas de cr_dito.

    #               En la tabla de proveedores tambi_n se establece el monto y la fecha

    #               de la _ltima compra.

    # NOTA:         Debe correr dentro de una transacci_n.



  Declare vAbono_acum decimal(14,4);



  # Primero recalculo el saldo de las facturas y notas de crédito 

  # y luego el saldo del proveedor.



    

  If pcProcode is null then 

	 # Recalcular todos los proveedores

	

     # Establecer el acumulado de abonos y la fecha del _ltimo abono.

     Update cxpfacturas Set 

        abono_acum = ifNull(AplicadoAFacturaCXP(factura,tipo,procode) / tipoca,0), -- Viene en moneda local y se convierte a la moneda del registro.

        fec_ult_ab = FechaUltAbFacturaCXP(factura,tipo)

     Where tipo in ('FAC','NCR')

     and vence_en > 0

	 and cerrado = 'N'; -- Bosco agregado 14/03/2013



     # Recalcular el saldo los registros en la tabla cxpfacturas

     Update cxpfacturas Set 

        saldo = total_fac - abono_acum

     Where vence_en > 0

	 and cerrado = 'N'; -- Bosco agregado 14/03/2013



     # Recalcular el saldo y la fecha de la _ltima compra de los proveedores

     Update inproved Set prosald = 0, profeuc = null;



     Update inproved

       Set prosald = IfNull((Select sum(saldo * tipoca)

                             from cxpfacturas

                             Where procode = inproved.procode 

                             and saldo <> 0),0);



     Update inproved

       Set profeuc = (Select max(fecha_fac)

                      from cxpfacturas

                      where procode = inproved.procode

                      and tipo = 'FAC');



  Else 

	 # Recalcular un solo proveedor

	 

     # Establecer el acumulado de abonos y la fecha del _ltimo abono.

	 Update cxpfacturas Set 

		abono_acum = IfNull(AplicadoAFacturaCXP(factura,tipo,procode) / tipoca,0), -- Viene en moneda local y se convierte a la moneda del registro.

		fec_ult_ab = FechaUltAbFacturaCXP(factura,tipo)

     Where procode = pcProcode 

     and tipo in ('FAC','NCR')

     and vence_en > 0

	 and cerrado = 'N'; -- Bosco agregado 14/03/2013



     # Recalcular el saldo los registros en la tabla cxpfacturas

     Update cxpfacturas Set 

        saldo = total_fac - abono_acum

     Where procode = pcProcode 

     and vence_en > 0

	 and cerrado = 'N'; -- Bosco agregado 14/03/2013



     # Recalcular el saldo y la fecha de la _ltima compra del proveedor

     Update inproved Set prosald = 0, profeuc = null Where procode = pcProcode;



     Update inproved

       Set prosald = IfNull((Select sum(saldo * tipoca)

                             from cxpfacturas

                             Where procode = inproved.procode

                             and saldo <> 0),0)

     Where procode = pcProcode;

     

     Update inproved

       Set profeuc = (Select max(fecha_fac)

                      from cxpfacturas

                      where procode = inproved.procode

                      and tipo = 'FAC')

     Where procode = pcProcode;

  End if;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_ComprasD151;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_ComprasD151`(


  IN  `pFacfech1`     datetime,


  IN  `pFacfech2`     datetime


)
BEGIN


	# Autor: Bosco Garita Azofeifa 23/10/2013





	Declare vEmpresa varchar(60);


	Declare vTotalVentas double;





	Set vEmpresa = (Select empresa from config);





	# Default para las fechas inicial y final


	If pFacfech1 is null then


		Set pFacfech1 = '1900-01-01';


	End if;


	If pFacfech2 is null then


		Set pFacfech2 = now();


	End if;





	Create temporary table tmpComprasD151


		SELECT


			a.procode, b.prodesc,


			SUM((a.total_fac - a.impuesto) * a.tipoca) AS compra,


			SUM(a.impuesto * a.tipoca) AS impuesto,


			SUM(a.descuento * a.tipoca) AS descuento,


			SUM(a.total_fac * a.tipoca) AS total_fac


		FROM cxpfacturas a


		LEFT  JOIN inproved b ON a.procode = b.procode


		WHERE a.fecha_fac between pFacfech1 and pFacfech2


		AND a.tipo = 'FAC' 


		GROUP BY a.procode, b.prodesc;





	Create temporary table tmpComprasD151_2


		SELECT


			procode, prodesc,


			SUM(compra)    AS compra,


			SUM(impuesto)  AS impuesto,


			SUM(descuento) AS descuento,


			SUM(total_fac) AS total_fac


		FROM tmpComprasD151


		GROUP BY procode, prodesc;








	Select tmpComprasD151_2.*,vEmpresa as Empresa


	from tmpComprasD151_2 order by compra Desc;








	Drop table tmpComprasD151;


	Drop table tmpComprasD151_2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS RecodificarArticulo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecodificarArticulo`(


  IN  `pArtcodeOrigen`   varchar(20),


  IN  `pArtcodeDestino`  varchar(20)


)
BEGIN


    # Autor     : Bosco Garita 16/04/2011


    # Objetivo  : Recodificar un artículo de inventario


    # Observ.   : Este SP controla las foráneas y las transacciones.


    # Devuelve  : Un ResultSet con dos campos; vHayError SmallInt(1) y vErrorMessage varchar(1000)


    # Modificado: Bosco 19/04/2011.  Elimino el control de llaves foráneas porque lo que había era


    #             un error en el diseño de la integridad por llave foránea.  Ahora basta con actualizar


    #             la tabla maestra y todas las demás se van en cascada.


    


    


    Declare vHayError SmallInt(1);


    Declare vErrorMessage varchar(1000);


    Declare vTabla varchar(20);


    


    DECLARE EXIT HANDLER FOR SQLEXCEPTION


    BEGIN


        RollBack;


        -- SET FOREIGN_KEY_CHECKS=1;


        Set vHayError = 1;


        Set vErrorMessage = 


            Concat('[BD] No se pudo recodificar el artículo ',


            pArtcodeOrigen, ' tabla ', vTabla);


        Select vHayError,vErrorMessage;


    END;


    


    Set vHayError = 0;


    Set vErrorMessage = '';


    


    # Verifico que no exista el nuevo código


    If Exists(Select artcode from inarticu Where artcode = pArtcodeDestino) then


        Set vHayError = 1;


        Set vErrorMessage = '[BD] El código nuevo ya existe.';


    End if;


    


    # Solo procedo si no hay error


    If not vHayError then


        # Deshabilito la integridad referencial para evitar errores


        -- SET FOREIGN_KEY_CHECKS=0;


        


        # INICIO LA TRANSACCIÓN


        START TRANSACTION;


        


        # Proceso las tablas por orden alfabético


        --         Set vTabla = 'ARTPROV';


        --         Update ARTPROV Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'BODEXIS';


        --         Update BODEXIS Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'CONTEO';


        --         Update CONTEO Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'FADETALL';


        --         Update FADETALL Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'HBODEXIS';


        --         Update HBODEXIS Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'HCONTEO';


        --         Update HCONTEO Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'HINARTICU';


        --         Update HINARTICU Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;





        Set vTabla = 'INARTICU';


        Update INARTICU Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        


        --         Set vTabla = 'INMOVIMD';


        --         Update INMOVIMD Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'PEDIDOD';


        --         Update PEDIDOD Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'PEDIDOFD';


        --         Update PEDIDOFD Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


        --         


        --         Set vTabla = 'WRK_FADETALL';


        --         Update WRK_FADETALL Set artcode = pArtcodeDestino Where artcode = pArtcodeOrigen;


            


        # CIERRO LA TRANSACIÓN


        COMMIT;


        


        # Habilito nuevamente la integridad referencial


        -- SET FOREIGN_KEY_CHECKS=1;


        


     End if;  -- If not vHayError


     


    # Devolver el resultado


    Select vHayError,vErrorMessage;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Conteo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Conteo`(

	IN `pRangos` tinyint(1),

	IN `pBodega` char(3),

	IN `pLinea1` int,

	IN `pLinea2` int,

	IN `pOrden` tinyint

)
BEGIN

    -- Autor: Bosco Garita Azofeifa

    

    Declare vEmpresa varchar(60);

    

    If pRangos = 0 then 

        Select Empresa from config into vEmpresa;

        

        

        If pLinea1 is null then

            Select min(linea) from conteo where bodega = pBodega into pLinea1;

        End if;

        

        If pLinea2 is null or pLinea2 < pLinea1 then

            Select max(linea) from conteo where bodega = pBodega into pLinea2;

        End if;

        

        

        Select pordesc from conteo Where bodega = pBodega limit 1 into pOrden;

        

        Select conteo.*, inarticu.artdesc, bodegas.descrip, vEmpresa as Empresa

        from conteo 

        Inner join inarticu on conteo.artcode = inarticu.artcode

        Inner join bodegas  on conteo.bodega  = bodegas.bodega

        Where conteo.bodega = pBodega

        and linea between pLinea1 and pLinea2

        Order by If(pOrden = 1,inarticu.artdesc,conteo.artcode);

    Else 

        Select min(linea) from conteo where bodega = pBodega into pLinea1;

        Select max(linea) from conteo where bodega = pBodega into pLinea2;

        

        Select pLinea1 as linea1, pLinea2 as linea2;

    End if;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_AntigSaldCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_AntigSaldCXC`(


  IN  `pClicode1`  int,


  IN  `pClicode2`  int,


  IN  `pSoloVenc`  tinyint(1),


  IN  `pSaldoMay`  double,


  IN  `pClasif1`   tinyint(2),


  IN  `pClasif2`   tinyint(2),


  IN  `pClasif3`   tinyint(2),


  IN  `pFechaDoc`  tinyint(1),


  IN  `pOrden`     tinyint(1)


)
BEGIN


	


    Declare vEmpresa varchar(60);





    


    If pOrden is null or pOrden > 5 or pOrden < 1 then


        Set pOrden = 1;


    End if;





    If pClicode1 = 0 then


        Set pClicode1 = (Select min(clicode) from inclient);


    End if;


    If pClicode2 = 0 then


        Set pClicode2 = (Select max(clicode) from inclient);


    End if;





    Set pSaldoMay = IfNull(pSaldoMay,0);


    Set pFechaDoc = IfNull(pFechaDoc,1);








    Select Empresa from config into vEmpresa;








    Create Temporary Table AntigSald


    Select


        vEmpresa as Empresa,


        b.clicode,


        b.clidesc,


        b.clitel1,


        b.clicelu,


        a.facnume,


        If(pFechaDoc,a.facfepa,a.facfech) as FechaRep,


        If(pFechaDoc = 1,'Venc','Emis') as TipoFecha,


        a.facfech,


        a.facplazo,


        a.facfepa as Vence,


        If(DateDiff(Now(),a.facfepa) < 0,0,DateDiff(Now(),a.facfepa)) as DiasVenc,


        a.facmont * a.tipoca as facmont,


        a.facsald * a.tipoca as facsald,


        Concat('0 - ',Cast(pClasif1 as char(3))) as Strclasif1,


        Concat(Cast(pClasif1 + 1 as char(3)),' - ',Cast(pClasif2 as char(3))) as Strclasif2,


        Concat(Cast(pClasif2 + 1 as char(3)),' - n') as Strclasif3


    From faencabe a


    Inner join inclient b on a.clicode = b.clicode


    Where b.clicode between pClicode1 and pClicode2


    and (a.facsald * a.tipoca) > pSaldoMay


    and a.facnd <= 0


    and a.facestado = ''


    and If(pSoloVenc = 1,DateDiff(Now(),a.facfepa) > 0,1);








    Case pOrden


        When 1 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, facsald, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, facsald, 0) as Clasif2,


                IF(DiasVenc > pClasif2, facsald, 0) as Clasif3


            from AntigSald


            Order by Vence;


        When 2 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, facsald, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, facsald, 0) as Clasif2,


                IF(DiasVenc > pClasif2, facsald, 0) as Clasif3


            from AntigSald


            Order by clicode;


        When 3 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, facsald, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, facsald, 0) as Clasif2,


                IF(DiasVenc > pClasif2, facsald, 0) as Clasif3


            from AntigSald


            Order by clidesc;


        When 4 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, facsald, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, facsald, 0) as Clasif2,


                IF(DiasVenc > pClasif2, facsald, 0) as Clasif3


            from AntigSald


            Order by facnume;


        When 5 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, facsald, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, facsald, 0) as Clasif2,


                IF(DiasVenc > pClasif2, facsald, 0) as Clasif3


            from AntigSald


            Order by facsald desc;


    End Case;





    Drop table AntigSald;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_CXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_CXC`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pVend1`     smallint,


  IN  `pVend2`     smallint,


  IN  `pResumido`  tinyint,


  IN  `pOrden`     tinyint


)
BEGIN


  


  Declare vEmpresa varchar(60);





  


  If pOrden is null or pOrden > 3 then


    Set pOrden = 3;


  End if;





  


  Set pFacfech1 = IfNull(pFacfech1,'1900-01-01');


  Set pFacfech2 = IfNull(pFacfech2,Date(Now()));





  


  


  Set pFacfech1 = date(pFacfech1);


  Set pFacfech2 = date(pFacfech2);





  


  If pVend1 = 0 then


    Set pVend1 = (Select min(vend) from vendedor);


  End if;


  If pVend2 = 0 then


    Set pVend2 = (Select max(vend) from vendedor);


  End if;





  


  Select Empresa from config into vEmpresa;





  


  Create Temporary Table cxc


      SELECT


        vEmpresa as Empresa,


        a.clicode,


        b.clidesc,


        a.facnume,


        If(a.facnd < 0,'ND','F') as tipo,


        a.facfech,


        a.facmont * a.tipoca as facmont,


        a.facsald * a.tipoca as facsald,


        a.facplazo,


        a.facfepa as Vence,


        DateDiff(Now(),a.facfech) as Dias


      FROM faencabe a


      INNER JOIN inclient b on a.clicode = b.clicode


      WHERE a.facfech BETWEEN pFacfech1 and pFacfech2


      and a.facsald <> 0


      AND a.vend BETWEEN pVend1 and pVend2


      AND a.facnd <= 0


      AND a.facestado = '';








  If pResumido = 0 then


    Case When pOrden = 0 Then


         Select * from cxc order by clidesc;





         When pOrden = 1 Then


         Select * from cxc order by facfech;





         When pOrden = 2 Then


         Select * from cxc order by facsald desc;





         When pOrden = 3 Then


         Select * from cxc order by facnume;


    End Case;


  Else


    Select


      Empresa,


      clicode,


      clidesc,


      sum(facmont) as facmont,


      sum(facsald) as facsald


    From cxc


    Group by clicode


    Order by facsald desc;


  End if;


  Drop table cxc;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_AntigSaldCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_AntigSaldCXP`(


  IN  `pProcode1`  varchar(15),


  IN  `pProcode2`  varchar(15),


  IN  `pSoloVenc`  tinyint(1),


  IN  `pSaldoMay`  double,


  IN  `pClasif1`   tinyint(2),


  IN  `pClasif2`   tinyint(2),


  IN  `pClasif3`   tinyint(2),


  IN  `pFechaDoc`  tinyint(1),


  IN  `pOrden`     tinyint(1)


)
BEGIN


	-- Autor: Bosco Garita Azofeifa


    Declare vEmpresa varchar(60);





    


    If pOrden is null or pOrden > 5 or pOrden < 1 then


        Set pOrden = 1;


    End if;





    If pProcode1 = '0' then


        Set pProcode1 = (Select min(procode) from inproved);


    End if;


    If pProcode2 = '0' then


        Set pProcode2 = (Select max(procode) from inproved);


    End if;





    Set pSaldoMay = IfNull(pSaldoMay,0);


    Set pFechaDoc = IfNull(pFechaDoc,1);








    Select Empresa from config into vEmpresa;








    Create Temporary Table AntigSald


    Select


        vEmpresa as Empresa,


        b.procode,


        b.prodesc,


        b.protel1,


        b.protel2,


        a.factura,


        If(pFechaDoc,a.fecha_pag,a.fecha_fac) as FechaRep,


        If(pFechaDoc = 1,'Venc','Emis') as TipoFecha,


        a.fecha_fac,


        a.vence_en,


        a.fecha_pag as Vence,


        If(DateDiff(Now(),a.fecha_pag) < 0,0,DateDiff(Now(),a.fecha_pag)) as DiasVenc,


        a.total_fac * a.tipoca as facmont,


        a.saldo * a.tipoca as saldo,


        Concat('0 - ',Cast(pClasif1 as char(3))) as Strclasif1,


        Concat(Cast(pClasif1 + 1 as char(3)),' - ',Cast(pClasif2 as char(3))) as Strclasif2,


        Concat(Cast(pClasif2 + 1 as char(3)),' - n') as Strclasif3


    From cxpfacturas a


    Inner join inproved b on a.procode = b.procode


    Where b.procode between pProcode1 and pProcode2


    and (a.saldo * a.tipoca) > pSaldoMay


    and a.tipo in('FAC','NCR')


    and If(pSoloVenc = 1,DateDiff(Now(),a.fecha_pag) > 0,1);





    


    Case pOrden


        When 1 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, saldo, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, saldo, 0) as Clasif2,


                IF(DiasVenc > pClasif2, saldo, 0) as Clasif3


            from AntigSald


            Order by Vence;


        When 2 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, saldo, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, saldo, 0) as Clasif2,


                IF(DiasVenc > pClasif2, saldo, 0) as Clasif3


            from AntigSald


            Order by procode;


        When 3 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, saldo, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, saldo, 0) as Clasif2,


                IF(DiasVenc > pClasif2, saldo, 0) as Clasif3


            from AntigSald


            Order by prodesc;


        When 4 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, saldo, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, saldo, 0) as Clasif2,


                IF(DiasVenc > pClasif2, saldo, 0) as Clasif3


            from AntigSald


            Order by factura;


        When 5 then


            Select


                AntigSald.*,


                IF(DiasVenc <= pClasif1, saldo, 0) as Clasif1,


                IF(DiasVenc > pClasif1 and DiasVenc <= pClasif2, saldo, 0) as Clasif2,


                IF(DiasVenc > pClasif2, saldo, 0) as Clasif3


            from AntigSald


            Order by saldo desc;


    End Case;





    Drop table AntigSald;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_CXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_CXP`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pProcode1`  varchar(15),


  IN  `pProcode2`  varchar(15),


  IN  `pResumido`  tinyint,


  IN  `pOrden`     tinyint


)
BEGIN


  # Autor:    Bosco Garita Azofeifa 26/05/2012.


  # Objet:    Obtener un RS con los documentos por pagar


  


  Declare vEmpresa varchar(60);





  # Validar el orden del reporte.


  If pOrden is null or pOrden > 3 then


    Set pOrden = 3;


  End if;





  # Si las fechas vienen nulas entonces establezco los l_mites


  Set pFacfech1 = IfNull(pFacfech1,'1900-01-01');


  Set pFacfech2 = IfNull(pFacfech2,Date(Now()));





  


  # Si alguna fecha viene con hora se le elimina.


  Set pFacfech1 = date(pFacfech1);


  Set pFacfech2 = date(pFacfech2);





  # Establecer los rangos de proveedores


  Set pProcode1 = IfNull(pProcode1,'0');


  Set pProcode2 = IfNull(pProcode2,'0');


  


  If pProcode1 = '0' then


    Set pProcode1 = (Select min(procode) from inproved);


  End if;


  If pProcode2 = '0' then


    Set pProcode2 = (Select max(procode) from inproved);


  End if;





  -- Select pProcode1, pProcode2, pFacfech1, pFacfech2;


  


  # Cargar el nombre de la empresa


  Select Empresa from config into vEmpresa;





  # Crear la tabla temporal con los datos a mostrar


  Create Temporary Table cxp


      SELECT


        vEmpresa as Empresa,


        a.procode,


        b.prodesc,


        a.factura,


        tipo,


        a.fecha_fac,


        a.total_fac * a.tipoca as monto,


        a.saldo * a.tipoca as saldo,


        a.vence_en as plazo,


        a.fecha_pag as Vence,


        DateDiff(Now(),a.fecha_fac) as Dias


      FROM cxpfacturas A


      INNER JOIN inproved B on A.procode = B.procode


      WHERE a.fecha_fac BETWEEN pFacfech1 and pFacfech2


      and a.saldo <> 0


      AND a.procode BETWEEN pProcode1 and pProcode2


      AND a.tipo in('FAC','NCR');





  If pResumido = 0 then


    # Ordenamiento para el reporte detallado


    Case When pOrden = 0 Then


         Select * from cxp order by prodesc;





         When pOrden = 1 Then


         Select * from cxp order by fecha_fac;





         When pOrden = 2 Then


         Select * from cxp order by saldo desc;





         When pOrden = 3 Then


         Select * from cxp order by factura;


    End Case;


  Else 


    # Reporte resumido


    Select


      Empresa,


      procode,


      prodesc,


      sum(monto) as monto,


      sum(saldo) as saldo


    From cxp


    Group by procode


    Order by saldo desc;


  End if;


  Drop table cxp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_DetalleCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_DetalleCXC`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pOrden`     tinyint


)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    Declare vEmpresa varchar(60);


    Declare vFacturas int;        


    Declare vOtrosDoc int;        


    Declare vDocumento int;


    Declare vmonto  double;


    Declare vNconsecutivo int;


    Declare vNeto   double;       





    


    If pOrden is null or pOrden > 3 then


		Set pOrden = 0;


    End if;





    


    Set pFacfech1 = IfNull(pFacfech1,'1900-01-01');


    Set pFacfech2 = IfNull(pFacfech2,Date(Now()));








    


    Set pFacfech1 = date(pFacfech1);


    Set pFacfech2 = date(pFacfech2);








    Select Empresa from config into vEmpresa;








    


    CREATE Temporary TABLE cxc (


        Factura  int(10) default 0,


        MontoFa  double  default 0,


        Ndebito  int(10) default 0,


        MontoND  double  default 0,


        Ncredito int(10) default 0,


        MontoNC  double  default 0,


        Abono    int(10) default 0,  


        MontoAb  double  default 0,


        nConsecutivo int AUTO_INCREMENT primary key);





    


    INSERT INTO cxc (Factura,MontoFa)


        SELECT facnume,facmont * tipoca AS facmont


        FROM faencabe


        WHERE facfech BETWEEN pFacfech1 AND pFacfech2


        AND facnd = 0


        AND facestado = ''


        AND facplazo > 0;





    


    Select count(factura) from cxc into vFacturas;


    Set vFacturas = IfNull(vFacturas,0);





    


    CREATE TEMPORARY TABLE tmpOtros (


        Documento int,


        monto     double,


        Tipo      char(1),      


        procesado char(1) not null default 'N');





    


    INSERT tmpOtros (Documento,Monto,Tipo)


        SELECT  


          recnume,monto*tipoca,'R'


        FROM pagos


        WHERE fecha BETWEEN pFacfech1 AND pFacfech2


        


        UNION ALL


        


        SELECT  


          Abs(facnume), Abs(facmont * tipoca),'C'


        FROM faencabe


        WHERE facfech BETWEEN pFacfech1 AND pFacfech2


        AND facnd > 0


        AND facestado = ''


        AND facplazo > 0


        


        UNION ALL


        


        SELECT  


          facnume, facmont * tipoca,'D'


        FROM faencabe


        WHERE facfech BETWEEN pFacfech1 and pFacfech2


        AND facnd < 0


        AND facestado = ''


        AND facplazo > 0;





    


    Select count(Documento) from tmpOtros Where Tipo = 'R' into vOtrosDoc;


    Set vOtrosDoc = IfNull(vOtrosDoc,0);





    


    WHILE vFacturas < vOtrosDoc DO


        INSERT INTO cxc (Factura) VALUES(0);


        SET vFacturas = vFacturas + 1;


    END WHILE;





    


    Select count(Documento) from tmpOtros Where Tipo = 'C' into vOtrosDoc;


    Set vOtrosDoc = IfNull(vOtrosDoc,0);








    


    


    WHILE vFacturas < vOtrosDoc DO


        INSERT INTO cxc (Factura) VALUES(0);


        SET vFacturas = vFacturas + 1;


    END WHILE;





    


    Select count(Documento) from tmpOtros Where Tipo = 'D' into vOtrosDoc;


    Set vOtrosDoc = IfNull(vOtrosDoc,0);








    


    


    WHILE vFacturas < vOtrosDoc DO


        INSERT INTO cxc (Factura) VALUES(0);


        SET vFacturas = vFacturas + 1;


    END WHILE;








    


    Select count(Documento) from tmpOtros Where Tipo = 'R' into vOtrosDoc;


    Set vOtrosDoc = IfNull(vOtrosDoc,0);





    


    WHILE vOtrosDoc > 0 DO


    


        


        SELECT Documento,monto FROM tmpOtros 


        WHERE procesado = 'N' AND Tipo = 'R' LIMIT 1 INTO vDocumento,vMonto;





        


        SELECT nConsecutivo FROM cxc


        WHERE Abono = 0 limit 1 INTO vNconsecutivo;





        


        UPDATE cxc


        SET abono = vDocumento, MontoAb = vMonto


        WHERE nConsecutivo = vNconsecutivo;





        


        UPDATE tmpOtros


        SET procesado = 'S'


        WHERE documento = vDocumento AND Tipo = 'R' AND procesado = 'N';





        


        SET vOtrosDoc = vOtrosDoc - 1;





    END WHILE;





    


    Select count(Documento) from tmpOtros Where Tipo = 'C' into vOtrosDoc;


    Set vOtrosDoc = IfNull(vOtrosDoc,0);





    


    WHILE vOtrosDoc > 0 DO





        SELECT Documento,monto FROM tmpOtros


        WHERE procesado = 'N' AND Tipo = 'C' LIMIT 1 INTO vDocumento,vMonto;





        SELECT nConsecutivo FROM cxc


        WHERE NCredito = 0 LIMIT 1 INTO vNconsecutivo;





        UPDATE cxc


			SET NCredito = vDocumento, MontoNC = vMonto


        WHERE nConsecutivo = vNconsecutivo;





        UPDATE tmpOtros


			SET procesado = 'S'


        WHERE documento = vDocumento AND Tipo = 'C' and procesado = 'N';





        SET vOtrosDoc = vOtrosDoc - 1;





    End While;





    


    Select count(Documento) from tmpOtros Where Tipo = 'D' into vOtrosDoc;


    Set vOtrosDoc = IfNull(vOtrosDoc,0);





    


    WHILE vOtrosDoc > 0 DO





        SELECT Documento,monto FROM tmpOtros


        Where procesado = 'N' AND Tipo = 'D' LIMIT 1 INTO vDocumento,vMonto;





        SELECT nConsecutivo FROM cxc


        WHERE NDebito = 0 LIMIT 1 INTO vNconsecutivo;





        UPDATE cxc


			SET NDebito = vDocumento, MontoND = vMonto


        WHERE nConsecutivo = vNconsecutivo;





        UPDATE tmpOtros


			SET procesado = 'S'


        WHERE documento = vDocumento AND Tipo = 'D' AND procesado = 'N';





        SET vOtrosDoc = vOtrosDoc - 1;





    END WHILE;





    


    Select Sum(MontoFa + MontoND - MontoNC - MontoAb) from cxc into vNeto;





    


    Case When pOrden = 0 Then


       Select


         vEmpresa as Empresa,


         cxc.*,


         vNeto as Neto


       from cxc order by Factura;





       When pOrden = 1 Then


       Select


         vEmpresa as Empresa,


         cxc.*,


         vNeto as Neto


       from cxc order by NCredito;





       When pOrden = 2 Then


       Select


         vEmpresa as Empresa,


         cxc.*,


         vNeto as Neto


       from cxc order by NDebito;





       When pOrden = 3 Then


       Select


         vEmpresa as Empresa,


         cxc.*,


         vNeto as Neto


       from cxc order by Abono;


    End Case;





    Drop table cxc;


    Drop table tmpOtros;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_DiferenciaPrecios;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_DiferenciaPrecios`(


  IN  `pFacfech1`    datetime,


  IN  `pFacfech2`    datetime,


  IN  `pTolerancia`  float,


  IN  `pUser`        char(16),


  IN  `pOrden`       tinyint(1)


)
BEGIN


  


	-- Autor: Bosco Garita Azofeifa


  Declare vUsarIVI tinyInt(1);


  Declare vEmpresa varchar(60);





  Select usarIvi, Empresa from config into vUsarIVI, vEmpresa;





  





  If pOrden is null or pOrden = 0 then


    Set pOrden = 1;


  End if;





  Select


    vEmpresa as Empresa,


    b.precio,


    a.artcode,


    c.artdesc,


    (Case b.precio


        When 1 then


        If(vUsarIVI,c.artpre1 / (1 + c.artimpv/100),1)


        When 2 then


        If(vUsarIVI,c.artpre2 / (1 + c.artimpv/100),1)


        When 3 then


        If(vUsarIVI,c.artpre3 / (1 + c.artimpv/100),1)


        When 4 then


        If(vUsarIVI,c.artpre4 / (1 + c.artimpv/100),1)


        When 5 then


        If(vUsarIVI,c.artpre5 / (1 + c.artimpv/100),1)


    End) as Vale,


    a.artprec * b.tipoca as SeVendio,


    b.facfech,


    a.facnume,


    b.user,


    a.faccant,


    ((Case b.precio


        When 1 then


        If(vUsarIVI,c.artpre1 / (1 + c.artimpv/100),1)


        When 2 then


        If(vUsarIVI,c.artpre2 / (1 + c.artimpv/100),1)


        When 3 then


        If(vUsarIVI,c.artpre3 / (1 + c.artimpv/100),1)


        When 4 then


        If(vUsarIVI,c.artpre4 / (1 + c.artimpv/100),1)


        When 5 then


        If(vUsarIVI,c.artpre5 / (1 + c.artimpv/100),1)


    End) - (a.artprec * b.tipoca)) /


    (Case b.precio


        When 1 then


        If(vUsarIVI,c.artpre1 / (1 + c.artimpv/100),1)


        When 2 then


        If(vUsarIVI,c.artpre2 / (1 + c.artimpv/100),1)


        When 3 then


        If(vUsarIVI,c.artpre3 / (1 + c.artimpv/100),1)


        When 4 then


        If(vUsarIVI,c.artpre4 / (1 + c.artimpv/100),1)


        When 5 then


        If(vUsarIVI,c.artpre5 / (1 + c.artimpv/100),1)


    End) * 100 as Porcentaje


  from fadetall a


  Inner join faencabe b on a.facnume = b.facnume and a.facnd = b.facnd


  Inner join inarticu c on a.artcode = c.artcode


  Where a.facnd = 0


  and b.facestado = ''


  and b.facfech between pFacfech1 and pFacfech2 and


  If(pUser > '',


      Substring(b.user FROM 1 FOR position('@' in b.user)-1) = pUser,


      b.user = b.user) and


  ((Case b.precio


        When 1 then


        If(vUsarIVI,c.artpre1 / (1 + c.artimpv/100),1)


        When 2 then


        If(vUsarIVI,c.artpre2 / (1 + c.artimpv/100),1)


        When 3 then


        If(vUsarIVI,c.artpre3 / (1 + c.artimpv/100),1)


        When 4 then


        If(vUsarIVI,c.artpre4 / (1 + c.artimpv/100),1)


        When 5 then


        If(vUsarIVI,c.artpre5 / (1 + c.artimpv/100),1)


    End) - (a.artprec * b.tipoca)) /


    (Case b.precio


        When 1 then


        If(vUsarIVI,c.artpre1 / (1 + c.artimpv/100),1)


        When 2 then


        If(vUsarIVI,c.artpre2 / (1 + c.artimpv/100),1)


        When 3 then


        If(vUsarIVI,c.artpre3 / (1 + c.artimpv/100),1)


        When 4 then


        If(vUsarIVI,c.artpre4 / (1 + c.artimpv/100),1)


        When 5 then


        If(vUsarIVI,c.artpre5 / (1 + c.artimpv/100),1)


    End) * 100 > pTolerancia


   Order by Case pOrden


               When 1 then a.artcode


               When 2 then c.artdesc


               When 3 then a.facnume


               When 4 then b.facfech


               When 5 then user


            End;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_DiferenciasInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_DiferenciasInv`(


  IN  `pBodega`  varchar(3),


  IN  `pOrden`   tinyint(1)


)
BEGIN


    -- Autor: Bosco Garita Azofeifa


    


    


    


    Declare vEmpresa varchar(60);


    


    Select Empresa from config into vEmpresa;


    


    


    If pOrden is null or pOrden not between 0 and 2 then


        Set pOrden = 0;


    End if;


    


    


    Create temporary table tmp


        Select


            a.linea,


            a.artcode,


            b.artdesc,


            a.cantidad,


            a.artexis,


            a.cantidad - a.artexis as diferencia,


            (a.cantidad - a.artexis) * a.artcosp as artcosp,


            vEmpresa as Empresa


        From conteo a


        Inner join inarticu b on a.artcode = b.artcode


        Where bodega = pBodega and (a.cantidad - a.artexis) <> 0;


    


    


    Case pOrden


        When 0 then


        Select * from tmp order by linea;


        


        When 1 then


        Select * from tmp order by artcode;


        


        When 2 then


        Select * from tmp order by artdesc;


    End Case;


    


    


    Drop table tmp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_DocInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_DocInv`(

	IN `pMovdocu` varchar(10),

	IN `pMovtimo` char(1),

	IN `pMovtido` tinyint(2)

)
BEGIN



    # Autor:    Bosco Garita A. 12/02/2011.



    # Objet:    Generar un Result Set con los datos de un documento (para impresión de documentos)



    #           Si el parámetro recibido en pMovtimo = 'A' o viene nulo se trata de un Ajuste



	#           Modificado por Bosco Garita 25/04/2015



	#			Determina si el documento es de CXC y si es así trae el nombre de cliente 



    



    Declare vEmpresa varchar(60); 



	Declare vClidesc varchar(50);







    Select Empresa from config into vEmpresa;







	-- Determinar si el documento es de CXC para traer el nombre del cliente



    Set vClidesc = '';



	If Exists(Select descrip from intiposdoc 



			  Where movtido = pMovtido and modulo = 'CXC') then



		if pMovtimo = 'E' then



			Set pMovdocu = Abs(pMovdocu); 



		End if;



		Select clidesc from faencabe, inclient



		Where facnume = pMovdocu



		and If(pMovtimo = 'S', facnd = 0, facnd > 0)



		and faencabe.clicode = inclient.clicode



		limit 1



		Into vClidesc;



		-- Select vClidesc;



	End if;











	-- Detalle del movimiento



    Select         



        a.movdocu,

        a.movtimo,

        a.artcode,

        b.barcode,   

        b.artdesc,   

        a.bodega,    

        a.movcant,

        a.movcant * a.artprec as PrecioT,

        a.movcant * a.movcoun as CostoT,

        a.movcoun,   

        a.artprec,   

        a.facimve,   

        a.facdesc,   

        c.tipoca,    

        dtoc(c.movfech) as movfech,

        c.user,      

        c.movdesc,   

        d.descrip,

        e.simbolo,

        c.estado,

	   c.movorco,

	   vClidesc as cliente,

	   vEmpresa as Empresa , pMovdocu



    From inmovimd a 

    Inner join inarticu b on a.artcode = b.artcode 

    Inner join inmovime c on a.movdocu = c.movdocu                      

    and a.movtimo = c.movtimo                      

    and a.movtido = c.movtido 

    Inner join intiposdoc d on a.movtido = d.movtido 

    Inner join monedas    e on c.codigoTC = e.codigo

    Where a.movdocu = pMovdocu

	and a.movtimo = pMovtimo

    and a.movtido = pMovtido;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_DocumentosXTipo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_DocumentosXTipo`(


	IN pFecha1 datetime, -- Fecha inicial


	IN pFecha2 datetime, -- Fecha final


	IN pOrden  tinyInt)
BEGIN


	# Autor:    Bosco Garita A. 08/02/2014.


    # Objet:    Generar un Result Set con los documentos de inventario para el rango


	# 			de fechas que el usuario seleccionó.


    


    Declare vEmpresa varchar(60);


    Select Empresa from config into vEmpresa;





	/*


	Las opciones de ordenamiento son:


	0 = Tipo de documento


	1 = Fecha del documento


	2 = Monto del documento (desc)





	Se hace el cambio para ajustar el número de acuerdo con el número de columna.


	*/


	


	Create temporary table movxtido


		Select 


			a.movdocu,


			b.descrip as Tipo_doc,


			a.movtimo,


			a.movfech,


			a.movdesc,


			(Select sum(movcoun * a.tipoca * movcant) 


			 from inmovimd 


			 Where inmovimd.movdocu = a.movdocu 


			 and inmovimd.movtimo = a.movtimo and inmovimd.movtido = a.movtido) as monto,


			vEmpresa as Empresa 


		from inmovime a, intiposdoc b


		Where a.movfech between pFecha1 and pFecha2


		and (a.estado is null or a.estado = '')


		and a.movtido = b.movtido;


	


    Case pOrden


		When 0 then


		Select * from movxtido order by 2,4;





		When 1 then


		Select * from movxtido order by 4;





		Else


		Select * from movxtido order by 6 desc;


	End Case;





	Drop table movxtido;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_EstadoDeLasCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_EstadoDeLasCXC`(


  IN  `pFecha`  datetime,


  IN  `pOrden`  tinyint


)
BEGIN


    # Autor:    Bosco Garita A. 19/03/2011.


    # Objet:    Generar un ResultSet con las facturas, ND y NC calculadas a la fecha que reciba por parámetro.


    #           Para lograrlo se usa el SP CalcularCXC(pFecha datetime) que genera la tabla temporal tmp_faencabe


    #           y de ahí se toman los datos requeridos.


    


    


    # Si la fecha viene nula se establece entonces con la fecha de hoy


    Set pFecha = IfNull(pFecha, now());


    


    # Validar el orden


    # 0=Número de documento; 1=Fecha y documento; 2=Cliente y fecha; 3=Saldo (mayor)


    If pOrden is null or pOrden not between 0 and 3 then


        Set pOrden = 0;


    End if;


    


    # Calcular los registros


    Call CalcularCXC(pFecha);


    


    Select Empresa from config into @Empresa;


    


    # Desplegar los datos


    Case pOrden


        When 0 then


        SELECT 


            tmp_faencabe.*,


            inclient.clidesc,


            pFecha as fecha,


            @Empresa as Empresa,


            If(tmp_faencabe.facnd < 0,'ND','F') as tipo 


        FROM tmp_faencabe


        INNER JOIN inclient on tmp_faencabe.clicode = inclient.clicode


        WHERE tmp_faencabe.facnd <= 0   # Solo se muestran facturas y notas de débito


        ORDER BY facnume;


        


        When 1 then


        SELECT 


            tmp_faencabe.*,


            inclient.clidesc,


            pFecha as fecha,


            @Empresa as Empresa,


            If(tmp_faencabe.facnd < 0,'ND','F') as tipo 


        FROM tmp_faencabe


        INNER JOIN inclient on tmp_faencabe.clicode = inclient.clicode


        WHERE tmp_faencabe.facnd <= 0   # Solo se muestran facturas y notas de débito


        Order by facfech,facnume;


        


        When 2 then


        SELECT 


            tmp_faencabe.*,


            inclient.clidesc,


            pFecha as fecha,


            @Empresa as Empresa,


            If(tmp_faencabe.facnd < 0,'ND','F') as tipo 


        FROM tmp_faencabe


        INNER JOIN inclient on tmp_faencabe.clicode = inclient.clicode


        WHERE tmp_faencabe.facnd <= 0   # Solo se muestran facturas y notas de débito


        Order by clidesc,facfech;


        


        When 3 then


        SELECT 


            tmp_faencabe.*,


            inclient.clidesc,


            pFecha as fecha,


            @Empresa as Empresa,


            If(tmp_faencabe.facnd < 0,'ND','F') as tipo 


        FROM tmp_faencabe


        INNER JOIN inclient on tmp_faencabe.clicode = inclient.clicode


        WHERE tmp_faencabe.facnd <= 0   # Solo se muestran facturas y notas de débito


        Order by facsald desc;


    End Case;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_EstadoCtaCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_EstadoCtaCXC`(


  IN  `pClicode`  int,


  IN  `pMeses`    smallint,


  IN  `pFCancel`  bit,


  IN  `pOrden`    tinyint


)
BEGIN





    Declare vEmpresa varchar(60);


    Declare vDesde date;


    Declare vNconsecutivo  int; 


    Declare vFacturas smallInt; 


    Declare vRecibos  smallInt; 


    Declare vRecnume  int;      


    Declare vFecha    datetime; 


    Declare vMonto    double;   


    Declare vReconc   char(1);  


    Declare vTotalCom double;   


    Declare vClisald  double;   


    Declare vClidesc  varchar(50); 


    Declare vMoneda   varchar(25);  








    If pFCancel is null or pFCancel not between 0 and 1 then


        Set pFCancel = 1;


    end if;





    -- Establecer los meses


    If pMeses is null or pMeses not between 0 and 36  then


        Set pMeses = 0;


    End if;








    If pOrden is null or pOrden not between 0 and 3  then


        Set pOrden = 3;


    End if;





    # Recalculo el saldo del cliente para garantizar la integridad de los datos.


    Call RecalcularSaldoClientes(pClicode);





    # Carlo el saldo y el nombre del cliente en variables


    Select


        clisald,


        clidesc


    from inclient Where clicode = pClicode 


    into vClisald, vClidesc;





    # Cargo la empresa y la moneda en variables


    Select empresa,descrip from config


    Inner Join monedas on config.codigoTC = monedas.codigo


    into vEmpresa,vMoneda;





    # Calculo la fecha inicial del reporte basado en los meses que el usuario eligió


    Set vDesde = date(now()) - interval pMeses month;





    # Creo una tabla temporal que tendrá todos los datos del estados de cuenta.


    CREATE TEMPORARY TABLE EstadoCTA


        (facnume int not null default 0,


        facond   char(1),      -- Factura o nota de débito


        facfech  datetime,


        facplazo smallint,


        CredCont char(2),      


        facfepa  datetime,     


        vencida  char(1),      


        facmont  double,


        facsald  double,


        recnume  int not null default 0,


        reconc   char(1),      -- Recibo o nota de crédito


        fecha    datetime,


        monto    double,


        nConsecutivo int AUTO_INCREMENT primary key);








    # Cargo las facturas y notas de débito


    Insert into EstadoCTA (


        facnume,


        facfech,


        facplazo,


        CredCont,


        facmont,


        facsald,


        facond,


        facfepa,


        vencida)


        Select


            facnume,


            facfech,


            facplazo,


            If(facplazo = 0,'CO','CR'),


            facmont*tipoca,


            facsald*tipoca,


            If(facnd = 0,'F','N'),


            facfepa,


            If(facsald > 0 and date(facfepa) < date(now()),'*','')


        From faencabe


        Where clicode = pClicode


        and (facfech >= vDesde or facsald > 0)


        and facestado = ''


        and facnume > 0


        and facnd <= 0;





    # Totalizo los montos por cobrar


    Select sum(facmont) From EstadoCTA into vTotalCom;








    # Si el usuario no quiere facturas canceladas entonces las elimino de la tabla temporal


    If pFCancel = 0 then


        Delete from EstadoCTA Where facnume > 0 and facsald <= 0;


    End if;





    # Cuento los registros para saber más adelante si se necesitan más registros en esta tabla


    Select count(facnume) from EstadoCTA into vFacturas;


    Set vFacturas = IfNull(vFacturas,0);





    # Creo la estructura temporal de los pagos y las notas de crédito


    CREATE TEMPORARY TABLE tmpPagos


        (recnume  int,


        fecha     datetime,


        monto     double,


        reconc    char(1),      -- Recibo o nota de crédito


        procesado char(1) not null default 'N');





    # Cargo los recibos y las notas de crédito


    Insert into tmpPagos (recnume,fecha,monto,reconc)


        Select recnume,fecha,monto*tipoca,'R'


        From pagos


        Where clicode = pClicode and fecha >= vDesde and estado = ''


        Union all


        Select abs(facnume),facfech,abs(facmont*tipoca),'N'


        From faencabe


        Where clicode = pClicode and facfech >= vDesde and facestado = ''


        and facnume < 0 and facnd > 0;





    # Cuento los registros de pagos y NC para comparar contra facturas y ND


    Select count(recnume) from tmpPagos into vRecibos;


    


    Set vRecibos = IfNull(vRecibos,0);








    # Agrego los registros que sean necesarios para colocar tanto facturas y ND como recibos y NC.


    While vFacturas < vRecibos Do


        Insert into EstadoCTA (recnume) values(0);


        Set vFacturas = vFacturas + 1;


    End While;





    # Proceso los recibos


    While vRecibos > 0 Do


        


        Select


            recnume,


            fecha,


            monto,


            reconc


        from tmpPagos


        Where procesado = 'N' limit 1


        into vRecnume,vFecha,vMonto,vReconc;





        # Encuentro el número de registro que se usará para el recibo en cuestión


        Select nConsecutivo from EstadoCTA


        Where recnume = 0 limit 1 into vNconsecutivo;





        # Ya el registro está en variables, ahora lo guardo en la estructura temporal principal


        Update EstadoCTA


        Set recnume = vRecnume, fecha = vFecha, monto = vMonto, reconc = vReconc


        Where nConsecutivo = vNconsecutivo;





        # Marco el registro como procesado


        Update tmpPagos


        Set procesado = 'S'


        Where recnume = vRecnume and procesado = 'N';





        # Control de registros procesados


        Set vRecibos = vRecibos - 1;





    End While;








    # Genero un ResultSet ordenado de la forma que el usuario lo solicitó


    Case pOrden


        When 0 then


            Select


                vEmpresa  as Empresa,


                vTotalCom as Compras,


                vDesde    as Desde,


                vClisald  as Saldo,


                vClidesc  as clidesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by fecha;





        When 1 then


            Select


                vEmpresa  as Empresa,


                vTotalCom as Compras,


                vDesde    as Desde,


                vClisald  as Saldo,


                vClidesc  as clidesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by facfech;





        When 2 then


            Select


                vEmpresa  as Empresa,


                vTotalCom as Compras,


                vDesde    as Desde,


                vClisald  as Saldo,


                vClidesc  as clidesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by recnume;





        When 3 then


            Select


                vEmpresa  as Empresa,


                vTotalCom as Compras,


                vDesde    as Desde,


                vClisald  as Saldo,


                vClidesc  as clidesc,


                EstadoCTA.*,


                vMoneda   as Moneda


            from EstadoCTA order by facnume;


    End Case;





    Drop table EstadoCTA;


    Drop table tmpPagos;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Existencias;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Existencias`(


  IN  `pArtcode1`  varchar(20),


  IN  `pArtcode2`  varchar(20),


  IN  `pBodega1`   varchar(3),


  IN  `pBodega2`   varchar(3),


  IN  `pnExcluir`  tinyint(1),


  IN  `pnMargen`   float,


  IN  `pnOrden`    tinyint(1),


  IN  `pnCosto`    tinyint(1),


  IN  `pnOferta`   tinyint(1)


)
BEGIN





  # Autor    : Bosco Garita 01/01/2011


  # Objetivo : Generar un listado de Existencias por bodega





  Declare vEmpresa varchar(60);





  Set vEmpresa = (Select empresa from config);





  # Establecer los rangos del reporte


  If pArtcode1 = '' or pArtcode1 is null then


    Set pArtcode1 = (Select min(artcode) from inarticu);


  End if;


  If pArtcode2 = '' or pArtcode2 is null then


    Set pArtcode2 = (Select max(artcode) from inarticu);


  End if;


  If pBodega1 = '' or pBodega1 is null then


    Set pBodega1 = (Select min(bodega) from bodegas);


  End if;


  If pBodega2 = '' or pBodega2 is null then


    Set pBodega2 = (Select max(bodega) from bodegas);


  End if;





  # Establecer el filtro de exclusión


  # 1=Excluir artículos sin existencia, 2=con existencia, 3=No excluir


  If pnExcluir is null or pnExcluir not between 1 and 3 then


    Set pnExcluir = 3;


  End if;





  # Establecer el filtro de utilidad (margen)


  # NOTA: Este filtro solo aplica para el precio uno.


  # Si este parámetro viene nulo o con un cero significa no se filtra.


  Set pnMargen = IfNull(pnMargen,0);





  # Establecer la forma de cálculo para el costo


  # 0=Costo total,1=Costo unitario


  If pnCosto is null or pnCosto not between 0 and 1 then


    Set pnCosto = 0;


  End if;





  # Establecer el orden


  # 0=Artcode,1=artdesc,2=artfam


  If pnOrden is null or pnOrden not between 0 and 2 then


    Set pnOrden = 0;


  End if;





  -- Create temporary table tmp


      Select


        bodexis.artcode,


        inarticu.artdesc,


        inarticu.artfam,


        infamily.familia,


        inarticu.artmaxi,


        bodexis.minimo as artmini,


        bodexis.artexis,


        inarticu.otroc,


        bodexis.bodega,


        bodegas.descrip,


        inarticu.artcost,


        If(pnCosto = 0,inarticu.artcosp * bodexis.artexis,inarticu.artcosp) as artcosp,


        inarticu.artcosfob,


        inarticu.artpre1,


        inarticu.artpre2,


        inarticu.artpre3,


        inarticu.artpre4,


        inarticu.artpre5,


        inarticu.artgan1 as margen1,


        inarticu.artgan2 as margen2,


        inarticu.artgan3 as margen3,


        inarticu.artgan4 as margen4,


        inarticu.artgan5 as margen5,


        inarticu.artfeuc,


        inarticu.artfeus,


        vEmpresa as Empresa


      From bodexis


      Inner join bodegas  on bodexis.bodega  = bodegas.bodega


      Inner join inarticu on bodexis.artcode = inarticu.artcode


      Inner join infamily on inarticu.artfam = infamily.artfam


      Where bodexis.artcode between pArtcode1 and pArtcode2


      and bodexis.bodega between pBodega1 and pBodega2


      and Case pnExcluir When 1 then bodexis.artexis > 0


                         When 2 then bodexis.artexis = 0


                         Else bodexis.artexis = bodexis.artexis


          End


	  and inarticu.AplicaOferta = If(pnOferta = 1, pnOferta, inarticu.AplicaOferta)


      and If(pnMargen <> 0,


            ((inarticu.artpre1 - inarticu.artcost)/inarticu.artcost*100) <= pnMargen,0=0)


      order by Case pnOrden when 0 then bodexis.artcode


                            When 1 then inarticu.artdesc


                            Else inarticu.artfam


               End;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Facturacion;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Facturacion`(


  IN  pFacfech1  datetime,


  IN  pFacfech2  datetime,


  IN  pVend1     tinyint(3),


  IN  pVend2     tinyint(3),


  IN  pUser       varchar(40),


  IN  pSoloForm  tinyint(1),


  IN  pExcServ   tinyint(1), 


  IN  pOrden     tinyint(2)


)
BEGIN


    Declare vEmpresa varchar(60);


	Declare vServicios double;





    Set vEmpresa = (Select empresa from config);


	


    


    If pFacfech1 is null then


        Set pFacfech1 = '1900-01-01';


    End if;


    If pFacfech2 is null then


        Set pFacfech2 = now();


    End if;





    If pVend1 = 0 or pVend1 is null then


        Set pVend1 = (Select min(vend) from vendedor);


    End if;


    If pVend2 = 0 or pVend2 is null then


        Set pVend2 = (Select max(vend) from vendedor);


    End if;





	if pUser > '' then


		Set pUser = Concat(trim(pUser), '@%');


	End if;





	





    


    Set pOrden = IfNull(pOrden,1);








    


    Select


        facnume,


        nombre as vendedor,     


        inclient.clidesc,


        formulario,


        If(facplazo > 0, 'CR', 'CO') as Tipo,


        facfech,


        If(facestado = ' ',


			(facmont - facimve + facdesc) * tipoca - If(pExcServ = 1,FacturacionServiciosF(a.facnume,a.facnd), 0), 0) as SubTotal,


        If(facestado = ' ',facdesc * tipoca,0) as Descuento,


        If(facestado = ' ',facimve * tipoca,0) as IV,


        If(facestado = ' ',facmont * tipoca - If(pExcServ = 1,FacturacionServiciosF(a.facnume,a.facnd), 0),0) as Total,


        If(facestado = ' ', ConsultarVentaExenta(facnume),0) * tipoca as Exento,


        If(facestado = 'A', 'Nula', ' ') as Estado,


        CASE  


             When factipo = 0 and facnume < 0 and facplazo = 0 and faccsfc = 1 then 'Efectivo'  


             When factipo = 0 or facplazo > 0 then 'Desconocido'


             When factipo = 1 then 'Efectivo'


             When factipo = 2 then 'Cheque'


             When factipo = 3 then 'Tarjeta'


             Else 'Error'


        END as FormaPago,


        precio,


		a.facfechac,


        vEmpresa as Empresa


    From faencabe a


    Inner join vendedor on a.vend    = vendedor.vend


    Inner join inclient on a.clicode = inclient.clicode


    Where facfech >= pFacfech1 and facfech <= pFacfech2


    and a.vend >= pVend1 and a.vend <= pVend2


    and If(pSoloForm = 0, a.formulario = a.formulario, a.formulario > 0)


    and a.facnd >= 0  


	and If(pUser = '', a.user = a.user, a.user like pUser)


    Order by Case pOrden 


                    When 1 then facnume


                    When 2 then vendedor


                    When 3 then clidesc


                    When 4 then formulario


                    When 5 then facfech


           End;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_IntMoratCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_IntMoratCXC`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pOrden`     tinyint


)
BEGIN





  Declare vEmpresa varchar(60);





  


  If pOrden is null or pOrden > 2 then


    Set pOrden = 0;


  End if;





  


  Set pFacfech1 = IfNull(pFacfech1,'1900-01-01');


  Set pFacfech2 = IfNull(pFacfech2,Date(Now()));





  


  Set pFacfech1 = date(pFacfech1);


  Set pFacfech2 = date(pFacfech2);


  Set pFacfech2 = pFacfech2 + interval 23 hour + interval 59 minute + interval 59 second;





  


  Select Empresa from config into vEmpresa;





  


  Create Temporary Table notasDB


    Select


      a.clicode,


      b.clidesc,


      a.facnume,


      a.facfech,


      a.facmont * a.tipoca as facmont


    from faencabe A


    Inner join inclient B on a.clicode = b.clicode


    Where a.facnume > 0 and a.facnd < 0


    and a.facfech between pFacfech1 and pFacfech2


    and a.facestado = ''


    and a.chequeotar = 'INTERESES MORATORIOS';








  Case When pOrden = 0 Then


       Select vEmpresa as Empresa,notasDB.* from notasDB order by clidesc;





       When pOrden = 1 Then


       Select vEmpresa as Empresa,notasDB.* from notasDB order by facnume;





       When pOrden = 2 Then


       Select vEmpresa as Empresa,notasDB.* from notasDB order by facfech;


  End Case;


  Drop table notasDB;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_PagaresCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_PagaresCXC`(


  IN  `pFecha1`    datetime,


  IN  `pFecha2`    datetime,


  IN  `pClicode1`  int,


  IN  `pClicode2`  int,


  IN  `pOrden`     tinyint


)
BEGIN


  


  Declare vEmpresa varchar(60);





  


  


  If pOrden is null or pOrden > 2 then


    Set pOrden = 0;


  End if;





  


  Set pFecha1 = IfNull(pFecha1,'1900-01-01');


  Set pFecha2 = IfNull(pFecha2,Date(Now()));





  


  


  Set pFecha1 = date(pFecha1);


  Set pFecha2 = date(pFecha2);





  


  Set pClicode1 = IfNull(pClicode1,0);


  Set pClicode2 = IfNull(pClicode2,0);





  


  If pClicode1 = 0 then


    Set pClicode1 = (Select min(clicode) from inclient);


  End if;


  If pClicode2 = 0 then


    Set pClicode2 = (Select max(clicode) from inclient);


  End if;





  


  Select Empresa from config into vEmpresa;





  


  Create Temporary Table tmp_Pagarescxc


    Select


      vEmpresa as Empresa,


      a.Pagare,


      a.Emision,


      a.Vencimiento,


      b.clidesc,


      a.Monto * a.tipoca as Monto,


      b.clisald


    from pagarescxc A


    Inner join inclient B on a.clicode = b.clicode


    Where a.Emision between pFecha1 and pFecha2


    and b.clicode between pClicode1 and pClicode2;








  Case When pOrden = 0 Then


       Select * from tmp_Pagarescxc order by clidesc;





       When pOrden = 1 Then


       Select * from tmp_Pagarescxc order by pagare;





       When pOrden = 2 Then


       Select * from tmp_Pagarescxc order by Emision;


  End Case;


  Drop table tmp_Pagarescxc;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_PagosCXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_PagosCXC`(


  IN  `pFecha1`    datetime,


  IN  `pFecha2`    datetime,


  IN  `pClicode1`  int,


  IN  `pClicode2`  int,


  IN  `pOrden`     tinyint


)
BEGIN


  


  Declare vEmpresa varchar(60);





  


  


  If pOrden is null or pOrden > 3 then


    Set pOrden = 1;


  End if;





  Set pFecha1 = IfNull(pFecha1,'1900-01-01');


  Set pFecha2 = IfNull(pFecha2,Date(Now()));





  


  


  Set pFecha1 = date(pFecha1);


  Set pFecha2 = date(pFecha2);





  


  If pClicode1 = 0 then


    Set pClicode1 = (Select min(clicode) from inclient);


  End if;


  If pClicode2 = 0 then


    Set pClicode2 = (Select max(clicode) from inclient);


  End if;





  


  Select Empresa from config into vEmpresa;





  


  Create Temporary Table Pagos_cxc


  SELECT


    vEmpresa as Empresa,


    a.clicode,


    b.clidesc,


    a.recnume,


    a.concepto,


    a.fecha,


    a.monto * a.tipoca as monto,


    If(a.Estado = 'A','Nulo','') as estado


  From pagos a


  Inner join inclient b on a.clicode = b.clicode


  Where a.fecha between pFecha1 and pFecha2


  and a.clicode between pClicode1 and pClicode2;








  Case When pOrden = 0 Then


       Select * from Pagos_cxc order by clidesc;





       When pOrden = 1 Then


       Select * from Pagos_cxc order by recnume;





       When pOrden = 2 Then


       Select * from Pagos_cxc order by fecha;





       When pOrden = 3 Then


       Select * from Pagos_cxc order by monto desc;


  End Case;


  Drop table Pagos_cxc;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_PagosCXP;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_PagosCXP`(


  IN  `pFecha1`    datetime,


  IN  `pFecha2`    datetime,


  IN  `pProcode1`  varchar(15),


  IN  `pProcode2`  varchar(15),


  IN  `pOrden`     tinyint


)
BEGIN


  -- Autor: Bosco Garita Azofeifa


  Declare vEmpresa varchar(60);





  


  


  If pOrden is null or pOrden > 3 then


    Set pOrden = 1;


  End if;





  Set pFecha1 = IfNull(pFecha1,'1900-01-01');


  Set pFecha2 = IfNull(pFecha2,Date(Now()));





  


  


  Set pFecha1 = date(pFecha1);


  Set pFecha2 = date(pFecha2);





  


  If pProcode1 = '' then


    Set pProcode1 = (Select min(procode) from inproved);


  End if;


  If pProcode2 = '' then


    Set pProcode2 = (Select max(procode) from inproved);


  End if;





  


  Select Empresa from config into vEmpresa;





  


  Create Temporary Table Pagos_cxp


  SELECT


    vEmpresa as Empresa,


    a.procode,


    b.prodesc,


    a.recnume,


    a.concepto,


    a.fecha,


    a.monto * a.tipoca as monto,


    If(a.Estado = 'A','Nulo','') as estado


  From cxppage a


  Inner join inproved b on a.procode = b.procode


  Where date(a.fecha) between pFecha1 and pFecha2


  and a.procode between pProcode1 and pProcode2;








  Case When pOrden = 0 Then


       Select * from Pagos_cxp order by prodesc;





       When pOrden = 1 Then


       Select * from Pagos_cxp order by recnume;





       When pOrden = 2 Then


       Select * from Pagos_cxp order by fecha;





       When pOrden = 3 Then


       Select * from Pagos_cxp order by monto desc;


  End Case;


  Drop table Pagos_cxp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_PedidosxFamilia;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_PedidosxFamilia`(


  IN  `pArtfam1`   varchar(4),


  IN  `pArtfam2`   varchar(4),


  IN  `pClientes`  tinyint(1),


  IN  `pSoloPND`   tinyint(1),


  IN  `pOrden`     tinyint(1)


)
BEGIN


  


  # Autor  : Bosco Garita 02/01/2011


  # Objet. : Generar un listado de pedidos agrupados por artículo y filtrados por familia








  Declare vEmpresa varchar(60);





  Set vEmpresa = (Select empresa from config);








  # Establezco los rangos de familias


  If pArtfam1 is null or pArtfam1 = '' then


    Select min(artfam) from infamily into pArtfam1;


  End if;


  If pArtfam2 is null or pArtfam2 = '' then


    Select max(artfam) from infamily into pArtfam2;


  End if;





  # Clientes 1=Contado, 2=Crédito,3=Todos


  If pClientes is null or pClientes not between 1 and 3 then


    Set pClientes = 3;


  End if;





  # Revisar si el usuario quiere solo pedidos no cubiertos.


  # 1=Sólo pedidos no cubiertos, 0=Todos


  If pSoloPND is null or pSoloPND not between 0 and 1 then


    Set pSoloPND = 1;


  End if;





  # Establezco el orden de despliegue de datos


  # 0=Artdesc,pedido desc; 1=Artfam,Artdesc; 2=Bodega,Artdesc





  # Genero una tabla temporal con los datos principales


  Create temporary table tmp


      Select


        a.artcode,


        b.artdesc,


        a.bodega,


        Sum(a.faccant) as pedido,


        Sum(c.artexis - c.artreserv) as Disponible,


        Sum(If(a.faccant - (c.artexis - c.artreserv) > 0, a.faccant - (c.artexis - c.artreserv),0) ) as Pedir


      from pedidod A


      Inner join inarticu B on a.artcode = b.artcode


      Inner join bodexis  C on a.artcode = c.artcode and a.bodega = c.bodega


      Inner join pedidoe  D on a.facnume = d.facnume


      Inner join inclient E on d.clicode = e.clicode


      Inner join infamily F on b.artfam  = f.artfam


      Where Case When pClientes = 1 then e.cliplaz = 0 -- Contado


                 When pClientes = 2 then e.cliplaz > 0 -- Crédito


                 Else e.cliplaz = e.cliplaz           -- Todos


            End


      and f.artfam between pArtfam1 and pArtfam2


      Group by a.artcode,b.artdesc,a.bodega;





  # Si el usuario solo quiere los pedidos no cubiertos...


  If pSoloPND = 1 then


    Delete from tmp where Pedir <= 0;


  End if;





  Case When pOrden = 0 then


        Select tmp.*,inarticu.artfam,vEmpresa as Empresa


        From tmp


        Inner join inarticu on tmp.artcode = inarticu.artcode


        Order by tmp.artdesc,tmp.pedido desc;





       When pOrden = 1 then


        Select tmp.*,inarticu.artfam,vEmpresa as Empresa


        From tmp


        Inner join inarticu on tmp.artcode = inarticu.artcode


        Order by inarticu.artfam,tmp.artdesc;





       Else


        Select tmp.*,inarticu.artfam,vEmpresa as Empresa 


        From tmp


        Inner join inarticu on tmp.artcode = inarticu.artcode


        Order by tmp.bodega, tmp.artdesc;


  End Case;





  Drop table tmp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_PedidosyAp;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_PedidosyAp`(


  IN  `pArtcode1`  varchar(20),


  IN  `pArtcode2`  varchar(20),


  IN  `pBodega`    varchar(3)


)
BEGIN


	-- Autor: Bosco Garita Azofeifa





	Declare vEmpresa varchar(60);





	Set vEmpresa = (Select empresa from config);








	If pArtcode1 is null or pArtcode1 = '' then


		Select min(artcode) from inarticu into pArtcode1;


	End if;


	If pArtcode2 is null or pArtcode2 = '' then


		Select max(artcode) from inarticu into pArtcode2;


	End if;





	Set pBodega = IfNull(pBodega,'');





	Select


		a.artcode,


		a.bodega,


		b.artdesc,


		a.faccant as Pedido,


		a.reservado,


		d.clidesc,


		a.fechaped,


		a.fechares,


		vEmpresa as Empresa


	From pedidod a


	Inner join inarticu b on b.artcode = a.artcode


	Inner join pedidoe  c on c.facnume = a.facnume


	Inner join inclient d on c.clicode = d.clicode


	Where a.artcode between pArtcode1 and pArtcode2


	and a.bodega = If(pBodega = '', a.bodega, pBodega)


	Order by b.artdesc, a.reservado desc;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_PedidosyDisponibles;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_PedidosyDisponibles`(


  IN `vPorConfirmar` tinyint(1)


)
BEGIN


    Declare vEmpresa varchar(60);


    Set vEmpresa = (Select empresa from config);





    # Definir el tipo de reporte


    # 0=Pedidos y disponibles, 1=Pedidos por confirmar


    If vPorConfirmar is null or vPorConfirmar not in (0,1) then


        Set vPorConfirmar = 0;


    End if;





    Create temporary table tmp


        Select


            c.clidesc,


            b.clicode,


            a.artcode,


            e.artdesc,


            a.bodega,


            a.faccant as pedido,


            a.reservado as apartado,


            d.artexis - d.artreserv as disponible,


            c.clitel1,


            c.clitel2,


            c.clitel3,


            c.clicelu,


            c.cliemail,


            If(c.encomienda,'SI','NO') as encomienda,


            If(c.encomienda,c.direncom,'') as direncom,


            vEmpresa as Empresa


        from pedidod A


        Inner join pedidoe  B on a.facnume = b.facnume


        Inner join inclient C on b.clicode = c.clicode


        Inner join bodexis  D on a.artcode = d.artcode and a.bodega = d.bodega


        Inner join inarticu E on a.artcode = e.artcode


        Where If(vPorConfirmar = 0, a.faccant > 0, a.faccant + a.reservado > 0);





    # Ordeno los datos dependiendo del tipo de reporte


    If vPorConfirmar = 0 then


        Select * from tmp order by artdesc,pedido desc;


    Else


        # Se eliminan aquellos pedidos que no se pueden cubrir.


        # Se mantienen los reservados y los que se puedan cubrir parcialmente.


        Delete from tmp Where pedido > 0 and apartado = 0 and disponible <= 0;


        


        Select * from tmp order by clidesc,bodega,artdesc;


    End if;


    # Elimino la tabla temporal


    Drop table tmp;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_VentasD151;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_VentasD151`(


  IN  `pFacfech1`     datetime,


  IN  `pFacfech2`     datetime,


  IN  `pClicode1`     int, 		-- Bosco agregado 12/10/2015


  IN  `pClicode2`     int, 		-- Bosco agregado 12/10/2015


  IN  `pFormularios`  tinyint(1)


)
BEGIN


	# Autor: Bosco Garita Azofeifa





	Declare vEmpresa varchar(60);


	Declare vTotalVentas double;





	Set vEmpresa = (Select empresa from config);





	# Default para las fechas inicial y final


	If pFacfech1 is null then


		Set pFacfech1 = '1900-01-01';


	End if;


	If pFacfech2 is null then


		Set pFacfech2 = now();


	End if;





	# Default para los clientes -- Bosco agregado 12/10/2015


	If pClicode1 is null or pClicode1 = 0 then


		Select min(clicode) from inclient into pClicode1;


	End if;


	If pClicode2 is null or pClicode2 = 0 then


		Select max(clicode) from inclient into pClicode2;


	End if;





	If pFormularios is null or pFormularios not between 0 and 1 then


		Set pFormularios = 1;


	End if;





	Create temporary table tmpVentasD151


		SELECT


			a.clicode, b.clidesc,


			SUM((a.facmont - a.facimve) * a.tipoca) AS venta,


			SUM(a.facimve * a.tipoca) AS facimve,


			SUM(a.facdesc * a.tipoca) AS facdesc,


			SUM(a.facmonexp * a.tipoca) AS facmonexp,


			SUM(a.facmont * a.tipoca) AS facmont


		FROM faencabe a


		LEFT  JOIN inclient b ON a.clicode = b.clicode


		WHERE a.facfech between pFacfech1 and pFacfech2


		AND a.facestado = ''


		AND a.facnd >= 0 


		AND a.clicode between pClicode1 and pClicode2 -- Bosco agregado 12/10/2015


		AND If(pFormularios = 1, a.formulario > 0, a.formulario = a.formulario)


		GROUP BY a.clicode, b.clidesc;








	Create temporary table tmpVentasD151_2


		SELECT


			clicode, clidesc,


			SUM(venta)   AS venta,


			SUM(facimve) AS facimve,


			SUM(facdesc) AS facdesc,


			SUM(facmonexp) AS facmonexp,


			SUM(facmont) AS facmont


		FROM tmpVentasD151


		GROUP BY clicode, clidesc;








	Select tmpVentasD151_2.*,vEmpresa as Empresa


	from tmpVentasD151_2 order by venta Desc;








	Drop table tmpVentasD151;


	Drop table tmpVentasD151_2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Saldos;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Saldos`(


  IN  `pArtcode1`  varchar(20),


  IN  `pArtcode2`  varchar(20),


  IN  `pBodega1`   char(3),


  IN  `pBodega2`   char(3),


  IN  `pArtfam1`   char(4),


  IN  `pArtfam2`   char(4),


  IN  `pMovfech1`  datetime,


  IN  `pMovfech2`  datetime,


  IN  `pOrden`     tinyint


)
BEGIN


   # Autor:	Bosco Garita Azofeifa.


   # Descr: Generar un RS con el saldo inicial, entradas, salidas y saldo final 


   # 	    para el rango que el usuario elija (fechas, bodegas, artículos).





   Declare vEntradas decimal(14,4);


   Declare vSalidas  decimal(14,4);


   


   Set vEntradas = 0;


   Set vSalidas  = 0;


   


   # Establecer los rangos default


   If pArtcode1 = '' or pArtcode1 is null then


     Set pArtcode1 = (Select min(artcode) from inarticu);


   End if;


   If pArtcode2 = '' or pArtcode2 is null then


     Set pArtcode2 = (Select max(artcode) from inarticu);


   End if;


   If pBodega1 = '' or pBodega1 is null then


     Set pBodega1 = (Select min(bodega) from bodegas);


   End if;


   If pBodega2 = '' or pBodega2 is null then


     Set pBodega2 = (Select max(bodega) from bodegas);


   End if;


   If pArtfam1 = '' or pArtfam1 is null then


     Set pArtfam1 = (Select min(artfam) from infamily);


   End if;


   If pArtfam2 = '' or pArtfam2 is null then


     Set pArtfam2 = (Select max(artfam) from infamily);


   End if;


   If pMovfech1 is null then


     Set pMovfech1 = '1900-01-01';


   End if;


   If pMovfech2 is null then


     Set pMovfech2 = now();


   End if;


   


   # Se toma la existencia anterior y luego se resta y suma según corresponda para obtener el nuevo saldo


   Create Temporary table Temp_Rep_Saldos


	   Select


		 bodexis.artcode,


		 bodexis.bodega,


		 bodexis.artexis as SaldoAnt,


		 Cast(0 as Decimal(14,4)) as Entradas,


		 Cast(0 as Decimal(14,4)) as Salidas


	   From bodexis


	   Inner join inarticu on bodexis.artcode = inarticu.artcode


	   Where bodexis.artcode between pArtcode1 and pArtcode2


	   and   bodexis.bodega  between pBodega1  and pBodega2


	   and   inarticu.artfam between pArtfam1  and pArtfam2;


   


   # Agregar el campo para iterar


   ALTER TABLE Temp_Rep_Saldos ADD COLUMN `recno` INT AUTO_INCREMENT, ADD PRIMARY KEY (`recno`) ;





   Set @vRango1 := (Select Min(recno) from Temp_Rep_Saldos);


   Set @vRango2 := (Select Max(recno) from Temp_Rep_Saldos);





   # Calcular el saldo anterior tomando como punto de partida la existencia actual


   # NOTA: Si el inventario no está calculado a la fecha actual entonces el resultado


   #       de este SP es incorrecto. Por esa razón debe cambiar según nota más abajo.


   While @vRango1 <= @vRango2 Do





     Set @vArtcode  := '';


     Set @vBodega   := '';


     Set vEntradas = 0.00;


     Set vSalidas  = 0.00;


     


     Select artcode,bodega from Temp_Rep_Saldos Where recno = @vRango1 into @vArtcode, @vBodega;





     # Por ahora se usa el método de restar movimientos a la existencia actual


     # más adelante esto deberá cambiar al otro método donde se busca un punto


     # de partida utilizando la tabla HBODEXIS.  Bosco 16/10/2011


     


     Select


       Sum(If(inmovimd.movtimo = 'E',movcant,0)),


       Sum(If(inmovimd.movtimo = 'S',movcant,0))


     from inmovimd


     Inner join inmovime on inmovimd.movdocu = inmovime.movdocu


            and inmovimd.movtimo = inmovime.movtimo


            and inmovimd.movtido = inmovime.movtido


     Where artcode = @vArtcode


     and bodega = @vBodega


	 and inmovime.movfech >= pMovfech1


     and (inmovime.estado is null or inmovime.estado = '')


     INTO vEntradas,vSalidas;


     


     Set vEntradas = IfNull(vEntradas, 0);


     Set vSalidas  = IfNull(vSalidas , 0);


     


     Update Temp_Rep_Saldos Set


        SaldoAnt = SaldoAnt - vEntradas + vSalidas


     Where recno = @vRango1;


     


     Set @vRangoTMP := @vRango1;


     Set @vRango1 := null;


     Set @vRango1 := (Select Min(recno) from Temp_Rep_Saldos Where recno > @vRangoTMP);


   End While; 





   


   Set @vRango1 = (Select Min(recno) from Temp_Rep_Saldos);





    # Calcular las entradas y las salidas del período


   While @vRango1 <= @vRango2 Do


     


     Set @vArtcode  := '';


     Set @vBodega   := '';


     Set vEntradas = 0;


     Set vSalidas  = 0;


     


     Select artcode,bodega from Temp_Rep_Saldos 


	 Where recno = @vRango1 INTO @vArtcode, @vBodega;





     Select


       Sum(If(inmovimd.movtimo = 'E',movcant,0)),


       Sum(If(inmovimd.movtimo = 'S',movcant,0))


     from inmovimd


     Inner join inmovime on inmovimd.movdocu = inmovime.movdocu


            and inmovimd.movtimo = inmovime.movtimo


            and inmovimd.movtido = inmovime.movtido


     Where artcode = @vArtcode


     and bodega = @vBodega


	 and inmovime.movfech between pMovfech1 and pMovfech2


     and (inmovime.estado is null or inmovime.estado = '')


     INTO vEntradas,vSalidas;





     Set vEntradas = IfNull(vEntradas, 0);


     Set vSalidas  = IfNull(vSalidas , 0);





     Update Temp_Rep_Saldos Set


       Entradas = vEntradas,


       Salidas  = vSalidas


     Where recno = @vRango1;





     Set @vRangoTMP := @vRango1;


     Set @vRango1   := null;


     


     Set @vRango1 := (Select Min(recno) from Temp_Rep_Saldos 


					  Where recno > @vRangoTMP);


   End While; 





   Select empresa from config into @vEmpresa;


   


   Select


     a.artcode,


     b.artdesc,


     a.bodega,


     b.artfam,


     a.SaldoAnt,


     a.Entradas,


     a.Salidas,


     a.SaldoAnt + a.Entradas - a.Salidas as SaldoActual,


     @vEmpresa as empresa


   From Temp_Rep_Saldos a


   Inner join inarticu b on a.artcode = b.artcode


   Order by (Case pOrden When 0 then a.artcode


                         When 1 then b.artdesc


                         When 2 then Concat(a.bodega, a.artcode)


                         When 3 then b.artfam


                         Else b.artdesc End);








   


   Drop table Temp_Rep_Saldos;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Ventasxarticulo;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Ventasxarticulo`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pArtcode1`  char(20),


  IN  `pArtcode2`  char(20),


  IN  `pOrden`     tinyint(1)


)
BEGIN


	# Autor: Bosco Garita Azofeifa


    Declare vEmpresa varchar(60);


    Declare vTotalVX decimal(14,4);





    Set vEmpresa = (Select empresa from config);





    # Establecer los varoles default


    If pFacfech1 is null then


        Set pFacfech1 = '1900-01-01';


    End if;


    If pFacfech2 is null then


        Set pFacfech2 = now();


    End if;





    If pArtcode1 is null or pArtcode1 = '' then


        Set pArtcode1 = (Select min(artcode) from inarticu);


    End if;


    


    If pArtcode2 is null or pArtcode2 = '' then


        Set pArtcode2 = (Select max(artcode) from inarticu);


    End if;


	-- Si el parámetro de orden viene nulo o fuera de rango lo ubico en el primer orden


    If pOrden is null or pOrden not between 0 and 3 then


        Set pOrden = 0;


    End if;





    Create temporary table tmpVentasxarticulo


        Select


            a.artcode,c.artdesc,


            Sum(a.faccant) as faccant,


            SUM(If(a.facnd > 0, a.artcosp * a.faccant * -1, a.artcosp * a.faccant)) AS artcosp,   


            Sum(a.facmont * b.tipoca) as facmont,


            Sum(a.facimve * b.tipoca) AS facimve,


            SUM(a.facdesc * b.tipoca) AS facdesc,


            SUM((a.facmont + a.facimve - a.facdesc) * b.tipoca) as Venta,


            SUM((a.facmont - a.facdesc) * b.tipoca) as VentaX


        from fadetall a


        Left join faencabe b on a.facnume = b.facnume and a.facnd = b.facnd


        Left join inarticu c on a.artcode = c.artcode


        Where b.facfech between pFacfech1 and pFacfech2


        and a.artcode between pArtcode1 and pArtcode2


        and b.facestado = ''


        and (b.facnd >= 0) 


        Group by a.artcode,c.artdesc;





    Create temporary table tmpVentasxarticulo2


        Select


            artcode,artdesc,


            Sum(faccant) as faccant,


            SUM(artcosp) AS artcosp,


            Sum(facmont) as facmont,


            Sum(facimve) AS facimve,


            SUM(facdesc) AS facdesc,


            SUM(Venta)   as Venta,


            SUM(VentaX)  as VentaX


        FROM tmpVentasxarticulo


        GROUP BY artcode,artdesc;


        


    Alter table tmpVentasxarticulo2 add column util double not null default 0;


    Alter table tmpVentasxarticulo2 add column porc double not null default 0;





    # Obener el total de la venta que se usa para la utilidad.


    Set vTotalVX = (Select sum(VentaX) from tmpVentasxarticulo2);


    


    # Calcular el factor de utilidad por artículo


    Update tmpVentasxarticulo2 


    Set util = If(artcosp > 0,Round((VentaX - artcosp)/artcosp*100,4),100),


        porc = Round(VentaX/vTotalVX*100,4);


    


        


    # Desplegar los datos en el orden seleccionado


    Case When pOrden = 0 Then


        Select tmpVentasxarticulo2.*,vEmpresa as Empresa


        from tmpVentasxarticulo2 order by artdesc;





    When pOrden = 1 Then


        Select tmpVentasxarticulo2.*,vEmpresa as Empresa


        from tmpVentasxarticulo2 order by faccant desc;





    When pOrden = 2 Then


        Select tmpVentasxarticulo2.*,vEmpresa as Empresa


        from tmpVentasxarticulo2 order by venta desc;





	When pOrden = 3 Then


        Select tmpVentasxarticulo2.*,vEmpresa as Empresa


        from tmpVentasxarticulo2 order by util;


    End Case;








    Drop table tmpVentasxarticulo;


    Drop table tmpVentasxarticulo2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_VentasxClientDetalle;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_VentasxClientDetalle`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pClicode`   integer,


  IN  `pOrden`     tinyint(1),


  IN  `pVen_mov`   char(20)


)
BEGIN


  


  Declare vEmpresa varchar(60);


  Declare vTotalVentas double;





  Set vEmpresa = (Select empresa from config);





  


  If pFacfech1 is null then


    Set pFacfech1 = '1900-01-01';


  End if;


  If pFacfech2 is null then


    Set pFacfech2 = now();


  End if;





  


  Set pClicode = IfNull(pClicode,0);





  


  Set pVen_mov = If(pVen_mov is null or pVen_mov not in ('V','M'),'M',pVen_mov);





  


  


  If pOrden is null or pOrden not between 0 and 2 then


    Set pOrden = 0;


  End if;





  Create temporary table tmpVentasxclienteDet


      SELECT


        a.facnume, a.facfech,


		    a.clicode, b.clidesc,


    		(a.facmont - a.facdesc + a.facimve) * a.tipoca AS SubTotal,


	    	a.facimve * a.tipoca AS facimve,


  	  	a.facdesc * a.tipoca AS facdesc,


  		  a.facmonexp * a.tipoca AS facmonexp,


        a.facmont * a.tipoca AS venta,


        Case


          When a.facnd = 0 then 'FAC'


          When a.facnd < 0 then 'ND'


          ELSE 'NC'


        End as Tipo


      FROM faencabe a


      LEFT  JOIN inclient b ON a.clicode = b.clicode


      WHERE If(pClicode = 0, a.clicode = a.clicode, a.clicode = pClicode)


      AND a.facfech between pFacfech1 and pFacfech2


      AND a.facestado = ''


      


      AND If(pVen_mov = 'V', a.facnd >= 0, a.facnd = a.facnd);








  


  Case When pOrden = 0 Then


       Select tmpVentasxclienteDet.*,vEmpresa as Empresa


       from tmpVentasxclienteDet order by clidesc,facnume;





       When pOrden = 1 Then


       Select tmpVentasxclienteDet.*,vEmpresa as Empresa


       from tmpVentasxclienteDet order by facfech,facnume;





       When pOrden = 2 Then


       Select tmpVentasxclienteDet.*,vEmpresa as Empresa


       from tmpVentasxclienteDet order by facnume,tipo;


  End Case;





  


  Drop table tmpVentasxclienteDet;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_VentasxClientDetalle2;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_VentasxClientDetalle2`(


  IN  `pFacfech1`  datetime, -- Fecha inicial


  IN  `pFacfech2`  datetime, -- Fecha final


  IN  `pClicode`   integer,  -- Código de cliente


  IN  `pOrden`     tinyint(1), -- Ordenamiento de los datos


  IN  `pVen_mov`   char(20)


)
BEGIN


  


  Declare vEmpresa varchar(60);


  Declare vTotalVentas double;





  Set vEmpresa = (Select empresa from config);





  


  If pFacfech1 is null then


    Set pFacfech1 = '1900-01-01';


  End if;


  If pFacfech2 is null then


    Set pFacfech2 = now();


  End if;





  


  Set pClicode = IfNull(pClicode,0);





  


  Set pVen_mov = If(pVen_mov is null or pVen_mov not in ('V','M'),'M',pVen_mov);





  


  


  If pOrden is null or pOrden not between 0 and 2 then


    Set pOrden = 0;


  End if;





  Create temporary table tmpVentasxclienteDet


		Select 


			d.clidesc,


			a.facnume,


			Case When a.facnd = 0 then 'FAC'


				 When a.facnd > 0 then 'NCR'


				 Else 'NDB'


			End as tipo,


			b.facfech,


			c.artdesc,


			a.faccant,


			(a.facmont - a.facdesc - a.facimve) * b.tipoca as venta


		from fadetall a


		Inner join faencabe b on a.facnume = b.facnume and a.facnd = b.facnd


		Inner join inarticu c on a.artcode = c.artcode


		Inner Join inclient d on b.clicode = d.clicode


		WHERE If(pClicode = 0, b.clicode = b.clicode, b.clicode = pClicode)


		AND b.facfech between pFacfech1 and pFacfech2


		AND b.facestado = ''


		AND If(pVen_mov = 'V', a.facnd >= 0, a.facnd = a.facnd);





  


  Case When pOrden = 0 Then


       Select tmpVentasxclienteDet.*,vEmpresa as Empresa


       from tmpVentasxclienteDet order by clidesc,facnume;





       When pOrden = 1 Then


       Select tmpVentasxclienteDet.*,vEmpresa as Empresa


       from tmpVentasxclienteDet order by facfech,facnume;





       When pOrden = 2 Then


       Select tmpVentasxclienteDet.*,vEmpresa as Empresa


       from tmpVentasxclienteDet order by facnume,tipo;


  End Case;





  


  Drop table tmpVentasxclienteDet;


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Ventasxcliente;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Ventasxcliente`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pInClSinV`  tinyint(1),


  IN  `pOrden`     tinyint(1)


)
BEGIN


	# Autor: Bosco Garita Azofeifa








	Declare vEmpresa varchar(60);





	Set vEmpresa = (Select empresa from config);








	If pFacfech1 is null then


		Set pFacfech1 = '1900-01-01';


	End if;


	If pFacfech2 is null then


		Set pFacfech2 = now();


	End if;











	If pOrden is null or pOrden not between 0 and 2 then


		Set pOrden = 0;


	End if;





	Create temporary table tmpVentasxcli


		SELECT


			b.clicode,b.terr,c.clidesc,


			SUM(a.faccant) as faccant,


			SUM(a.facimve * b.tipoca) as facimve,


			SUM(a.facdesc * b.tipoca) as facdesc,


			SUM(a.facmont * b.tipoca) as facmont,


			SUM(a.artcosp * a.faccant) as artcosp,


			SUM((a.facmont + a.facimve - a.facdesc) * b.tipoca) as Venta


		From fadetall a


		LEFT join faencabe b on a.facnume = b.facnume and a.facnd = b.facnd


		LEFT join inclient c on b.clicode = c.clicode


		Where b.facfech between pFacfech1 and pFacfech2


		AND a.facnd >= 0


		AND b.facestado = ''


		and b.facnd >= 0  


		Group by b.clicode,b.terr,c.clidesc;








	Create temporary table tmpVentasxcli2


		SELECT


			clicode,terr,clidesc,


			SUM(faccant) as faccant,


			SUM(facimve) AS facimve,


			SUM(facdesc) AS facdesc,


			SUM(facmont) AS facmont,


			SUM(artcosp) AS artcosp,


			SUM(venta)   AS venta


		FROM tmpVentasxcli


		GROUP BY clicode,terr,clidesc ;








	If pInClSinV = 1 then


		Insert into tmpVentasxcli2


			Select clicode,terr,clidesc,0,0,0,0,0,0


			From inclient


			Where not exists(Select clicode from tmpVentasxcli


							 Where clicode = tmpVentasxcli.clicode);


	End if;








	Case When pOrden = 0 Then


		Select tmpVentasxcli2.*,vEmpresa as Empresa


		from tmpVentasxcli2 order by clidesc;





	When pOrden = 1 Then


		Select tmpVentasxcli2.*,vEmpresa as Empresa


		from tmpVentasxcli2 order by venta desc;





	When pOrden = 2 Then


		Select tmpVentasxcli2.*,vEmpresa as Empresa


		from tmpVentasxcli2 order by faccant desc;


	End Case;





	Drop table tmpVentasxcli;


	Drop table tmpVentasxcli2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Ventasxfamilia;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Ventasxfamilia`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pOrden`     tinyint(1)


)
BEGIN


  


  





  Declare vEmpresa varchar(60);





  Set vEmpresa = (Select empresa from config);





  


  If pFacfech1 is null then


    Set pFacfech1 = '1900-01-01';


  End if;


  If pFacfech2 is null then


    Set pFacfech2 = now();


  End if;





  


  


  If pOrden is null or pOrden not between 0 and 1 then


    Set pOrden = 0;


  End if;





  Create temporary table tmpVentasxfamilia


    Select


      c.artfam,d.familia,


      Sum(a.faccant) as faccant,


      Sum(a.facmont * b.tipoca) as facmont,


      Sum(a.facimve * b.tipoca) AS facimve,


      SUM(a.facdesc * b.tipoca) AS facdesc,


      SUM((a.facmont + a.facimve - a.facdesc) * b.tipoca) as Venta


    from fadetall A


    Left join faencabe B on a.facnume = b.facnume and a.facnd = b.facnd


    Left join inarticu C on a.artcode = c.artcode


    Left join infamily D on c.artfam  = d.artfam


    Where b.facfech between pFacfech1 and pFacfech2


    and b.facestado = ''


    and (b.facnd >= 0) 


    Group by c.artfam,d.familia;





  


  Create temporary table tmpVentasxfamilia2


    SELECT


  	  artfam, familia,


      Sum(faccant) as faccant,


    	SUM(facmont) AS facmont,


    	SUM(facimve) AS facimve,


    	SUM(facdesc) AS facdesc,


      sum(venta)   as venta


	  FROM tmpVentasxfamilia


  	GROUP BY artfam, familia ;





  


  Case When pOrden = 0 Then


       Select tmpVentasxfamilia2.*,vEmpresa as Empresa


       from tmpVentasxfamilia2 order by familia;





       When pOrden = 1 Then


       Select tmpVentasxfamilia2.*,vEmpresa as Empresa


       from tmpVentasxfamilia2 order by artfam;


  End Case;





  


  Drop table tmpVentasxfamilia;


  Drop table tmpVentasxfamilia2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Ventasxproveedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Ventasxproveedor`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pArtfam1`   varchar(4),


  IN  `pArtfam2`   varchar(4),


  IN  `pOrden`     tinyint(1)


)
BEGIN


  


  





  Declare vEmpresa varchar(60);





  Set vEmpresa = (Select empresa from config);





  


  If pFacfech1 is null then


    Set pFacfech1 = '1900-01-01';


  End if;


  If pFacfech2 is null then


    Set pFacfech2 = now();


  End if;





  If pArtfam1 = '0' or pArtfam1 is null then


    Set pArtfam1 = (Select min(artfam) from infamily);


  End if;


  If pArtfam2 = '0' or pArtfam2 is null then


    Set pArtfam2 = (Select max(artfam) from infamily);


  End if;





  


  


  If pOrden is null or pOrden not between 0 and 2 then


    Set pOrden = 0;


  End if;





  Create temporary table tmpVentasxprov


    SELECT


	    d.procode, d.prodesc, a.artcode, c.artdesc,


    	SUM(a.faccant) as faccant,


    	SUM((a.facmont + a.facimve - a.facdesc) * b.tipoca) AS venta,


    	SUM(a.facimve * b.tipoca) AS facimve,


    	SUM(a.facdesc * b.tipoca) AS facdesc,


    	SUM(a.artcosp * a.faccant) AS artcosp 


    FROM fadetall a


    LEFT JOIN faencabe b ON a.facnume = b.facnume AND a.facnd = b.facnd


    LEFT JOIN inarticu c ON a.artcode = c.artcode


    LEFT JOIN inproved d ON c.procode = d.procode


    WHERE b.facfech BETWEEN pFacfech1 and pFacfech2


    AND b.facestado = ''


    AND a.facnd >= 0


    AND c.artfam BETWEEN pArtfam1 and pArtfam2


    GROUP BY d.procode, d.prodesc, a.artcode, c.artdesc;





  


  Create temporary table tmpVentasxprov2


    SELECT


  	  procode, prodesc, artcode, artdesc,


    	SUM(faccant) as faccant,


	    SUM(venta)   AS venta,


    	SUM(facimve) AS facimve,


	    SUM(facdesc) AS facdesc,


  	  SUM(artcosp) AS artcosp


	  FROM tmpVentasxprov


  	GROUP BY procode, prodesc, artcode, artdesc ;





  


  Case When pOrden = 0 Then


       Select tmpVentasxprov2.*,vEmpresa as Empresa


       from tmpVentasxprov2 order by prodesc;





       When pOrden = 1 Then


       Select tmpVentasxprov2.*,vEmpresa as Empresa


       from tmpVentasxprov2 order by artdesc;





       When pOrden = 2 Then


       Select tmpVentasxprov2.*,vEmpresa as Empresa


       from tmpVentasxprov2 order by faccant desc;


  End Case;





  


  Drop table tmpVentasxprov;


  Drop table tmpVentasxprov2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Ventasxzona;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Ventasxzona`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pOrden`     tinyint(1)


)
BEGIN


  


  





  Declare vEmpresa varchar(60);





  Set vEmpresa = (Select empresa from config);





  


  If pFacfech1 is null then


    Set pFacfech1 = '1900-01-01';


  End if;


  If pFacfech2 is null then


    Set pFacfech2 = now();


  End if;





  


  


  If pOrden is null or pOrden not between 0 and 1 then


    Set pOrden = 0;


  End if;





  Create temporary table tmpVentasxzona


    SELECT


	    a.terr, b.DESCRIP,


    	SUM(a.facmont * a.tipoca) AS venta,


    	SUM(a.facimve * a.tipoca) AS facimve,


    	SUM(a.facdesc * a.tipoca) AS facdesc,


    	SUM(a.facmonexp * a.tipoca) AS facmonexp


  	FROM faencabe a


	  LEFT JOIN territor B ON a.terr = b.terr


  	WHERE a.facfech between pFacfech1 and pFacfech2


	  AND a.facestado = ''


  	AND a.facnd >= 0


	  GROUP BY a.terr, b.DESCRIP;





  


  Create temporary table tmpVentasxzona2


    SELECT


  	  terr, DESCRIP,


    	SUM(venta) AS venta,


    	SUM(facimve) AS facimve,


    	SUM(facdesc) AS facdesc,


    	SUM(facmonexp) AS facmonexp


	  FROM tmpVentasxzona


  	GROUP BY terr, DESCRIP ;





  


  Case When pOrden = 0 Then


       Select tmpVentasxzona2.*,vEmpresa as Empresa


       from tmpVentasxzona2 order by DESCRIP;





       When pOrden = 1 Then


       Select tmpVentasxzona2.*,vEmpresa as Empresa


       from tmpVentasxzona2 order by terr;


  End Case;





  


  Drop table tmpVentasxzona;


  Drop table tmpVentasxzona2;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS Rep_Ventasxvendedor;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `Rep_Ventasxvendedor`(


  IN  `pFacfech1`  datetime,


  IN  `pFacfech2`  datetime,


  IN  `pZona_Fam`  char(20)


)
BEGIN


  


  


  


  


  


  





  Declare vEmpresa varchar(60);


  Declare vTotalVentas double;





  Set vEmpresa = (Select empresa from config);





  


  If pFacfech1 is null then


    Set pFacfech1 = '1900-01-01';


  End if;


  If pFacfech2 is null then


    Set pFacfech2 = now();


  End if;





  


  If pZona_Fam is null or pZona_Fam not in ('Z','F') then


    Set pZona_Fam = 'Z';


  End if;





  


  If pZona_Fam = 'Z' then


    Create temporary table tmpVentasxvend


      SELECT


		    a.vend, a.terr, b.nombre, c.DESCRIP,


    		SUM(a.facmont * a.tipoca) AS venta,


	    	SUM(a.facimve * a.tipoca) AS facimve,


  	  	SUM(a.facdesc * a.tipoca) AS facdesc,


  		  SUM(a.facmonexp * a.tipoca) AS facmonexp


      FROM faencabe a


      LEFT  JOIN vendedor b ON a.vend = b.vend


      LEFT  JOIN territor c ON a.terr = c.terr


      WHERE a.facfech between pFacfech1 and pFacfech2


      AND a.facestado = ''


      AND a.facnd >= 0


      GROUP BY a.vend, a.terr, b.nombre, c.DESCRIP;





    


    Create temporary table tmpVentasxvend2


      SELECT


  	    vend, terr, nombre, DESCRIP,


  	    SUM(venta)   AS venta,


      	SUM(facimve) AS facimve,


	      SUM(facdesc) AS facdesc,


    	  SUM(facmonexp) AS facmonexp


	    FROM tmpVentasxvend


  	  GROUP BY vend, terr, nombre, DESCRIP;





    


    Alter table tmpVentasxvend2 Add column porcent double default 0.00;





    Select sum(venta) From tmpVentasxvend2 into vTotalVentas;





    Update tmpVentasxvend2


    Set porcent = venta / vTotalVentas * 100


    Where venta > 0;





    


    Select tmpVentasxvend2.*,vEmpresa as Empresa


    from tmpVentasxvend2 order by nombre, DESCRIP;





    


    Drop table tmpVentasxvend;


    Drop table tmpVentasxvend2;





  Else





    


    


    Create temporary table tmpVentasxvend


      SELECT


      	e.vend, c.artfam, e.nombre, c.familia,


      	SUM((a.facmont + a.facimve - a.facdesc)  * d.tipoca) AS venta,


    	  SUM(a.facimve * d.tipoca) AS facimve,


      	SUM(a.facdesc * d.tipoca) AS facdesc


      FROM fadetall a


      INNER JOIN inarticu b ON a.artcode = b.artcode


      LEFT  JOIN infamily c ON b.artfam = c.artfam


      INNER JOIN faencabe d ON a.facnume = d.facnume AND a.facnd = d.facnd


      LEFT  JOIN vendedor e ON d.vend = e.vend


      WHERE d.facfech between pFacfech1 and pFacfech2


      AND d.facestado = ''


      AND a.facnd >= 0


      GROUP BY e.vend, c.artfam, e.nombre, c.familia;


    


    Create temporary table tmpVentasxvend2


      SELECT


  	    vend, artfam, nombre, familia,


  	    SUM(venta)   AS venta,


      	SUM(facimve) AS facimve,


	      SUM(facdesc) AS facdesc


	    FROM tmpVentasxvend


  	  GROUP BY vend, artfam, nombre, familia;





    


    Alter table tmpVentasxvend2 Add column porcent double default 0.00;





    Select sum(venta) From tmpVentasxvend2 into vTotalVentas;





    Update tmpVentasxvend2


    Set porcent = venta / vTotalVentas * 100


    Where venta > 0;





    


    Select tmpVentasxvend2.*,vEmpresa as Empresa


    from tmpVentasxvend2 order by nombre, familia;





    


    Drop table tmpVentasxvend;


    Drop table tmpVentasxvend2;





  End if;





END$
delimiter ;
--
DROP PROCEDURE IF EXISTS TrasladarMovimientosInv;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `TrasladarMovimientosInv`(


	IN pCodigoOrigen  varchar(20),


	IN pCodigoDestino varchar(20))
BEGIN


	# Autor: Bosco Garita Azofeifa 25/12/2013


	# Este SP traslada los movimientos de un artículo a otro.


	# 


	# NOTA: Este SP no tiene control de transacciones, el programa que lo 


	#	    invoque deberá hacerlo.  Tampoco hace ninguna validación, el prog


	#		que lo invoque deberá hacer las validaciones y capturar los errores.


	# El programa que invoque este SP debe correr también los sps de recalcular


	# existencias y luego el de recalcular reservados.


	# No se deben ejecutar desde este sp porque uno de ellos maneja transacciones.





	update inmovimd 


		set artcode = pCodigoDestino 


	where artcode = pCodigoOrigen;





	update hconteo 


		set artcodeorigen = artcode, artcode = pCodigoDestino


	where artcode = pCodigoOrigen;





	update fadetall 


		set artcode = pCodigoDestino 


	where artcode = pCodigoOrigen;





	update pedidod 


		set artcode = pCodigoDestino 


	where artcode = pCodigoOrigen;


	


END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ReservarNC_CXC;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ReservarNC_CXC`(

	IN `pID` int(10),

	IN `pBodega` varchar(3),

	IN `pArtcode` varchar(20),

	IN `pFaccant` decimal(12,4),

	IN `pArtprec` decimal(12,2),

	IN `pFacpive` float,

	IN `pFacfech` datetime,

	IN `pVend` tinyint(3),

	IN `pTerr` tinyint(3),

	IN `pPrecio` tinyint(2),

	IN `pCodigoTC` char(3),

	IN `pTipoca` float,

	IN `pFacpdesc` FLOAT

)
BEGIN



	# Bosco Garita Azofeifa 07/03/2010



	# Este SP reserva los artículos para las notas de crédito

	Declare pFaccantAnterior decimal(12,4);  

	Declare pFaccantActual   decimal(12,4);  

	Declare vArtcosp         decimal(14,4);  

	Declare vResultado       tinyInt(1);     

	Declare vErrorMessage    varchar(100);   

	Declare vFacimve         decimal(12,2);  

	Declare vFacdesc         decimal(12,2);  

	Declare vFacmont         decimal(12,2);  

	Declare vFacfepa         datetime;       

	Declare vFacfppago       datetime;       

	Declare vRedondear       bit;            

	Declare vRedondearA5     bit;       

	DECLARE vCodigotarifa	VARCHAR(3);

	DECLARE vCodigoCabys	VARCHAR(20);     





	-- Setear las variables para el control de errores

	Set vResultado    = 1;

	Set vErrorMessage = '';



	Set pFacfech   = IfNull(pFacfech,now());

	Set vFacfepa   = AddDate(pFacfech, interval 1 day);

	Set vFacfppago = vFacfepa;







	-- Verificar el redondeo de los decimales

	Set vRedondear =

		 Case When pCodigoTC = (Select codigoTC from config) then (Select redondear from config)

			  else 0

		 End;





	-- Verificar el redondeo a 5 y 10

	Set vRedondearA5 =

		 Case When pCodigoTC = (Select codigoTC from config) then (Select redond5 from config)

			  else 0

		 End;





	-- Obtener el costo promedio

	-- Set vArtcosp = (Select artcosp from inarticu where artcode = pArtcode);

	Select 

		artcosp,

		codigoTarifa,

		codigoCabys

	into vArtcosp, vCodigoTarifa, vCodigoCabys

	From inarticu

	where artcode = pArtcode;





	-- Sumar la cantidad registrada (tabla de trabajo) antes de este artículo

	Set pFaccantAnterior =

		(Select sum(faccant)

		 from wrk_fadetall

		 Where id = pID and Bodega = pBodega and artcode = pArtcode);



	  Set pFaccantAnterior = ifnull(pFaccantAnterior,0);

	  Set pFaccantActual   = pFaccantAnterior + pFaccant;



	-- Validar los negativos

	If pFaccantActual < 0 then

		 Set vResultado    = 0;

		 Set vErrorMessage = '[BD] La cantidad no puede quedar negativa';

	End if;





	-- Si el artículo ya existe se suma (o resta),

	-- caso contrario se agrega.



	If (Select count(*)

		   from wrk_fadetall

		   Where id = pID and Bodega = pBodega and artcode = pArtcode) > 0 then

		Update wrk_fadetall Set

			faccant   = pFaccantActual,

			artprec   = pArtprec,

			facmont   = pFaccantActual * pArtprec,

			facpive   = pFacpive,

			codigoTarifa = pCodigoTarifa,

			codigocabys = vCodigoCabys,

			artcosp   = vArtcosp

		Where id = pID and Bodega = pBodega and artcode = pArtcode;

	Else

		Insert into wrk_fadetall (

			id,

			artcode,

			bodega,

			faccant,

			artprec,

			facmont,

			facpive,

			codigoTarifa,

			codigoCabys,

			artcosp,

			facpdesc)

		Values (

			pID,

			pArtcode,

			pBodega,

			pFaccant,

			pArtprec,

			pFaccant * pArtprec,

			pFacpive,

			vCodigoTarifa,

			vCodigoCabys,

			vArtcosp,

			pFacpdesc);

	End if; 



	if row_count() = 0 then

		Set vResultado    = 0;

		Set vErrorMessage = '[BD] No se pudo actualizar la tabla de detalle (NC)';

	End if;



	-- Si se afectaron registros proceso el resto de los datos

	if vResultado > 0 then

		-- Calcular el imnpuesto y el descuento

		Update wrk_fadetall Set

			facdesc = facmont * (facpdesc/100),

			facimve = (facmont - facdesc) * (facpive/100)

		Where id = pID;



		-- Obtener los totales para el encabezado de la NC

		Set vFacimve = (Select sum(facimve) from wrk_fadetall Where id = pID);

		Set vFacdesc = (Select sum(facdesc) from wrk_fadetall Where id = pID);

		Set vFacmont = (Select sum(facmont) from wrk_fadetall Where id = pID);

		Set vFacmont = vFacmont - vFacdesc + vFacimve;



		-- Procesar los redondeos

		if vRedondear = 1 then

			Set vFacmont = Round(vFacmont,2);

		end if;



		if vRedondearA5 = 1 then

			Set vFacmont = RedondearA5(vFacmont);

		end if;



		Update wrk_faencabe Set

			facimve    = vFacimve,

			facdesc    = vFacdesc,

			facmont    = vFacmont,

			facfech    = pFacfech,

			facplazo   = 1,

			facfepa    = vFacfepa,

			vend       = pVend,

			terr       = pTerr,

			factipo    = 0,     

			chequeotar = '',

			facnpag    = 1,

			facdpago   = 1,

			facfppago  = vFacfppago,

			facmpag    = facmont / facnpag,

			facsald    = If(facplazo > 0, facmont, 0),

			precio     = pPrecio,

			codigoTC   = pCodigoTC,

			tipoca     = pTipoca

		Where id = pID;



	End if; -- if vResultado > 0



	Select vResultado, vErrorMessage;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS ReservarPedido;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `ReservarPedido`(

	IN `pFacnume` int(10),

	IN `pClicode` int(10),

	IN `pBodega` varchar(4),

	IN `pArtcode` varchar(20),

	IN `pFaccant` double,

	IN `pReservado` double,

	IN `pArtprec` double,

	IN `pFacpive` FLOAT,

	IN `pCodigoTarifa` VARCHAR(3)

)
BEGIN

    -- Autor: Bosco Garita Azofeifa, Octubre 2011

    Declare vReservadoAnterior double;

    Declare vReservadoActual   double;

    Declare vFaccantAnterior   double;

    Declare vFaccantActual     double;

    Declare vDisponible        double;

    Declare vArtcosp           double;  

    Declare vResultado         tinyInt(1);     

    Declare vErrorMessage      varchar(80);    

    Declare vFacimve           double;  

    Declare vFacdesc           double;  

    Declare vFacmont           double;  

    Declare vFechapedAnterior  datetime;       

    Declare vFechapedActual    datetime;       



    Set vResultado    = 1;

    Set vErrorMessage = '';



    Set vArtcosp = (Select artcosp from inarticu where artcode = pArtcode);



    Set vReservadoAnterior =

        (Select sum(reservado)

        from pedidod

        Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode);



    Set vFaccantAnterior =

        (Select sum(faccant)

        from pedidod

        Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode);



    Set vReservadoAnterior = Ifnull(vReservadoAnterior,0);

    Set vReservadoActual   = vReservadoAnterior + pReservado;

    Set vFaccantAnterior   = Ifnull(vFaccantAnterior,0);

    Set vFaccantActual     = vFaccantAnterior + pFaccant;

    Set vDisponible        = ConsultarExistenciaDisponible(pArtcode,pBodega);



    Set vFechapedAnterior = null;



    If vFaccantAnterior > 0 then

        Select max(fechaped) from pedidod

        Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode

        Into vFechapedAnterior;

    End if;



    If vReservadoActual < 0 then

        Set vResultado    = 0;

        Set vErrorMessage = '[BD] La cantidad reservada no puede quedar negativa';

    End if;



    If vFaccantActual < 0 then

        Set vResultado    = 0;

        Set vErrorMessage = '[BD] El pedido no puede quedar negativo';

    End if;



    If vResultado = 1 then

        Set vFaccantActual = vFaccantActual - pReservado;



        # Bosco modificado 21/01/2012.

        # Si no se está reservando nada el sistema debe permitir que se agregue el pedido.

        -- If vDisponible - pReservado < 0 then

        If pReservado > 0 and vDisponible - pReservado < 0 then

            Set vResultado    = 0;

            Set vErrorMessage = '[BD] El disponible para este artículo es insuficiente';

        end if;

    End if;



    Set vFechapedActual = If(vFaccantActual > 0, vFechapedAnterior, null);



    If vFechapedActual is null and vFaccantActual > 0 then

        Set vFechapedActual = now();

    End if;



    If pFaccant <= 0 and pReservado >= 0 then

        If (Select count(*)

            from pedidod

            Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode) = 0 then

            Set vResultado    = 0;

            Set vErrorMessage = '[BD] El pedido no tiene registrado este artículo';

        End if;

    End if;



    If vResultado = 1 then

        Update Bodexis

        Set Artreserv = Artreserv + pReservado

        Where Artcode = pArtcode and Bodega = pBodega;



        if row_count() = 0 then

            Set vResultado = 0;

            Set vErrorMessage = '[BD] Ocurrió un error al intentar reservar la cantidad en bodega';

        End if;

    End if; -- If vResultado = 1



    If vResultado = 1 then

        If (Select count(*)

            from pedidod

            Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode) > 0 then



            Update pedidod Set

               reservado = vReservadoActual,

               faccant   = vFaccantActual,

               artprec   = pArtprec,

               facmont   = vReservadoActual * pArtprec,

               fechares  = Case When vReservadoActual > 0 and pReservado > 0 then now()

                                When vReservadoActual > 0 and fechares is not null then fechares

                                When vReservadoActual > 0 and fechares is null then now()

                                When vReservadoActual = 0 then null

                                Else null

                           End,

               facpive   = pFacpive,

               artcosp   = vArtcosp,

               codigoTarifa = pCodigoTarifa,

               fechaped  = vFechapedActual

            Where Facnume = pFacnume and Bodega = pBodega and artcode = pArtcode;

        Else

            Insert into pedidod (

              facnume,

              artcode,

              bodega,

              faccant,

              artprec,

              facmont,

              reservado,

              fechares,

              facpive,

              artcosp,

              codigoTarifa,

              fechaped)

            Values (

              pFacnume,

              pArtcode,

              pBodega,

              pFaccant - pReservado,

              pArtprec,

              pReservado * pArtprec,

              pReservado,

              Case When pReservado > 0 then now() else null end,

              pFacpive,

              vArtcosp,

              pCodigoTarifa,

              vFechapedActual);



        End if; -- If (Select count(*)..else..



        if row_count() = 0 then

            Set vResultado    = 0;

            Set vErrorMessage = '[BD] No se pudo actualizar la tabla de pedidos';

        End if;



        if vResultado > 0 then

            Update pedidod Set

                facimve = Round((facmont - facdesc) * (facpive/100),2) 

            Where facnume = pFacnume;



            Set vFacimve = (Select sum(facimve) from pedidod Where facnume = pFacnume);

            Set vFacdesc = (Select sum(facdesc) from pedidod Where facnume = pFacnume);

            Set vFacmont = (Select sum(facmont) from pedidod Where facnume = pFacnume);



            Update pedidoe Set

                facimve = vFacimve,

                facdesc = vFacdesc,

                facmont = vFacmont - vFacdesc + vFacimve

            Where facnume = pFacnume;

        End if; -- if vResultado > 0

    End if; -- If vResultado = 1



    Select vResultado, vErrorMessage;

END$
delimiter ;
--
DROP PROCEDURE IF EXISTS TrasladarPedido;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `TrasladarPedido`(

	IN `pFacnume` integer,

	IN `pArtcode` varchar(20),

	IN `pBodega` char(3)

)
BEGIN

	Declare vHayError tinyInt;     

	Declare vError varchar(500);   

	Declare vBorrarLinea tinyInt;  

	Declare vReservado Float;      

	Declare vExisteEnc tinyInt;    

	Declare vExisteDet tinyInt;    

	

	Set vHayError  = 0;

	Set vError     = '';

	Set vExisteEnc = 0;

	

	Set vReservado = IfNull((

		Select Reservado from pedidod

		Where facnume = pFacnume

		and artcode = pArtcode

		and bodega  = pBodega),0);

	

	If vReservado = 0 then

		Set vHayError = 1;

		Set vError    = '[BD] No se puede enviar a facturación una línea con reservado cero';

	End if;

	

	If vHayError = 0 then

		Set vExisteEnc = If(Exists(Select facnume from pedidofe Where facnume = pFacnume), 1, 0);

		

		INSERT INTO `pedidofd`

			(`facnume`,

			`artcode`,

			`bodega`,

			`faccant`,

			`reservado`,

			`fechares`,

			`tempres`,

			`artprec`,

			`facimve`,

			`facpive`,

			`facdesc`,

			`facmont`,

			`artcosp`,

			`facestado`,

			`fechaped`,

			`codigoTarifa`)

			SELECT 

			    `facnume`,

			    `artcode`,

			    `bodega`,

			    `faccant`,

			    `reservado`,

			    `fechares`,

			    `artprec`, -- Debe ir dos veces

			    `artprec`,

			    `facimve`,

			    `facpive`,

			    `facdesc`,

			    `facmont`,

			    `artcosp`,

			    `facestado`,

			    `fechaped`,

			    `codigoTarifa`

			FROM `pedidod`

			Where facnume = pFacnume

			and artcode = pArtcode

			and bodega  = pBodega;

		

		-- Insert into pedidofd

-- 			Select * from pedidod

-- 			Where facnume = pFacnume

-- 			and artcode = pArtcode

-- 			and bodega  = pBodega;

		

		If (Select count(*)

			  from pedidofd

			  Where facnume = pFacnume

			  and artcode = pArtcode and bodega  = pBodega) = 0 then

			

			Set vHayError = 1;

			Set vError = '[BD] Esta línea no se pudo enviar a facturación.';

		

		End if;

	End if; 

	

	If vHayError = 0 then

		Set vBorrarLinea =

			If(Exists(Select faccant from pedidod

			  Where facnume = pFacnume

			  and artcode = pArtcode

			  and bodega  = pBodega

			  and faccant > 0), 0, 1);

		

		If vBorrarLinea = 1 then

			Delete from pedidod

			Where facnume = pFacnume

			and artcode = pArtcode

			and bodega  = pBodega;

		Else

			Update pedidod Set Reservado = 0

			Where facnume = pFacnume

			and artcode = pArtcode

			and bodega  = pBodega;

		End if;

	

		If row_count() = 0 then

			Set vHayError = 1;

			Set vError    = '[BD] No se pudo actualizar la tabla de pedidos.';

		End if;

	End if;

	

	If vHayError = 0 and vExisteEnc = 0 then

		INSERT INTO `pedidofe`

		       (`facnume`,

		        `clicode`,

		        `factipo`,

		        `chequeotar`,

		        `vend`,

		        `terr`,

		        `facfech`,

		        `facplazo`,

		        `facimve`,

		        `facdesc`,

		        `facmont`,

		        `user`,

		        `precio`,

		        `facivi`)

		  Select

		        `facnume`,

		        `clicode`,

		        `factipo`,

		        `chequeotar`,

		        `vend`,

		        `terr`,

		        `facfech`,

		        `facplazo`,

		        `facimve`,

		        `facdesc`,

		        `facmont`,

		        `user`,

		        `precio`,

		        `facivi`

		  From pedidoe

		  Where facnume = pFacnume;

		If row_count() = 0 then

			Set vHayError = 1;

			Set vError = '[BD] No se pudo agregar el encabezado del pedido';

		End if;

	End if;

	

	Select vHayError, vError;



END$
delimiter ;
--
DROP PROCEDURE IF EXISTS TrasladarPedidoaSalida;
delimiter $
CREATE DEFINER=`root`@`localhost` PROCEDURE `TrasladarPedidoaSalida`(


  IN  `pFacnume`  integer,


  IN  `pArtcode`  varchar(20),


  IN  `pBodega`   char(3)


)
BEGIN


  # Autor:    Bosco Garita Azofeifa 16/05/2012


  # Objet:    Trasladar un art_culo que tiene cantidad reservada hacia la tabla transitoria de salidas.


  #           Si se produjera un error controlado entoces el select final lo mostrar_a mediante la variable vError.


  


  Declare vHayError tinyInt;     


  Declare vError varchar(500);   


  Declare vBorrarLinea tinyInt;  


                                 


  Declare vReservado Float;      





  Set vHayError  = 0;


  Set vError     = '';





  # Establecer la cantidad reservada


  Set vReservado = IfNull((


      Select Reservado from pedidod


      Where facnume = pFacnume


      and artcode = pArtcode


      and bodega  = pBodega),0);


  If vReservado = 0 then


     Set vHayError = 1;


     Set vError    = '[BD] No se puede enviar a salida una l_nea con reservado cero';


  End if;





  # Si no hay error...


  If vHayError = 0 then


     # ... inserto el registro en la tabla transitoria de salidas.


     INSERT INTO salida (


        movdocu, 


        movtimo, 


        artcode, 


        bodega, 


        procode, 


        movcant, 


        movcoun, 


        artcosfob, 


        artprec, 


        facimve, 


        facdesc, 


        movtido, 


        centroc, 


        fechaven) 


      Select 


        ltrim(a.facnume), -- conversi_n autom_tica


        'S',


        a.artcode,


        a.bodega,


        '',


        a.reservado,


        a.artcosp,


        b.artcosfob,


        a.artprec,


        a.facimve,


        a.facdesc,


        6,            -- Salida por requisici_n


        '',


        null


      From pedidod a, inarticu b


      Where a.facnume = pFacnume


      and a.artcode = pArtcode


      and a.bodega  = pBodega


      and a.artcode = b.artcode;





     If ROW_COUNT() = 0 then


          Set vHayError = 1;


          Set vError = '[BD] Esta línea no se pudo enviar a salida.';


     End if;


  End if; 





  # Si no hubo error...


  If vHayError = 0 then


     # ... actualizo la tabla de pedidos.


     Set vBorrarLinea =


         If(Exists(Select faccant from pedidod


            Where facnume = pFacnume


            and artcode = pArtcode


            and bodega  = pBodega


            and faccant > 0), 0, 1);





     If vBorrarLinea = 1 then


        Delete from pedidod


        Where facnume = pFacnume


        and artcode = pArtcode


        and bodega  = pBodega;


     Else


        Update pedidod Set Reservado = 0


        Where facnume = pFacnume


        and artcode = pArtcode


        and bodega  = pBodega;


     End if;





     If row_count() = 0 then


        Set vHayError = 1;


        Set vError    = '[BD] No se pudo actualizar la tabla de pedidos.';


    End if;





  End if;





  # Devolver el resultado de la ejecución  


  Select vHayError, vError;


END$
delimiter ;
--
--
-- Dump completed on: 2024/03/02 09:10:59
--
