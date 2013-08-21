USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspCalculaHorasEnvio]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspCalculaHorasEnvio];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspCalculaHorasEnvio]
(
	  @IDReporteHora INT
	, @HorasAEnviar DECIMAL(4, 2) OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 24-06-2011
 * Descripcion:
 * - CALCULA LAS HORAS QUE SE DEBEN ENVIAR DE UN REGISTRO DE HORA
	 DE ACUERDO A 2 CONDICIONES.
	 
	 1: SI EL TOTAL DE HORAS EFECTIVAS DEL REPORTE DE HORAS ES
	    MAYORES A LA CANTIDAD MINIMA DE HORAS PARA ENVIO ENTONCES
	    SOLO SE ENVIARAN TODAS LAS HORAS DE AQUELLOS REGISTROS
	    DE TIPO EFECTIVAS.
	    
	 2: SI EL TOTAL DE HORAS EFECTIVAS DEL REPORTE DE HORAS ES
	    MENOR A LA CANTIDAD MINIMA DE HORAS PARA ENVIO ENTONCES
	    SE ENVIARAN PRIMERO TODAS LAS HORAS DE TIPO EFECTIVAS
	    QUE ESTEN APROBADAS Y SE TOMARA LA CANTIDAD FALTANTE
	    PARA LLEGAR AL MINIMO DE LAS HORAS DE TIPO MANTENIMIENTO,
	    REPARACION U OCIO.
	    
	 

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
 * - 04-07-2011 [Uziel]: SE SIMPLIFICO EL ALGORITMO DE CALCULO DE HORAS
						 PARA ENVIAR Y SE PERMITIO EL ENVIO DE HORAS
						 QUE NO SEAN EFECTIVAS CUANDO EL REPORTE NO
						 TENGA HORAS EFECTIVAS.
*/
BEGIN
	SET NOCOUNT ON;
	-- ESTABLECE LUNES COMO PRIMER DIA DE LA SEMANA
	SET DATEFIRST 1;

	DECLARE
	  @IDReporte INT = NULL
	, @FechaReporte DATE = NULL
	, @IDMaquina INT = NULL
	, @IDProyecto INT = NULL
	  -- TIPO DE HORA DE ESTE REGISTRO DE HORA
	, @IDTipoHora TINYINT = NULL
	  -- CANTIDAD DE HORAS DISPONIBLES DE ESTE REGISTRO DE HORA
	, @HorasDisponiblesRegistro DECIMAL(4, 2) = .00;

	DECLARE
	  @HorasOperacion INT = 0
	  -- MINIMO DE HORAS EFECTIVAS A ENVIAR A SAO
	  -- DE ACUERDO CON LA EQUIVALENCIA DE HORAS OPERACION
	, @HorasMinimoEnviar DECIMAL(4, 2) = .00
	  -- TOTAL DE HORAS ENVIADAS DEL REPORTE DE HORAS
	, @TotalHorasEnviadas DECIMAL(4, 2) = .00
	  -- TOTAL DE HORAS APROBADAS DEL REPORTE DE HORAS
	, @TotalHorasAprobadas DECIMAL(4, 2) = .00
	  -- TOTAL DE HORAS EFECTIVAS APROBADAS DEL REPORTE DE HORAS
	, @TotalHorasEfectivasAprobadas DECIMAL(4, 2) = .00
	  -- TOTAL DE HORAS EFECTIVAS ENVIADAS DEL REPORTE
	, @TotalHorasEfectivasEnviadas DECIMAL(4, 2) = .00
	  -- TOTAL DE HORAS EFECTIVAS POR ENVIAR
	, @HorasEfectivasPorEnviar DECIMAL(4, 2) = .00
	  -- TOTAL DE HORAS POR ENVIAR DE ACUERDO A LA CANTIDAD MINIMA DE HORAS
	  -- EFECTIVAS POR ENVIAR
	--, @HorasPorEnviar DECIMAL(4, 2) = .00;

	SET @HorasAEnviar = .00;

	/*
	 * OBTIENE DATOS DEL REPORTE DE HORAS
	*/
	SELECT
		  @IDReporte = [ReporteHoras].[IDReporte]
		, @FechaReporte = [ReporteHoras].[FechaReporte]
		, @IDMaquina = [ReporteHoras].[IDMaquina]
		, @IDProyecto = [ReporteHoras].[IDProyecto]
		, @IDTipoHora = [ReporteHorasDetalle].[IDTipoHora]
		, @HorasDisponiblesRegistro = [ReporteHorasDetalle].[CantidadHoras] - [ReporteHorasDetalle].[CantidadHorasEnviada]
	FROM
		[ControlMaquinaria].[ReporteHoras]
	INNER JOIN
		[ControlMaquinaria].[ReporteHorasTurnos]
		ON
			[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
	INNER JOIN
		[ControlMaquinaria].[ReporteHorasDetalle]
		ON
			[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno]
	WHERE
		[ReporteHorasDetalle].[IDReporteHora] = @IDReporteHora;


	/*
	 * OBTIENE LAS HORAS DE OPERACION DEL REPORTE
	 * Y LA CANTIDAD MINIMA DE HORAS EFECTIVAS A ENVIAR AL SAO
	 * DE ACUERDO A LAS HORAS OPERACION Y EL DIA DE LA SEMANA DE LA FECHA
	 * DEL REPORTE DE HORAS
	*/
	SELECT
	@HorasMinimoEnviar = CASE
						   -- SI EL DIA ES ENTRE LUNES Y VIERNES
						   WHEN DATEPART(DW, @FechaReporte) BETWEEN 1 AND 5 THEN [EquivalenciaHorasOperacion].[HorasLunesAViernes]
						   -- SI EL DIA ES SABADO
						   WHEN DATEPART(DW, @FechaReporte) = 6 THEN [EquivalenciaHorasOperacion].[HorasSabado]
						   -- SI EL DIA ES DOMINGO
						   WHEN DATEPART(DW, @FechaReporte) = 7 THEN [EquivalenciaHorasOperacion].[HorasDomingo]
						 END
	FROM
		[ControlMaquinaria].[ReporteHoras]
	INNER JOIN
		[ControlMaquinaria].[HorasMensuales]
		ON
			[ReporteHoras].[IDHoraMensual] = [HorasMensuales].[IDHoraMensual]
	INNER JOIN
		[ControlMaquinaria].[EquivalenciaHorasOperacion]
		ON
			[HorasMensuales].[IDEquivalenciaHoras] = [EquivalenciaHorasOperacion].[IDEquivalenciaHoras]
	WHERE
		[ReporteHoras].[IDReporte] = @IDReporte;
	
	
	--SELECT
	--  @HorasOperacion = [OperacionVigente].[HorasOperacion]
	--, @HorasMinimoEnviar = CASE
	--						 -- SI EL DIA ES ENTRE LUNES Y VIERNES
	--						 WHEN DATEPART(DW, @FechaReporte) BETWEEN 1 AND 5 THEN [EquivalenciaHorasOperacion].[HorasLunesAViernes]
	--						 -- SI EL DIA ES SABADO
	--						 WHEN DATEPART(DW, @FechaReporte) = 6 THEN [EquivalenciaHorasOperacion].[HorasSabado]
	--						 -- SI EL DIA ES DOMINGO
	--						 WHEN DATEPART(DW, @FechaReporte) = 7 THEN [EquivalenciaHorasOperacion].[HorasDomingo]
	--					   END
	--FROM [ControlMaquinaria].[EquivalenciaHorasOperacion]
	--CROSS APPLY (
	--	SELECT TOP 1
	--	  [HorasMensuales].[Vigencia]
	--	, [HorasMensuales].[HorasOperacion]
	--	FROM [ControlMaquinaria].[HorasMensuales]
	--	WHERE [HorasMensuales].[IDMaquina] = @IDMaquina
	--	AND [HorasMensuales].[IDEquivalenciaHoras] = [EquivalenciaHorasOperacion].[IDEquivalenciaHoras]
	--	ORDER BY [HorasMensuales].[Vigencia] DESC
	--) AS [OperacionVigente];


	/*
	 * TOTAL DE HORAS EFECTIVAS APROBADAS DEL REPORTE
	 * TOTAL DE HORAS EFECTIVAS ENVIADAS DEL REPORTE
	 * TOTAL DE HORAS ENVIADAS DEL REPORTE
	*/
	SELECT
		  @TotalHorasEfectivasAprobadas = SUM( CASE [ReporteHorasDetalle].[IDTipoHora]
												 WHEN 1 THEN [ReporteHorasDetalle].[CantidadHoras]
												 ELSE .00
											   END
											 )
		, @TotalHorasEfectivasEnviadas = SUM( CASE [ReporteHorasDetalle].[IDTipoHora]
												WHEN 1 THEN [ReporteHorasDetalle].[CantidadHorasEnviada]
												ELSE .00
											  END
											)
		, @TotalHorasAprobadas = SUM([CantidadHoras])
		, @TotalHorasEnviadas = SUM([CantidadHorasEnviada])
	FROM
		[ControlMaquinaria].[ReporteHoras]
	INNER JOIN
		[ControlMaquinaria].[ReporteHorasTurnos]
		ON
			[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
	INNER JOIN
		[ControlMaquinaria].[ReporteHorasDetalle]
		ON
			[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno]
	WHERE
		[ReporteHoras].[IDReporte] = @IDReporte
			AND
		[ReporteHorasDetalle].[Aprobada] = 1;

	--SELECT @HorasOperacion AS [HorasOperacion], @HorasMinimoEnviar AS [HorasMinimoEnviar]
	--, @TotalHorasEfectivas AS [TotalHorasEfectivas], @HorasEfectivasEnviadas AS [HorasEfectivasEnviadas],
	--@HorasDisponiblesRegistro AS [HorasDisponiblesRegistro]

	-- SI LAS HORAS ESTAN APROBADAS
	IF( @TotalHorasAprobadas > 0 )
	BEGIN
		
		-- CUANDO LAS HORAS SEAN EFECTIVAS SIEMPRE SE ENVIARAN
		IF( @IDTipoHora = 1 )
		BEGIN
			SET @HorasAEnviar = @HorasDisponiblesRegistro;
		END
		ELSE
		BEGIN
			-- CUANDO LAS HORAS NO SEAN EFECTIVAS
			
			/*
			 * CUANDO EL TOTAL DE HORAS EFECTIVAS DEL REPORTE CUBRA O SUPERE EL MINIMO
			 * DE HORAS A ENVIAR, YA NO SE ENVIARA NINGUNA HORA MAS DE CUALQUIER OTRO TIPO
			*/
			IF( @TotalHorasEfectivasAprobadas >= @HorasMinimoEnviar )
				SET @HorasAEnviar = .00;
			ELSE
			BEGIN
				-- CALCULA LAS HORAS FALTANTES POR ENVIAR CON LA DIFERENCIA DE
				-- EL MINIMO A ENVIAR Y EL TOTAL DE ENVIADAS
				SET @HorasAEnviar = @HorasMinimoEnviar - @TotalHorasEnviadas;
				--PRINT @HorasMinimoEnviar;
				/*
				 * PUEDEN DARSE 2 CASOS PARA CALCULAR LAS HORAS QUE SE ENVIARAN DE ESTE REGISTRO DE HORA
				 * 1: LA CANTIDAD DE HORAS POR ENVIAR SEA MAYOR QUE LA CANTIDAD DE HORAS DISPONIBLES
					  DEL REGISTRO DE HORA.
					  PARA ESTE CASO SE ENVIA LA CANTIDAD DE HORAS DISPONIBLES Y QUEDARA LA DIFERENCIA
					  PARA ENVIAR SI EXISTE OTRO REGISTRO DE HORA CON HORAS DISPONIBLES.
				 
				 * 2: LA CANTIDAD DE HORAS POR ENVIAR SEA MENOR QUE LA CANTIDAD DE HORAS DISPONIBLES
					  DEL REGISTRO DE HORA.
					  EN ESTE CASO SE ENVIA LA CANTIDAD DE HORAS POR ENVIAR Y LA DIFERENCIA QUEDARA
					  DISPONIBLE EN EL REGISTRO DE HORA.
				*/
				SET @HorasAEnviar = CASE
									  WHEN @HorasAEnviar <= @HorasDisponiblesRegistro THEN @HorasAEnviar
									  ELSE @HorasDisponiblesRegistro
									END;
			END
		END
	END
END
GO

--DECLARE
--  @HorasPorEnviar DECIMAL(4, 2) = .00

--EXECUTE [ControlMaquinaria].[uspCalculaHorasEnvio]
--	@IDReporteHora = 223761, -- int
--    @HorasAEnviar = @HorasPorEnviar OUTPUT -- decimal

--SELECT @HorasPorEnviar