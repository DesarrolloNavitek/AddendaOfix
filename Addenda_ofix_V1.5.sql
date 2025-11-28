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
/************************** Vista **************************/
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID('dbo.CFDIVentaV4') AND type = 'V')
DROP VIEW [dbo].[CFDIVentaV4]
GO
CREATE VIEW [dbo].[CFDIVentaV4]          
AS          
        
SELECT DISTINCT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,Vta.ID))))) + RTRIM(LTRIM(CONVERT(varchar,Vta.ID))) +          
  REPLICATE(' ',12) + REPLICATE(' ',7) + REPLICATE(' ',50)              OrdenExportacion, -- 4v3ng3r         
  Vta.ID                           ID,
  Vta.Peso							Peso, --ADDENDA OFIX
  Vta.EnviarA						EnviarA, --ADDENDA OFIX
  dbo.fnTotalBultosOfix(Vta.ID) AS TotalBultos, --ADDENDA OFIX
  dbo.fnSerieConsecutivo(Vta.MovID)                    VentaSerie,          
  dbo.fnFolioConsecutivo(Vta.MovID)                    VentaFolio,          
  dbo.fnFechaConDiferenciaHoraria(CONVERT(datetime,Vta.FechaRegistro, 126), isnull(Sucursal.DifHorariaVerano, 0),isnull(Sucursal.DifHorariaInvierno, 0)) VentaFechaRegistro,          
  CASE WHEN ISNULL(Condicion.TipoCondicion,'') = 'Credito' AND ISNULL(FP.ClaveSAT,'') = '23' THEN '23'          
   WHEN ISNULL(Condicion.TipoCondicion,'') = 'Credito' THEN '99'          
   WHEN ISNULL(Vta.FormaPagoTipo,'') <> '' THEN FP.ClaveSAT          
   WHEN ISNULL(VC.FormaCobro1,'') <> '' THEN FP1.ClaveSAT          
   WHEN ISNULL(CteEmpresaCFD.InfoFormaPago,'') <> '' THEN FP3.ClaveSAT                 
   WHEN ISNULL(CteCFD.InfoFormaPago,'') <> '' THEN FP2.ClaveSAT          
  ELSE '99' END                          FormaPago,          
  dbo.fnXMLValor(REPLACE(REPLACE(Vta.Condicion,'(',''),')',''))             VentaCondicion,          
  dbo.fnValorTotalCFDVentaV4 (Vta.ID, 1)                   VentaSubTotal,          
  --CASE WHEN dbo.fnValorTotalCFDVentaV4 (Vta.ID, 2) = 0 THEN NULL          
  --ELSE dbo.fnValorTotalCFDVentaV4 (Vta.ID, 2) END   VentaDescuentoImporte,            
   0 VentaDescuentoImporte,          
  CASE WHEN ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN) = 1 THEN 'MXN' ELSE SATMon.Clave END        Moneda,          
  CASE WHEN ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN) = 1 THEN '1.0' ELSE Vta.TipoCambio END       VentaTipoCambio,          
  dbo.fnValorTotalCFDVentaV4 (Vta.ID, 3)                   VentaTotal,          
  SATTipComp.TipoComprobante                      TipoComprobante,          
  SATMetodoPago.IDClave                       MetodoPago,          
  EmpresaCP.ClaveCP                        LugarExpedicionEmpresa,          
  SucCP.ClaveCP                         LugarExpedicionSucursal,          
  CASE WHEN vr.SATExportacion IS NOT NULL THEN vr.SATExportacion ELSE '01' END         Exportacion ,           
  dbo.fnXMLValor(Empresa.Nombre)                     EmpresaNombre,          
  dbo.fnXMLValor(Empresa.RFC)                      EmpresaRFC,          
  Empresa.FiscalRegimen                       EmpresaRegimenFiscal,          
  dbo.fnXMLValor(Sucursal.Nombre)                     SucursalNombre,          
  dbo.fnXMLValor(Sucursal.RFC)                     SucursalRFC,          
  Sucursal.FiscalRegimen                       SucursalRegimenFiscal,          
  NULL                           FacAtrAdquirente,   --VERIFICAR ESTE CAMPO          
  CASE WHEN ISNULL(c.ClaveUsoCFDI,'') = '' THEN CteCFD.ClaveUsoCFDI          
  ELSE c.ClaveUsoCFDI END                       ClaveUsoCFDI,          
  CASE WHEN mt.CFD_TipoDeComprobante= 'traslado' AND ISNULL(mt.CartaPorte, 0) = 1  
  THEN Empresa.FiscalRegimen ELSE          
  dbo.fnDatosReceptorCP('VTAS', vta.ID, Empresa.FiscalRegimen,      (SELECT CASE WHEN vr.FiscalRegimen IS NOT NULL THEN vr.FiscalRegimen ELSE cte.FiscalRegimen END)) END   RegimenFiscalReceptor,          
  CASE WHEN SATPais.ClavePais= 'MEX' THEN NULL ELSE SATPais.ClavePais END           CteResidenciaFiscal,          
  CteCFD.NumRegIdTrib                        CteNumRegIdTrib,          
  CASE WHEN mt.CFD_TipoDeComprobante= 'traslado' AND ISNULL(mt.CartaPorte, 0) = 1  
  THEN Empresa.CodigoPostal ELSE          
  dbo.fnDatosReceptorCP('VTAS', vta.ID, SucCP.ClaveCP,          
  (SELECT CASE WHEN dbo.fnXMLValor(Cte.RFC) IN ('XAXX010101000','XEXX010101000')          
THEN SucCP.ClaveCP ELSE cte.CodigoPostal END)) END                DomicilioFiscalReceptor,          
  CASE WHEN mt.CFD_TipoDeComprobante= 'traslado' AND ISNULL(mt.CartaPorte, 0) = 1  
  THEN Empresa.Nombre ELSE          
  dbo.fnDatosReceptorCP('VTAS', vta.ID, dbo.fnXMLValor(Empresa.Nombre), dbo.fnXMLValor(Cte.Nombre)) END   ClienteNombre,         
  CASE WHEN mt.CFD_TipoDeComprobante= 'traslado' AND ISNULL(mt.CartaPorte, 0) = 1 
  THEN dbo.fnXMLValor(Empresa.RFC) ELSE          
  dbo.fnDatosReceptorCP('VTAS', vta.ID, dbo.fnXMLValor(Empresa.RFC), dbo.fnXMLValor(Cte.RFC)) END     ClienteRFC,          
  CASE WHEN Vta.Estatus IN ('CONCLUIDO','PENDIENTE') THEN 'ORIGINAL' ELSE 'DELETE' END       VentaEstatusCancelacion,          
  CASE          
   WHEN mt.Clave IN ('VTAS.F','VTAS.FM','VTAS.FR') THEN 'INVOICE'          
   WHEN mt.Clave IN ('VTAS.B','VTAS.D','VTAS.DF')  THEN 'CREDIT_NOTE'          
  END                            VentaTipoDocumento,          
  dbo.fnNumeroEnEspanol(vtce.TotalNeto-ISNULL(Vta.Retencion,0.00), CASE WHEN ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN) = 1 THEN 'M.N.' ELSE Vta.Moneda END) VentaImporteLetra,          
  Vta.OrdenCompra                         VentaOrdenCompra,          
  Vta.FechaOrdenCompra                       VentaOrdenCompraFecha,          
  CFDFolio.noAprobacion                       CFDnoAprobacion,          
  VentaEntrega.Recibo                        VentaEntregaRecibo,          
  VentaEntrega.ReciboFecha                      VentaEntregaReciboFecha,          
  Cte.GLN                           ClienteGLN,          
  CteDepto.Clave                         CteDeptoClave,          
  Empresa.GLN                          EmpresaGLN,          
  ISNULL(CteDeptoEnviarA.ProveedorID, CteEmpresaCFD.ProveedorID)             ClienteProveedorID,          
  RTRIM(ISNULL(Cte.Direccion,'') + ' ' + ISNULL(Cte.DireccionNumero,'') + ' ' +          
  ISNULL(Cte.DireccionNumeroInt,'')) + ', ' + ISNULL(Cte.Colonia,'')            ClienteDireccion,          
  Cte.Poblacion                         ClienteLocalidad,          
  Cte.CodigoPostal                        ClienteCodigoPostal,          
  Mon.Clave                          VentaMoneda,          
  CASE          
   WHEN Condicion.TipoCondicion = 'Credito' THEN 'DATE_OF_INVOICE'          
   WHEN Condicion.TipoCondicion = 'Contado' THEN 'EFFECTIVE_DATE'          
  END                            VentaTipoPago,          
  ISNULL(Condicion.DiasVencimiento,0)                    CondicionDiasVencimiento,          
  Descuento.Clave                         VentaDescuentoGlobalClave,          
  Descuento.Porcentaje                       VentaPorcentajeDescuentoGlobal   ,      
  vta.Observaciones   VentaObservaciones      
 FROM Venta Vta          
 JOIN VentaTCalcExportacion Vtce ON Vta.ID = Vtce.ID          
 JOIN MovTipo mt ON mt.Mov = Vta.Mov AND mt.Modulo = 'VTAS'          
 JOIN Mon ON Vta.Moneda = Mon.Moneda          
 JOIN Empresa ON Vta.Empresa = Empresa.Empresa          
 JOIN Sucursal ON Vta.Sucursal = Sucursal.Sucursal          
 JOIN Cte ON Cte.Cliente = Vta.Cliente          
 JOIN EmpresaCFD ON Vta.Empresa = EmpresaCFD.Empresa          
