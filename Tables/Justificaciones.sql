USE [ModulosSAO]
GO

IF EXISTS(SELECT 1 FROM [sys].[objects] WHERE [type] = 'U' AND [name] = 'Justificaciones')
BEGIN
	DROP TABLE [Maquinaria].[Justificaciones];
END

CREATE TABLE [Maquinaria].[Justificaciones] (
	  [idJustificacion] INT NOT NULL IDENTITY
	, [Justificacion] VARCHAR(50) NOT NULL
);

GO

-- PRIMARY KEY CONSTRAINT
IF EXISTS(SELECT 1 FROM [sys].[objects] WHERE [type] = 'PK' AND [name] = 'PK_Justificaciones')
BEGIN
	ALTER TABLE [Maquinaria].[Justificaciones]
	DROP CONSTRAINT [PK_Justificaciones];
END

ALTER TABLE [Maquinaria].[Justificaciones]
ADD CONSTRAINT [PK_Justificaciones]
PRIMARY KEY CLUSTERED([idJustificacion] ASC)
WITH FILLFACTOR = 90;

GO

-- UNIQUE CONSTRAINT FOR FIELD [Justificacion]
IF EXISTS(SELECT 1 FROM [sys].[objects] WHERE [type] = 'UQ' AND [name] = 'UQ_Justificaciones_Justificacion')
BEGIN
	ALTER TABLE [Maquinaria].[Justificaciones]
	DROP CONSTRAINT [UQ_Justificaciones_Justificacion];
END

ALTER TABLE [Maquinaria].[Justificaciones]
ADD CONSTRAINT [UQ_Justificaciones_Justificacion]
UNIQUE([Justificacion]);


GO

INSERT INTO [Maquinaria].[Justificaciones](
      [Justificacion]
)
VALUES
('Apoyo a Comuneros'),
('Calentando'),
('Traslados'),
('Talacha'),
--('Mantenimiento Menor'),
--('Mantenimiento Mayor'),
('Arranque Pruebas De Mtto Preventivo'),
('Arranque Pruebas De Mtto Correctivo'),
('Pruebas De Mtto Preventivo'),
('Pruebas De Mtto Correctivo'),
('En Mtto Preventivo'),
('En Mtto Correctivo'),
('Cambio De Herramientas De Ataque'),
('En Espera Por Falta De Operador Externo'),
('En Espera Por Falta De Operador Interno')

GO

SELECT * FROM [Maquinaria].[Justificaciones]