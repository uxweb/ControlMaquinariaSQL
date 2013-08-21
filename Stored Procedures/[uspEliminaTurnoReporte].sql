USE [ModulosSAO];
GO

IF OBJECT_ID(N'[uspEliminaTurnoReporte].[uspEliminaTurnoReporte]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [uspEliminaTurnoReporte].[uspEliminaTurnoReporte];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspEliminaTurnoReporte]
(
	@IDReporteTurno INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 04-07-2011
 * Descripcion:
 * - ELIMINA EL REGISTRO DE UN TURNO DEL REPORTE DE HORAS
	 CON TODOS LOS REGISTROS DE HORA RELACIONADOS A EL.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @IDReporte INT = NULL;
	
	/*
	 * VERIFICA QUE EL TURNO NO TENGA HORAS
	 * APROBADAS O ENVIADAS
	*/
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasDetalle]
		WHERE
			[IDReporteTurno] = @IDReporteTurno
				AND
			(
				[Aprobada] = 1
					OR
				[EnviadaSAO] = 1
			)
	)
	BEGIN
		RAISERROR('El turno no se puede eliminar por que contiene registros de hora aprobados o enviados.', 16, 1);
		RETURN(1);
	END
	
	-- OBTIENE EL IDENTIFICADOR DEL REPORTE DE HORAS
	-- PARA ELIMINARLO SI YA NO EXISTEN TURNOS RELACIONADOS
	SELECT
		@IDReporte = [IDReporte]
	FROM
		[ControlMaquinaria].[ReporteHorasTurnos]
	WHERE
		[IDReporteTurno] = @IDReporteTurno;
	
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DELETE
			[ControlMaquinaria].[ReporteHorasTurnos]
		WHERE
			[IDReporteTurno] = @IDReporteTurno;
		
		-- VERIFICA SI EXISTEN MAS TURNOS
		-- SI YA NO HAY MAS TURNOS ELIMINA EL REGISTRO
		-- DEL REPORTE DE HORAS
		IF NOT EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHorasTurnos]
			WHERE
				[IDReporte] = @IDReporte
		)
		BEGIN
			DELETE
				[ControlMaquinaria].[ReporteHoras]
			WHERE
				[IDReporte] = @IDReporte;
		END
	
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		
		THROW;
	END CATCH
END
GO

--EXECUTE [ControlMaquinaria].[uspEliminaTurnoReporte]
--	@IDReporteTurno = 0