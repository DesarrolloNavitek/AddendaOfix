SET DATEFIRST 7  
SET ANSI_NULLS OFF  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET LOCK_TIMEOUT-1  
SET QUOTED_IDENTIFIER OFF  
GO 
--BEGIN TRAN
--select Peso,TotalBultos,VentaOrdenCompra,EnviarA from CFDIVentaV4 where id =125970
--select Bulto,VentaDArticulo,ArtCtePresentacion,VentaDCantidad,CantidadOrden,PesoArt from CFDIVentaDV4 where id =125970

use NVTEST
go
/************************** Articulos relacionados **************************/
--BEGIN TRAN
--SELECT * FROM ArtCte WHERE Cliente = '9067'
/*
INSERT INTO ArtCte
  (Articulo, SubCuenta, Cliente, UltimoPrecio, UltimaVenta, Estatus, Presentacion, Tamano, Cantidad, Codigo)

VALUES
 ('92404815000',' ','9067',NULL,NULL,'ACTIVO','920671',NULL,1,NULL),
 ('80551806500',' ','9067',NULL,NULL,'ACTIVO','920676',NULL,1,NULL),
 ('80552406500',' ','9067',NULL,NULL,'ACTIVO','920677',NULL,1,NULL),
 ('81804805002',' ','9067',NULL,NULL,'ACTIVO','920679',NULL,1,NULL),
 ('80551201000',' ','9067',NULL,NULL,'ACTIVO','920678',NULL,1,NULL),
 ('80551203300',' ','9067',NULL,NULL,'ACTIVO','920673',NULL,1,NULL),
 ('80551206500',' ','9067',NULL,NULL,'ACTIVO','920675',NULL,1,NULL),
 ('80551803300',' ','9067',NULL,NULL,'ACTIVO','920674',NULL,1,NULL),
 ('82424805062',' ','9067',NULL,NULL,'ACTIVO','920670',NULL,1,NULL),
 ('92404815062',' ','9067',NULL,NULL,'ACTIVO','920672',NULL,1,NULL),
 ('85814810001',' ','9067',NULL,NULL,'ACTIVO','920687',NULL,1,NULL),
 ('82424805000',' ','9067',NULL,NULL,'ACTIVO','920669',NULL,1,NULL),
 ('81101205000',' ','9067',NULL,NULL,'ACTIVO','920681',NULL,1,NULL),
 ('81101805000',' ','9067',NULL,NULL,'ACTIVO','920682',NULL,1,NULL),
 ('81102405000',' ','9067',NULL,NULL,'ACTIVO','920683',NULL,1,NULL),
 ('81103605000',' ','9067',NULL,NULL,'ACTIVO','920684',NULL,1,NULL),
 ('81104805000',' ','9067',NULL,NULL,'ACTIVO','920680',NULL,1,NULL),
 ('81804801002',' ','9067',NULL,NULL,'ACTIVO','920685',NULL,1,NULL),
 ('80954502000D',' ','9067',NULL,NULL,'ACTIVO','1010076',NULL,1,NULL),
 ('80954500200D',' ','9067',NULL,NULL,'ACTIVO','1010075',NULL,1,NULL),
 ('80965003600',' ','9067',NULL,NULL,'ACTIVO','2780097',NULL,1,NULL),
 ('31604001000',' ','9067',NULL,NULL,'ACTIVO','830054',NULL,1,NULL),
 ('31604000500',' ','9067',NULL,NULL,'ACTIVO','830053',NULL,1,NULL),
 ('31606001000',' ','9067',NULL,NULL,'ACTIVO','830056',NULL,1,NULL),
 ('31606000500',' ','9067',NULL,NULL,'ACTIVO','830055',NULL,1,NULL)*/

 /************************** Sucursales del cliente **************************/
