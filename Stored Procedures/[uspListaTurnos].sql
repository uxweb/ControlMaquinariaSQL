USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspListaTurnos]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspListaTurnos];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspListaTurnos]
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 30-05-2011
 * Descripcion:
 * - OBTIENE LA LISTA DE TURNOS DE TRABAJO DE MAQUINARIA

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT
	  [IDTurno]
	, [Turno]
	, CAST([HoraInicio] AS VARCHAR) + ' a ' +  CAST([HoraTermino] AS VARCHAR) AS [DuracionTurno]
	FROM
		[ControlMaquinaria].[Turnos];
END
GO

EXECUTE [ControlMaquinaria].[uspListaTurnos]