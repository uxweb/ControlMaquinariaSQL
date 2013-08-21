USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspEliminaHorasMensuales]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspEliminaHorasMensuales];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspEliminaHorasMensuales]
(
	  @IDMaquina INT
	, @Vigencia DATE
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 23-06-2011
 * Descripcion:
 * - ELIMINA UN REGISTRO DE HORAS MENSUALES
     DE UNA MAQUINA DEL PROYECTO DONDE ESTA

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @IDHoraMensual INT = NULL;
	
	SELECT
		@IDHoraMensual = [idHoraMensual]
	FROM
		[ControlMaquinaria].[HorasMensuales]
	WHERE
		[IDMaquina] = @IDMaquina
			AND
		[Vigencia] = @Vigencia;
	
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		WHERE
			[IDHoraMensual] = @IDHoraMensual
	)
	BEGIN
		RAISERROR('No se puede eliminar este registro, uno o mas reportes de horas hacen referencia al registro.', 16, 1);
		RETURN(1);
	END
	
	DELETE
		[ControlMaquinaria].[HorasMensuales]
	WHERE
		[IDHoraMensual] = @IDHoraMensual;
END
GO
