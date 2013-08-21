USE [ModulosSAO];
GO

IF OBJECT_ID( N'[ControlMaquinaria].[uspRegistraHorasMensuales]', 'P' ) IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRegistraHorasMensuales];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRegistraHorasMensuales]
(
	  @IDMaquina INT
	, @Vigencia DATE
	, @HorasContrato SMALLINT
	, @HorasOperacion SMALLINT
	, @HorasPrograma SMALLINT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 22-06-2011
 * Descripcion:
 * - CREA UN REGISTRO DE HORAS MENSUALES

 * Changelog:
 * - dd-mm-aaaa [nombre]:

 * - 07-03-2013 [UZIEL]: SE AGREGO UN REGISTRO DE EQUIVALENCIA DEFAULT PARA CUANDO NO EXISTA
						 LA EQUIVALENCIA PARA LAS HORAS DE OPERACION QUE SE PRETENDEN REGISTRAR
						 
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		  @IDProyecto INT = NULL
		, @IDEquivalenciaHoras INT = NULL;
	  
	-- OBTIENE EL IDENTIFICADOR DEL PROYECTO DONDE ESTA ACTUALMENTE LA MAQUINA
	SELECT
		@IDProyecto = [IDProyecto]
	FROM
		[ControlMaquinaria].[Maquinas]
	WHERE
		[IDMaquina] = @IDMaquina;
	
	/*
	 * VERIFICA SI YA EXISTE UN REGISTRO
	 * DE HORAS MENSUALES CON VIGENCIA MAYOR O IGUAL
	 * NO SE PERMITIRA EL REGISTRO SI OCURRE ESTE CASO
	*/
	IF EXISTS
	(
		SELECT 1
		FROM [ControlMaquinaria].[HorasMensuales]
		WHERE
			[IDMaquina] = @IDMaquina
				AND
			[IDProyecto] = @IDProyecto
				AND
			[Vigencia] >= @Vigencia
	)
	BEGIN
		RAISERROR('Ya existe un registro de horas mensuales con vigencia mayor o igual.', 16, 1);
		RETURN(1);
	END
	
	/*
	 * OBTIENE LA EQUIVALENCIA VIGENTE DE LAS HORAS DE OPERACION
	 * PARA LAS HORAS MENSUALES A REGISTRAR
	*/
	SELECT TOP 1
		@IDEquivalenciaHoras = [IDEquivalenciaHoras]
	FROM
		[ControlMaquinaria].[EquivalenciaHorasOperacion]
	WHERE
		[IDProyecto] = @IDProyecto
			AND
		[HorasOperacion] = @HorasOperacion
	ORDER BY
		[Vigencia] DESC;
	
	BEGIN TRY
		
		BEGIN TRANSACTION

			IF ( @IDEquivalenciaHoras IS NULL )
			BEGIN
				EXECUTE [ControlMaquinaria].[uspRegistraEquivalenciaHoras] 
					@IDProyecto = @IDProyecto
				  , -- int
					@HorasOperacion = @HorasOperacion
				  , -- smallint
					@IDEquivalenciaHoras = @IDEquivalenciaHoras OUTPUT;
			END
	
			/*
			 * CREA EL REGISTRO DE LAS HORAS MENSUALES
			*/
			INSERT INTO [ControlMaquinaria].[HorasMensuales]
			(
				  [IDEquivalenciaHoras]
				, [IDMaquina]
				, [IDProyecto]
				, [Vigencia]
				, [HorasContrato]
				, [HorasOperacion]
				, [HorasPrograma]
			)
			VALUES
			(
				    @IDEquivalenciaHoras
				,   @IDMaquina
				, -- IDMaquina - int
					@IDProyecto
				, -- IDProyecto - int
					@Vigencia
				, -- Vigencia - date
					@HorasContrato
				, -- HorasContrato - smallint
					@HorasOperacion
				, -- HorasOperacion - smallint
					@HorasPrograma
					-- HorasOperacion - smallint
			);

		COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH
		IF ( @@TRANCOUNT > 0 )
			ROLLBACK TRANSACTION;

		THROW;
    END CATCH;
END
GOO