USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[ReporteHorasDetalle]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[ReporteHorasDetalle];
END
GO

CREATE TABLE [ControlMaquinaria].[ReporteHorasDetalle]
(
	  [IDReporteHora]		 INT NOT NULL IDENTITY(1, 1)
	, [IDReporteTurno]		 INT NOT NULL
	, [IDTipoHora]			 INT NOT NULL
	, [IDActividad]			 INT NULL
	, [RutaActividad]		 VARCHAR(MAX) NULL
	, [UnidadActividad]		 VARCHAR(16) NULL
	, [CantidadHoras]		 DECIMAL(4, 2) NOT NULL
	, [Observaciones]		 VARCHAR(MAX) NULL
	, [Aprobada]			 BIT NOT NULL
	, [EnviadaSAO]			 BIT NOT NULL
	, [IDItemSAO]			 INT NULL
	, [CantidadHorasEnviada] DECIMAL(4, 2) NOT NULL
	, [PrecioUnitario]		 SMALLMONEY NULL
	, [NumeroSerieMaquina]	 VARCHAR(64) NULL
	, [FechaHoraEnvio]		 SMALLDATETIME NULL
	, [FechaHoraRegistro]	 SMALLDATETIME NOT NULL
	, [IDUsuarioRegistro]	 INT NOT NULL
);

GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [PK_ReporteHorasDetalle]
PRIMARY KEY CLUSTERED ([IDReporteHora])
WITH FILLFACTOR = 80;
GO

-- FOREIGN KEY CONSTRAINT WITH [ReporteHorasTurnos] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [FK_ReporteHorasDetalle_ReporteHorasTurnos]
FOREIGN KEY ([IDReporteTurno])
REFERENCES [ControlMaquinaria].[ReporteHorasTurnos]([IDReporteTurno])
	ON UPDATE NO ACTION
	ON DELETE CASCADE;
GO

-- FOREIGN KEY CONSTRAINT WITH [Seguridad].[Usuarios] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [FK_ReporteHorasDetalle_SeguridadUsuarios]
FOREIGN KEY ([IDUsuarioRegistro])
REFERENCES [Seguridad].[Usuarios] ([IDUsuario])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

-- FOREIGN KEY CONSTRAINT WITH [TiposHora] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [FK_ReporteHorasDetalle_TiposHora]
FOREIGN KEY ([IDTipoHora])
REFERENCES [ControlMaquinaria].[TiposHora] ([IDTipoHora])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [DF_ReporteHorasDetalle_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO

-- DEFAULT CONSTRAINT FOR [EnviadaSAO] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [DF_ReporteHoras_EnviadaSAO]
DEFAULT(0) FOR [EnviadaSAO];
GO

-- DEFAULT CONSTRAINT FOR [Aprobada] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [DF_ReporteHoras_Aprobada]
DEFAULT(0) FOR [Aprobada];
GO

-- DEFAULT CONSTRAINT FOR [CantidadHorasEnviada]
ALTER TABLE [ControlMaquinaria].[ReporteHorasDetalle]
ADD CONSTRAINT [DF_ReporteHorasDetalle_CantidadHorasEnviada]
DEFAULT(0) FOR [CantidadHorasEnviada];
GO

SELECT * FROM [ControlMaquinaria].[ReporteHorasDetalle]