/*
UPDATE CteEnviarA SET Plano = 10 WHERE Cliente ='9067' AND ID = 2
UPDATE CteEnviarA SET Plano = 12 WHERE Cliente ='9067' AND ID = 3
UPDATE CteEnviarA SET Plano = 15WHERE Cliente ='9067' AND ID = 4
UPDATE CteEnviarA SET Plano = 16WHERE Cliente ='9067' AND ID = 5
UPDATE CteEnviarA SET Plano = 19WHERE Cliente ='9067' AND ID = 6
UPDATE CteEnviarA SET Plano = 20WHERE Cliente ='9067' AND ID = 7
UPDATE CteEnviarA SET Plano = 21WHERE Cliente ='9067' AND ID = 8
UPDATE CteEnviarA SET Plano = 30WHERE Cliente ='9067' AND ID = 9
UPDATE CteEnviarA SET Plano = 32WHERE Cliente ='9067' AND ID = 10
UPDATE CteEnviarA SET Plano = 33WHERE Cliente ='9067' AND ID = 11
UPDATE CteEnviarA SET Plano = 41WHERE Cliente ='9067' AND ID = 12
UPDATE CteEnviarA SET Plano = 50WHERE Cliente ='9067' AND ID = 13
UPDATE CteEnviarA SET Plano = 53WHERE Cliente ='9067' AND ID = 14
UPDATE CteEnviarA SET Plano = 60WHERE Cliente ='9067' AND ID = 15
UPDATE CteEnviarA SET Plano = 70WHERE Cliente ='9067' AND ID = 16
UPDATE CteEnviarA SET Plano = 13WHERE Cliente ='9067' AND ID = 17
UPDATE CteEnviarA SET Plano = 14WHERE Cliente ='9067' AND ID = 18
UPDATE CteEnviarA SET Plano = 17WHERE Cliente ='9067' AND ID = 19
UPDATE CteEnviarA SET Plano = 18WHERE Cliente ='9067' AND ID = 20
UPDATE CteEnviarA SET Plano = 31WHERE Cliente ='9067' AND ID = 21
UPDATE CteEnviarA SET Plano = 51WHERE Cliente ='9067' AND ID = 22
UPDATE CteEnviarA SET Plano = 11WHERE Cliente ='9067' AND ID = 23
UPDATE CteEnviarA SET Plano = 22WHERE Cliente ='9067' AND ID = 24
UPDATE CteEnviarA SET Plano = 71WHERE Cliente ='9067' AND ID = 25
UPDATE CteEnviarA SET Plano = 72WHERE Cliente ='9067' AND ID = 26
UPDATE CteEnviarA SET Plano = 54WHERE Cliente ='9067' AND ID = 27
UPDATE CteEnviarA SET Plano = 73WHERE Cliente ='9067' AND ID = 28
UPDATE CteEnviarA SET Plano = 34WHERE Cliente ='9067' AND ID = 29
*/
GO
/************************** Tabla detalle de la addenda **************************/
--drop table nvk_tb_DetalleAddendaOFIX
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('dbo.nvk_tb_DetalleAddendaOFIX') AND type = 'U')
CREATE TABLE dbo.nvk_tb_DetalleAddendaOFIX(

Id					int not null,
Renglon				FLOAT NOT NULL,
RenglonSub			INT	NOT NULL,
Articulo				varchar(20),
Caja					int,
Cantidad			float

--CONSTRAINT prinvk_tb_DetalleAddendaOFIX PRIMARY KEY CLUSTERED (Id, Renglon, RenglonSub)
)
GO
EXEC spADD_INDEX 'nvk_tb_DetalleAddendaOFIX', 'DetalleOfix', 'Id, Renglon, RenglonSub'

