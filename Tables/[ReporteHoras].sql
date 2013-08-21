USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[ReporteHoras]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[ReporteHoras];
END
GO

CREATE TABLE [ControlMaquinaria].[ReporteHoras]
(
	  [IDReporte]		  INT NOT NULL IDENTITY(1, 1)
	, [IDProyecto]		  INT NOT NULL
	, [IDMaquina]		  INT NOT NULL
	, [FechaReporte]	  DATE NOT NULL
	, [EnviadoSAO]		  BIT NOT NULL
	, [IDHoraMensual]	  INT NULL
	, [IDTransaccionSAO]  INT NULL
	, [NumeroFolioSAO]    INT NULL
	, [FechaHoraEnvio]    SMALLDATETIME NULL
	, [IDUsuarioEnvio]    INT NULL
	, [FechaHoraRegistro] SMALLDATETIME NOT NULL
);
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [PK_ReporteHoras]
PRIMARY KEY CLUSTERED([IDProyecto], [IDMaquina], [FechaReporte])
WITH FILLFACTOR = 85;
GO

-- UNIQUE CONSTRAINT FOR [idReporte] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [UQ_ReporteHoras_IDReporte]
UNIQUE([IDReporte]);
GO

-- FOREIGN KEY CONSTRAINT WITH [ControlMaquinaria].[Maquinas] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [FK_ReporteHoras_Maquinas]
FOREIGN KEY ([IDMaquina])
REFERENCES [ControlMaquinaria].[Maquinas]([IDMaquina])
  ON UPDATE NO ACTION
  ON DELETE CASCADE;
GO

-- FOREIGN KEY CONSTRAINT WITH [Seguridad].[Usuarios] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [FK_ReporteHoras_SeguridadUsuarios]
FOREIGN KEY ([IDUsuarioEnvio])
REFERENCES [Seguridad].[Usuarios] ([IDUsuario])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

-- FOREIGN KEY CONSTRAINT WITH [ControlMaquinaria].[HorasMensuales] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [FK_ReporteHoras_HorasMensuales]
FOREIGN KEY ([IDHoraMensual])
REFERENCES [ControlMaquinaria].[HorasMensuales] ([IDHoraMensual])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [DF_ReporteHoras_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO

-- DEFAULT CONSTRAINT FOR [EnviadoSAO] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHoras]
ADD CONSTRAINT [DF_ReporteHoras_EnviadoSAO]
DEFAULT(0) FOR [EnviadoSAO];
GO