USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRegistraReporteHoras]', 'P' ) IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRegistraReporteHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRegistraReporteHoras]
(
	  @IDMaquina INT
	, @FechaReporte DATE
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 09-06-2011
 * Descripcion:
 * - CREA EL REGISTRO DEL REPORTE DE HORAS.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
   - 12-12-2011 [Uziel]: SE AGREGO EL BLOQUE QUE OBTIENE EL IDENTIFICADOR DE LA
						 HORA MENSUAL VIGENTE PARA QUE LO HAGA SIEMPRE QUE SE REGISTRA
						 EL REPORTE Y NO HASTA QUE SE ENVIE AL SAO PARA EVITAR PROBLEMAS
						 DE INCONSISTENCIA.
						 
   - 18-05-2012 [UZIEL]: SE MODIFICO LA CONSULTA QUE OBTIENE LAS HORAS MENSUALES VIGENTES
						 PARA QUE OBTENGA LAS HORAS DE ACUERDO A LA FECHA DEL REPORTE Y LA VIGENCIA
						 Y YA NO TOME SOLO EL MAS ACTUAL. ESTO PARA CUANDO LLEGUEN A REGISTRAR HORAS
						 QUE FALTARON CUANDO LA MAQUINA TENIA UN CONTRATO DIFERENTE.
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		  @IDProyecto INT = NULL
		, @IDHoraMensual INT = NULL;

	SELECT
		@IDProyecto = [IDProyecto]
	FROM
		[ControlMaquinaria].[Maquinas]
	WHERE
		[IDMaquina] = @IDMaquina;
	
	/*
	 * OBTIENE EL IDENTIFICADOR DE EL REGISTRO DE HORAS
	 * DE OPERACION VIGENTE DE ACUERDO A LA FECHA DEL REPORTE
	 * CON EL QUE SE BASA PARA CALCULAR LAS HORAS A ENVIAR DEL REPORTE AL SAO
	*/
	SELECT TOP 1
		@IDHoraMensual = [HorasMensuales].[IDHoraMensual]
	FROM
		[ControlMaquinaria].[HorasMensuales]
	WHERE
		[HorasMensuales].[IDMaquina] = @IDMaquina
			AND
		[Vigencia] <= @FechaReporte
	ORDER BY
		[HorasMensuales].[Vigencia] DESC;
	
	PRINT @IDHoraMensual;

	IF( @IDHoraMensual IS NULL )
	BEGIN
		RAISERROR('No se encontro un registro de horas mensuales vigente para la fecha de este reporte.', 16, 1);
		RETURN (1);
	END
	
	INSERT INTO [ControlMaquinaria].[ReporteHoras]
	(
		  [IDProyecto]
		, [IDMaquina]
		, [IDHoraMensual]
		, [FechaReporte]
	)
	VALUES
	(
		    @IDProyecto
		, -- idProyecto - int
			@IDMaquina
		, -- idMaquina - int
			@IDHoraMensual
		, -- idHoraMensual int
			@FechaReporte
		  -- FechaReporte - date
	);
END
GO

--EXECUTE [ControlMaquinaria].[uspRegistraReporteHoras]
--	@IDMaquina = 377, -- int
--    @FechaReporte = '2013-02-08 19:49:16' -- date