GO
/************************** STORED PROCEDURE **************************/
if exists (select * from sysobjects where id = object_id('dbo.xpInvVerificarDetalle') and sysstat & 0xf = 4) 
drop procedure dbo.xpInvVerificarDetalle
GO
CREATE PROCEDURE xpInvVerificarDetalle 
@ID						int,  
@Accion					char(20),  
@Base					char(20),  
@Empresa					char(5),  
@Usuario					char(10),  
@Modulo					char(5),  
@Mov						char(20),  
@MovID					varchar(20),  
@MovTipo					char(20),  
@MovMoneda				char(10),  
@MovTipoCambio			float,  
@Estatus					char(15),  
@EstatusNuevo			char(15),  
@FechaEmision			datetime,  
@Renglon					float,  
@RenglonSub				int,  
@Articulo				char(20),  
@Cantidad				float,  
@Importe					money,  
@ImporteNeto				money,  
@Impuestos				money,  
@ImpuestosNetos			money,  
@Ok						int  OUTPUT,  
@OkRef					varchar(255) OUTPUT  
AS 
BEGIN  
DECLARE 
@CantidadTMA				float,  
@Ordenmov				varchar(20),  
@CantidadTarima			float,
@FactorAU				float,
@Cajas					float,
@i						INT = 1


  
SELECT @OrdenMov = InvOrdenEntarimado FROM EmpresaCfgMov WHERE Empresa = @Empresa  



 IF @Modulo ='VTAS' AND @Ok IS NULL
 BEGIN
  IF @MovTipo = 'VTAS.VP' AND @Accion = 'AFECTAR'  
  BEGIN  
  --Con haber un articulo en PCKTarimaVentaPerdida debe validar todos   
    IF EXISTS (SELECT 1 FROM PCKTarimaVentaPerdida WHERE IDVenta = @ID and Reacomodar = 1 /*AND Articulo = @Articulo */)  
    BEGIN             
   SELECT @CantidadTMA = 0  
      SELECT @CantidadTMA = Sum(CantidadPicking) FROM PCKTarimaVentaPerdida WHERE IDVenta = @ID AND Empresa = @Empresa AND Articulo = @Articulo AND Reacomodar = 1  
  
      IF ISNULL(@Cantidad,0) > ISNULL(@CantidadTMA,0)  
        SELECT @Ok = 13240,   
               @OkREf = 'Articulo:'+ @Articulo + ' Cantidad perdida: '+ convert(varchar(16), ISNULL(@Cantidad,0)) + ' Cantidad a reacomodar: '+ convert(varchar(16), ISNULL(@CantidadTMA,0))  
    END  
  END
  
  IF @MovTipo = 'VTAS.F' AND @Mov ='Factura' AND @Accion = 'AFECTAR'
  BEGIN

  SELECT @FactorAU = AU.Factor 
  FROM VentaD VD
  LEFT JOIN ArtUnidad AU ON VD.Articulo = AU.Articulo AND AU.Unidad='CJA-CAJA'
WHERE ID =@ID 
AND Renglon = @Renglon 
AND RenglonSub = @RenglonSub
AND VD.Articulo=@Articulo

IF COALESCE(@FactorAU, '') <> ''
BEGIN
	   SELECT @Cajas = @Cantidad / @FactorAU
	   
			WHILE (@Cajas >= @i)
			BEGIN
				INSERT INTO nvk_tb_DetalleAddendaOFIX 
					--SELECT @Id,@Articulo,@i
					SELECT @id,@Renglon,@RenglonSub,@Articulo,@i,@FactorAU
				SET @i = @i + 1
			END
END
ELSE
SELECT @Ok = 10065, @OkRef = 'Debe indicar la unidad de empaque del articulo '+@Articulo


  END

 END
 

  IF @Modulo = 'INV' AND @Mov = @OrdenMov  
  BEGIN  
    SELECT @CantidadTarima = CantidadTarima FROM Art a WHERE Articulo = @Articulo   
 IF ISNULL(@CantidadTarima,1) <= 0.5
 BEGIN   
   SELECT @OK = 20015, @OkRef = 'Revisar configuración del artículo.  Su cantidad Tarima es 0 o 0.5: '+@Articulo   
 END  
 ELSE   
 BEGIN  
   IF @Cantidad/@CantidadTarima > 100  
     SELECT @OK = 20015, @OkRef = 'Revisar configuración del artículo.  Excede mas de 100 tarimas a generar: '+@Articulo   
    END  
  
  END  
  
