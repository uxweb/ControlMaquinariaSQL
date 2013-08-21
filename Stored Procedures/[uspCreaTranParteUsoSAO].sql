USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspCreaTranParteUsoSAO]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspCreaTranParteUsoSAO];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspCreaTranParteUsoSAO]
(
	  @IDReporte INT
	, @Usuario VARCHAR(50)
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-06-2011
 * Descripcion:
 * - CREA UN REGISTRO EN LA TABLA TRANSACCIONES
     DE UNA TRANSACCION DE PARTES DE USO PARA PODER
     REGISTRAR LAS HORAS DE UN REPORTE COMO ITEMS DE LA TRANSACCION.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
   - 08-07-2011 [Uziel]: SE AGREGO EL PARAMETRO @Usuario
						 PARA IDENTIFICAR QUE USUARIO
						 ENVIA LA PARTE DE USO AL SAO
*/
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE
	  @IDTransaccionSAO INT = NULL
	, @IDProyectoUnificado INT = NULL
	, @FechaReporte SMALLDATETIME = NULL
	, @IDAlmacenSAO INT = NULL
	, @IDUsuario INT = NULL;
	
	BEGIN TRY
		/*
		 * VERIFICA SI EL USUARIO QUE ENVIA EL REPORTE
		 * EXISTE COMO USUARIO DE SISTEMA
		*/
		EXECUTE [ControlMaquinaria].[uspObtieneIdUsuario]
			@Usuario = @Usuario, -- varchar(100)
			@IDUsuario = @IDUsuario OUTPUT; -- int
	
		IF ( @IDUsuario IS NULL )
		BEGIN
			RAISERROR('No es posible identificar al usuario para enviar el registro al SAO.', 16, 1);
		END
	
		/*
		 * DATOS DEL REPORTE DE HORAS
		*/	
		SELECT
			  @FechaReporte = [ReporteHoras].[FechaReporte]
			, @IDProyectoUnificado = [vwListaProyectosUnificados].[IDProyectoUnificado]
			, @IDAlmacenSAO = [Maquinas].[IDAlmacenSAO]
		FROM
			[ControlMaquinaria].[ReporteHoras]
		INNER JOIN
			[ControlMaquinaria].[Maquinas]
		  ON
			[ReporteHoras].[IDMaquina] = [Maquinas].[IDMaquina]
		INNER JOIN
			[Proyectos].[vwListaProyectosUnificados]
		  ON
			[ReporteHoras].[IDProyecto] = [vwListaProyectosUnificados].[IDProyecto]
				AND
			[vwListaProyectosUnificados].[IDTipoSistemaOrigen] = 1
				AND
			[vwListaProyectosUnificados].[IDTipoBaseDatos] = 1
		INNER JOIN
			[SAO1814App].[dbo].[almacenes]
		  ON
			[Maquinas].[IDAlmacenSAO] = [almacenes].[id_almacen]
		WHERE
			[ReporteHoras].[IDReporte] = @IDReporte;
	
		/*
		 * VERIFICA SI EL REPORTE DE HORAS YA FUE ENVIADO
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
			RAISERROR('La transaccion para este reporte ya fue enviada al SAO.', 16, 1);
		END
	
		/*
		 * VERIFICA SI YA EXISTE UNA TRANSACCION DE PARTES DE USO
		 * CON LA MISMA FECHA QUE EL REPORTE DE HORAS
		*/
		IF EXISTS
		(
			SELECT 1
			FROM
				[GH3].[SAO1814].[dbo].[transacciones]
			WHERE
				[id_obra] = @IDProyectoUnificado
					AND
				[tipo_transaccion] = 36
					AND
				[cumplimiento] = @FechaReporte
					AND
				[id_almacen] = @IDAlmacenSAO
		)
		BEGIN
			RAISERROR('Ya existe una transaccion de partes de uso con esta fecha en el SAO.', 16, 1);
		END
	
		BEGIN DISTRIBUTED TRANSACTION;
		
		/*
		 * CREA EL REGISTRO DE LA TRANSACCION DE PARTES DE USO
		 * EN EL SAO
		*/
		INSERT INTO
		[GH3].[SAO1814].[dbo].[transacciones]
		(
			  [tipo_transaccion]
			, [fecha]
			, [id_obra]
			, [id_almacen]
			, [cumplimiento]
			, [opciones]
			, [comentario]
		)
		SELECT
			  36
			, [ReporteHoras].[FechaReporte] AS [fecha]
			, [vwListaProyectosUnificados].[IDProyectoUnificado] AS [id_obra]
			, [Maquinas].[idAlmacenSAO] AS [id_almacen]
			, [ReporteHoras].[FechaReporte] AS [cumplimiento]
			, 0 AS [opciones]
			, 'I;' + CONVERT(VARCHAR(10), GETDATE(), 103) + ' ' + CONVERT(VARCHAR(5), GETDATE(), 114) + ';ControlMaqSAO|' AS [comentario]
		FROM
			[ControlMaquinaria].[ReporteHoras]
		INNER JOIN
			[ControlMaquinaria].[Maquinas]
		  ON
			[ReporteHoras].[IDMaquina] = [Maquinas].[IDMaquina]
		INNER JOIN
			[Proyectos].[vwListaProyectosUnificados]
		  ON
			[Maquinas].[IDProyecto] = [vwListaProyectosUnificados].[IDProyecto]
			  AND
			[vwListaProyectosUnificados].[idTipoSistemaOrigen] = 1
			  AND
			[vwListaProyectosUnificados].[idTipoBaseDatos] = 1
		WHERE
			[IDReporte] = @IDReporte;
		
		EXECUTE [GH3].[SAO1814].[dbo].[uspGetRowIdentity]
			@IDTransaccionSAO OUTPUT;
		
		IF ( @IDTransaccionSAO IS NULL )
		BEGIN
			RAISERROR('No se pudo registrar la transaccion de partes de uso en el SAO', 16, 1);
		END
		
		/*
		 * ACTUALIZA LOS DATOS DEL REPORTE CON LOS DATOS
		 * DE LA TRANSACCION DEL SAO
		*/
		UPDATE
			[ControlMaquinaria].[ReporteHoras]
		SET
			  [EnviadoSAO] = 1
			, [IDTransaccionSAO] = @IDTransaccionSAO
			, [NumeroFolioSAO] = ( SELECT
									  [numero_folio]
								   FROM
										[GH3].[SAO1814].[dbo].[transacciones]
								   WHERE
										[id_transaccion] = @IDTransaccionSAO
								 )
			, [FechaHoraEnvio] = GETDATE()
			, [IDUsuarioEnvio] = @IDUsuario
		WHERE
			[IDReporte] = @IDReporte;
		
		IF(XACT_STATE() > 0)
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF(XACT_STATE() != 0)
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
GO

--EXECUTE [ControlMaquinaria].[uspCreaTranParteUsoSAO]
--	@IDReporte = 79 -- int