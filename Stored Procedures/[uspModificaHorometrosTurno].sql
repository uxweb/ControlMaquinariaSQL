USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspModificaHorometrosTurno]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspModificaHorometrosTurno];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspModificaHorometrosTurno]
(
	  @IDReporteTurno INT
	, @HorometroInicial DECIMAL(6, 1)
	, @HorometroFinal DECIMAL(6, 1)
	, @Observaciones VARCHAR(MAX)
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 15-06-2011
 * Descripcion:
 * - MODIFICA EL NUMERO DE HORAS EN HOROMETRO DE UN TURNO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
   - 08-07-2011 [Uziel]: SE AGREGO EL PARAMETRO @Observaciones PARA PERMITIR
						 REGISTRAR OBSERVACIONES SOBRE LOS HOROMETROS. 
*/
BEGIN
	SET NOCOUNT ON;
	
	/*
	 * VERIFICA QUE EL VALOR DEL HOROMETRO INICIAL NO SEA MAYOR AL HOROMETRO FINAL
	*/
	IF ( @HorometroInicial > @HorometroFinal )
	BEGIN
		RAISERROR('El horometro inicial no puede ser mayor al horometro final.', 16, 1);
		RETURN (1);
	END
	
	UPDATE
		[ControlMaquinaria].[ReporteHorasTurnos]
	SET
		  [HorometroInicial] = @HorometroInicial
		, [HorometroFinal] = @HorometroFinal
		, [Observaciones] = @Observaciones
	WHERE
		[IDReporteTurno] = @IDReporteTurno;
END
GO