RETURN  
END  

GO

/************************** CONFIGURACION MOV **************************/
IF NOT EXISTS (SELECT * FROM MovTipoCFDFlex WHERE Modulo = 'VTAS' AND Mov='Factura' AND Contacto = '9067')
INSERT INTO MovTipoCFDFlex
  (Modulo, Mov, Contacto, Comprobante, Adenda, Estatus, XSD, OrigenModulo, OrigenMov)

VALUES
  ('VTAS','Factura','9067','CFDI_4.0','OFIX','CONCLUIDO',NULL,NULL,NULL)
GO
IF NOT EXISTS (SELECT * FROM MovTipoCFDFlexD WHERE Modulo = 'VTAS' AND Mov = 'Factura' AND Contacto = '9067' AND Comprobante = 'CFDI_4.0' AND Complemento ='OFIX' AND TipoComplemento = '3')

INSERT INTO MovTipoCFDFlexD
  (Modulo, Mov, Contacto, Comprobante, Complemento, TipoComplemento)

VALUES
  ('VTAS','Factura','9067','CFDI_4.0','OFIX','3')
GO
/************************** funciones **************************/
 IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID=OBJECT_ID('dbo.fnDetalleCantidadOrigen') AND TYPE = 'fn')
DROP FUNCTION dbo.fnDetalleCantidadOrigen
GO
CREATE FUNCTION dbo.fnDetalleCantidadOrigen (@Id	int,@Empresa char(5), @Sucursal int,@Articulo varchar(20), @Renglon  float)
RETURNS FLOAT
AS
BEGIN
DECLARE
@CantidadOrden				float,
@Cantidad					float,
@CantidadPendiente			float,
@CantidadReservada			float,
@CantidadOrdenada			float


SELECT @Cantidad = ISNULL(Cantidad,0.0), @CantidadPendiente = ISNULL(CantidadPendiente,0.0), @CantidadReservada = ISNULL(CantidadReservada,0.0), @CantidadOrdenada =  ISNULL(CantidadOrdenada,0.0)  
  FROM ventad vd
 WHERE ID 
IN(
SELECT mf1.OID

FROM MovFlujo mf1
LEFT JOIN MovTipo			mt ON mt.Mov=mf1.OMov
WHERE mf1.DID = @Id
AND mf1.DModulo = 'VTAS' 
AND mf1.Sucursal =@Sucursal
AND mf1.Empresa = @Empresa 
AND mf1.Cancelado = 0
AND mt.Clave = 'VTAS.P')
AND vd.Articulo = @Articulo
AND vd.Renglon = @Renglon


SELECT @CantidadOrden = CASE WHEN @Cantidad > @CantidadPendiente THEN @Cantidad ELSE @CantidadPendiente END

RETURN(@Cantidad)
END
GO

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID=OBJECT_ID('dbo.fnTotalBultosOfix') AND TYPE = 'fn')
DROP FUNCTION dbo.fnTotalBultosOfix
GO
CREATE FUNCTION dbo.fnTotalBultosOfix (@Id	int)
RETURNS FLOAT
AS
BEGIN
DECLARE
@TotalBultos				float

SELECT @TotalBultos = (SUM (ISNULL(vd.Cantidad,0.0)/ ISNULL(a.Factor,0.0)) )
FROM VentaD vd 
LEFT JOIN ArtUnidad a ON vd.Articulo=a.Articulo 
WHERE vd.ID =@Id  
AND a.unidad ='CJA-CAJA'

RETURN(@TotalBultos)
END
GO

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE ID=OBJECT_ID('dbo.fnPesoTotal') AND TYPE = 'fn')
DROP FUNCTION dbo.fnPesoTotal
GO
CREATE FUNCTION dbo.fnPesoTotal (@Id	int)
RETURNS FLOAT
AS
BEGIN
DECLARE
@PesoT		float

