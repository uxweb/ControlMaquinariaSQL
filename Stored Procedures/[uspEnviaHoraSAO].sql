USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspEnviaHoraSAO]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspEnviaHoraSAO];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspEnviaHoraSAO]
(
	  @IDReporteHora INT
	, @Usuario VARCHAR(50)
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-06-2011
 * Descripcion:
 * - ENVIA UN REGISTRO DE HORA COMO ITEM DE TRANSACCION
     DE PARTES DE USO EN EL SAO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
 * - 29-06-2011 [Uziel]: SE CAMBIO EL TIPO DE ENVIO PARA LOS SIGUIENTES TIPOS DE HORAS
						 - Reparacion menor -> Ocio
						 - Mantenimiento    -> Ocio
						 ANTES DEL CAMBIO SE ENVIABAN COMO Reparacion.

 * - 08-07-2011 [Uziel]: SE AGREGO EL PARAMETRO @Usuario PARA IDENTIFICAR EL USUARIO
						 QUE ENVIA LA PARTE DE USO AL SAO.
*/
BEGIN
	SET NOCOUNT ON;
	SET DATEFIRST 1; -- LUNES ES EL PRIMER DIA DE LA SEMANA
	SET XACT_ABORT ON;
	
	/*
	 * DATOS DEL REPORTE DE HORAS
	*/
	DECLARE
		  @IDReporte		INT = NULL
		, @FechaReporte		DATE = NULL
		, @IDMaquina		INT = NULL
		, @IDProyecto		INT = NULL
		, @IDTransaccionSAO INT = NULL
		, @IDActividadSAO	INT = NULL
		, @IDTipoHora		INT = NULL
		, @IDTipoHoraSAO	INT = NULL
		, @HorasEnviar		DECIMAL(4, 2) = NULL
		, @idItem			INT = NULL;
	
	/*
	 * DATOS DE LA MAQUINA ACTIVA EN EL ALMACEN DEL SAO
	*/
	DECLARE
		  @IDLoteAlmacen	  INT = NULL
		, @IDAlmacenSAO		  INT = NULL
		, @IDMaterial		  INT = NULL
		, @NumeroSerie		  VARCHAR(64) = NULL
		, @PrecioUnitarioHora FLOAT = 0
		, @UnidadActividad	  VARCHAR(16) = NULL
		, @Anticipo			  REAL = 0;
	
	
	/*
	 * VERIFICA QUE EL REGISTRO DE HORA EXISTA
	*/
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasDetalle]
		WHERE
			[IDReporteHora] = @IDReporteHora
	)
	BEGIN
		RAISERROR('El registro de hora no existe, no es posible enviar.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * VERIFICA QUE EL REGISTRO DE HORA ESTE APROBADO
	*/	
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasDetalle]
		WHERE
			[IDReporteHora] = @IDReporteHora
				AND
			[Aprobada] = 0
	)
	BEGIN
		RAISERROR('El registro de hora no ha sido aprobado.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * VERIFICA QUE EL REGISTRO DE HORA NO HAYA SIDO ENVIADO
	*/
	IF EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHorasDetalle]
		WHERE
			[IDReporteHora] = @IDReporteHora
				AND
			[EnviadaSAO] = 1
	)
	BEGIN
		RAISERROR('El registro de hora ya fué enviado al SAO.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * OBTIENE DATOS DEL REPORTE DE HORAS
	*/
	SELECT
		  @FechaReporte = [ReporteHoras].[FechaReporte]
		, @IDMaquina = [ReporteHoras].[IDMaquina]
		, @IDProyecto = [ReporteHoras].[IDProyecto]
		, @IDReporte = [ReporteHoras].[IDReporte]
		, @IDAlmacenSAO = [Maquinas].[IDAlmacenSAO]
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
	INNER JOIN
		[ControlMaquinaria].[Maquinas]
		ON
			[ReporteHoras].[IDMaquina] = [Maquinas].[IDMaquina]
	WHERE
		[ReporteHorasDetalle].[IDReporteHora] = @IDReporteHora;
	
	
	/*
	 * VERIFICA SI EXISTEN HORAS DE OPERACION
	*/
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[HorasMensuales]
		WHERE
			[IDMaquina] = @IDMaquina
	)
	BEGIN
		RAISERROR('No existen horas de operación registradas.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * VERIFICA SI EXISTE EQUIVALENCIA PARA LAS HORAS DE OPERACION
	 * VIGENTES
	*/
	IF NOT EXISTS
	(
		SELECT
		1
		FROM
			[ControlMaquinaria].[EquivalenciaHorasOperacion]
		CROSS APPLY
		(
			SELECT TOP 1
				[HorasMensuales].[HorasOperacion]
			FROM
				[ControlMaquinaria].[HorasMensuales]
			WHERE
				[HorasMensuales].[IDEquivalenciaHoras] = [EquivalenciaHorasOperacion].[IDEquivalenciaHoras]
					AND
				[HorasMensuales].[IDMaquina] = @IDMaquina
			ORDER BY
				[HorasMensuales].[Vigencia] DESC
		) AS [HorasOperacionVigentes]
		WHERE
			[EquivalenciaHorasOperacion].[IDProyecto] = @IDProyecto
	)
	BEGIN
		RAISERROR('No existe equivalencia para las horas de operacion vigentes de la maquina.', 16, 1);
		RETURN(1);
	END

	/*
	 * VERIFICA QUE EXISTA UNA MAQUINA EN EL ALMACEN
	 * CON FECHA DE ENTRADA MENOR A LA FECHA DEL REPORTE
	 * Y QUE NO HAYA SALIDO. SI HAY DOS MAQUINAS ACTIVAS
	 * SE TOMA LA PRIMERA DE ACUERDO CON EL id_lote
	 *
	*/
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
		  @IDMaterial = [inventarios].[id_material]
		, @NumeroSerie = [inventarios].[referencia]
		, @PrecioUnitarioHora = [ItemsEntradaEquipo].[precio_unitario]
		, @Anticipo = [ItemsEntradaEquipo].[anticipo]
	FROM
		[GH3].[SAO1814].[dbo].[inventarios]
	INNER JOIN
		[GH3].[SAO1814].[dbo].[items] AS [ItemsEntradaEquipo]
		ON
			[inventarios].[id_item] = [ItemsEntradaEquipo].[id_item]
	WHERE
		[inventarios].[id_lote] = @IDLoteAlmacen;

	/*
	 * GENERA EL ENVIO DEL REGISTRO DE HORA AL SAO
	 */
	BEGIN TRY
		BEGIN DISTRIBUTED TRANSACTION;

		/*
		 * VERIFICA SI EL REGISTRO DE REPORTE
		 * YA FUE ENVIADO AL SAO COMO TRANSACCION DE PARTES DE USO
		 * SI NO SE HA ENVIADO, CREARA LA TRANSACCION EN EL SAO
		 * PARA PODER AGREGARLE LA HORA COMO ITEM.
		*/
		IF NOT EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHoras]
			WHERE
				[ReporteHoras].[IDMaquina] = @IDMaquina
					AND
				[ReporteHoras].[IDProyecto] = @IDProyecto
					AND
				[ReporteHoras].[FechaReporte] = @FechaReporte
					AND
				[ReporteHoras].[EnviadoSAO] = 1
		)
		BEGIN
			/*
			 * EL REPORTE NO ESTA ENVIADO COMO TRANSACCION DE PARTES DE USO
			 * CREA LA TRANSACCION DE PARTES DE USO EN EL SAO CON LOS DATOS
			 * DEL REPORTE DE HORAS
			 */
			EXECUTE [ControlMaquinaria].[uspCreaTranParteUsoSAO]
				@IDReporte,
				@Usuario;
		END
		
		/*
		 * OBTIENE DATOS DE LA MAQUINA PARA PODER REGISTRAR
		 * LA HORA COMO UN ITEM DE LA TRANSACCION DE PARTES DE USO
		*/
		SELECT
			  @IDTransaccionSAO = [ReporteHoras].[IDTransaccionSAO]
			, @IDTipoHora = [ReporteHorasDetalle].[IDTipoHora]
			, @IDTipoHoraSAO = CASE @IDTipoHora
								 -- Efectivas
								 WHEN 1 THEN 0 -- Trabajo
								 -- Reparacion Menor
								 WHEN 2 THEN 1 -- Espera
								 -- Reparacion Mayor
								 WHEN 3 THEN 2 -- Reparacion
								 -- Mantenimiento
								 WHEN 4 THEN 1 -- Espera
								 -- Ocio
								 WHEN 5 THEN 1 -- Espera
							   END
			, @UnidadActividad = [UnidadActividad]
			, @IDActividadSAO = [ReporteHorasDetalle].[IDActividad]
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
			[ReporteHorasDetalle].[IDReporteHora] = @IDReporteHora;

		/*
		 * CALCULA LAS HORAS A ENVIAR DE EL REGISTRO DE HORAS
		*/
		EXECUTE [ControlMaquinaria].[uspCalculaHorasEnvio]
			@IDReporteHora = @IDReporteHora, -- int
		    @HorasAEnviar = @HorasEnviar OUTPUT -- decimal
		
		/*
		 * SI LAS HORAS A ENVIAR SON 0 NO SE ACTUALIZA EL REGISTRO DE HORA
		 * NI SE CREA EN EL SAO
		*/
		IF ( @HorasEnviar > .00 )
		BEGIN
			/*
			 * REGISTRA LA HORA COMO UN ITEM DE LA TRANSACCION DE
			 * PARTES DE USO
			 */
			INSERT INTO [GH3].[SAO1814].[dbo].[items]
			(
				  [id_transaccion]
				, [id_almacen]
				, [id_concepto]
				, [id_material]
				, [unidad]
				, [numero]
				, [cantidad]
				, [importe]
				, [precio_unitario]
				, [anticipo]
				, [referencia]
			)
			SELECT
				  @IDTransaccionSAO
				, @IDAlmacenSAO
				, @IDActividadSAO
				, @IDMaterial
				, @UnidadActividad
				, @IDTipoHoraSAO
				, @HorasEnviar
				,
				-- SOLO SE CALCULA EL IMPORTE PARA HORAS TRABAJADAS Y EN ESPERA
				CASE 
				  WHEN @IDTipoHoraSAO IN(0, 1) THEN (@HorasEnviar * @PrecioUnitarioHora)
				  ELSE 0
				END
				, @PrecioUnitarioHora
				, @Anticipo
				, @NumeroSerie;
			
			-- OBTIENE EL IDENTIFICADOR DEL ITEM DE LA PARTE DE USO REGISTRADA
			EXECUTE [GH3].[SAO1814].[dbo].[uspGetRowIdentity]
				@idItem OUTPUT;

			/*
			 * PARA LAS HORAS QUE SON EFECTIVAS U OCIO
			 * SE DEBE ACTUALIZAR EL REGISTRO DE LA TABLA INVENTARIOS
			 * DEL SAO PARA ACUMULAR LA CANTIDAD E IMPORTE DE HORAS
			 */
			IF ( @IDTipoHoraSAO IN(0, 1) )
			BEGIN
				UPDATE
					[GH3].[SAO1814].[dbo].[inventarios]
				SET
				-- EN CANTIDAD SE ACUMULA LA CANTIDAD DE HORAS TRABAJADAS Y EN ESPERA
				  [cantidad] = [cantidad] + @HorasEnviar
				-- EN SALDO SOLO SE ACUMULA LA CANTIDAD DE HORAS CUANDO SON EN ESPERA
				, [saldo] = CASE
							  WHEN @IDTipoHoraSAO = 1 THEN [saldo] + @HorasEnviar
							  ELSE [saldo]
							END
				-- EN MONTO_TOTAL SE ACUMULA EL IMPORTE POR HORAS TRABAJADAS Y EN ESPERA
				, [monto_total] = [monto_total] + (@HorasEnviar * @PrecioUnitarioHora)
				WHERE [id_lote] = @IDLoteAlmacen;
				
				/*
				 * PARA HORAS EFECTIVAS SE DEBE EJECUTAR EL PROCEDIMIENTO
				 * sp_uso_maquinaria DEL SAO
				 */
				IF( @IDTipoHoraSAO = 0 )
				BEGIN
					EXECUTE [GH3].[SAO1814].[dbo].[sp_uso_maquinaria]
						@id_item = @idItem,
						@id_lote = @IDLoteAlmacen;
				END
			END
			
			/*
			 * CAMBIA EL ESTATUS DEL REGISTRO DE HORA
			 * Y GUARDA LA REFERENCIA DEL ITEM QUE SE AFECTO EN EL SAO
			 * POR EL REGISTRO DE HORA
			 */
			UPDATE
				[ControlMaquinaria].[ReporteHorasDetalle]
			SET
				  [EnviadaSAO] = 1
				, [IDItemSAO] = @idItem
				, [NumeroSerieMaquina] = @NumeroSerie
				, [FechaHoraEnvio] = GETDATE()
				, [CantidadHorasEnviada] = @HorasEnviar
				, [PrecioUnitario] = @PrecioUnitarioHora
			WHERE
				[IDReporteHora] = @IDReporteHora;
		END
		
		IF( XACT_STATE() > 0 )
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		/*
		 * SI EXISTE UNA TRANSACCION
		 * SE REVIERTE
		*/
		IF( XACT_STATE() != 0 )
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
GO

--SELECT * FROM [sys].[dm_tran_locks]
--EXECUTE [ControlMaquinaria].[uspEnviaHoraSAO]
--@IDReporteHora = 35 -- int
