USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRevierteReporteHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRevierteReporteHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRevierteReporteHoras]
(
	  @IDMaquina	INT
	, @FechaReporte DATE
	, @Operacion	TINYINT = 2-- 1: Revertir como Aprobada, 2: Revertir como Capturada
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 30-03-2012
 * Descripcion:
 * - REVIERTE UN REPORTE DE HORAS QUE FUE ENVIADO AL SAO REVIRTIENDO
	 EL ESTATUS DE ENVIADA A SAO Y LIMPIANDO LOS DATOS DEL ENVIO.
	 
     PARA PODER REVERTIR EL REPORTE, ES NECESARIO QUE LA PARTE DE USO
     CORRESPONDIENTE YA ESTE ELIMINADA DEL SAO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @IDTransaccionSAO INT;
	
	SELECT
		@IDTransaccionSAO = [IDTransaccionSAO]
	FROM
		[ControlMaquinaria].[ReporteHoras]
	WHERE
		[IDMaquina] = @IDMaquina
			AND
		[FechaReporte] = @FechaReporte;
	
	-- VERIFICA SI EL REPORTE EXISTE
	IF NOT EXISTS
	(
		SELECT 1
		FROM
			[ControlMaquinaria].[ReporteHoras]
		WHERE
			[IDMaquina] = @IDMaquina
				AND
			[FechaReporte] = @FechaReporte
	)
	BEGIN
		RAISERROR( 'El reporte no ha sido capturado.', 16, 1 );
		RETURN (1);
	END
	
	BEGIN TRY
	
		-- VERIFICA QUE LA OPERACION PARA REVERTIR ELEGIDA SEA VALIDA
		IF( @Operacion NOT BETWEEN 1 AND 2 )
		BEGIN
			RAISERROR('La operacion indicada no es valida.', 16, 1);
		END
		
		-- VERIFICA SI EL REPORTE FUE ENVIADO AL SAO
		IF EXISTS
		(
			SELECT 1
			FROM
				[ControlMaquinaria].[ReporteHoras]
			WHERE
				[IDMaquina] = @IDMaquina
					AND
				[FechaReporte] = @FechaReporte
					AND
				[EnviadoSAO] = 0
		)
		BEGIN
			RAISERROR('El reporte de horas no ha sido enviado al SAO. No es posible revertirlo.', 16, 1);
		END
		
		-- VERIFICAR SI LA PARTE DE USO YA FUE BORRADA DEL SAO
		IF EXISTS
		(
			SELECT 1
			FROM
				[GH3].[SAO1814].[dbo].[transacciones]
			WHERE
				[id_transaccion] = @IDTransaccionSAO
		)
		BEGIN
			RAISERROR('La parte de uso correspondiente a este reporte de horas no ha sido borrada del SAO.', 16, 1);
		END
		
		BEGIN TRANSACTION
		
			-- MODIFICAR LOS REGISTROS DE HORA
			UPDATE
				[ControlMaquinaria].[ReporteHorasDetalle]
			SET
				[Aprobada] = CASE @Operacion
							   WHEN 1 THEN 1
							   WHEN 2 THEN 0
							 END
				, [EnviadaSAO] = 0
				, [IDItemSAO] = NULL
				, [CantidadHorasEnviada] = 0
				, [PrecioUnitario] = NULL
				, [NumeroSerieMaquina] = NULL
				, [FechaHoraEnvio] = NULL
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
				[ReporteHoras].[IDMaquina] = @IDMaquina
					AND
				[ReporteHoras].[FechaReporte] = @FechaReporte;

			-- ACTUALIZAR EL REPORTE DE HORAS
			UPDATE
				[ControlMaquinaria].[ReporteHoras]
			SET
				  [EnviadoSAO] = 0
				, [IDTransaccionSAO] = NULL
				, [NumeroFolioSAO] = NULL
				, [FechaHoraEnvio] = NULL
				, [IDUsuarioEnvio] = NULL
			WHERE
				[IDMaquina] = @IDMaquina
					AND
				[FechaReporte] = @FechaReporte;
			
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		IF( @@TRANCOUNT > 0 )
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
GO