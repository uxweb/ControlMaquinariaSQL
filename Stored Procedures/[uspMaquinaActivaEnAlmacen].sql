USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspMaquinaActivaEnAlmacen]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspMaquinaActivaEnAlmacen];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspMaquinaActivaEnAlmacen]
(
	  @IDAlmacenSAO INT
	, @FechaReporte DATE
	, @IDLoteAlmacen INT OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 21-07-2011
 * Descripcion:
 * - OBTIENE EL IDENTIFICADOR DEL LOTE DE LA MAQUINA
	 A LA QUE SE LE ASIGNARAN LAS HORAS DEL REPORTE
	 DE ACUERDO A LA FECHA DEL REPORTE DE HORAS

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT TOP 1
		@IDLoteAlmacen = [inventarios].[id_lote]
	FROM
		[SAO1814App].[dbo].[inventarios]
	WHERE
		[inventarios].[id_almacen] = @IDAlmacenSAO
			AND
		[inventarios].[fecha_desde] <= CAST(@FechaReporte AS SMALLDATETIME)
			AND
		(
			[inventarios].[fecha_hasta] IS NULL
				OR
			[inventarios].[fecha_hasta] >= CAST(@FechaReporte AS SMALLDATETIME)
		)
	ORDER BY
		[inventarios].[id_lote] DESC;
END
GO

--DECLARE
--  @IDLoteAlmacen INT
  
--EXECUTE [ControlMaquinaria].[uspMaquinaActivaEnAlmacen]
--	@IDAlmacenSAO = 26, -- int
--    @FechaReporte = '2008-12-17', -- date
--    @IDLoteAlmacen = @IDLoteAlmacen OUTPUT -- int

--SELECT @IDLoteAlmacen