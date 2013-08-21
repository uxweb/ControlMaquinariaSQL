USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspPresupuestoSAO]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspPresupuestoSAO];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspPresupuestoSAO]
(
	@IDProyecto INT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 01-07-2011
 * Descripcion:
 * - OBTIENE EL PRESUPUESTO DE OBRA DEL PROYECTO
	 EN LOS ULTIMOS NIVELES SOLO SE MUESTRA MAQUINARIA
	 YA QUE ESTOS DESTINOS SON LOS QUE USA LA OBRA
	 PARA ENVIAR LAS PARTES DE USO.
 
 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		@IDProyectoUnificado INT = NULL;
	
	/*
	 * EL RENDIMIENTO DE LA CONSULTA A LA TABLA DE CONCEPTOS EN LA BASE
	 * DE DATOS DE PRODUCCION NO ES BUENO, POR LO TANTO SE REALIZA A LA
	 * BASE DEL SAO PARA REPORTES, YA QUE LA TABLA DE CONCEPTOS EN ESTA
	 * BASE ESTA OPTIMIZADA PARA ENTREGAR MAS RAPIDO LA INFORMACION
	 * Y CUALQUIER ACTUALIZACION DEL PRESUPUESTO QUE AFECTE LOS DESTINOS DONDE
	 * SE ENVIAN LAS PARTES DE USO, TENDRA QUE ESPERAR A QUE SE ACTUALICE LA BASE
	 * DE REPORTES.
	*/
	SELECT
		@IDProyectoUnificado = [IDProyectoUnificado]
	FROM
		[Proyectos].[vwListaProyectosUnificados]
	WHERE
		[IDTipoSistemaOrigen] = 1
			AND
		[IDTipoBaseDatos] = 1
			AND
		[IDProyecto] = @IDProyecto;
	
	SELECT
		  [conceptos].[id_concepto] AS [idConceptoBase]
		, [ConceptosPadre].[id_concepto] AS [idConceptoPadre]
		, [conceptos].[descripcion] AS [Descripcion]
		, [conceptos].[unidad] AS [Unidad]
		, [conceptos].[concepto_medible] AS [TipoConcepto]
		, [conceptos].[acumulador] AS [Acumulador]
		, ISNULL([CuentaSubActividades].[SubActividades], 0) AS [SubActividades]
		,
		CASE ISNULL([CuentaSubActividades].[SubActividades], 0)
			WHEN 0 THEN 0
			ELSE 1
		END AS [TieneSubNiveles]
	FROM
		[SAO1814App].[dbo].[conceptos]
	LEFT OUTER JOIN
		[SAO1814App].[dbo].[conceptos] AS [ConceptosPadre]
		ON
			[conceptos].[id_obra] = [ConceptosPadre].[id_obra]
				AND
			LEFT([conceptos].[nivel], LEN([conceptos].[nivel]) - 4) = [ConceptosPadre].[nivel]
	LEFT OUTER JOIN
	(
		SELECT
				[id_obra]
			,
			CASE LEN([nivel])
				WHEN 4 THEN NULL
				ELSE LEFT([nivel], LEN([nivel]) - 4)
			END AS [NivelPadre]
			, COUNT(*) AS [SubActividades]
		FROM
			[SAO1814App].[dbo].[conceptos]
		WHERE
			UPPER([conceptos].[descripcion]) NOT IN('MATERIALES', 'MATERIAL', 'MANO DE OBRA', 'HERRAMIENTA', 'HERRAMIENTA y EQUIPO', 'SUBCONTRATOS', 'SUBCONTRATO')
				AND
			[conceptos].[id_material] IS NULL
		GROUP BY [id_obra]
		,
		CASE LEN([nivel])
			WHEN 4 THEN NULL
			ELSE LEFT([nivel], LEN([nivel]) - 4)
		END
	) AS [CuentaSubActividades]
		ON
			[conceptos].[id_obra] = [CuentaSubActividades].[id_obra]
				AND
			[conceptos].[nivel] = [CuentaSubActividades].[NivelPadre]
	WHERE
		UPPER([conceptos].[descripcion]) NOT IN('MATERIALES', 'MATERIAL', 'MANO DE OBRA', 'HERRAMIENTA', 'HERRAMIENTA y EQUIPO', 'SUBCONTRATOS', 'SUBCONTRATO')
			AND
		[conceptos].[id_obra] = @IDProyectoUnificado
			AND
		[conceptos].[id_material] IS NULL
	ORDER BY
		[conceptos].[nivel]
END
GO

EXECUTE [ControlMaquinaria].[uspPresupuestoSAO]
	@IDProyecto = 42