LEFT JOIN Causa c on Vta.Causa = c.Causa AND c.Modulo = 'VTAS'          
LEFT JOIN SATMoneda SATMon ON Mon.Clave = SATMon.Clave          
LEFT JOIN SATCatTipoComprobante SATTipComp ON LOWER(mt.CFD_TipoDeComprobante) = LOWER(SATTipComp.Descripcion)          
LEFT JOIN SATCatCP EmpresaCP ON Empresa.CodigoPostal = EmpresaCP.ClaveCP          
LEFT JOIN SATCatCP SucCP ON Sucursal.CodigoPostal = SucCP.ClaveCP          
LEFT JOIN FormaPago FP ON Vta.FormaPagoTipo = FP.FormaPago          
LEFT JOIN VentaCobro VC ON Vta.Id = VC.ID          
LEFT JOIN FormaPago FP1 ON VC.FormaCobro1 = FP1.FormaPago          
LEFT JOIN Condicion ON Condicion.Condicion = Vta.Condicion          
LEFT JOIN SATMetodoPago ON Condicion.CFD_metodoDePago = SATMetodoPago.Clave     
LEFT JOIN SATPais ON SATPais.Descripcion = Cte.Pais          
LEFT JOIN FiscalRegimen FiscalRegimenE ON Empresa.FiscalRegimen = FiscalRegimenE.FiscalRegimen          
LEFT JOIN FiscalRegimen FiscalRegimenS ON Sucursal.FiscalRegimen = FiscalRegimenS.FiscalRegimen          
LEFT JOIN CteCFD ON CteCFD.Cliente = Vta.Cliente          
LEFT JOIN FormaPago FP2 ON CteCFD.InfoFormaPago = FP2.FormaPago          
LEFT JOIN CFDFolio ON CFDFolio.Empresa = Vta.Empresa AND CFDFolio.Modulo = mt.ConsecutivoModulo AND CFDFolio.Mov = mt.ConsecutivoMov AND CFDFolio.FechaAprobacion <= Vta.FechaRegistro AND dbo.fnFolioConsecutivo(Vta.MovID) BETWEEN CFDFolio.FolioD AND CFDFolio.FolioA AND ISNULL(dbo.fnSerieConsecutivo(Vta.MovID),'') = ISNULL(CFDFolio.Serie,'') AND (CASE WHEN ISNULL(CFDFolio.Nivel,'') = 'Sucursal' THEN ISNULL(CFDFolio.Sucursal,0) ELSE Vta.Sucursal END) = Vta.Sucursal AND CFDFolio.Estatus = 'ALTA'          
LEFT JOIN VentaEntrega ON Vta.ID = VentaEntrega.ID          
LEFT JOIN CteDepto ON Vta.Cliente = CteDepto.Cliente AND Vta.Departamento = CteDepto.Departamento          
LEFT JOIN CteEmpresaCFD ON Vta.Cliente = CteEmpresaCFD.Cliente AND Vta.Empresa = CteEmpresaCFD.Empresa          
LEFT JOIN CteCFDFormaPago ON CteEmpresaCFD.Cliente = CteCFDFormaPago.Cliente          
LEFT JOIN FormaPago FP3 ON CteCFDFormaPago.FormaPago = FP3.FormaPago          
LEFT JOIN CteDeptoEnviarA ON CteDeptoEnviarA.Empresa = Vta.Empresa AND CteDeptoEnviarA.Departamento = Vta.Departamento AND CteDeptoEnviarA.Cliente = Vta.Cliente AND CteDeptoEnviarA.EnviarA = Vta.EnviarA          
LEFT JOIN Descuento ON Descuento.Descuento = Vta.Descuento          
LEFT JOIN VentaCFDIRelacionado vr ON vr.ID=vta.ID

