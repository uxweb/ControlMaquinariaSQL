USE [ModulosSAO]
GO

IF OBJECT_ID(N'[ControlMaquinaria].[vwHorasMaquina]', 'V') IS NOT NULL
BEGIN
	DROP VIEW [ControlMaquinaria].[vwHorasMaquina];
END
GO

CREATE VIEW [ControlMaquinaria].[vwHorasMaquina]
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: dd-mm-aaaa

 * Descripcion:
 * - .

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
AS
SELECT
	  [Maquinas].[IDMaquina]
	, [Maquinas].[IDAlmacenSAO]
	, [ReporteHoras].[IDProyecto]
	, [ReporteHoras].[FechaReporte]
	, [ReporteHoras].[EnviadoSAO]
	, [ReporteHoras].[IDTransaccionSAO]
	, [ReporteHorasTurnos].[IDTurno]
	, [ReporteHorasTurnos].[HorometroInicial]
	, [ReporteHorasTurnos].[HorometroFinal]
	, [ReporteHorasDetalle].[IDTipoHora]
	, [ReporteHorasDetalle].[CantidadHoras]
FROM
	[ControlMaquinaria].[Maquinas]
INNER JOIN
	[ControlMaquinaria].[ReporteHoras]
	ON
		[Maquinas].[IDMaquina] = [ReporteHoras].[IDMaquina]
INNER JOIN
	[ControlMaquinaria].[ReporteHorasTurnos]
	ON
		[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
INNER JOIN
	[ControlMaquinaria].[ReporteHorasDetalle]
	ON
		[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno];
GO

SELECT * FROM [ControlMaquinaria].[vwHorasMaquina]