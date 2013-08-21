USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspModificaHora]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspModificaHora];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspModificaHora]
(
	  @IDReporteHora INT
	, @CantidadHoras DECIMAL(4, 2)
	, @IDActividad	 INT
	, @RutaActividad VARCHAR(MAX)
	, @Observaciones VARCHAR(MAX)
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 15-06-2011
 * Descripcion:
 * - MODIFICA LOS DATOS DE UN REGISTRO DE HORA.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	UPDATE
		[ControlMaquinaria].[ReporteHorasDetalle]
	SET
		  [CantidadHoras] = @CantidadHoras
		, [IDActividad] = CASE [IDTipoHora]
							WHEN 1 THEN @IDActividad
							ELSE NULL
						  END
		, [RutaActividad] = @RutaActividad
		, [Observaciones] = @Observaciones
	WHERE
		[IDReporteHora] = @IDReporteHora;
END
GO