GO
/*********************************************  CFDIVentaDV4  *************************************************************/

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID ('CFDIVentaDV4') AND TYPE ='V')
DROP VIEW CFDIVentaDV4
GO  
 CREATE VIEW CFDIVentaDV4
AS      
    
  SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,VD.ID))))) + RTRIM(LTRIM(CONVERT(varchar,VD.ID))) +      
      REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,CONVERT(int,VD.Renglon)))))) + RTRIM(LTRIM(CONVERT(varchar,CONVERT(int,VD.Renglon)))) +      
      REPLICATE(' ',50)     OrdenExportacion,      
      VD.ID,
	  Venta.Cliente,
      VD.Renglon,      
      VD.RenglonSub,
	  dbo.fnRenglonID('VTAS',VD.ID,VD.Renglon,VD.RenglonSub) as Bulto, --ADDENDA OFIX
	  TRIM(ArtCte.Presentacion) ArtCtePresentacion, --ADDENDA OFIX
	  dbo.fnDetalleCantidadOrigen (VD.ID,Venta.Empresa,Venta.Sucursal,VD.Articulo,VD.Renglon) AS CantidadOrden, --ADDENDA OFIX
      CPS.Clave                     ClaveProdServ,      
      CU.ClaveUnidad                    ClaveUnidad,      
      dbo.fnXMLValor(VD.Unidad)                 VentaDUnidad,      
      dbo.fnXMLValor(VD.Articulo)                 VentaDArticulo,      
      dbo.fnXMLValor(VD.SubCuenta)                 VentaDSubCuenta,      
      VD.Cantidad-ISNULL(VD.CantidadObsequio,0)             VentaDCantidad,
	  VD.Aplica,
	  VD.AplicaID,
	  VD.Cantidad,
	  VD.CantidadA,
	  VD.CantidadPendiente,
	  VD.CantidadCancelada,
	  Art.Peso*VD.Cantidad-ISNULL(VD.CantidadObsequio,0)             PesoArt,
      --CASE WHEN ISNULL(m.ObjetoImpuesto,sai.SatObjetoImp) = '03' THEN      
      --     CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00)      
      --  ELSE (vtc.SubTotalSinDL/(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))+ ((ISNULL(vtc.Impuestos, 0.00) - ISNULL(vtc.Retencion1Total, 0.00) - ISNULL(vtc.Retencion2Total, 0.00) - ISNULL(vtc.Retencion3Total, 0.00)) / (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) ) END      
      --   ELSE      
      --   CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00)      
      --ELSE vtc.SubTotalSinDL/(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) END        
      --   END    VentaDPrecio,   
         CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END)      
     ELSE (CASE WHEN vtc.RenglonTipo = 'J' THEN /*ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Importe'),0.00)*/ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.Importe END/vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))      
      END                       VentaDPrecio,  
  
      --   CASE WHEN ISNULL(m.ObjetoImpuesto,sai.SatObjetoImp) = '03' THEN      
      --     CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotalSinDL'),0.00)      
      --  ELSE vtc.SubTotalSinDL + ISNULL(vtc.Impuestos, 0.00) - ISNULL(vtc.Retencion1Total, 0.00) - ISNULL(vtc.Retencion2Total, 0.00) - ISNULL(vtc.Retencion3Total, 0.00) END      
      --   ELSE      
      --CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotalSinDL'),0.00)      
      --ELSE vtc.SubTotalSinDL END       
      --   END VentaDImporte,    
   -----  
         CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END*VD.Cantidad)      
     ELSE CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.SubTotal END*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))          
      END                       VentaDImporte,  
  
  
  
  
     -- CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1      
     --THEN CASE WHEN vtc.RenglonTipo = 'J' THEN NULLIF(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'ImpIncDescuentosTotales'),0.00) ELSE NULLIF(vtc.ImpIncDescuentosTotales,0.00) END      
     --ELSE CASE WHEN vtc.RenglonTipo = 'J' THEN NULLIF(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'DescuentosTotales'),0.00) ELSE NULLIF(vtc.DescuentosTotales,0.00) END      
     -- END              
  0  VentaDDescuentoImporte,      
      CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00)      
      ELSE vtc.SubTotal END                  VentaDImpuestoBase,      
      dbo.fnXMLValor(Art.Descripcion1)                VentaDDescripcion,      
      dbo.fnXMLValor(Art.Descripcion2)                VentaDDescripcion2,      
      SAI.CuentaPredial                   CuentaPredialV,      
      dbo.fnQueCodigo(EmpresaCFD.EAN13, VD.Articulo, VD.SubCuenta, VD.Codigo, Venta.Cliente)  EAN13,      
      dbo.fnQueCodigo(EmpresaCFD.SKU, VD.Articulo, VD.SubCuenta, VD.Codigo, Venta.Cliente)   SKUCliente,      
      U.Clave                      UnidadClave,      
      CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN  ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END)      
     ELSE (CASE WHEN vtc.RenglonTipo = 'J' THEN /*ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Importe'),0.00)*/ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.Importe END/vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))      
      END                       VentaDImporteUnitario,      
      CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.PrecioSinDL END)      
     ELSE (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.SubTotal END/Vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))      
      END                       VentaDSubTotalUnitario,      
      CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END*VD.Cantidad)      
     ELSE CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.SubTotal END*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))          
      END                       VentaDSubTotal,      
      ISNULL(m.ObjetoImpuesto,sai.SatObjetoImp)             ObjetoImp   ,
	  VD.DescripcionExtra VentaDDescripcionExtra,
	   VTC.TotalNeto  TotalNetoD
    FROM Venta      
    JOIN VentaD VD    ON Venta.ID = VD.ID      
    JOIN Art      ON VD.Articulo = Art.Articulo
	LEFT JOIN ArtCte ON VD.Articulo = ArtCte.Articulo AND ArtCte.Cliente=Venta.Cliente
  LEFT JOIN MovObjetoImpuesto m  ON m.Modulo = 'VTAS' AND m.ModuloID=VD.ID AND vd.RenglonID=m.RenglonID AND vd.Renglon = m.Renglon AND vd.RenglonSub = m.RenglonSub      
  LEFT JOIN SATArticuloInfo SAI  ON VD.Articulo = SAI.Articulo      
  LEFT JOIN Unidad U     ON ISNULL(VD.Unidad, Art.Unidad) = U.Unidad      
    JOIN EmpresaCFD    ON Venta.Empresa = EmpresaCFD.Empresa      
       JOIN MovTipo mt    ON mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov      
    JOIN EmpresaCfg    ON Venta.Empresa = EmpresaCfg.Empresa      
    JOIN VentaTCalc vtc   ON vtc.ID = VD.ID AND vtc.Renglon = VD.Renglon AND vtc.RenglonSub = VD.RenglonSub      
  LEFT JOIN SATCatClaveProdServ CPS ON SAI.ClaveSAT = CPS.Clave      
  LEFT JOIN SATCatClaveUnidad CU  ON U.ClaveSAT = CU.ClaveUnidad      
   WHERE VD.RenglonTipo NOT IN ('C','E') AND VD.Cantidad-ISNULL(VD.CantidadObsequio,0) <> 0  
