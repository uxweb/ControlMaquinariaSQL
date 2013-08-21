USE [ModulosSAO]
GO



SELECT
  [ReporteHoras].[FechaReporte]
, [ReporteHorasDetalle].[idTipoHora]
,
CASE [ReporteHorasDetalle].[idTipoHora]
  WHEN 1 THEN 0
  WHEN 2 THEN 2
  WHEN 3 THEN 2
  WHEN 4 THEN 2
  WHEN 5 THEN 1
END AS [TipoHoraSAO]
, [ReporteHorasDetalle].[idActividad]
, SUM([ReporteHorasDetalle].[CantidadHoras]) AS [CantidadHoras]
FROM [ControlMaquinaria].[ReporteHoras]
INNER JOIN [ControlMaquinaria].[ReporteHorasDetalle]
  ON [ReporteHoras].[idReporte] = [ReporteHorasDetalle].[idReporte]
WHERE [ReporteHoras].[idMaquina] = 1
AND [ReporteHoras].[FechaReporte] = '20110606'
AND [ReporteHorasDetalle].[Aprobada] = 1
AND [ReporteHorasDetalle].[EnviadaSAO] = 0
GROUP BY [ReporteHoras].[FechaReporte]
	   , [ReporteHorasDetalle].[idTipoHora]
	   , [ReporteHorasDetalle].[idActividad]
	   
	   SELECT * FROM  [ControlMaquinaria].[Maquinas]
	   WHERE [idMaquina] = 1
	   SELECT * FROM [ControlMaquinaria].[ReporteHoras]
	   
	   
	   SELECT * FROM  [ControlMaquinaria].[ReporteHorasDetalle]
	   
	   DBCC CHECKIDENT('[ControlMaquinaria].[Maquinas]', RESEED, 0)
	   
	   
	   
	   
	   
	SELECT
	  [vwListaProyectosUnificados].[idProyecto]
	FROM [SAO1814Reportes].[dbo].[almacenes]
	INNER JOIN [Proyectos].[vwListaProyectosUnificados]
	  ON [almacenes].[id_obra] = [Proyectos].[vwListaProyectosUnificados].[idProyectoUnificado]
	  AND [Proyectos].[vwListaProyectosUnificados].[idTipoSistemaOrigen] = 1
	  AND [Proyectos].[vwListaProyectosUnificados].[idTipoBaseDatos] = 1
	LEFT OUTER JOIN [ControlMaquinaria].[Maquinas]
	  ON [almacenes].[id_almacen] = [ControlMaquinaria].[Maquinas].[idAlmacenSAO]
	WHERE [almacenes].[tipo_almacen] = 2
	AND [almacenes].[id_almacen] = 1823