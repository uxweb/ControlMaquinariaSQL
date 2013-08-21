USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[MaquinasPropiedad]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[MaquinasPropiedad];
END
GO

CREATE TABLE [ControlMaquinaria].[MaquinasPropiedad]
(
	  [IDPropiedad] INT NOT NULL IDENTITY(1, 1)
	, [Propiedad] VARCHAR(50) NOT NULL
	, [FechaHoraRegistro] SMALLDATETIME
);

GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[MaquinasPropiedad]
ADD CONSTRAINT [PK_MaquinasPropiedad]
PRIMARY KEY CLUSTERED ([IDPropiedad]);
GO

-- DEFAULT CONSTRAINT FOR FechaHoraRegistro FIELD
ALTER TABLE [ControlMaquinaria].[MaquinasPropiedad]
ADD CONSTRAINT [DF_MaquinasPropiedad_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];

GO

--INSERT INTO [ControlMaquinaria].[MaquinasPropiedad]
--        ( [Propiedad]
--        )
--VALUES  ('Propio'), ('Rentado')

--GO