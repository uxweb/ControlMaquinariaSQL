USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspReporteHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspReporteHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspReporteHoras]
(
	  @IDMaquina INT
	, @FechaReporte DATE
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 01-06-2011
 * Descripcion:
 * - OBTIENE LA INFORMACION DE HORAS DE UNA FECHA PARA UNA MAQUINA.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;

	SELECT
		  [ReporteHoras].[IDReporte]
		, [ReporteHoras].[IDMaquina]
		, [ReporteHoras].[FechaReporte]
		, [ReporteHoras].[EnviadoSAO]
		, [ReporteHoras].[NumeroFolioSAO]
		, [ReporteHorasTurnos].[IDReporteTurno]
		, [ReporteHorasTurnos].[IDTurno]
		, 'De ' + CAST([Turnos].[HoraInicio] AS VARCHAR) + ' a ' + CAST([Turnos].[HoraTermino] AS VARCHAR) AS [Turno]
		, [ReporteHorasTurnos].[HorometroInicial]
		, [ReporteHorasTurnos].[HorometroFinal]
		, ([ReporteHorasTurnos].[HorometroFinal] - [ReporteHorasTurnos].[HorometroInicial]) AS [HorasHorometro]
		, ISNULL([ReporteHorasTurnos].[Observaciones], '') AS [ObservacionesHorometro]
		, [ReporteHorasDetalle].[IDReporteHora]
		, [ReporteHorasDetalle].[IDTipoHora]
		,
		CASE [ReporteHorasDetalle].[IDTipoHora]
		  WHEN 1 THEN 'Efectivas'
		  WHEN 2 THEN 'Reparación Menor'
		  WHEN 3 THEN 'Reparación Mayor'
		  WHEN 4 THEN 'Mantenimiento'
		  WHEN 5 THEN 'Ocio'
		END AS [TipoHora]
		, [ReporteHorasDetalle].[CantidadHoras]
		, [ReporteHorasDetalle].[CantidadHorasEnviada]
		, [ReporteHorasDetalle].[IDActividad]
		, COALESCE([ReporteHorasDetalle].[RutaActividad], [conceptos].[descripcion], '') AS [Actividad]
		, ISNULL([ReporteHorasDetalle].[Observaciones], '') AS [Observaciones]
		, [ReporteHorasDetalle].[Aprobada]
		, [ReporteHorasDetalle].[EnviadaSAO]
	FROM
		[ControlMaquinaria].[ReporteHoras]
	INNER JOIN
		[ControlMaquinaria].[Maquinas]
	  ON
		[ReporteHoras].[IDMaquina] = [Maquinas].[IDMaquina]
	LEFT OUTER JOIN
		[ControlMaquinaria].[ReporteHorasTurnos]
	  ON
		[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
	LEFT OUTER JOIN
		[ControlMaquinaria].[Turnos]
	  ON
		[ReporteHorasTurnos].[IDTurno] = [Turnos].[IDTurno]
	LEFT OUTER JOIN
		[ControlMaquinaria].[ReporteHorasDetalle]
	  ON
		[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno]
	LEFT OUTER JOIN
		[Proyectos].[vwListaProyectosUnificados]
	  ON
		[Maquinas].[idProyecto] = [vwListaProyectosUnificados].[IDProyecto]
			  AND
		[vwListaProyectosUnificados].[IDTipoSistemaOrigen] = 1
			  AND
		[vwListaProyectosUnificados].[IDTipoBaseDatos] = 1
	LEFT OUTER JOIN
		[SAO1814App].[dbo].[conceptos]
	  ON
		[ReporteHorasDetalle].[IDActividad] = [conceptos].[id_concepto]
			AND
		[vwListaProyectosUnificados].[IDProyectoUnificado] = [conceptos].[id_obra]
	WHERE
		[ReporteHoras].[IDMaquina] = @IDMaquina
			AND
		[ReporteHoras].[FechaReporte] = @FechaReporte
	ORDER BY
		  [ReporteHorasTurnos].[IDTurno]
		, [ReporteHorasDetalle].[IDTipoHora];
END
GO

--EXECUTE [ControlMaquinaria].[uspReporteHoras] 70, '20110622'