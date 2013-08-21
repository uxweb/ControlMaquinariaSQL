USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspAgregaHoraReporte]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspAgregaHoraReporte];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspAgregaHoraReporte]
(
	  @IDReporteTurno INT
	, @IDTipoHora INT
	, @IDActividad INT = NULL
	, @RutaActividad VARCHAR(MAX) = NULL
	, @CantidadHoras DECIMAL(4, 2)
	, @Observaciones VARCHAR(MAX)
	, @Usuario VARCHAR(20)
	, @IDReporteHora INT OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 01-06-2011
 * Descripcion:
 * - CREA UN REGISTRO DE HORAS EN EL REPORTE DE HORAS INDICADO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
   - 08-07-2011 [Uziel]: SE AGREGO EL PARAMETRO @Usuario PARA IDENTIFICAR
						 EL USUARIO QUE CREA EL REGISTRO DE HORA.
   - 26-07-2011 [Uziel]: SE AGREGO EL PARAMETRO @RutaActividad PARA GUARDAR
						 LA JERARQUIA COMPLETA DE LA ACTIVIDAD EN EL PRESUPUESTO.
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		  @IDUsuario INT = NULL
		, @UnidadActividad VARCHAR(16) = NULL
		, @IDReporte INT = NULL
		, @FechaReporte DATE = NULL
		, @IDAlmacenSAO INT = NULL
		, @IDLoteAlmacen INT = NULL
		, @NumeroSerie VARCHAR(64) = NULL;
	
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasTurnos]
		WHERE
			[IDReporteTurno] = @IDReporteTurno
	)
	BEGIN
		RAISERROR('No existe un reporte de horas por turno para agregar las horas.', 16, 1);
		RETURN (1);
	END
	
	/*
	 * SE AGREGO PARA OBTERNER EL IDENTIFICADOR DEL USUARIO
	 * QUE CREA EL REGISTRO DE HORA
	*/
	EXECUTE [ControlMaquinaria].[uspObtieneIdUsuario]
		@Usuario = @Usuario, -- varchar(100)
	    @IDUsuario = @IDUsuario OUTPUT -- int
	
	
	IF ( @IDUsuario IS NULL )
	BEGIN
		RAISERROR('No es posible identificar al usuario para crear el registro.', 16, 1);
		RETURN (1);
	END
	
	IF ( @IDTipoHora = 1 AND @IDActividad IS NULL )
	BEGIN
		RAISERROR('Para horas efectivas debe elegir un destino.', 16, 1);
		RETURN (1);
	END
	
	-- LA CANTIDAD DE HORAS NO PUEDE SER 0
	IF ( @CantidadHoras <= 0 )
	BEGIN
		RAISERROR('Debe especificar la cantidad de horas.', 16, 1);
		RETURN (1);
	END
	
	-- NO SE PERMITE AGREGAR MAS HORAS A UN REPORTE ENVIADO

	SELECT
		@IDReporte = [IDReporte]
	FROM
		[ControlMaquinaria].[ReporteHorasTurnos]
	WHERE
		[IDReporteTurno] = @IDReporteTurno;
	

	SELECT
		  @IDAlmacenSAO = [Maquinas].[IDAlmacenSAO]
		, @FechaReporte = [ReporteHoras].[FechaReporte]
	FROM
		[ControlMaquinaria].[ReporteHoras]
	INNER JOIN
		[ControlMaquinaria].[Maquinas]
		ON [ReporteHoras].[IDMaquina] = [Maquinas].[IDMaquina]
	WHERE
		[ReporteHoras].[IDReporte] = @IDReporte;

	-- EL TOTAL DE HORAS DEL REPORTE NO PUEDE SUPERAR LAS 24 HORAS
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasDetalle]
		INNER JOIN
			[ControlMaquinaria].[ReporteHorasTurnos]
			ON
				[ReporteHorasDetalle].[IDReporteTurno] = [ReporteHorasTurnos].[IDReporteTurno]
		INNER JOIN
			[ControlMaquinaria].[ReporteHoras]
			ON
				[ReporteHorasTurnos].[IDReporte] = [ReporteHoras].[IDReporte]
		WHERE
			[ReporteHoras].[IDReporte] = @IDReporte
		HAVING
			( SUM([CantidadHoras]) + @CantidadHoras ) > 24
	)
	BEGIN
		RAISERROR('El numero total de horas del reporte no puede superar las 24 horas.', 16, 1);
		RETURN (1);
	END
	
	-- IDENTIFICA LA UNIDAD DEL DESTINO PARA HORAS EFECTIVAS
	IF ( @IDTipoHora = 1 )
	BEGIN
		SELECT
			@UnidadActividad = [unidad]
		FROM
			[SAO1814App].[dbo].[conceptos]
		WHERE
			[id_concepto] = @IDActividad;
	END
	

	EXECUTE [ControlMaquinaria].[uspMaquinaActivaEnAlmacen]
		@IDAlmacenSAO = @IDAlmacenSAO, -- int
		@FechaReporte = @FechaReporte, -- date
		@IDLoteAlmacen = @IDLoteAlmacen OUTPUT; -- int
	
	IF( @IDLoteAlmacen IS NULL )
	BEGIN
		RAISERROR('No hay maquina activa en el almacen o la fecha del reporte esta fuera del periodo de entrada de la maquina.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * DATOS DE LA MAQUINA ACTIVA EN EL ALMACEN
	 */
	SELECT
		  @NumeroSerie = [inventarios].[referencia]
		--, @PrecioUnitarioHora = [ItemsEntradaEquipo].[precio_unitario]
		--, @Anticipo = [ItemsEntradaEquipo].[anticipo]
	FROM
		[SAO1814App].[dbo].[inventarios]
	INNER JOIN
		[SAO1814App].[dbo].[items] AS [ItemsEntradaEquipo]
		ON
			[inventarios].[id_item] = [ItemsEntradaEquipo].[id_item]
	WHERE
		[inventarios].[id_lote] = @IDLoteAlmacen;


	INSERT INTO [ControlMaquinaria].[ReporteHorasDetalle]
	(
		  [IDReporteTurno]
		, [IDTipoHora]
		, [IDActividad]
		, [RutaActividad]
		, [UnidadActividad]
		, [CantidadHoras]
		, [Observaciones]
		, [NumeroSerieMaquina]
		, [IDUsuarioRegistro]
	)
	VALUES
	(
		@IDReporteTurno
	    , -- idReporte - int
		@IDTipoHora
	    , -- idTipoHora - int
	        CASE
	        WHEN @IDTipoHora > 1 THEN NULL
	        ELSE @IDActividad
	        END
	    , @RutaActividad
	    , @UnidadActividad
	    , @CantidadHoras
	    , -- CantidadHoras - smallint
	        CASE LEN(LTRIM(RTRIM(@Observaciones)))
	          WHEN 0 THEN NULL
	          ELSE @Observaciones
	        END
	    , -- Observaciones - varchar(max)
		  @NumeroSerie
		, --NumeroSerieMaquina
	      @IDUsuario
	    -- idUsuarioRegistro - int
	);

	SET @IDReporteHora = @@IDENTITY;
END
GO

--DECLARE
--  @IDReporteHora INT = NULL;

--EXECUTE [ControlMaquinaria].[uspAgregaHoraReporte]
--	@IDReporteTurno = 1, -- int
--    @IDTipoHora = 2, -- int
--    @IDActividad = 200, -- int
--    @CantidadHoras = .5, -- decimal
--    @Observaciones = 'ABCDE', -- varchar(max)
--    @IDReporteHora = @IDReporteHora OUTPUT;
    
--SELECT @IDReporteHora