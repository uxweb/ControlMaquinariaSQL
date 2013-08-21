/*
 * LERMA 3 MARIAS
*/
-- CONSUELO ALVAREZ PEREZ 30.06.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Consuelo Alvarez Perez', -- varchar(100)
    @Usuario = 'caperez', -- varchar(20)
    @Password = '#cap85%' -- varchar(20)

-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( 11, -- idUsuario - int
          4  -- idAplicacion - int
         )
-- ACCESO A LA OBRA DE LERMA 3 MARIAS
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( 10
        , -- idUsuario - int
          2
        , -- idAplicacion - int
          5  -- idProyecto - int
        );

GO


/*
 * PRESA EL ZAPOTILLO
*/
-- Argenis Hernandez Barroso 01.07.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Argenis Hernandez Barroso', -- varchar(100)
    @Usuario = 'ahbarroso', -- varchar(20)
    @Password = '#ahb85%' -- varchar(20)


-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( 11, -- idUsuario - int
          4  -- idAplicacion - int
         )

-- ACCESO AL PROYECTO ZAPOTILLO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( 11
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          2  -- idProyecto - int
        );
GO
-- Horacio Ponce de León Gutierrez 20.07.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Horacio Ponce de León Gutierrez', -- varchar(100)
    @Usuario = 'hpleon', -- varchar(20)
    @Password = '#hplg85%' -- varchar(20)
DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4  -- idAplicacion - int
         )

-- ACCESO AL PROYECTO ZAPOTILLO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          2  -- idProyecto - int
        );
GO
-- Briceyra Monserrat Romero Salomón 20.07.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Briceyra Monserrat Romero Salomón', -- varchar(100)
    @Usuario = 'bmromero', -- varchar(20)
    @Password = '#bmrs85%' -- varchar(20)
DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4  -- idAplicacion - int
         )

-- ACCESO AL PROYECTO ZAPOTILLO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          2  -- idProyecto - int
        );
        
GO

/*
 * ATALCOMULCO 11
*/
-- Brandok Matiaz Cruz 01.07.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Brandok Matiaz Cruz', -- varchar(100)
    @Usuario = 'bmcruz', -- varchar(20)
    @Password = '#bmc85%' -- varchar(20)


-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( 12, -- idUsuario - int
          4  -- idAplicacion - int
         )

-- ACCESO AL PROYECTO ZAPOTILLO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( 12
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          14  -- idProyecto - int
        );
        

GO

/*
 * CARRETERA DURANGO MAZATLAN
*/
-- Viridiana Camacho Alcaraz 01.07.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Viridiana Camacho Alcaraz', -- varchar(100)
    @Usuario = 'vcalcaraz', -- varchar(20)
    @Password = '#vca85%' -- varchar(20)


-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( 13, -- idUsuario - int
          4  -- idAplicacion - int
         )

-- ACCESO AL PROYECTO ZAPOTILLO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( 13
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          4  -- idProyecto - int
        );

/*
 EMISOR CENTRAL 5
*/
-- Edgar Villagran Rodriguez 15.08.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Edgar Villagran Rodriguez', -- varchar(100)
    @Usuario = 'evrod', -- varchar(20)
    @Password = '#evr85%' -- varchar(20)
DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4 -- idAplicacion - int
         )

-- ACCESO AL PROYECTO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          13  -- idProyecto - int
        );

GO

-- Juan Abraham Mancilla Cantero 15.08.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Juan Abraham Mancilla Cantero', -- varchar(100)
    @Usuario = 'jamancilla', -- varchar(20)
    @Password = '#jamc85%' -- varchar(20)

DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4 -- idAplicacion - int
         )

-- ACCESO AL PROYECTO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          16  -- idProyecto - int
        ),
        ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          17  -- idProyecto - int
        );

GO

-- Edgar Damian Luna Sanchez 15.08.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Edgar Damian Luna Sanchez', -- varchar(100)
    @Usuario = 'edluna', -- varchar(20)
    @Password = '#edls85%' -- varchar(20)

DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4 -- idAplicacion - int
         )

