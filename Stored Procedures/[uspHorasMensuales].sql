USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspHorasMensuales]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspHorasMensuales];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspHorasMensuales]
(
	@IDMaquina INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 22-06-2011
 * Descripcion:
 * - OBTIENE LAS HORAS DE OPERACION DE LA MAQUINA
     EN EL PROYECTO QUE SE ENCUENTRE

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;

	SELECT
		  [HorasMensuales].[Vigencia]
		, CONVERT(VARCHAR(10), [HorasMensuales].[Vigencia], 105) AS [VigenciaFormato]
		, [HorasMensuales].[HorasContrato]
		, [HorasMensuales].[HorasOperacion]
		, [HorasMensuales].[HorasPrograma]
	FROM
		[ControlMaquinaria].[HorasMensuales]
	INNER JOIN
		[ControlMaquinaria].[Maquinas]
	  ON
		[HorasMensuales].[IDMaquina] = [Maquinas].[IDMaquina]
	WHERE
		[HorasMensuales].[IDMaquina] = @IDMaquina;
END
GO

EXECUTE [ControlMaquinaria].[uspHorasMensuales]
	@IDMaquina = 44 -- int
