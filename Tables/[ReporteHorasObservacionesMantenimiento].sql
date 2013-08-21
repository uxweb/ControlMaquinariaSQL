USE [ModulosSAO];
GO

IF ( OBJECT_ID(N'[ControlMaquinaria].[ReporteHorasObservacionesMantenimiento]') IS NOT NULL )
BEGIN
	DROP TABLE [ControlMaquinaria].[ReporteHorasObservacionesMantenimiento];
END
GO

CREATE TABLE [ControlMaquinaria].[ReporteHorasObservacionesMantenimiento]
(
	[idReporte] INT NOT NULL,
	[Observaciones] VARCHAR(MAX) NOT NULL,
	[idUsuario] INT NOT NULL,
	[FechaHoraRegistro] SMALLDATETIME NOT NULL
);
GO

-- FOREIGN KEY CONSTRAINT WITH [ControlMaquinaria].[ReporteHorasObservacionesMantenimiento]
ALTER TABLE [ControlMaquinaria].[ReporteHorasObservacionesMantenimiento]
ADD CONSTRAINT [FK_ReporteHoras_ReporteHorasObservacionesMantenimiento]
FOREIGN KEY ([idReporte])
REFERENCES [ControlMaquinaria].[ReporteHoras] ([idReporte])
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

-- DEFAULT CONSTRAINT FOR [FechaHoraRegistro] FIELD
ALTER TABLE [ControlMaquinaria].[ReporteHorasObservacionesMantenimiento]
ADD CONSTRAINT [DF_ReporteHorasObservacionesMantenimiento_FechaHoraRegistro]
DEFAULT (GETDATE()) FOR [FechaHoraRegistro];
GO