SELECT @PesoT = SUM((vd.Cantidad/AU.Factor)*a.Peso)
  FROM VentaD vd
  LEFT JOIN Art a ON vd.Articulo = a.Articulo
  LEFT JOIN ArtUnidad AU ON AU.Articulo=VD.Articulo AND AU.Unidad='CJA-CAJA'
  WHERE vd.ID = @Id

RETURN(@PesoT)
END
GO
/************************** Vista **************************/
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.CFDIVentaAddendas') AND type = 'V')
DROP VIEW [dbo].[CFDIVentaAddendas]
GO
CREATE VIEW [dbo].[CFDIVentaAddendas]         
AS          
        
SELECT DISTINCT       
  Vta.ID										ID,
  CEA.Plano										EnviarA, --ADDENDA OFIX
  dbo.fnTotalBultosOfix(Vta.ID)				 AS TotalBultos, --ADDENDA OFIX
  dbo.fnPesoTotal(Vta.ID)					 AS Peso,	--ADDENDA OFIX
  Vta.OrdenCompra								VentaOrdenCompra,  --ADDENDA OFIX
  Vta.FechaOrdenCompra							VentaOrdenCompraFecha,          
  Cte.GLN										ClienteGLN,          
  Empresa.GLN									EmpresaGLN, 
  vta.Observaciones								VentaObservaciones      
 FROM Venta Vta
 JOIN Empresa ON Vta.Empresa = Empresa.Empresa              
 JOIN Cte ON Cte.Cliente = Vta.Cliente
 LEFT JOIN CteEnviarA CEA ON CEA.Cliente = vta.Cliente AND CEA.ID = vta.Sucursal
 JOIN EmpresaCFD ON Vta.Empresa = EmpresaCFD.Empresa   
GO
/*********************************************  CFDIVentaDAddendas  *************************************************************/

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID ('CFDIVentaDAddendas') AND TYPE ='V')
DROP VIEW CFDIVentaDAddendas
GO  
 CREATE VIEW CFDIVentaDAddendas
AS      
    
  SELECT      
      VD.ID,
	  Venta.Cliente,
      VD.Renglon,      
      VD.RenglonSub,
	  ADO.Caja					AS Bulto, --ADDENDA OFIX
	  TRIM(ArtCte.Presentacion) ArtCtePresentacion, --ADDENDA OFIX
	  Art.Peso AS PesoGramos, --ADDENDA OFIX
	  dbo.fnDetalleCantidadOrigen (VD.ID,Venta.Empresa,Venta.Sucursal,VD.Articulo,VD.Renglon) AS CantidadOrden, --ADDENDA OFIX
	  ado.Cantidad AS CantidadOfix, --ADDENDA OFIX
      dbo.fnXMLValor(VD.Articulo)                 VentaDArticulo, --ADDENDA OFIX     
      Art.Peso*VD.Cantidad-ISNULL(VD.CantidadObsequio,0)             PesoArt
     FROM			Venta      
    JOIN			VentaD VD    ON Venta.ID = VD.ID      
    JOIN			Art			 ON VD.Articulo = Art.Articulo
	JOIN			nvk_tb_DetalleAddendaOFIX ado ON ado.Id=VD.ID AND ado.Articulo=VD.Articulo AND ado.Renglon = VD.Renglon AND ado.RenglonSub = VD.RenglonSub
	LEFT JOIN		ArtCte		 ON VD.Articulo = ArtCte.Articulo AND ArtCte.Cliente=Venta.Cliente
   WHERE VD.RenglonTipo NOT IN ('C','E') 
     AND VD.Cantidad-ISNULL(VD.CantidadObsequio,0) <> 0  

GO
/************************** eDoc **************************/

