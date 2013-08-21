USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspEliminaReporteHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspEliminaReporteHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspEliminaReporteHoras]
(
    @IDMaquina INT
  , @FechaReporte DATE
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 30-03-2012
 * Descripcion:
 * - ELIMINA UN REPORTE DE HORAS.
	 
     PARA PODER ELIMINAR UN REPORTE DE HORAS ES NECESARIO:
     - QUE NO ESTE APROBADO
     - QUE NO ESTE ENVIADO

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @IDTransaccionSAO INT;
	
	-- VERIFICA SI EL REPORTE EXISTE
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		WHERE
			[IDMaquina] = @IDMaquina
				AND
			[FechaReporte] = @FechaReporte
	)
	BEGIN
		RAISERROR( 'El reporte no ha sido capturado.', 16, 1 );
		RETURN (1);
	END
	
	-- VERIFICA SI EL REPORTE NO ESTA RPOBADO O ENVIADO
	IF EXISTS
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
			[ReporteHoras].[IDMaquina] = @IDMaquina
				AND
			[ReporteHoras].[FechaReporte] = @FechaReporte
				AND
			(
				[ReporteHoras].[EnviadoSAO] = 1
					OR
				[ReporteHorasDetalle].[Aprobada] = 1
			)
	)
	BEGIN
		RAISERROR( 'No es posible borrar un reporte enviado o con horas aprobadas. Se debe revertir el envio o aprobación.', 16, 1 );
		RETURN (1);
	END
	
	BEGIN TRY

		BEGIN TRANSACTION;
		
			-- ELIMINAR LOS REGISTROS DE HORAS DEL REPORTE CON LA FECHA INDICADA
			DELETE
				[ControlMaquinaria].[ReporteHorasDetalle]
			FROM
				[ControlMaquinaria].[ReporteHorasDetalle]
			INNER JOIN
				[ControlMaquinaria].[ReporteHorasTurnos]
			  ON
				[ReporteHorasDetalle].[IDReporteTurno] = [ReporteHorasTurnos].[IDReporteTurno]
			INNER JOIN
				[ControlMaquinaria].[ReporteHoras]
			  ON
				[ReporteHorasTurnos].[IDReporte] = [ReporteHoras].[IDReporte]
			WHERE
				[ReporteHoras].[IDMaquina] = @IDMaquina
					AND
				[ReporteHoras].[FechaReporte] = @FechaReporte;
			
			-- ELIMINAR LOS REGISTROS DE TURNOS DEL REPORTE DE HORAS
			DELETE
				[ControlMaquinaria].[ReporteHorasTurnos]
			FROM
				[ControlMaquinaria].[ReporteHorasTurnos]
			INNER JOIN
				[ControlMaquinaria].[ReporteHoras]
			  ON
				[ReporteHorasTurnos].[IDReporte] = [ReporteHoras].[IDReporte]
			WHERE
				[ReporteHoras].[IDMaquina] = @IDMaquina
					AND
				[ReporteHoras].[FechaReporte] = @FechaReporte;
			
			-- ELIMINAR EL REGISTRO DEL REPORTE DE HORAS DE LA FECHA INDICADA
			DELETE
				[ControlMaquinaria].[ReporteHoras]
			WHERE
				[IDMaquina] = @IDMaquina
					AND
				[FechaReporte] = @FechaReporte;
		
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF( @@TRANCOUNT > 0 )
			ROLLBACK TRANSACTION;
		
		THROW;
	END CATCH
END
GO

--EXECUTE [ControlMaquinaria].[uspEliminaReporteHoras]
--	@IDMaquina = 939, -- int
--    @FechaReporte = '2012-06-30'