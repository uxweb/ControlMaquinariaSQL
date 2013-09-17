USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspListaMaquinas]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspListaMaquinas];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspListaMaquinas]
(
	@Usuario VARCHAR(50),
	@IdObra INTEGER = NULL
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 23-05-2011
 * Descripcion:
 * - LISTA DE ALMACENES DE MAQUINARIA POR PROYECTO.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
 
 * - 01-07-2011 [Uziel]: SE AGREGO UN PARAMETRO QUE PERMITE MOSTRAR
					     SOLO LAS MAQUINAS DE LOS PPROYECTOS A LOS QUE
					     EL USUARIO TIENE ACCESO

 * - 01-07-2011 [Uziel]: SE MODIFICO LA CONSULTA PARA QUE NO MUESTRE LOS ALMACENES
						 QUE YA NO TIENEN MAQUINAS ACTIVAS.
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		@DiasTolerancia SMALLINT = NULL;
	
	SELECT
		@DiasTolerancia = [DiasToleranciaBaja]
	FROM
		[ControlMaquinaria].[ParametrosAplicacion];
	
	IF ( @DiasTolerancia IS NULL )
	BEGIN
		RAISERROR('No se han definido los dias de tolerancia de captura despues de baja.', 16, 1);
		RETURN(1);
	END
	
	IF EXISTS
	(
		SELECT 1
		FROM
			[Seguridad].[Usuarios]
		WHERE
			[Usuario] = @Usuario
				AND
			[AccesoTodosProyectos] = 1
	)
	BEGIN
		
		SELECT DISTINCT
			  [vwListaProyectosUnificados].[IDProyecto]
			, [vwListaProyectosUnificados].[NombreProyecto] AS [Proyecto]
			, [Maquinas].[IDMaquina]
			, [almacenes].[id_almacen] AS [IDAlmacen]
			, [almacenes].[descripcion] AS [Almacen]
			--, [CuentaMaquinasAlmacen].[CantidadMaquinas]
			, [inventarios].[fecha_hasta] AS [FechaBaja]
			,
			CASE
			  WHEN [Maquinas].[idMaquina] IS NULL THEN 0
			  ELSE 1
			END AS [Registrada]
			,
			CASE
			  WHEN [Maquinas].[idActivoSCAF] IS NULL THEN 0
			  ELSE 1
			END AS [AsociadaSCAF]
		FROM
			[SAO1814App].[dbo].[almacenes]
		INNER JOIN
			[SAO1814App].[dbo].[inventarios]
			ON
				[almacenes].[id_almacen] = [inventarios].[id_almacen]
					AND
				[inventarios].[fecha_desde] IS NOT NULL
					AND
				(
					[fecha_hasta] IS NULL -- NO TIENE BAJA O FECHA DE SALIDA
						/*
							* SI TIENE BAJA O FECHA DE SALIDA, QUE ESTA +/- LOS DIAS DE TOLERANCIA
							* NO EXEDAN LA FECHA ACTUAL
						*/
						OR
					(
						DATEADD(DAY, -@DiasTolerancia, [inventarios].[fecha_hasta]) <= GETDATE()
							AND
						DATEADD(DAY, @DiasTolerancia, [inventarios].[fecha_hasta]) >= GETDATE()
					)
				)
		INNER JOIN
			[SAO1814App].[dbo].[obras]
			ON
				[almacenes].[id_obra] = [obras].[id_obra]
		INNER JOIN
			[Proyectos].[vwListaProyectosUnificados]
			ON
				[obras].[id_obra] = [Proyectos].[vwListaProyectosUnificados].[IDProyectoUnificado]
					AND
				[Proyectos].[vwListaProyectosUnificados].[IDTipoSistemaOrigen] = 1
					AND
				[Proyectos].[vwListaProyectosUnificados].[IDTipoBaseDatos] = 1
		LEFT OUTER JOIN
			[ControlMaquinaria].[Maquinas]
			ON
				[almacenes].[id_almacen] = [ControlMaquinaria].[Maquinas].[IDAlmacenSAO]
		WHERE
			[almacenes].[tipo_almacen] = 2
				AND
			[obras].[id_obra] = ISNULL(@IdObra, [obras].[id_obra])
		ORDER BY
			  [vwListaProyectosUnificados].[NombreProyecto]
			, [Almacen]
	END
	ELSE
	BEGIN
		SELECT DISTINCT
			  [vwListaProyectosUnificados].[IDProyecto]
			, [vwListaProyectosUnificados].[NombreProyecto] AS [Proyecto]
			, [Maquinas].[IDMaquina]
			, [almacenes].[id_almacen] AS [IDAlmacen]
			, [almacenes].[descripcion] AS [Almacen]
			--, [CuentaMaquinasAlmacen].[CantidadMaquinas]
			, [inventarios].[fecha_hasta] AS [FechaBaja]
			,
			CASE
			  WHEN [Maquinas].[IDMaquina] IS NULL THEN 0
			  ELSE 1
			END AS [Registrada]
			,
			CASE
			  WHEN [Maquinas].[IDActivoSCAF] IS NULL THEN 0
			  ELSE 1
			END AS [AsociadaSCAF]
		FROM
			[SAO1814App].[dbo].[almacenes]
		INNER JOIN
			[SAO1814App].[dbo].[inventarios]
		  ON
			[almacenes].[id_almacen] = [inventarios].[id_almacen]
				AND
			[inventarios].[fecha_desde] IS NOT NULL
				AND
			(
				[fecha_hasta] IS NULL -- NO TIENE BAJA O FECHA DE SALIDA
					/*
					 * SI TIENE BAJA O FECHA DE SALIDA, QUE ESTA +/- LOS DIAS DE TOLERANCIA
					 * NO EXEDAN LA FECHA ACTUAL
					*/
					OR
				(
					DATEADD(DAY, -@DiasTolerancia, [inventarios].[fecha_hasta]) <= GETDATE()
						AND
					DATEADD(DAY, @DiasTolerancia, [inventarios].[fecha_hasta]) >= GETDATE()
				)
			)
		INNER JOIN
			[SAO1814App].[dbo].[obras]
			ON
				[almacenes].[id_obra] = [obras].[id_obra]
		INNER JOIN
			[Proyectos].[vwListaProyectosUnificados]
			ON
				[obras].[id_obra] = [Proyectos].[vwListaProyectosUnificados].[IDProyectoUnificado]
					AND
				[Proyectos].[vwListaProyectosUnificados].[IDTipoSistemaOrigen] = 1
					AND
				[Proyectos].[vwListaProyectosUnificados].[IDTipoBaseDatos] = 1
		INNER JOIN
			[Seguridad].[UsuariosProyectos]
			ON
				[vwListaProyectosUnificados].[IDProyecto] = [UsuariosProyectos].[IDProyecto]
		INNER JOIN
			[Seguridad].[Usuarios]
			ON
				[Usuarios].[Usuario] = @Usuario
					AND
				[UsuariosProyectos].[IDUsuario] = [Usuarios].[IDUsuario]
		LEFT OUTER JOIN
			[ControlMaquinaria].[Maquinas]
			ON
				[almacenes].[id_almacen] = [ControlMaquinaria].[Maquinas].[IDAlmacenSAO]
		WHERE
			[almacenes].[tipo_almacen] = 2
				AND
			[obras].[id_obra] = ISNULL(@IdObra, [obras].[id_obra])
		ORDER BY
			  [vwListaProyectosUnificados].[NombreProyecto]
			, [Almacen]
	END
END
GO

--EXECUTE [ControlMaquinaria].[uspListaMaquinas] 'ubueno'