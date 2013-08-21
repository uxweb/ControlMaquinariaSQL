USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspDatosMaquinaSAO]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspDatosMaquinaSAO];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspDatosMaquinaSAO]
(
	@IDMaquina INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 26-05-2011
 * Descripcion:
 * - DATOS DE LA MAQUINA ACTIVA EN ALMACEN DEL SAO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @IDAlmacenSAO INT = NULL;
	  
	SELECT
		@IDAlmacenSAO = [IDAlmacenSAO]
	FROM
		[ControlMaquinaria].[Maquinas]
	WHERE
		[IDMaquina] = @IDMaquina;
	
	SELECT
		  [almacenes].[id_obra] AS [idProyecto]
		, [Familia].[id_material] AS [idFamiliaMaquina]
		, [Familia].[descripcion] AS [FamiliaMaquina]
		, [materiales].[id_material] AS [idMaterialMaquina]
		, [materiales].[descripcion] AS [MaterialMaquina]
		, [materiales].[numero_parte] AS [NumeroParte]
		, [almacenes].[id_almacen] AS [idMaquina]
		, [almacenes].[descripcion] AS [Maquina]
		, [EntradaMaquinaria].[NumeroSerie]
		, [OrdenesRenta].[idProveedor]
		, [OrdenesRenta].[Proveedor]
		, [OrdenesRenta].[idSucursal]
		, [OrdenesRenta].[Sucursal]
		, [EntradaMaquinaria].[FechaEntrada]
		, [SalidaMaquinaria].[FechaSalida]
		,
		CASE
		  WHEN PATINDEX('%P_%', [almacenes].[descripcion]) < 10 THEN 1
		  WHEN PATINDEX('%R_%', [almacenes].[descripcion]) < 10 THEN 2
		  ELSE NULL
		END AS [idPropiedad]
		,
		CASE
		  WHEN PATINDEX('%P_%', [almacenes].[descripcion]) < 10 THEN 'Propio'
		  WHEN PATINDEX('%R_%', [almacenes].[descripcion]) < 10 THEN 'Terceros'
		  ELSE NULL
		END AS [Propiedad]
		,
		CASE
		  WHEN UPPER(LEFT([materiales].[numero_parte], 1)) = 'A' THEN 1
		  WHEN UPPER(LEFT([materiales].[numero_parte], 1)) = 'B' THEN 2
		  WHEN UPPER(LEFT([materiales].[numero_parte], 1)) = 'C' THEN 3
		  --ELSE 'Desconocido'
		END AS [idCategoria]
		,
		CASE
		  WHEN UPPER(LEFT([materiales].[numero_parte], 1)) = 'A' THEN 'Mayor'
		  WHEN UPPER(LEFT([materiales].[numero_parte], 1)) = 'B' THEN 'Menor'
		  WHEN UPPER(LEFT([materiales].[numero_parte], 1)) = 'C' THEN 'Transporte'
		  --ELSE 'Desconocido'
		END AS [Categoria]
		, [PartesUso].[UltimaParteUso]
		, [EntradaMaquinaria].[PrecioHoraRenta]
		, [PrecioPorHoraPresupuesto].[PrecioPromPresupuestado]
		, [EntradaMaquinaria].[ImporteHorasInventario]  -- REVISAR ESTE IMPORTE POR LA FALLA QUE TIENE EL SAO AL ELIMINAR PARTES DE USO
	FROM
		[SAO1814App].[dbo].[almacenes]
	INNER JOIN
		[SAO1814App].[dbo].[materiales]
		ON
			[almacenes].[id_material] = [materiales].[id_material]
	LEFT OUTER JOIN
		[SAO1814App].[dbo].[materiales] AS [Familia]
		ON
			[materiales].[tipo_material] = [Familia].[tipo_material]
				AND
			LEFT([materiales].[nivel], 4) = [Familia].[nivel]
	LEFT OUTER JOIN
	(
		SELECT
			  [EntradaMaquina].[id_obra]
			, [inventarios].[monto_total] AS [ImporteHorasInventario]
			, [EntradaMaquina].[fecha] AS [FechaEntrada]
			, [items].[id_almacen] AS [idAlmacenMaquina]
			, [items].[referencia] AS [NumeroSerie]
			, [items].[precio_unitario] AS [PrecioHoraRenta]
			--, [EntradaMaquina].[id_empresa] AS [idProveedor]
			--, [empresas].[razon_social] AS [Proveedor]
			--, [EntradaMaquina].[id_sucursal] AS [idSucursal]
			--, [sucursales].[descripcion] AS [Sucursal]
			, [EntradaMaquina].[id_antecedente]
			, [items].[item_antecedente]
		FROM
			[SAO1814App].[dbo].[transacciones] AS [EntradaMaquina]
		INNER JOIN
			[SAO1814App].[dbo].[items]
			ON
				[EntradaMaquina].[id_transaccion] = [items].[id_transaccion]
		--INNER JOIN [SAO1814Reportes].[dbo].[empresas]
		--  ON [EntradaMaquina].[id_empresa] = [empresas].[id_empresa]
		--INNER JOIN [SAO1814Reportes].[dbo].[sucursales]
		--  ON [EntradaMaquina].[id_empresa] = [sucursales].[id_empresa]
		--  AND [EntradaMaquina].[id_sucursal] = [sucursales].[id_sucursal]
		INNER JOIN
			[SAO1814App].[dbo].[inventarios]
			ON
				[items].[id_item] = [inventarios].[id_item]
		WHERE
			[EntradaMaquina].[tipo_transaccion] = 33
				AND
			[EntradaMaquina].[opciones] = 8
	) AS [EntradaMaquinaria]
	  ON
		[almacenes].[id_obra] = [EntradaMaquinaria].[id_obra]
			AND
		[almacenes].[id_almacen] = [EntradaMaquinaria].[idAlmacenMaquina]
	LEFT OUTER JOIN
	(
		SELECT
			  [salidaMaquinaria].[id_obra]
			, [salidaMaquinaria].[fecha] AS [FechaSalida]
			, [items].[id_almacen] AS [idAlmacenMaquina]
			, [items].[cantidad] AS [DiasEnObra]
		FROM
			[SAO1814App].[dbo].[transacciones] AS [salidaMaquinaria]
		INNER JOIN
			[SAO1814App].[dbo].[items]
			ON
				[SalidaMaquinaria].[id_transaccion] = [items].[id_transaccion]
		WHERE
			[SalidaMaquinaria].[tipo_transaccion] = 34
				AND
			[SalidaMaquinaria].[opciones] = 8
	) AS [SalidaMaquinaria]
	  ON
		[almacenes].[id_obra] = [SalidaMaquinaria].[id_obra]
			AND
		[almacenes].[id_almacen] = [SalidaMaquinaria].[idAlmacenMaquina]
	LEFT OUTER JOIN
	(
		SELECT
			  [transacciones].[id_obra]
			, [items].[id_almacen] AS [idAlmacenMaquina]
			, MAX([transacciones].[cumplimiento]) AS [UltimaParteUso]
		FROM
			[SAO1814App].[dbo].[transacciones]
		INNER JOIN
			[SAO1814App].[dbo].[items]
			ON
				[transacciones].[id_transaccion] = [items].[id_transaccion]
		INNER JOIN
			[SAO1814App].[dbo].[materiales]
			ON
				[items].[id_material] = [materiales].[id_material]
					AND
				[materiales].[tipo_material] = 8
		WHERE
			[transacciones].[tipo_transaccion] = 36
				AND
			[items].[numero] IN(0, 1, 2)
		GROUP BY
			  [transacciones].[id_obra]
			, [items].[id_almacen]
	) AS [PartesUso]
	  ON
		[almacenes].[id_obra] = [PartesUso].[id_obra]
			AND
		[almacenes].[id_almacen] = [PartesUso].[idAlmacenMaquina]
	LEFT OUTER JOIN
	(
		SELECT
			  [transacciones].[id_obra]
			, [transacciones].[id_transaccion] AS [idOrdenRenta]
			, [items].[id_item]
			--, [items].[precio_unitario] AS [PrecioHoraRenta]
			, [transacciones].[id_empresa] AS [idProveedor]
			, [empresas].[razon_social] AS [Proveedor]
			, [transacciones].[id_sucursal] AS [idSucursal]
			, [sucursales].[descripcion] AS [Sucursal]
		FROM
			[SAO1814App].[dbo].[transacciones]
		INNER JOIN
			[SAO1814App].[dbo].[items]
			ON
				[transacciones].[id_transaccion] = [items].[id_transaccion]
		INNER JOIN
			[SAO1814App].[dbo].[empresas]
			ON
				[transacciones].[id_empresa] = [empresas].[id_empresa]
		INNER JOIN
			[SAO1814App].[dbo].[sucursales]
			ON
				[transacciones].[id_empresa] = [sucursales].[id_empresa]
					AND
				[transacciones].[id_sucursal] = [sucursales].[id_sucursal]
		WHERE
			[transacciones].[tipo_transaccion] = 19
				AND
			[transacciones].[opciones] = 8
	) AS [OrdenesRenta]
	  ON
		[EntradaMaquinaria].[id_antecedente] = [OrdenesRenta].[idOrdenRenta]
			AND
		[EntradaMaquinaria].[item_antecedente] = [OrdenesRenta].[id_item]
	LEFT OUTER JOIN
	(
		SELECT
			  [id_obra]
			, [id_material]
			, AVG([precio_unitario]) AS [PrecioPromPresupuestado]
		FROM
			[SAO1814App].[dbo].[conceptos]
		GROUP BY
			  [id_obra]
			, [id_material]
	) AS [PrecioPorHoraPresupuesto]
	  ON
		[almacenes].[id_obra] = [PrecioPorHoraPresupuesto].[id_obra]
			AND
		[almacenes].[id_material] = [PrecioPorHoraPresupuesto].[id_material]
	WHERE
		[almacenes].[id_almacen] = @IDAlmacenSAO
END
GO

EXECUTE [ControlMaquinaria].[uspDatosMaquinaSAO]
	@IDMaquina = 227