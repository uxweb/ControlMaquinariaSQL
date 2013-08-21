USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspEnviaReporteHorasSAO]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspEnviaReporteHorasSAO];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspEnviaReporteHorasSAO]
(
	  @IDProyecto INT
	, @IDMaquina INT
	, @FechaReporte DATE
	, @Usuario VARCHAR(50)
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 09-06-2011
 * Descripcion:
 * - ENVIA LOS REGISTROS DE HORA DE UN REPORTE DE HORAS
     AL SAO COMO TRANSACCION DE PARTES DE USO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
 * - 08-07-2011 [Uziel]: SE AGREGO EL PARAMETRO @Usuario PARA IDENTIFICAR
						 EL USUARIO QUE ENVIA LA PARTE DE USO AL SAO.
						 
 * - 27-10-2011 [Uziel]: SE AGREGO EL REGISTRO DE LA DURACION DEL ENVIO EN EL
						 LOG DE LANZAMIENTOS.

 * - 12-04-2013 [Uziel]: SE COMENTO LA REGLA QUE EVITABA EL ENVIO DE REPORTES DE HORA
						 SIN HORAS EFECTIVAS LOS DOMINGOS.
*/
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE
		  @IDReporte INT = NULL
		, @IDTransaccionSAO INT = NULL
		, @IDReporteHora INT = NULL
		, @StartTime DATETIME = GETDATE();
	
	-- OBTIENE EL IDENTIFICADOR DEL REPORTE
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
	 * VERIFICA SI EXISTE EL REPORTE
	*/
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		WHERE
			[IDReporte] = @IDReporte
	)
	BEGIN
		RAISERROR('El reporte de horas no existe.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * VERIFICA SI EL REPORTE YA SE ENVIO
	*/
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		WHERE
			[IDReporte] = @IDReporte
				AND
			[EnviadoSAO] = 1
	)
	BEGIN
		RAISERROR('El reporte de horas ya fue enviado al SAO.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * VERIFICA SI EL REPORTE TIENE HORAS APROBADAS POR ENVIAR
	*/
	IF NOT EXISTS
	(
		SELECT 1
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
			[ReporteHorasDetalle].[Aprobada] = 1
	)
	BEGIN
		RAISERROR('No existen registros de hora aprobados para realizar el envio.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * LOS DIAS DOMINGOS SOLO SE ENVIAN HORAS EFECTIVAS, SI EL REPORTE NO TIENE HORAS EFECTIVAS
	 * SE EVITARA QUE HAGA EL ENVIO
	 */
	--IF NOT EXISTS
	--(
	--	SELECT 1
	--	FROM
	--		[ControlMaquinaria].[ReporteHoras]
	--	INNER JOIN
	--		[ControlMaquinaria].[ReporteHorasTurnos]
	--		ON
	--			[ReporteHoras].[IDReporte] = [ReporteHorasTurnos].[IDReporte]
	--	INNER JOIN
	--		[ControlMaquinaria].[ReporteHorasDetalle]
	--		ON
	--			[ReporteHorasTurnos].[IDReporteTurno] = [ReporteHorasDetalle].[IDReporteTurno]
	--	WHERE
	--		[ReporteHoras].[IDReporte] = @IDReporte
	--			AND
	--		[ReporteHorasDetalle].[IDTipoHora] = 1
	--)
	--AND DATEPART(DW, @FechaReporte) = 1
	--BEGIN
	--	RAISERROR('El dia domingo solo pueden ser enviadas horas efectivas.', 16, 1);
	--	RETURN (1);
	--END
	
	/*
	 * VERIFICAR SI YA EXISTE UNA PARTE DE USO PARA ESTA MAQUINA CON LA MISMA FECHA EN EL SAO
	 */
	
	BEGIN TRY
		BEGIN TRANSACTION;
		
		/*
		 * ENVIA UNA A UNA LAS HORAS APROBADAS POR ENVIAR
		*/
		DECLARE cr_horas CURSOR FAST_FORWARD READ_ONLY FOR
		SELECT
		  [ReporteHorasDetalle].[IDReporteHora]
		FROM
			[ControlMaquinaria].[Maquinas]
		INNER JOIN
			[ControlMaquinaria].[ReporteHoras]
			ON
				[Maquinas].[IDMaquina] = [ReporteHoras].[IDMaquina]
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
			[ReporteHorasDetalle].[Aprobada] = 1
				AND
			[ReporteHorasDetalle].[EnviadaSAO] = 0
		ORDER BY
			[ReporteHorasDetalle].[IDTipoHora] ASC;
		
		OPEN cr_horas;
		
		FETCH NEXT FROM cr_horas INTO
			@IDReporteHora;
		
		WHILE( @@FETCH_STATUS = 0 )
		BEGIN
			EXECUTE [ControlMaquinaria].[uspEnviaHoraSAO]
				@IDReporteHora,
				@Usuario;

			FETCH NEXT FROM cr_horas INTO
				@IDReporteHora;
		END
		
		CLOSE cr_horas;
		DEALLOCATE cr_horas;
		
		-- CREA UN REGISTRO DEL LANZAMIENTO EN EL LOG DE LANZAMIENTOS
		INSERT INTO [ControlMaquinaria].[LogLanzamientos]
		(
			  [IDReporte]
	        , [TiempoInicio]
	        , [TiempoTermino]
		)
		VALUES
		( 
		         @IDReporte -- idReporte - int
		        , @StartTime -- TiempoInicio - smalldatetime
		        , GETDATE()  -- TiempoTermino - smalldatetime
		);
		
		IF( XACT_STATE() > 0 )
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		CLOSE cr_horas;
		DEALLOCATE cr_horas;
		
		IF( XACT_STATE() != 0 )
			ROLLBACK TRANSACTION;
			
		THROW;
	END CATCH
END
GO

--EXECUTE [ControlMaquinaria].[uspEnviaReporteHorasSAO]
--	@IDProyecto = 2, -- int
--    @IDMaquina = 898, -- int
--    @FechaReporte = '2012-09-11',
--    @Usuario = 'ubueno'