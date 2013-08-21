USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[Maquinas]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[Maquinas];
END
GO

CREATE TABLE [ControlMaquinaria].[Maquinas]
(
	  [IDMaquina]		  INT NOT NULL IDENTITY(1, 1)
	, [IDProyecto]		  INT NOT NULL
	, [IDAlmacenSAO]	  INT NOT NULL
	, [IDActivoSCAF]	  INT NULL
	, [IDClaseMotor]	  TINYINT NULL
	, [NumeroEconomico]	  VARCHAR(50) NULL
	, [NumeroSerieMotor]  VARCHAR(50) NULL
	, [Marca]			  VARCHAR(50) NULL
	, [Modelo]			  VARCHAR(50) NULL
	, [Capacidad]		  VARCHAR(20) NULL
	, [CapacidadHP]		  VARCHAR(20) NULL
	, [IDCategoria]		  INT NULL
	, [IDPropiedad]		  INT NULL
	, [HorasParaMantenimiento] SMALLINT NULL
	, [FechaEntrada]	  DATE NULL
	, [FechaSalida]		  DATE NULL
	, [FechaHoraRegistro] SMALLDATETIME NOT NULL
	, [idUsuarioRegistro] INT NULL
);
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[Maquinas]
ADD CONSTRAINT [PK_Maquinas]
PRIMARY KEY CLUSTERED ([IDProyecto], [IDAlmacenSAO])
WITH FILLFACTOR = 85
GO

-- UNIQUE COSNTRAINT
ALTER TABLE [ControlMaquinaria].[Maquinas]
ADD CONSTRAINT [UQ_Maquinas_IDMaquina]
UNIQUE ([IDMaquina]);
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro]
ALTER TABLE [ControlMaquinaria].[Maquinas]
ADD CONSTRAINT [DF_Maquinas_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO

--SELECT * INTO [ControlMaquinaria].MaquinasBak FROM [ControlMaquinaria].[Maquinas]

--GO

--SELECT * FROM [ControlMaquinaria].[Maquinas]
--SELECT * FROM [ControlMaquinaria].[MaquinasBak]
--WHERE [NumeroSerieMotor] IS NOT NULL


--SET IDENTITY_INSERT [ControlMaquinaria].[Maquinas] ON;

--INSERT INTO [ControlMaquinaria].[Maquinas]
--        (  [idMaquina]
--        , [idProyecto]
--        , [idAlmacenSAO]
--        , [idActivoSCAF]
--        , [idClaseMotor]
--        , [NumeroEconomico]
--        , [NumeroSerieMotor]
--        , [Marca]
--        , [Modelo]
--        , [Capacidad]
--        , [CapacidadHP]
--        , [idCategoria]
--        , [idPropiedad]
--        , [HorasParaMantenimiento]
--        , [FechaEntrada]
--        , [FechaSalida]
--        , [FechaHoraRegistro]
--        , [idUsuarioRegistro]
--        )
--SELECT
--  [idMaquina]
--, [idProyecto]
--, [idAlmacenSAO]
--, [idActivoSCAF]
--, [idClaseMotor]
--, [NumeroSerieMotor]
--, [NumeroSerieMotor]
--, [Marca]
--, [Modelo]
--, [Capacidad]
--, [CapacidadHP]
--, NULL
--, NULL
--, [HorasParaMantenimiento]
--, [FechaEntrada]
--, [FechaSalida]
--, [FechaHoraRegistro]
--, NULL
--FROM [ControlMaquinaria].[MaquinasBak]

--SET IDENTITY_INSERT [ControlMaquinaria].[Maquinas] OFF


SELECT * FROM [ControlMaquinaria].[Maquinas]