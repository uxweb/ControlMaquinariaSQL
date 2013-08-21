USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[EquivalenciaHorasOperacion]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[EquivalenciaHorasOperacion];
END
GO

CREATE TABLE [ControlMaquinaria].[EquivalenciaHorasOperacion]
(
	  [IDEquivalenciaHoras] INT NOT NULL IDENTITY(1, 1)
	, [IDProyecto] INT NOT NULL
	, [HorasOperacion] SMALLINT NOT NULL
	, [HorasLunesAViernes] DECIMAL(4, 2) NOT NULL
	, [HorasSabado] DECIMAL(4, 2) NOT NULL
	, [HorasDomingo] DECIMAL(4, 2) NOT NULL
	, [Vigencia] DATE NOT NULL
)
GO

-- PRIMARY KEY CONTRAINT
ALTER TABLE [ControlMaquinaria].[EquivalenciaHorasOperacion]
ADD CONSTRAINT [PK_EquivalenciaHorasOperacion]
PRIMARY KEY CLUSTERED ([IDProyecto], [HorasOperacion], [Vigencia])
WITH FILLFACTOR = 90;
GO

-- UNIQUE CONSTRAINT FOR [idEquivalenciaHoras] FIELD
ALTER TABLE [ControlMaquinaria].[EquivalenciaHorasOperacion]
ADD CONSTRAINT [UQ_EquivalenciaHorasOperacion_IDEquivalenciaHoras]
UNIQUE([IDEquivalenciaHoras]);
GO

-- FOREIGN KEY CONSTRAINT WITH [Proyectos].[Proyectos] TABLE
--ALTER TABLE [ControlMaquinaria].[EquivalenciaHorasOperacion]
--ADD CONSTRAINT [FK_EquivalenciaHorasOperacion_Proyectos]
--FOREIGN KEY ([IDProyecto])
--REFERENCES [Proyectos].[Proyectos] ([IDProyecto])
--	ON UPDATE NO ACTION
--	ON DELETE NO ACTION;
--GO

-- DEFAULT CONSTRAINT FOR [HorasDomingo] FIELD
ALTER TABLE [ControlMaquinaria].[EquivalenciaHorasOperacion]
ADD CONSTRAINT [DF_EquivalenciaHorasOperacion_HorasDomingo]
DEFAULT(0.0) FOR [HorasDomingo];
GO

SELECT * FROM [ControlMaquinaria].[EquivalenciaHorasOperacion]