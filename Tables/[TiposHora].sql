USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[TiposHora]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[TiposHora];
END
GO

CREATE TABLE [ControlMaquinaria].[TiposHora]
(
	  [IDTipoHora] INT NOT NULL IDENTITY(1, 1)
	, [TipoHora] VARCHAR(50) NOT NULL
	, [FechaHoraRegistro] SMALLDATETIME NOT NULL
);
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[TiposHora]
ADD CONSTRAINT [PK_TiposHora]
PRIMARY KEY CLUSTERED ([IDTipoHora])
WITH (FILLFACTOR = 90,PAD_INDEX = ON);
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro] FIELD
ALTER TABLE [ControlMaquinaria].[TiposHora]
ADD CONSTRAINT [DF_TiposHora_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO


SELECT * FROM [ControlMaquinaria].[TiposHora]