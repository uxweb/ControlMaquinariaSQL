USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspObtieneIDUsuario]', 'P' ) IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspObtieneIDUsuario];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspObtieneIDUsuario]
(
	  @Usuario VARCHAR(50)
	, @IDUsuario INT OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 08-07-2011
 * Descripcion:
 * - OBTIENE EL IDENTIFICADOR DEL USUARIO
     PARA UTILIZARLO EN ALGUN OTRO BLOQUE.
     ES SOLO UN TRADUCTOR DEL NOMBRE DE USUARIO
     A SU ID

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		@IDUsuario = [IDUsuario]
	FROM
		[Seguridad].[Usuarios]
	WHERE
		[Usuario] = @Usuario;
END
GO

--DECLARE
--  @IDUsuario INT = NULL;

--EXECUTE [ControlMaquinaria].[uspObtieneIdUsuario]
--	@Usuario = 'caperez', -- varchar(100)
--    @IDUsuario = @IDUsuario OUTPUT

--SELECT @IDUsuario