IF EXISTS (SELECT * FROM eDoc WHERE Modulo = 'VTAS' AND eDoc = 'OFIX')
DELETE FROM eDoc WHERE Modulo = 'VTAS' AND eDoc = 'OFIX'
GO
INSERT INTO eDoc (Modulo,eDoc,TipoXML,Documento,XSD,
TipoCFD,DecimalesPorOmision,TipoCFDI,TimbrarEnTransaccion,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,UltimoCambio,UltimaCompilacion,Sellar,ComplementoConcepto)
SELECT Modulo,'OFIX',TipoXML,'
{Encabezado}
<kdsu:KDSU xmlns:kdsu="http://kdsu.tony.mx/namespace/addenda" Version="2.0">
    <kdsu:Entrega TotalPesoKg="[TotalPesoKg]" TotalBultos="[TotalBultos]" Orden="[Orden]" Sucursal="[Sucursal]"/>
<kdsu:ConceptosKDSU>
    {/Encabezado}
    {Detalle}
            <kdsu:ConceptoKDSU Bulto="[Bulto]" CodigoFactura="[CodigoFactura]" CodigoOrden="[CodigoOrden]" CantidadFactura="[CantidadFactura]" CantidadOrden="[CantidadOrden]" PesoUnidadFacturaGr="[PesoUnidadFacturaGr]"/>
    {/Detalle}
{Fin}
    </kdsu:ConceptosKDSU>
</kdsu:KDSU>
{/Fin}','',
	0,2,1,0,	CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,GETDATE(),UltimaCompilacion,Sellar,ComplementoConcepto
FROM eDoc
WHERE Modulo = 'VTAS' AND eDoc = 'TONY'

GO
/************************** eDocD **************************/
IF EXISTS (SELECT * FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX')
DELETE FROM eDocD WHERE Modulo = 'VTAS' AND eDoc = 'OFIX'
GO
INSERT INTO eDocD (Modulo,eDoc,Orden,Seccion,SubSeccionDe,Vista,Cierre,TablaSt)
SELECT Modulo,'OFIX',Orden,CASE WHEN Seccion = 'Tony' THEN 'Encabezado' WHEN Seccion = 'Detalles' THEN 'Detalle' ELSE Seccion END,SubSeccionDe,CASE WHEN Seccion ='Detalles' THEN 'CFDIVentaDAddendas' ELSE 'CFDIVentaAddendas' END,Cierre,TablaSt 
FROM eDocD 
 WHERE Modulo = 'VTAS' and eDoc = 'TONY'
GO
/************************** eDocDMapeoCampo **************************/
--begin tran
IF EXISTS (SELECT * FROM eDocDMapeoCampo WHERE Modulo = 'VTAS' and eDoc = 'OFIX')
DELETE FROM eDocDMapeoCampo WHERE Modulo = 'VTAS' AND eDoc = 'OFIX'


INSERT INTO eDocDMapeoCampo (Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Encabezado'),
'[TotalPesoKg]',
'Peso',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Pedido]' and idseccion=3188
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Encabezado'),
'[TotalBultos]',
'TotalBultos',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Peso]' and idseccion=3188
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Encabezado'),
'[Orden]',
'VentaOrdenCompra',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Paquetes]' and idseccion=3188
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Encabezado'),
'[Sucursal]',
'EnviarA',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Paquetes]' and idseccion=3188
--Detalle
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[Bulto]',
'Bulto',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[CantidadPza]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[CodigoFactura]',
'VentaDArticulo',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[CodigoTony]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[CodigoOrden]',
'ArtCtePresentacion',--CampoVista,
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Articulo]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[CantidadFactura]',
'CantidadOfix',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Articulo]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[CantidadOrden]',
'CantidadOfix',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Articulo]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[PesoUnidadFacturaGr]',
'PesoGramos',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Articulo]' and idseccion=3189

