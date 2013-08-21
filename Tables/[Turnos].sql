USE [ModulosSAO]
GO

IF OBJECT_ID('[ControlMaquinaria].[Turnos]', 'U') IS NOT NULL
BEGIN
	DROP TABLE [ControlMaquinaria].[Turnos];
END
GO

CREATE TABLE [ControlMaquinaria].[Turnos]
(
	  [IDTurno] INT NOT NULL IDENTITY
	, [Turno] VARCHAR(50) NOT NULL
	, [HoraInicio] TIME(0) NOT NULL
	, [HoraTermino] TIME(0) NOT NULL
	, [HorasTurno] AS ABS( CASE
						     WHEN [HoraInicio] < [HoraTermino] THEN DATEDIFF(HOUR, [HoraInicio], [HoraTermino])
						     ELSE DATEDIFF(HOUR, DATEADD(HOUR, -CAST(DATEPART(HOUR, [HoraTermino]) AS INT), [HoraInicio]), [HoraTermino])
						   END
						 )
);
GO

-- PRIMARY KEY CONSTRAINT
ALTER TABLE [ControlMaquinaria].[Turnos]
ADD CONSTRAINT [PK_Turnos]
PRIMARY KEY CLUSTERED ([IDTurno] ASC)
WITH FILLFACTOR = 90;

GO

--INSERT INTO [ControlMaquinaria].[Turnos]
--        ( [Turno]
--        , [HoraInicio]
--        , [HoraTermino]
--        )
--VALUES  ( 'Primer Turno'
--        , -- Turno - varchar(50)
--          '07:00'
--        , -- HoraInicio - time
--          '18:00'
--        ),
--		( 'Segundo Turno'
--        , -- Turno - varchar(50)
--          '18:00'
--        , -- HoraInicio - time
--          '04:00'
--        )

--SELECT
--  DATEDIFF(HOUR, '14:00:00', '04:00:00')
--, DATEDIFF(HOUR, '04:00:00', '18:00:00') - 4
--, DATEDIFF(HOUR, '07:00:00', '18:00:00') - 7

--SELECT * FROM [ControlMaquinaria].[Turnos]

--SELECT
--  [idTurno]
--, [Turno]
--, [HoraInicio]
--, [HoraTermino]
--, [HorasTurno]
--, DATEDIFF(HOUR, [HoraInicio], [HoraTermino])
--, DATEDIFF(SECOND, [HoraTermino], [HoraInicio])
--,
--CASE
--  WHEN [HoraInicio] < [HoraTermino] THEN DATEDIFF(HOUR, [HoraInicio], [HoraTermino])
--  ELSE DATEDIFF(HOUR, DATEADD(HOUR, -CAST(DATEPART(HOUR, [HoraTermino]) AS INT), [HoraInicio]), [HoraTermino])
--END
----, -CAST(DATEPART(HOUR, [HoraTermino]) AS INT)
--FROM [ControlMaquinaria].[Turnos]



--GO

---- INITIAL DATA REGISTRATION

--INSERT INTO [Maquinaria].[Turnos](
--	  [Turno]
--	, [HorasTurno]
--	, [Unidad]
--)
--VALUES
--( 'Cuadro', 16, 'Hras'),
--( 'Turno 1/2', 12, 'Hras'),
--( 'Normal', 8, 'Hras'),
--( 'Medio', 6, 'Hras')

--GO