/*   
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID ('CFDIVentaDV4') AND TYPE ='V')
DROP VIEW CFDIVentaDV4
GO  
 CREATE VIEW CFDIVentaDV4
AS      
    
  SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,VD.ID))))) + RTRIM(LTRIM(CONVERT(varchar,VD.ID))) +      
      REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,CONVERT(int,VD.Renglon)))))) + RTRIM(LTRIM(CONVERT(varchar,CONVERT(int,VD.Renglon)))) +      
      REPLICATE(' ',50)     OrdenExportacion,      
      VD.ID,
	  Venta.Cliente,
      VD.Renglon,      
      VD.RenglonSub,      
      CPS.Clave                     ClaveProdServ,      
      CU.ClaveUnidad                    ClaveUnidad,      
      dbo.fnXMLValor(VD.Unidad)                 VentaDUnidad,      
      dbo.fnXMLValor(VD.Articulo)                 VentaDArticulo,      
      dbo.fnXMLValor(VD.SubCuenta)                 VentaDSubCuenta,      
      VD.Cantidad-ISNULL(VD.CantidadObsequio,0)             VentaDCantidad,
	  VD.Aplica,
	  VD.AplicaID,
	  VD.Cantidad,
	  VD.CantidadA,
	  VD.CantidadPendiente,
	  VD.CantidadCancelada,
	  Art.Peso*VD.Cantidad-ISNULL(VD.CantidadObsequio,0)             PesoArt,
      --CASE WHEN ISNULL(m.ObjetoImpuesto,sai.SatObjetoImp) = '03' THEN      
      --     CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00)      
      --  ELSE (vtc.SubTotalSinDL/(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))+ ((ISNULL(vtc.Impuestos, 0.00) - ISNULL(vtc.Retencion1Total, 0.00) - ISNULL(vtc.Retencion2Total, 0.00) - ISNULL(vtc.Retencion3Total, 0.00)) / (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) ) END      
      --   ELSE      
      --   CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00)      
      --ELSE vtc.SubTotalSinDL/(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) END        
      --   END    VentaDPrecio,   
         CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END)      
     ELSE (CASE WHEN vtc.RenglonTipo = 'J' THEN /*ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Importe'),0.00)*/ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.Importe END/vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))      
      END                       VentaDPrecio,  
  
      --   CASE WHEN ISNULL(m.ObjetoImpuesto,sai.SatObjetoImp) = '03' THEN      
      --     CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotalSinDL'),0.00)      
      --  ELSE vtc.SubTotalSinDL + ISNULL(vtc.Impuestos, 0.00) - ISNULL(vtc.Retencion1Total, 0.00) - ISNULL(vtc.Retencion2Total, 0.00) - ISNULL(vtc.Retencion3Total, 0.00) END      
      --   ELSE      
      --CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotalSinDL'),0.00)      
      --ELSE vtc.SubTotalSinDL END       
      --   END VentaDImporte,    
   -----  
         CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END*VD.Cantidad)      
     ELSE CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.SubTotal END*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))          
      END                       VentaDImporte,  
  
  
  
  
     -- CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1      
     --THEN CASE WHEN vtc.RenglonTipo = 'J' THEN NULLIF(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'ImpIncDescuentosTotales'),0.00) ELSE NULLIF(vtc.ImpIncDescuentosTotales,0.00) END      
     --ELSE CASE WHEN vtc.RenglonTipo = 'J' THEN NULLIF(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'DescuentosTotales'),0.00) ELSE NULLIF(vtc.DescuentosTotales,0.00) END      
     -- END              
  0  VentaDDescuentoImporte,      
      CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00)      
      ELSE vtc.SubTotal END                  VentaDImpuestoBase,      
      dbo.fnXMLValor(Art.Descripcion1)                VentaDDescripcion,      
      dbo.fnXMLValor(Art.Descripcion2)                VentaDDescripcion2,      
      SAI.CuentaPredial                   CuentaPredialV,      
      dbo.fnQueCodigo(EmpresaCFD.EAN13, VD.Articulo, VD.SubCuenta, VD.Codigo, Venta.Cliente)  EAN13,      
      dbo.fnQueCodigo(EmpresaCFD.SKU, VD.Articulo, VD.SubCuenta, VD.Codigo, Venta.Cliente)   SKUCliente,      
      U.Clave                      UnidadClave,      
      CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN  ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END)      
     ELSE (CASE WHEN vtc.RenglonTipo = 'J' THEN /*ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Importe'),0.00)*/ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.Importe END/vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))      
      END                       VentaDImporteUnitario,      
      CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.PrecioSinDL END)      
     ELSE (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.SubTotal END/Vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))      
      END                       VentaDSubTotalUnitario,      
      CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0      
     THEN (CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'Precio'),0.00) ELSE vtc.PrecioSinDL END*VD.Cantidad)      
     ELSE CASE WHEN vtc.RenglonTipo = 'J' THEN ISNULL(dbo.fnImporteJuego(VD.ID,VD.RenglonID,'SubTotal'),0.00) ELSE vtc.SubTotal END*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))          
      END                       VentaDSubTotal,      
      ISNULL(m.ObjetoImpuesto,sai.SatObjetoImp)             ObjetoImp   ,
	  VD.DescripcionExtra VentaDDescripcionExtra,
	   VTC.TotalNeto  TotalNetoD
    FROM Venta      
    JOIN VentaD VD    ON Venta.ID = VD.ID      
    JOIN Art      ON VD.Articulo = Art.Articulo      
  LEFT JOIN MovObjetoImpuesto m  ON m.Modulo = 'VTAS' AND m.ModuloID=VD.ID AND vd.RenglonID=m.RenglonID AND vd.Renglon = m.Renglon AND vd.RenglonSub = m.RenglonSub      
  LEFT JOIN SATArticuloInfo SAI  ON VD.Articulo = SAI.Articulo      
  LEFT JOIN Unidad U     ON ISNULL(VD.Unidad, Art.Unidad) = U.Unidad      
    JOIN EmpresaCFD    ON Venta.Empresa = EmpresaCFD.Empresa      
       JOIN MovTipo mt    ON mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov      
    JOIN EmpresaCfg    ON Venta.Empresa = EmpresaCfg.Empresa      
    JOIN VentaTCalc vtc   ON vtc.ID = VD.ID AND vtc.Renglon = VD.Renglon AND vtc.RenglonSub = VD.RenglonSub      
  LEFT JOIN SATCatClaveProdServ CPS ON SAI.ClaveSAT = CPS.Clave      
  LEFT JOIN SATCatClaveUnidad CU  ON U.ClaveSAT = CU.ClaveUnidad      
   WHERE VD.RenglonTipo NOT IN ('C','E') AND VD.Cantidad-ISNULL(VD.CantidadObsequio,0) <> 
  */
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
SELECT Modulo,'OFIX',Orden,CASE WHEN Seccion = 'Tony' THEN 'Encabezado' WHEN Seccion = 'Detalles' THEN 'Detalle' ELSE Seccion END,SubSeccionDe,CASE WHEN Seccion ='Detalles' THEN 'CFDIVentaDV4' ELSE 'CFDIVentaV4' END,Cierre,TablaSt 
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
'VentaDCantidad',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Articulo]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[CantidadOrden]',
'CantidadOrden',
FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero
FROM eDocDMapeoCampo
WHERE Modulo = 'VTAS' and eDoc = 'TONY' AND CampoXML = '[Articulo]' and idseccion=3189
UNION ALL
SELECT 'VTAS','OFIX',
		(SELECT RID FROM eDocD WHERE Modulo = 'VTAS' and eDoc = 'OFIX' AND Seccion = 'Detalle'),
'[PesoUnidadFacturaGr]',
'PesoArt',
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