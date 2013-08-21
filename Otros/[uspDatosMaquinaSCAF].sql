USE [ModulosSAO]
GO

IF( OBJECT_ID('ControlMaquinaria.uspDatosMaquinaSCAF', 'P') IS NOT NULL )
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspDatosMaquinaSCAF];
END

GO

CREATE PROCEDURE [ControlMaquinaria].[uspDatosMaquinaSCAF](
	@idMaquina INT
)
WITH EXECUTE AS 'ubueno'
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 01-06-2011
 * Descripcion:
 * - DATOS DEL ACTIVO RELACIONADO CON LA MAQUINA EN EL SCAF.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
	  @idActivoSCAF INT = NULL;

	SELECT
	  @idActivoSCAF = [idActivoSCAF]
	FROM [ControlMaquinaria].[Maquinas]
	WHERE [idMaquina] = @idMaquina;
	
	IF( @idActivoSCAF IS NULL )
	BEGIN
		RAISERROR('Esta maquina no esta asociada con el SCAF.', 16, 1);
		RETURN(1);
	END
	
	--EXECUTE AS LOGIN = 'ubueno';
	
	BEGIN TRY		
		SELECT *
		FROM OPENQUERY([MYSQLHC], 'SELECT
									  idPartida
									, idTipoActivo
									, TipoActivo
									, Marca
									, Modelo
									, NumeroSerie
									, Codigo AS NumeroEconomico
									, Propiedad
									FROM vw_partidasRegistradas
									WHERE idTipoActivo IN(3, 6, 7)')
		WHERE idPartida = @idActivoSCAF;
	END TRY
	BEGIN CATCH
		DECLARE
		  @errorMessage NVARCHAR(MAX) = NULL
		, @errorSeverity INT = NULL
		, @errorState INT = NULL;
		
		SELECT
		  @errorMessage = ERROR_MESSAGE()
		, @errorSeverity = ERROR_SEVERITY()
		, @errorState = ERROR_STATE();
		
		RAISERROR(@errorMessage, @errorSeverity, @errorState);
	END CATCH
END

GO

GRANT IMPERSONATE ON LOGIN::[ubueno] TO [ModulosSao]
ALTER DATABASE [ModulosSAO] SET TRUSTWORTHY ON

EXECUTE AS USER = 'ModulosSAO'

EXECUTE [ControlMaquinaria].[uspDatosMaquinaSCAF] 2

REVERT