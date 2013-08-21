USE [ModulosSAO];
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspGuardaInformacionMaquina]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspGuardaInformacionMaquina];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspGuardaInformacionMaquina]
(
	  @IDMaquina INT
	, @IDClaseMotor TINYINT
	, @NumeroSerieMotor VARCHAR(50)
	, @Marca VARCHAR(50)
	, @Modelo VARCHAR(50)
	, @Capacidad VARCHAR(20)
	, @CapacidadHP VARCHAR(20)
	, @HorasMantenimiento SMALLINT
	, @FechaEntrada DATE
	, @FechaSalida DATE
)
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 21-07-2011
 * Descripcion:
 * - Modifica los datos de la maquina.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	UPDATE [ControlMaquinaria].[Maquinas]
	SET
		  [IDClaseMotor] = @IDClaseMotor
		, [NumeroSerieMotor] = @NumeroSerieMotor
		, [Marca] = @Marca
		, [Modelo] = @Modelo
		, [Capacidad] = @Capacidad
		, [CapacidadHP] = @CapacidadHP
		, [HorasParaMantenimiento] = @HorasMantenimiento
		, [FechaEntrada] = @FechaEntrada
		, [FechaSalida] = @FechaSalida
	WHERE
		[IDMaquina] = @IDMaquina;
END
GO

--EXECUTE [ControlMaquinaria].[uspGuardaInformacionMaquina]
--	@IDMaquina = 335, -- int
--    @IDClaseMotor = 1, -- tinyint
--    @NumeroSerieMotor = NULL, -- varchar(50)
--    @Marca = NULL, -- varchar(50)
--    @Modelo = NULL, -- varchar(50)
--    @Capacidad = NULL, -- varchar(20)
--    @CapacidadHP = NULL, -- varchar(20)
--    @HorasMantenimiento = 250, -- smallint
--    @FechaEntrada = '2011-07-01', -- date
--    @FechaSalida = '2011-07-30' -- date

--SELECT * FROM [ControlMaquinaria].[Maquinas]
--WHERE [idMaquina] = 335