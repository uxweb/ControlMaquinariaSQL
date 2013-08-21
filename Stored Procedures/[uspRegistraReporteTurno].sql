USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRegistraReporteTurno]', 'P' ) IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRegistraReporteTurno];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRegistraReporteTurno]
(
	  @IDMaquina		INT
	, @FechaReporte		DATE
	, @IDTurno			INT
	, @HorometroInicial DECIMAL(6, 1)
	, @HorometroFinal	DECIMAL(6, 1)
	, @Observaciones	VARCHAR(MAX)
	, @IDReporteTurno	INT OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 01-06-2011
 * Descripcion:
 * - REGISTRA UN TURNO AL REPORTE DE HORAS
     SI EL REPORTE DE HORAS NO EXISTE SE CREARA AUTOMATICAMENTE
     EL CONTROL DE LA CREACION DEL REPORTE ES MANEJADO DESDE
     ESTE PROCEDIMIENTO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @IDProyecto INT = NULL
	, @IDReporte INT = NULL;
	
	SELECT
		@IDProyecto = [IDProyecto]
	FROM
		[ControlMaquinaria].[Maquinas]
	WHERE
		[IDMaquina] = @IDMaquina;
	
	/*
	 * VERIFICA QUE EL VALOR DEL HOROMETRO INICIAL NO SEA MAYOR AL HOROMETRO FINAL
	*/
	IF ( @HorometroInicial > @HorometroFinal )
	BEGIN
		RAISERROR('El horometro inicial no puede ser mayor al horometro final.', 16, 1);
		RETURN (1);
	END	
	
	/*
	 * VERIFICA QUE EXISTA EL REGISTRO DEL REPORTE DE HORAS
	 * SI NO EXISTE LO CREARA PARA PODER RELACIONAR EL TURNO
	*/
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		WHERE
			[IDProyecto] = @IDProyecto
				AND
			[IDMaquina] = @IDMaquina
				AND
			[FechaReporte] = @FechaReporte		   
	)
	BEGIN
		/*
		 * CREA EL REGISTRO DEL REPORTE
		*/
		EXECUTE [ControlMaquinaria].[uspRegistraReporteHoras]
			@IDMaquina,    -- int
		    @FechaReporte; -- date
	END
	
	/*
	 * OBTIENE EL IDENTIFICADOR DEL REPORTE DE HORAS
	*/
	SELECT
		@IDReporte = [IDReporte]
	FROM
		[ControlMaquinaria].[ReporteHoras]
	WHERE
		[IDProyecto] = @IDProyecto
			AND
		[IDMaquina] = @IDMaquina
			AND
		[FechaReporte] = @FechaReporte;
	
	/*
	 * VERIFICA SI EL TURNO YA EXISTE
	*/
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasTurnos]
		WHERE
			[IDReporte] = @IDReporte
				AND
			[IDTurno] = @IDTurno
	)
	BEGIN
		RAISERROR('Este turno ya esta registrado.', 16, 1);
		RETURN (1);
	END
	
	/*
	 * CREA EL REGISTRO DEL TURNO
	*/
	INSERT INTO [ControlMaquinaria].[ReporteHorasTurnos]
	(
		  [IDReporte]
		, [IDTurno]
		, [HorometroInicial]
		, [HorometroFinal]
		, [Observaciones]
	)
	VALUES
	(
			@IDReporte
	    , -- idReporte
	        @IDTurno
	    , -- idTurno - int
	        @HorometroInicial
	    , -- HorometroInicial - smallint
	        @HorometroFinal
	    , -- HorometroFinal - smallint
	    CASE LEN(LTRIM(RTRIM(@Observaciones)))
	        WHEN 0 THEN NULL
	        ELSE @Observaciones
	    END
	);
	        
	SET @IDReporteTurno = @@IDENTITY;
END
GO

--DECLARE
--  @IDReporteTurno INT = NULL;

--EXECUTE [ControlMaquinaria].[uspRegistraReporteTurno]
--	@IDMaquina = 2, -- int
--    @FechaReporte = '2011-06-09', -- date
--    @IDTurno = 1, -- int
--    @HorometroInicial = 1811, -- smallint
--    @HorometroFinal = 1820, -- smallint
--    @IDReporteTurno = @IDReporteTurno OUTPUT

--SELECT @IDReporteTurno