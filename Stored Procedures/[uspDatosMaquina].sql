USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspDatosMaquina]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspDatosMaquina];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspDatosMaquina]
(
	@IDMaquina INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 22-07-2011
 * Descripcion:
 * - Obtiene los datos de la maquina adicionales al sao

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		  [IDClaseMotor]
		, [NumeroEconomico]
		, [NumeroSerieMotor]
		, [Marca]
		, [Modelo]
		, [Capacidad]
		, [CapacidadHP]
		, [HorasParaMantenimiento]
		, CONVERT(VARCHAR(10), [FechaEntrada], 105) AS [FechaEntrada]
		, CONVERT(VARCHAR(10), [FechaSalida], 105) AS [FechaSalida]
	FROM
		[ControlMaquinaria].[Maquinas]
	WHERE
		[IDMaquina] = @IDMaquina
END
GO

EXECUTE [ControlMaquinaria].[uspDatosMaquina]
	@IDMaquina = 335

--SELECT
--  [ReporteHoras].[idMaquina]
--, [almacenes].[descripcion] AS [Almacen]
--, [materiales].[descripcion] AS [TipoMaterial]
--, [ReporteHoras].[FechaReporte]
--, [HorasReporte].[Efectivas]
--, [HorasReporte].[Reparación Menor]
--, [HorasReporte].[Reparación Mayor]
--, [HorasReporte].[Mantenimiento]
--, [HorasReporte].[Ocio]
--, [ReporteHorasTurnos].[HorometroInicial]
--, [ReporteHorasTurnos].[HorometroFinal]
--, ([ReporteHorasTurnos].[HorometroFinal] - [ReporteHorasTurnos].[HorometroInicial]) AS [HorasHorometro]
--, [Turnos].[HoraInicio]
--, [Turnos].[HoraTermino]
--FROM (
--	SELECT
--	  [PvtHoras].[idReporteTurno]
--	, ISNULL([PvtHoras].[Efectivas], 0) AS [Efectivas]
--	, ISNULL([PvtHoras].[Reparación Menor], 0) AS [Reparación Menor]
--	, ISNULL([PvtHoras].[Reparación Mayor], 0) AS [Reparación Mayor]
--	, ISNULL([PvtHoras].[Mantenimiento], 0) AS [Mantenimiento]
--	, ISNULL([PvtHoras].[Ocio], 0) AS [Ocio]
--	FROM (
--		SELECT
--		  [idReporteTurno]
--		, [TiposHora].[TipoHora]
--		, [CantidadHoras]
--		FROM [ControlMaquinaria].[ReporteHorasDetalle]
--		INNER JOIN [ControlMaquinaria].[TiposHora]
--		  ON [ReporteHorasDetalle].[idTipoHora] = [TiposHora].[idTipoHora]
--	) AS [ReporteHorasDetalle]
--	PIVOT (
--			SUM([ReporteHorasDetalle].[CantidadHoras])
--			FOR [ReporteHorasDetalle].[TipoHora] IN([Efectivas], [Reparación Menor], [Reparación Mayor], [Mantenimiento], [Ocio])
--	) AS [PvtHoras]
--) AS [HorasReporte]
--INNER JOIN [ControlMaquinaria].[ReporteHorasTurnos]
--  ON [HorasReporte].[idReporteTurno] = [ReporteHorasTurnos].[idReporteTurno]
--INNER JOIN [ControlMaquinaria].[Turnos]
--  ON [ReporteHorasTurnos].[idTurno] = [Turnos].[idTurno]
--INNER JOIN [ControlMaquinaria].[ReporteHoras]
--  ON [ReporteHorasTurnos].[idReporte] = [ReporteHoras].[idReporte]
--INNER JOIN [ControlMaquinaria].[Maquinas]
--  ON [ReporteHoras].[idMaquina] = [Maquinas].[idMaquina]
--INNER JOIN [SAO1814App].[dbo].[almacenes]
--  ON [Maquinas].[idAlmacenSAO] = [almacenes].[id_almacen]
--INNER JOIN [SAO1814App].[dbo].[materiales]
--  ON [almacenes].[id_material] = [materiales].[id_material]
--WHERE [ReporteHoras].[idProyecto] = 5
--ORDER BY [ReporteHoras].[idMaquina]
--	   , [ReporteHoras].[FechaReporte]