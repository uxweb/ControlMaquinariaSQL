USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspRegistraEquivalenciaHoras]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspRegistraEquivalenciaHoras];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspRegistraEquivalenciaHoras]
(
	  @IDProyecto INT
	, @HorasOperacion SMALLINT
	, @IDEquivalenciaHoras INT OUTPUT
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 07-03-2013

 * Descripcion:
 * - CREA UN REGISTRO DE EQUIVALENCIA DE HORAS.
	 
	 ESTE PROCEDIMIENTO REGISTRA INICIALMENTE UNA EQUIVALENCIA
	 DEFAULT PARA 200 HORAS DE OPERACIÓN.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE
      @HorasLV	   DECIMAL(4, 2) = 0
	, @HorasSabado DECIMAL(4, 2) = 0
	, @TranCount   TINYINT = 0;

	SET @TranCount = @@TRANCOUNT;

	BEGIN TRY
    
		IF ( @TranCount = 0 )
			BEGIN TRANSACTION
        ELSE
			SAVE TRANSACTION RegistroEquivalenciaHoras;

		IF ( @HorasOperacion = 200 )
		BEGIN
			SET @HorasLV = 8;
			SET @HorasSabado = 6;
		END
		ELSE
		BEGIN
    		RAISERROR('No existe una regla estandar para el numero de horas operación.', 16, 1);
		END
  
		INSERT INTO [ControlMaquinaria].[EquivalenciaHorasOperacion]
		(
			  [IDProyecto]
			, [HorasOperacion]
			, [HorasLunesAViernes]
			, [HorasSabado]
			, [HorasDomingo]
			, [Vigencia]
		)
		VALUES
		(
				@IDProyecto
			, -- idProyecto - int
				@HorasOperacion
			, -- HorasOperacion - smallint
				@HorasLV
			, -- HorasLunesAViernes - decimal
				@HorasSabado
			, -- HorasSabado - decimal
				0
			, -- HorasDomingo - decimal
				GETDATE()  -- Vigencia - date
		);

		SET @IDEquivalenciaHoras = @@IDENTITY;
		
		IF ( @TranCount = 0 )
			COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH
  
		IF ( @TranCount = 0 AND @@TRANCOUNT > 0 )
			ROLLBACK TRANSACTION;
		ELSE
			ROLLBACK TRANSACTION RegistroEquivalenciaHoras;

		THROW;
    END CATCH
END
GO