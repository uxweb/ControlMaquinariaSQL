USE [ModulosSAO]
GO

CREATE SCHEMA [ControlMaquinaria]
	AUTHORIZATION [dbo];
GO

GRANT SELECT ON SCHEMA::[ControlMaquinaria] TO [ControlMaquinariaRole];
GO
GRANT EXECUTE ON SCHEMA::[ControlMaquinaria] TO [ControlMaquinariaRole];
GO

GRANT SELECT ON SCHEMA::[ControlMaquinaria] TO [Reportes]
GO