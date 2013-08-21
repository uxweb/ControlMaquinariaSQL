USE [ModulosSAO]
GO

IF OBJECT_ID(N'[ControlMaquinaria].[uspActivosSCAF]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [ControlMaquinaria].[uspActivosSCAF];
END
GO

CREATE PROCEDURE [ControlMaquinaria].[uspActivosSCAF]
--WITH EXECUTE AS 'ubueno'
AS
/*
 * Autor: Uziel Bueno Ramirez
 * Creado: 05-01-2012
 * Descripcion:
 * - OBTIENE LA LISTA DE ACTIVOS DEL SCAF QUE SON:
	 - EQUIPO MENOR
	 - EQUIPO MAYOR
	 - EQUIPO DE TRANSPORTE.

 * Changelog:
 * - dd-mm-aaaa [nombre]:
*/
BEGIN
	SET NOCOUNT ON;
	
	--EXECUTE AS USER = 'ubueno'
	--EXECUTE AS LOGIN = 'ubueno';
	SELECT
		  idActivo
		, idClasificacion
		, Clasificacion
		, idMarca
		, Marca
		, idModelo
		, Modelo
		, NumeroEconomico
		, idPropiedad
	FROM
		OPENQUERY([MYSQLHC], 
		'SELECT
			Partidas.idPartida AS idActivo
		, Partidas.idGrupo AS idClasificacion
		, grupos_activo.descripcion AS Clasificacion
		, Partidas.idMarca
		, marcas.marca AS Marca
		, Partidas.idModelo
		, modelos.modelo AS Modelo
		, Partidas.codNuevo AS NumeroEconomico
		, Partidas.propiedad AS idPropiedad
		FROM SCI.Partidas
		INNER JOIN SCI.grupos_activo
			ON Partidas.idGrupo = grupos_activo.idGrupo
		INNER JOIN SCI.marcas_modelos
			ON Partidas.idMarca = marcas_modelos.idMarca
			AND Partidas.idModelo = marcas_modelos.idModelo
		INNER JOIN SCI.marcas
			ON marcas_modelos.idMarca = marcas.idMarca
		INNER JOIN SCI.modelos
			ON marcas_modelos.idModelo = modelos.idModelo
		WHERE Partidas.idGrupo IN(3, 6, 7)
		AND Partidas.idEstado > 1
		AND Partidas.codNuevo != ''SIN ECO''
		AND Partidas.idEstado IN(1, 2, 3, 10, 16, 17, 19)
		AND EsVisible = ''Y''
		ORDER BY Partidas.idGrupo ASC
				, Partidas.codNuevo ASC');
END
GO

--EXECUTE AS LOGIN = 'ModulosSAO'

--EXECUTE [ControlMaquinaria].[uspActivosSCAF]

--REVERT

-- PARA PODER ACCESAR AL SERVIDOR VINCULADO DE MySQL
-- SE DEBE AGREGAR UN LOGIN REMOTO AL SERVIDOR VINCULADO
--EXEC [sys].[sp_addlinkedsrvlogin]
--	@rmtsrvname = 'MYSQLHC', -- sysname
--    @useself = 'false', -- varchar(8)
--    @locallogin = NULL, -- sysname
--    @rmtuser = 'WebMistress', -- sysname
--    @rmtpassword = 'wms_010189#' -- sysname
