--SELECT * FROM [SAO1814Reportes].[dbo].[obras]

SELECT * FROM [ControlMaquinaria].[ReporteHoras]

SELECT
  [Proyectos].[Proyectos].[idProyecto]
, [Maquinas].[idMaquina]
, [transacciones].[cumplimiento] AS [FechaReporte]
, 1 AS EnviadoSAO
, 1 AS idHoraMensual
, [transacciones].[id_transaccion] AS [idTransaccionSAO]
, [transacciones].[numero_folio] AS [NumeroFolioSAO]
, [transacciones].[fecha] AS [FechaHoraEnvio]
, 1 AS [idUsuarioEnvio]
, GETDATE() AS [FechaHoraRegistro]
FROM [SAO1814Reportes].[dbo].[transacciones]
INNER JOIN [ControlMaquinaria].[Maquinas]
  ON [transacciones].[id_almacen] = [Maquinas].[idAlmacenSAO]
INNER JOIN [Proyectos].[Proyectos]
  ON [Maquinas].[idProyecto] = [Proyectos].[idProyecto]
WHERE [transacciones].[tipo_transaccion] = 36
AND [transacciones].[id_obra] = 9
ORDER BY [idMaquina], fechareporte


SELECT * FROM [SAO1814Reportes].[dbo].[transacciones]
WHERE [id_obra] = 9
AND [tipo_transaccion] = 36




SELECT * FROM [ControlMaquinaria].[ReporteHorasDetalle]
ORDER BY [FechaHoraRegistro] DESC
WHERE [idReporteHora] = 12964

SELECT * FROM [ControlMaquinaria].[ReporteHorasTurnos]
WHERE [idReporteTurno] = 10297

SELECT * FROM [ControlMaquinaria].[ReporteHoras]
WHERE [idReporte] = 9239