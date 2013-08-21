USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[ReporteHorasTurnos]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[ReporteHorasTurnos];
END
GO

CREATE TABLE [ControlMaquinaria].[ReporteHorasTurnos]
(
	  [IDReporteTurno]	  INT NOT NULL IDENTITY(1, 1)
	, [IDReporte]		  INT NOT NULL
	, [IDTurno]			  INT NOT NULL
	, [HorometroInicial]  DECIMAL(6, 1) NOT NULL
	, [HorometroFinal]    DECIMAL(6, 1) NOT NULL
	, [Observaciones]	  VARCHAR(MAX) NULL
	, [FechaHoraRegistro] SMALLDATETIME NOT NULL
);
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[ReporteHorasTurnos]
ADD CONSTRAINT [PK_ReporteHorasTurnos]
PRIMARY KEY CLUSTERED ([IDReporte], [IDTurno])
WITH FILLFACTOR = 85;
GO

-- UNIQUE CONSTRAINT FOR [idReporteTurno] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHorasTurnos]
ADD CONSTRAINT [UQ_ReporteHorasTurnos_IDReporteTurno]
UNIQUE([IDReporteTurno]);
GO

-- FOREIGN KEY CONSTRAINT WITH [ControlMaquinaria].[ReporteHoras] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHorasTurnos]
ADD CONSTRAINT [FK_ReporteHorasTurnos_ReporteHoras]
FOREIGN KEY ([IDReporte])
REFERENCES [ControlMaquinaria].[ReporteHoras] ([IDReporte])
	ON UPDATE NO ACTION
	ON DELETE CASCADE;
GO

-- FOREIGN KEY CONSTRAINT WITH [ControlMaquinaria].[Turnos] TABLE
ALTER TABLE [ControlMaquinaria].[ReporteHorasTurnos]
ADD CONSTRAINT [FK_ReporteHorasTurnos_Turnos]
FOREIGN KEY ([IDTurno])
REFERENCES [ControlMaquinaria].[Turnos] ([IDTurno])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHorasTurnos]
ADD CONSTRAINT [DF_ReporteHorasTurnos_FechaHoraRegistro]
DEFAULT(GETDATE()) FOR [FechaHoraRegistro];
GO

SELECT * FROM [ControlMaquinaria].[ReporteHorasTurnos]