USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspAsociaSCAF]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspAsociaSCAF];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspAsociaSCAF](
	  @IDMaquina INT
	, @IDActivoSCAF INT
	, @NumeroEconomico VARCHAR(50)
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 05-01-2012
 * Descripcion:
 * - ASOCIA UN MAQUINA CON UN ACTIVO DEL SCAF

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	UPDATE
		[ControlMaquinaria].[Maquinas]
	SET
		  [IDActivoSCAF] = @IDActivoSCAF
		, [NumeroEconomico] = @NumeroEconomico
	WHERE
		[IDMaquina] = @IDMaquina;
END
GO