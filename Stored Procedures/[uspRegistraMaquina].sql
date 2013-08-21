USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRegistraMaquina]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRegistraMaquina];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRegistraMaquina]
(
	  @IDAlmacenSAO INT
	, @Usuario VARCHAR(20)
	, @IDMaquina INT OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 23-05-2011
 * Descripcion:
 * - REGISTRA UN ALMACEN DE MAQUINARIA DEL SAO
	 COMO MAQUINA EN EL CONTROL DE MAQUINARIA.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		  @IDProyecto INT = NULL
		, @IDUsuario INT = NULL;

	/*
	 * SE AGREGO PARA OBTERNER EL IDENTIFICADOR DEL USUARIO
	 * QUE CREA EL REGISTRO DE HORA
	*/
	EXECUTE [ControlMaquinaria].[uspObtieneIdUsuario]
		@Usuario = @Usuario, -- varchar(100)
	    @IDUsuario = @IDUsuario OUTPUT -- int
	
	
	IF ( @IDUsuario IS NULL )
	BEGIN
		RAISERROR('No es posible identificar al usuario para crear el registro.', 16, 1);
		RETURN(1);
	END

	IF EXISTS
	(
		SELECT
			1
		FROM
			[ControlMaquinaria].[Maquinas]
		WHERE
			[IDAlmacenSAO] = @IDAlmacenSAO
	)
	BEGIN
		RAISERROR('Este almacen ya se encuentra registrado como una maquina.', 16, 1);
		RETURN(1);
	END
	
	SELECT
		@IDProyecto = [vwListaProyectosUnificados].[IDProyecto]
	FROM
		[SAO1814App].[dbo].[almacenes]
	INNER JOIN
		[Proyectos].[vwListaProyectosUnificados]
		ON
			[almacenes].[id_obra] = [vwListaProyectosUnificados].[IDProyectoUnificado]
			  AND
			[vwListaProyectosUnificados].[IDTipoSistemaOrigen] = 1
			  AND
			[vwListaProyectosUnificados].[IDTipoBaseDatos] = 1
	LEFT OUTER JOIN
		[ControlMaquinaria].[Maquinas]
		ON
			[almacenes].[id_almacen] = [Maquinas].[IDAlmacenSAO]
	WHERE
		[almacenes].[tipo_almacen] = 2
			AND
		[almacenes].[id_almacen] = @IDAlmacenSAO;

	
	INSERT INTO [ControlMaquinaria].[Maquinas]
	(
		  [IDProyecto]
		, [IDAlmacenSAO]
		, [IDUsuarioRegistro]
	)
	VALUES
	(
		@IDProyecto
	  , @IDAlmacenSAO
	  , @IDUsuario
	);
	
	SET @idMaquina = @@IDENTITY;
END
GO

--DECLARE
--  @IDMaquina INT = NULL;

--EXEC [ControlMaquinaria].[uspRegistraMaquina]
--	2168, -- int
--    @IDMaquina OUTPUT -- int