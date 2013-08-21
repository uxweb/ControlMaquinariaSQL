USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[LogLanzamientos]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[LogLanzamientos];
END
GO

CREATE TABLE [ControlMaquinaria].[LogLanzamientos]
(
	  [IDLanzamiento] INT NOT NULL IDENTITY(1, 1)
	, [IDReporte] INT NOT NULL
	, [TiempoInicio] DATETIME NOT NULL
	, [TiempoTermino] DATETIME NOT NULL
	, [DuracionSegundos] AS (CAST(DATEDIFF(SECOND, [TiempoInicio], [TiempoTermino]) AS DECIMAL(5, 2)))
);

ALTER TABLE [ControlMaquinaria].[LogLanzamientos]
ADD CONSTRAINT [PK_LogLanzamientos]
PRIMARY KEY CLUSTERED ([IDLanzamiento] ASC, [IDReporte] ASC)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);
GO

--SELECT  [idLanzamiento]
--      , [idReporte]
--      , [TiempoInicio]
--      , [TiempoTermino]
--      , [DuracionSegundos] FROM [ControlMaquinaria].[LogLanzamientos]

--SELECT * FROM [ControlMaquinaria].[ReporteHoras]
--ORDER BY [FechaHoraRegistro] DESC


--SELECT * FROM [Seguridad].[Usuarios] WHERE [idUsuario] = 39


--SELECT CAST(GETDATE() AS SMALLDATETIME), GETDATE()