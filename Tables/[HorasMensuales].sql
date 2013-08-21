USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[HorasMensuales]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[HorasMensuales];
END
GO

CREATE TABLE [ControlMaquinaria].[HorasMensuales]
(
	  [IDHoraMensual]		INT IDENTITY(1,1) NOT NULL
	, [IDEquivalenciaHoras] INT NOT NULL
	, [IDProyecto]			INT NOT NULL
	, [IDMaquina]			INT NOT NULL
	, [Vigencia]			DATE NOT NULL
	, [HorasContrato]		SMALLINT NOT NULL
	, [HorasOperacion]		SMALLINT NOT NULL
	, [HorasPrograma]		SMALLINT NOT NULL
	, [FechaHoraRegistro]	SMALLDATETIME NOT NULL
);
GO

-- PRIMARY KEY CONTRAINT
ALTER TABLE [ControlMaquinaria].[HorasMensuales]
ADD CONSTRAINT [PK_HorasMensuales]
PRIMARY KEY CLUSTERED ([IDMaquina], [IDProyecto], [Vigencia])
WITH FILLFACTOR = 85;
GO

-- UNIQUE CONSTRAINT FOR [idHoraMensual] FIELD
ALTER TABLE [ControlMaquinaria].[HorasMensuales]
ADD CONSTRAINT [UQ_HorasMensuales_IDHoraMensual]
UNIQUE([IDHoraMensual])
GO

-- FOREIGN KEY CONSTRAINT WITH [Maquinas] TABLE
ALTER TABLE [ControlMaquinaria].[HorasMensuales]
ADD CONSTRAINT [FK_HorasMensuales_Maquinas]
FOREIGN KEY ([IDMaquina])
REFERENCES [ControlMaquinaria].[Maquinas] ([IDMaquina])
	ON UPDATE NO ACTION
	ON DELETE CASCADE;
GO

-- FOREIGN KEY CONSTRAINT WITH [EquivalenciaHorasOperacion]
ALTER TABLE [ControlMaquinaria].[HorasMensuales]
ADD CONSTRAINT [FK_HorasMensuales_EquivalenciaHorasOperacion]
FOREIGN KEY ([IDEquivalenciaHoras])
REFERENCES [ControlMaquinaria].[EquivalenciaHorasOperacion] ([IDEquivalenciaHoras])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro] FIELD
ALTER TABLE [ControlMaquinaria].[HorasMensuales]
ADD CONSTRAINT [DF_HorasMensuales_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO