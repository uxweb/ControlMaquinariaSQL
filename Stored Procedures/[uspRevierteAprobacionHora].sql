USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRevierteAprobacionHora]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRevierteAprobacionHora];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRevierteAprobacionHora]
(
	@IDReporteHora INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-06-2011
 * Descripcion:
 * - REVIERTE LA APROBACION DE UNA HORA SIEMPRE
	 QUE NO HAYA SIDO ENVIADA AL SAO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
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
		RAISERROR('No puede revertir la aprobación, la hora ya fue enviada a SAO.', 16, 1);
		RETURN(1);
	END
	
	UPDATE
		[ControlMaquinaria].[ReporteHorasDetalle]
	SET
		[Aprobada] = 0
	WHERE
		[IDReporteHora] = @IDReporteHora;
END
GO

--EXECUTE [ControlMaquinaria].[uspRevierteAprobacionHora]
--	@IDReporteHora = 1 -- int