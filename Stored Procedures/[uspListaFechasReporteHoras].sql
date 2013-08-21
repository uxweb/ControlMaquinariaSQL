USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspListaFechasReporteHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspListaFechasReporteHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspListaFechasReporteHoras]
(
	@IDMaquina INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-07-2011
 * Descripcion:
 * - OBTIENE EL ESTATUS DE LOS REPORTES DE HORA
     GENERADOS PARA UNA MAQUINA.
     EXISTEN 3 ESTATUS PARA LOS REPORTES:
     1: CAPTURADO
     2: ENVIADO A SAO
     3: NO CAPTURADO PERO YA EXISTE EN SAO
	 
	 UTILIZADO POR LA APLICACION PARA DAR UN COLOR
	 DIFERENTE AL DIA DEL REPORTE EN EL CALENDARIO
	 DE ACUERDO AL ESTATUS.
	 
 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		  [FechaReporte]
		,
		CASE
		  WHEN [EnviadoSAO] = 0 THEN 1 -- Capturado
		  WHEN [EnviadoSAO] = 1 THEN 2 -- Enviado a SAO
		  --WHEN [EnviadoSAO] = 1 AND [transacciones].[id_transaccion] IS NULL THEN 4
		END AS [Estatus]
		--,
		--CASE
		--  WHEN [EnviadoSAO] = 0 THEN 'Capturado'
		--  WHEN [EnviadoSAO] = 1 THEN 'Enviado a SAO'
		--  WHEN [EnviadoSAO] = 1 AND [transacciones].[id_transaccion] IS NULL THEN 'Enviado y Eliminado de SAO'
		--END AS [EstatusText]
	FROM
		[ControlMaquinaria].[ReporteHoras]
	INNER JOIN
		[ControlMaquinaria].[Maquinas]
	  ON
		[ReporteHoras].[IDMaquina] = [Maquinas].[IDMaquina]
			AND
		[ReporteHoras].[IDProyecto] = [Maquinas].[IDProyecto]
	LEFT OUTER JOIN
		[GH3].[SAO1814].[dbo].[transacciones]
	  ON
		[ReporteHoras].[IDTransaccionSAO] = [transacciones].[id_transaccion]
	WHERE
		[Maquinas].[IDMaquina] = @IDMaquina
	ORDER BY
		[FechaReporte];
END
GO

EXECUTE [ControlMaquinaria].[uspListaFechasReporteHoras]
	@IDMaquina = 70