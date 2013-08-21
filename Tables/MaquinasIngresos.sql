USE [ModulosSAO]
GO

CREATE TABLE [Maquinaria].[MaquinasIngresos](
	  [idMaquina] INT NOT NULL
	, [idProyecto] INT NOT NULL
	, [FechaIngreso] DATE NOT NULL
	, [HorometroIngreso] INT NOT NULL
	, [FechaInicioOperacion] DATE NULL
	, [idTipoContrato] INT NOT NULL
	, [Salida] BIT NOT NULL
	, [FechaSalidaProg] DATE NULL
	, [FechaTerminoOperacion] DATE NULL
	, [FechaSalida] DATE NULL
	, [HorometroSalida] INT NULL
)
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [Maquinaria].[MaquinasIngresos]
ADD CONSTRAINT [PK_MaquinasIngresos]
PRIMARY KEY CLUSTERED ([idMaquina], [idProyecto], [FechaIngreso])
WITH FILLFACTOR = 90

GO

