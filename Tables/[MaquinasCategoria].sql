USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[MaquinasCategoria]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[MaquinasCategoria];
END
GO

CREATE TABLE [ControlMaquinaria].[MaquinasCategoria]
(
	  [IDCategoria] INT NOT NULL IDENTITY(1, 1)
	, [Categoria] VARCHAR(50) NOT NULL
	, [FechaHoraRegistro] SMALLDATETIME NOT NULL
);
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[MaquinasCategoria]
ADD CONSTRAINT [PK_MaquinasCategoria]
PRIMARY KEY CLUSTERED ([IDCategoria]);
GO

-- DEFAULT CONSTRAINT FOR FechaHoraRegistro FIELD
ALTER TABLE [ControlMaquinaria].[MaquinasCategoria]
ADD CONSTRAINT [DF_MaquinasCategoria_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO

--INSERT INTO [ControlMaquinaria].[MaquinasCategoria]
--        ( [Categoria]
--        )
--VALUES  ('Mayor'), ('Menor'), ('Transporte')

--GO

SELECT * FROM [ControlMaquinaria].[MaquinasCategoria]