GO
/**************** XSD ***************/
/*
--select * from eDocDMapeoCampo where Modulo = 'VTAS' and eDoc = 'TEST_OFIX'
IF NOT EXISTS(SELECT * FROM eDocXSD WHERE Modulo = 'VTAS' AND Clave = 'OFIX')
DELETE FROM eDocXSD WHERE Modulo = 'VTAS' AND Clave = 'OFIX'
INSERT INTO eDocXSD (Modulo, Clave, XSD) SELECT 'VTAS', 'OFIX',
'<?xml version="1.0" encoding="utf-8"?>
<xs:schema xmlns:kdsu="http://kdsu.tony.mx/namespace/addenda" xmlns:xs="http://www.w3.org/2001/XMLSchema" targetNamespace="http://kdsu.tony.mx/namespace/addenda" attributeFormDefault="unqualified" elementFormDefault="qualified">
	<xs:element name="KDSU">
		<xs:annotation>
			<xs:documentation></xs:documentation>
		</xs:annotation>
		<xs:complexType>
			<xs:sequence>
				<xs:element name="OFIX">
                    <xs:annotation>
                        <xs:documentation></xs:documentation>
                    </xs:annotation>
					<xs:complexType>
						<xs:attribute name="TotalPesoKg" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
						<xs:attribute name="TotalBultos" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
						<xs:attribute name="Orden" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
                        <xs:attribute name="Sucursal" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
					</xs:complexType>
				</xs:element>
				<xs:element name="ListaEmpaque" minOccurs="0">
                    <xs:annotation>
                        <xs:documentation></xs:documentation>
                    </xs:annotation>
					<xs:complexType>
                        <xs:attribute name="RfcEmisor" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
                        <xs:attribute name="RfcReceptor" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
                        <xs:attribute name="Folio" type="xs:string" use="required">
                            <xs:annotation>
                                <xs:documentation></xs:documentation>
                            </xs:annotation>
                        </xs:attribute>
					</xs:complexType>
				</xs:element>
				<xs:element name="ConceptosKDSU" minOccurs="0">
                    <xs:annotation>
                        <xs:documentation></xs:documentation>
                    </xs:annotation>
					<xs:complexType>
						<xs:sequence>
							<xs:element name="ConceptoKDSU" maxOccurs="unbounded">
                                <xs:annotation>
                                    <xs:documentation></xs:documentation>
                                </xs:annotation>
								<xs:complexType>
									<xs:attribute name="Bulto" type="xs:string" use="required">
                                        <xs:annotation>
                                            <xs:documentation></xs:documentation>
                                        </xs:annotation>
                                    </xs:attribute>
									<xs:attribute name="CodigoFactura" type="xs:string" use="required">
                                        <xs:annotation>
                                            <xs:documentation></xs:documentation>
                                        </xs:annotation>
                                    </xs:attribute>
									<xs:attribute name="CodigoOrden" type="xs:string" use="required">
                                        <xs:annotation>
                                            <xs:documentation></xs:documentation>
                                        </xs:annotation>
                                    </xs:attribute>
									<xs:attribute name="CantidadFactura" type="xs:string" use="required">
                                        <xs:annotation>
                                            <xs:documentation></xs:documentation>
                                        </xs:annotation>
                                    </xs:attribute>
									<xs:attribute name="CantidadOrden" type="xs:string" use="required">
                                        <xs:annotation>
                                            <xs:documentation></xs:documentation>
                                        </xs:annotation>
                                    </xs:attribute>
									<xs:attribute name="PesoUnidadFacturaGr" type="xs:string" use="required">
                                        <xs:annotation>
                                            <xs:documentation></xs:documentation>
                                        </xs:annotation>
                                    </xs:attribute>
								</xs:complexType>
							</xs:element>
						</xs:sequence>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
			<xs:attribute name="Version" type="xs:string" fixed="2.0">
                <xs:annotation>
                    <xs:documentation></xs:documentation>
                </xs:annotation>
            </xs:attribute>
		</xs:complexType>
	</xs:element>
</xs:schema>'
*/
/* xsd table*/    

--EXEC spCFDFlexGenerarxmlSchema 'VTAS', 'OFIX'

