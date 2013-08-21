USE [ModulosSAO]
GO


ALTER PROCEDURE [ControlMaquinaria].[uspEnviaHoraSAO](
	@idReporteHora INT
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
*/
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE
	  @idReporte INT = NULL
	, @FechaReporte DATE = NULL
	, @idMaquina INT = NULL
	, @idProyecto INT = NULL
	, @idTransaccionSAO INT = NULL
	, @idAlmacenSAO INT = NULL
	, @idMaterial INT = NULL
	, @idActividadSAO INT = NULL
	, @idTipoHora INT = NULL
	, @idTipoHoraSAO INT = NULL
	, @CantidadHoras DECIMAL(4, 2) = NULL
	, @NumeroSerie VARCHAR(64) = NULL
	, @PrecioUnitarioHora FLOAT = 0
	, @idLoteAlmacen INT = NULL
	, @idItem INT = NULL;
	
	/*
	 * VERIFICA QUE EL REGISTRO DE HORA ESTE APROBADO
	 */	
	IF EXISTS( SELECT 1
			   FROM [ControlMaquinaria].[ReporteHorasDetalle]
			   WHERE [idReporteHora] = @idReporteHora
			   AND [Aprobada] = 0
			 )
	BEGIN
		RAISERROR('No puede enviar este registro de hora al SAO, no ha sido aprobado.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * VERIFICA QUE EL REGISTRO DE HORA NO HAYA SIDO ENVIADO
	 */
	IF EXISTS( SELECT 1
			   FROM [ControlMaquinaria].[ReporteHorasDetalle]
			   WHERE [idReporteHora] = @idReporteHora
			   AND [EnviadaSAO] = 1
			 )
	BEGIN
		RAISERROR('No puede enviar este registro de hora al SAO, ya ha sido enviado.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * OBTIENE DATOS DEL REPORTE DE LA HORA
	 */
	SELECT
	  @FechaReporte = [ReporteHoras].[FechaReporte]
	, @idMaquina = [ReporteHoras].[idMaquina]
	, @idProyecto = [ReporteHoras].[idProyecto]
	, @idReporte = [ReporteHoras].[idReporte]
	FROM [ControlMaquinaria].[ReporteHoras]
	INNER JOIN [ControlMaquinaria].[ReporteHorasDetalle]
	  ON [ReporteHoras].[idReporte] = [ReporteHorasDetalle].[idReporte]
	WHERE [idReporteHora] = @idReporteHora;
	
	/*
	 * GENERA EL ENVIO DE EL REGISTRO DE HORA AL SAO
	 */
	BEGIN TRY
		BEGIN DISTRIBUTED TRANSACTION;
		/*
		 * VERIFICA ALGUNO DE LOS REPORTES DE HORAS DE LA FECHA
		 * YA TIENE DATOS DEL SAO (DE LA TRANSACCION DE PARTES DE USO DEL SAO)
		 * PARA PODER AGREGARLE LA HORA COMO ITEM.
		 * SI NO LO TIENE SE CREARA PRIMERO EL REGISTRO DE LA TRANSACCION
		 */
		IF NOT EXISTS( SELECT 1
					   FROM [ControlMaquinaria].[ReporteHoras]
					   WHERE [ReporteHoras].[idMaquina] = @idMaquina
					   AND [ReporteHoras].[idProyecto] = @idProyecto
					   AND [ReporteHoras].[FechaReporte] = @FechaReporte
					   AND [ReporteHoras].[EnviadoSAO] = 1
					  )
		BEGIN
			/*
			 * EL REPORTE NO ESTA ENVIADO COMO TRANSACCION DE PARTES DE USO
			 * CREA LA TRANSACCION DE PARTES DE USO EN EL SAO CON LOS DATOS
			 * DEL REPORTE DE HORAS
			 */
			EXECUTE [ControlMaquinaria].[uspCreaTranParteUsoSAO] @idReporte;
		END
		ELSE
		BEGIN
			/*
			 * ACTUALIZA LOS DATOS DEL REPORTE CON LOS DATOS
			 * DEL EXISTENTE YA ENVIADO
			 */
			UPDATE [ControlMaquinaria].[ReporteHoras]
			SET [idTransaccionSAO] = [ReporteEnviado].[idTransaccionSAO]
			, [NumeroFolioSAO] = [ReporteEnviado].[NumeroFolioSAO]
			, [FechaHoraEnvio] = [ReporteEnviado].[FechaHoraEnvio]
			, [EnviadoSAO] = 1
			FROM [ControlMaquinaria].[ReporteHoras]
			CROSS APPLY (
				SELECT TOP 1
				  [idTransaccionSAO]
				, [NumeroFolioSAO]
				, [FechaHoraEnvio]
			    FROM [ControlMaquinaria].[ReporteHoras]
			    WHERE [ReporteHoras].[idMaquina] = @idMaquina
			    AND [ReporteHoras].[idProyecto] = @idProyecto
			    AND [ReporteHoras].[FechaReporte] = @FechaReporte
			    AND [ReporteHoras].[EnviadoSAO] = 1
			) AS [ReporteEnviado]
			WHERE [idReporte] = @idReporte;
		END
		
		/*
		 * OBTIENE DATOS DE LA MAQUINA PARA PODER REGISTRAR
		 * LA HORA COMO UN ITEM DE LA TRANSACCION DE PARTES DE USO
		 */	
		SELECT
		  @idTransaccionSAO = [ReporteHoras].[idTransaccionSAO]
		, @idAlmacenSAO = [Maquinas].[idAlmacenSAO]
		, @idTipoHora = [ReporteHorasDetalle].[idTipoHora]
		, @idTipoHoraSAO = CASE @idTipoHora
							 WHEN 1 THEN 0 -- Trabajo
							 WHEN 2 THEN 2 -- Reparacion
							 WHEN 3 THEN 2 -- Reparacion
							 WHEN 4 THEN 2 -- Reparacion
							 WHEN 5 THEN 1 -- Espera
						   END
		, @CantidadHoras = [ReporteHorasDetalle].[CantidadHoras]
		, @idActividadSAO = [ReporteHorasDetalle].[idActividad]
		, @idItem = [ReporteHorasDetalle].[idItemSAO]
		FROM [ControlMaquinaria].[Maquinas]
		INNER JOIN [ControlMaquinaria].[ReporteHoras]
		  ON [Maquinas].[idMaquina] = [ReporteHoras].[idMaquina]
		INNER JOIN [ControlMaquinaria].[ReporteHorasDetalle]
		  ON [ReporteHoras].[idReporte] = [ReporteHorasDetalle].[idReporte]
		WHERE [ReporteHorasDetalle].[idReporteHora] = @idReporteHora;
		
		/*
		 * DATOS DE LA MAQUINA ACTIVA EN EL ALMACEN
		 */
		SELECT
		  @idMaterial = [inventarios].[id_material]
		, @NumeroSerie = [inventarios].[referencia]
		, @PrecioUnitarioHora = [items].[precio_unitario]
		, @idLoteAlmacen = [inventarios].[id_lote]
		FROM [GH3].[PRUEBAS1814].[dbo].[inventarios]
		INNER JOIN [GH3].[PRUEBAS1814].[dbo].[items]
		  ON [inventarios].[id_item] = [items].[id_item]
		WHERE [inventarios].[id_almacen] = @idAlmacenSAO
		AND [inventarios].[fecha_desde] IS NOT NULL
		AND [inventarios].[fecha_hasta] IS NULL
		AND [inventarios].[lote_antecedente] IS NULL;
		
		
		/*
		 * IDENTIFICA SI YA EXISTE UN ITEM DEL MISMO TIPO DE HORA
		 * EN EL SAO PARA ACUMULARLO
		 */
		IF EXISTS( SELECT 1
				   FROM [GH3].[PRUEBAS1814].[dbo].[items]
				   WHERE [id_transaccion] = @idTransaccionSAO
				   AND [numero] = @idTipoHoraSAO
				   AND ( [id_concepto] = @idActividadSAO
						 OR [id_concepto] IS NULL
					   )
				 )
		BEGIN
			-- OBTIENE EL IDENTIFICADOR DEL ITEM PARA ACTUALIZAR EL
			-- REGISTRO DE LA HORA
			SELECT
			  @idItem = [id_item]
			FROM [GH3].[PRUEBAS1814].[dbo].[items]
			WHERE [id_transaccion] = @idTransaccionSAO
			AND ( [id_concepto] = @idActividadSAO
				  OR [id_concepto] IS NULL
			);

			-- ACTUALIZA LA CANTIDAD E IMPORTE DEL ITEM
			UPDATE [GH3].[PRUEBAS1814].[dbo].[items]
			SET [cantidad] = [cantidad] + @CantidadHoras
			, [importe] = [importe] + (@CantidadHoras * @PrecioUnitarioHora)
			WHERE [id_item] = @idItem;
		END
		ELSE
		BEGIN
			/*
			 * REGISTRA LA HORA COMO UN ITEM DE LA TRANSACCION DE
			 * PARTES DE USO
			 */
			INSERT INTO [GH3].[PRUEBAS1814].[dbo].[items](
				  [id_transaccion]
				, [id_almacen]
				, [id_concepto]
				, [id_material]
				, [numero]
				, [cantidad]
				, [importe]
				, [precio_unitario]
				, [referencia]
			)
			SELECT
			  @idTransaccionSAO
			, @idAlmacenSAO
			, @idActividadSAO
			, @idMaterial
			, @idTipoHoraSAO
			, @CantidadHoras
			, (@CantidadHoras * @PrecioUnitarioHora)
			, @PrecioUnitarioHora
			, @NumeroSerie;
			
			-- OBTIENE EL IDENTIFICADOR DEL ITEM
			EXECUTE [GH3].[PRUEBAS1814].[dbo].[uspGetRowIdentity]
				@idItem OUTPUT;

		END
				
		/*
		 * PARA LAS HORAS QUE SON EFECTIVAS U OCIO
		 * SE DEBE ACTUALIZAR EL REGISTRO DE LA TABLA INVENTARIOS
		 * DEL SAO PARA ACUMULAR EL NUMERO E IMPORTE DE HORAS
		 */
		IF(@idTipoHora IN(1, 5))
		BEGIN
			UPDATE [GH3].[PRUEBAS1814].[dbo].[inventarios]
			SET [cantidad] = CASE @idTipoHora
					           WHEN 1 THEN [cantidad] + @CantidadHoras
					           ELSE [cantidad]
					         END
			, [saldo] = CASE @idTipoHora
						  WHEN 1 THEN [saldo]
						  ELSE [saldo] + @CantidadHoras
						END
			, [monto_total] = CASE @idTipoHora
								WHEN 1 THEN [monto_total] + (@CantidadHoras * @PrecioUnitarioHora)
								ELSE [monto_total]
							  END
			WHERE [id_almacen] = @idAlmacenSAO
			AND [referencia] = @NumeroSerie;
			
			/*
			 * PARA HORAS EFECTIVAS SE DEBE EJECUTAR EL PROCEDIMIENTO
			 * sp_uso_maquinaria DEL SAO
			 */
			IF(@idTipoHora = 1)
			BEGIN
				EXECUTE [GH3].[PRUEBAS1814].[dbo].[sp_uso_maquinaria]
					@id_item = @idItem,
				    @id_lote = @idLoteAlmacen;
			END
		END
		
		/*
		 * CAMBIA EL ESTATUS DEL REGISTRO DE HORA
		 * Y GUARDA LA REFERENCIA DEL ITEM QUE SE AFECTO EN EL SAO
		 * POR EL REGISTRO DE HORA
		 */
		UPDATE [ControlMaquinaria].[ReporteHorasDetalle]
		SET [EnviadaSAO] = 1
		, [idItemSAO] = @idItem
		, [FechaHoraEnvio] = GETDATE()
		WHERE [idReporteHora] = @idReporteHora;
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		DECLARE
		  @ErrorMessage NVARCHAR(500) = ERROR_MESSAGE();

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN(1);
	END CATCH
END

GO

EXECUTE [ControlMaquinaria].[uspEnviaHoraSAO]
@idReporteHora = 6 -- int


SELECT * FROM [ControlMaquinaria].[ReporteHoras]
WHERE [FechaReporte] = '20110609'
SELECT * FROM [ControlMaquinaria].[ReporteHorasDetalle]
WHERE [idReporte] IN(4, 3)


SELECT * FROM [GH3].pruebas1814.dbo.transacciones
WHERE id_transaccion = 732816
