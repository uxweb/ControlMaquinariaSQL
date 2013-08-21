USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspEliminaHora]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspEliminaHora];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspEliminaHora]
(
	@IDReporteHora INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-06-2011
 * Descripcion:
 * - ELIMINA UN REGISTRO DE HORA EN EL REPORTE DE HORAS.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	

	BEGIN TRY
		/*
		 * SI LA HORA YA FUE ENVIADA
		 * NO SE PERMITE ELIMINAR. SOLO REVIRTIENDO EL ENVIO DE TODO EL REPORTE
		*/
		IF EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHorasDetalle]
			WHERE
				[IDReporteHora] = @IDReporteHora
					AND
				[EnviadaSAO] = 1
		)
		BEGIN
			RAISERROR('No puede eliminar una hora enviada, revierta el envio del reporte.', 16,  1);
		END
	
		IF EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHorasDetalle]
			WHERE
				[IDReporteHora] = @IDReporteHora
					AND
				[Aprobada] = 1
		)
		BEGIN
			RAISERROR('Las horas aprobadas no pueden eliminarse, revierta la aprobación.', 16,  1);
		END
	
		DELETE
			[ControlMaquinaria].[ReporteHorasDetalle]
		WHERE
			[IDReporteHora] = @IDReporteHora;
	END TRY
    BEGIN CATCH
		THROW;
	END CATCH
END
GO

--EXECUTE [ControlMaquinaria].[uspEliminaHora]