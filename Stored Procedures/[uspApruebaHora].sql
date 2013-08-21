USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspApruebaHora]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspApruebaHora];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspApruebaHora]
(
	@IDReporteHora INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-06-2011
 * Descripcion:
 * - APRUEBA UNA HORA DEL REPORTE DE HORAS.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
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
			RAISERROR('No puede aprobar, la hora ya fué enviada a SAO.', 16, 1);
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
			RAISERROR('La hora ya fué aprobada.', 16, 1);
		END
	
		UPDATE
			[ControlMaquinaria].[ReporteHorasDetalle]
		SET
			[Aprobada] = 1
		WHERE
			[IDReporteHora] = @IDReporteHora;
	END TRY
    BEGIN CATCH
		THROW;
    END CATCH
END
GO

--EXECUTE [ControlMaquinaria].[uspApruebaHora] @IDReporteHora = 1 -- int