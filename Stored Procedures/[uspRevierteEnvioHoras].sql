USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRevierteEnvioHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRevierteEnvioHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRevierteEnvioHoras]
(
	  @IDReporte INT
	, @Aprobado  BIT = 1
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION;
		
		UPDATE
			[ReporteHorasDetalle]
		SET
			  [ReporteHorasDetalle].[Aprobada] = @Aprobado
			, [ReporteHorasDetalle].[EnviadaSAO] = 0
			, [ReporteHorasDetalle].[IDItemSAO] = NULL
			, [ReporteHorasDetalle].[CantidadHorasEnviada] = 0
			, [ReporteHorasDetalle].[PrecioUnitario] = NULL
			, [ReporteHorasDetalle].[NumeroSerieMaquina] = NULL
			, [ReporteHorasDetalle].[FechaHoraEnvio] = NULL
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
			[ControlMaquinaria].[ReporteHoras].[IDReporte] = @IDReporte;
		
		UPDATE
			[ControlMaquinaria].[ReporteHoras]
		SET
			  [EnviadoSAO] = 0
			, [FechaHoraEnvio] = NULL
			, [IDTransaccionSAO] = NULL
			, [IDUsuarioEnvio] = NULL
			, [NumeroFolioSAO] = NULL
			, [IDHoraMensual] = NULL
		WHERE
			[IDReporte] = @IDReporte;
		
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END;
GO

--EXECUTE [ControlMaquinaria].[uspRevierteEnvioHoras]
--	@IDReporte = 18347, -- int
--    @Aprobado = 0 -- bit