-- ACCESO AL PROYECTO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          17  -- idProyecto - int
        )

GO

-- TMC

-- Eliacin Fabian Sanchez Pacheco 30.09.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Eliacin Fabian Sanchez Pacheco', -- varchar(100)
    @Usuario = 'ESanchezP', -- varchar(20)
    @Password = '#efsp85%' -- varchar(20)

DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4 -- idAplicacion - int
         )

-- ACCESO AL PROYECTO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          19  -- idProyecto - int
        )

GO

-- Gustavo López Morales 05.10.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Gustavo López Morales', -- varchar(100)
    @Usuario = 'glopez', -- varchar(20)
    @Password = '#glm85%' -- varchar(20)

DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4 -- idAplicacion - int
         )

-- ACCESO AL PROYECTO
INSERT INTO [Seguridad].[UsuariosProyectos](
	[idUsuario], [idAplicacion], [idProyecto]
)
VALUES  ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          21  -- idProyecto - int
        ),
        ( @idUsuario
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          22  -- idProyecto - int
        )
        
        
go

-- Carlos Gonzalez 06.10.2011
EXECUTE [Seguridad].[uspRegistraUsuario]
	@Nombre = 'Carlos Gonzalez', -- varchar(100)
    @Usuario = 'cgonzalez', -- varchar(20)
    @Password = '#cg85%' -- varchar(20)

DECLARE
  @idUsuario INT = @@IDENTITY;
  
-- ACCESO A CONTROL DE MAQUINARIA
INSERT INTO [Seguridad].[UsuariosAplicaciones]
        ( [idUsuario], [idAplicacion] )
VALUES  ( @idUsuario, -- idUsuario - int
          4 -- idAplicacion - int
        )

-- ACCESO AL PROYECTO
INSERT INTO [Seguridad].[UsuariosProyectos]
        ( [idUsuario]
        , [idAplicacion]
        , [idProyecto]
        )
SELECT 24
      , [idAplicacion]
      , [idProyecto] FROM [Seguridad].[UsuariosProyectos]
WHERE [idUsuario] = 2
AND [idAplicacion] = 4

SELECT * FROM [Seguridad].[Usuarios]
SELECT * FROM [Proyectos].[Proyectos]

INSERT INTO [Seguridad].[UsuariosProyectos]
        ( [idUsuario]
        , [idAplicacion]
        , [idProyecto]
        )
VALUES  ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          17  -- idProyecto - int
        )
        

SELECT * FROM [Proyectos].[Proyectos]
SELECT * FROM [Proyectos].[vwListaProyectosUnificados]
WHERE [idProyecto] = 17
AND [idTipoSistemaOrigen] = 3

SELECT * FROM [GH10\NOMINAS].[nomGenerales].[dbo].[NOM10000]
WHERE [IDEmpresa] = 50


SELECT * FROM [GH10\NOMINAS].nmLPC047BC.[dbo].[nom10001]
ORDER BY [apellidopaterno] DESC

SELECT * FROM [Seguridad].[Usuarios]



EXEC [Seguridad].[uspProyectosUsuario]
	 @Usuario = 'evrod', -- varchar(20)
    @idAplicacion = 4 -- int

INSERT INTO [Seguridad].[UsuariosProyectos]
        ( [idUsuario]
        , [idAplicacion]
        , [idProyecto]
        )
VALUES  ( 17
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          20  -- idProyecto - int
        ),
        ( 17
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          23  -- idProyecto - int
        ),
        ( 17
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          25  -- idProyecto - int
        )



INSERT INTO [Seguridad].[UsuariosProyectos]
        ( [idUsuario]
        , [idAplicacion]
        , [idProyecto]
        )
VALUES  ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          19 -- idProyecto - int
        ),
        ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          20 -- idProyecto - int
        ),
        ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          21 -- idProyecto - int
        ),
        ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          22 -- idProyecto - int
        ),
        ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          23 -- idProyecto - int
        ),
        ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          25 -- idProyecto - int
        ),
        ( 2
        , -- idUsuario - int
          4
        , -- idAplicacion - int
          26 -- idProyecto - int
        )
        
        
        
        


