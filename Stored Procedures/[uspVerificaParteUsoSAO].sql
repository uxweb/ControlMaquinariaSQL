USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspVerificaParteUsoSAO]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspVerificaParteUsoSAO];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspVerificaParteUsoSAO]
(
	  @IDMaquina INT
	, @FechaReporte SMALLDATETIME
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 04-07-2011
 * Descripcion:
 * - VERIFICA SI EXISTE YA EN EL SAO UNA PARTE DE USO
	 CON LA FECHA DE UN REPORTE DE HORAS DE MAQUINARIA.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		  @IDProyecto INT = NULL
		, @IDProyectoUnificado INT = NULL
		, @IDAlmacenSAO INT = NULL
		, @errorMessage VARCHAR(500) = NULL;
	
	SELECT
		  @IDProyecto = [IDProyecto]
		, @IDAlmacenSAO = [IDAlmacenSAO]
	FROM
		[ControlMaquinaria].[Maquinas]
	WHERE
		[IDMaquina] = @IDMaquina;
	
	SELECT
		@IDProyectoUnificado = [IDProyectoUnificado]
	FROM
		[Proyectos].[vwListaProyectosUnificados]
	WHERE
		[IDProyecto] = @IDProyecto
			AND
		[IDTipoSistemaOrigen] = 1
			AND
		[IDTipoBaseDatos] = 1;
	
	IF EXISTS
	(
		SELECT 1
		FROM
			[GH3].[SAO1814].[dbo].[transacciones]
		INNER JOIN
			[GH3].[SAO1814].[dbo].[items]
			ON
				[transacciones].[id_transaccion] = [items].[id_transaccion]
		WHERE
			[transacciones].[id_obra] = @IDProyectoUnificado
				AND
			[transacciones].[id_almacen] = @IDAlmacenSAO
				AND
			[transacciones].[fecha] = @FechaReporte
				AND
			[transacciones].[cumplimiento] = @FechaReporte
				AND
			[transacciones].[tipo_transaccion] = 36
	)
	BEGIN
		IF NOT EXISTS
		(
			SELECT
				1
			FROM
				[ControlMaquinaria].[ReporteHoras]
			WHERE
				[IDMaquina] = @IDMaquina
					AND
				[IDProyecto] = @IDProyecto
					AND
				[EnviadoSAO] = 1
					AND
				[FechaReporte] = @FechaReporte
			)
		BEGIN
			SET @errorMessage = 'Ya existe una transaccion de partes de uso con fecha [' + CONVERT(VARCHAR(10), @FechaReporte, 105) + '] en el SAO.';
			RAISERROR(@errorMessage, 16, 1);
			RETURN(1);
		END
	END
END
GO

--EXECUTE [ControlMaquinaria].[uspVerificaParteUsoSAO]
--	@IDMaquina = 70, -- int
--    @FechaReporte = '20110621' -- smalldatetime