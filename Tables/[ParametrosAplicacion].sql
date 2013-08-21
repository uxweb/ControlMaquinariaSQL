USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[ParametrosAplicacion]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[ParametrosAplicacion];
END
GO

CREATE TABLE [ControlMaquinaria].[ParametrosAplicacion]
(
	[DiasToleranciaBaja] TINYINT NOT NULL
);
GO


--INSERT INTO [ControlMaquinaria].[ParametrosAplicacion]
--        ( [DiasToleranciaBaja] )
--VALUES  ( 10  -- DiasToleranciaBaja - tinyint
--          )