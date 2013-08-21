USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspApruebaReporteHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspApruebaReporteHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspApruebaReporteHoras]
(
	  @IDProyecto INT
	, @IDMaquina INT
	, @FechaReporte DATE
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 09-06-2011
 * Descripcion:
 * - APRUEBA LOS REGISTROS DE HORA DE UN REPORTE DE HORAS.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		/*
		 * VERIFICA SI EXISTE EL REPORTE DE HORAS
		*/
		IF NOT EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHoras]
			WHERE
				[IDProyecto] = @IDProyecto
					AND
				[IDMaquina] = @IDMaquina
					AND
				[FechaReporte] = @FechaReporte
		)
		BEGIN
			RAISERROR('No existen registros de hora para aprobar.', 16, 1);
		END
	
		/*
		 * VERIFICA SI EL REPORTE TIENE HORAS POR APROBAR
		*/
		IF NOT EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHoras]
			INNER JOIN
				[ControlMaquinaria].[ReporteHorasTurnos]
				ON
					[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
			INNER JOIN
				[ControlMaquinaria].[ReporteHorasDetalle]
				ON
					[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno]
			WHERE
				[ReporteHoras].[IDProyecto] = @IDProyecto
					AND
				[ReporteHoras].[IDMaquina] = @IDMaquina
					AND
				[ReporteHoras].[FechaReporte] = @FechaReporte
					AND
				[ReporteHorasDetalle].[Aprobada] = 0
		)
		BEGIN
			RAISERROR('Todos los registros de hora ya fueron aprobados.', 16, 1);
		END
	
		UPDATE
			[ControlMaquinaria].[ReporteHorasDetalle]
		SET
			[ReporteHorasDetalle].[Aprobada] = 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		INNER JOIN
			[ControlMaquinaria].[ReporteHorasTurnos]
		  ON
			[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
		INNER JOIN
			[ControlMaquinaria].[ReporteHorasDetalle]
		  ON
			[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno]
		WHERE
			[ReporteHoras].[IDProyecto] = @IDProyecto
				AND
			[ReporteHoras].[IDMaquina] = @IDMaquina
				AND
			[ReporteHoras].[FechaReporte] = @FechaReporte
				AND
			[ReporteHorasDetalle].[Aprobada] = 0;

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END