SELECT * FROM [SAO1814Reportes].[dbo].[transacciones]
INNER JOIN [SAO1814Reportes].[dbo].[items]
  ON [SAO1814Reportes].[dbo].[transacciones].[id_transaccion] = [SAO1814Reportes].[dbo].[items].[id_transaccion]
WHERE [id_obra] = 10
AND [tipo_transaccion] = 36
AND [numero_folio] = 23481

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

/*============================================================================*/
/* Procedimiento: sp_uso_maquinaria                                           */
/* Proposito    : generar el uso de maquinaria                                */
/* Retorna      : 0 (bien), 1 (error)                                         */
/*============================================================================*/
CREATE PROCEDURE sp_uso_maquinaria
(
	@id_item     int,
	@id_lote     int
)
WITH ENCRYPTION AS

-- opciones
SET NOCOUNT ON

-- variables locales
DECLARE @id_movimiento  int
DECLARE @id_almacen     int
DECLARE	@id_concepto    int
DECLARE	@id_material    int
DECLARE	@id_insumo      int
DECLARE	@id_obra        int
DECLARE	@fecha          datetime
DECLARE	@cantidad       float
DECLARE	@consumo        real
DECLARE	@unidad         varchar(16)

-- generacion del movimiento
INSERT INTO movimientos
(
	id_concepto,
	id_item,
	id_material,
	lote_antecedente,
	cantidad,
	monto_total
)
SELECT
	id_concepto,
	id_item,
	id_material,
	@id_lote,
	cantidad,
	importe
  FROM items
 WHERE id_item = @id_item

-- id del movimiento
SET @id_movimiento = @@IDENTITY

-- distribuir el monto pagado
EXEC sp_distribuir_pagado @id_lote, 0

IF EXISTS (SELECT * FROM materiales JOIN items ON items.id_material = materiales.id_material
            WHERE id_item = @id_item AND tipo_material = 8 AND marca != 0)
BEGIN
	SELECT @id_almacen = id_almacen
	  FROM transacciones
	 WHERE id_transaccion = (SELECT id_transaccion FROM items WHERE id_item = @id_item)

	-- EXEC sp_consumos_maquina @id_movimiento, @id_almacen
	-- leemos la informacion relevante del movimiento
	SELECT @id_concepto = id_concepto,
	       @id_material = id_material,
	       @cantidad    = cantidad
	  FROM movimientos
	 WHERE id_movimiento = @id_movimiento

	SELECT @id_obra = id_obra, @fecha = cumplimiento
	  FROM transacciones JOIN items ON transacciones.id_transaccion = items.id_transaccion
	 WHERE id_item = @id_item

	-- insertamos los consumos
	DECLARE qryConsumosMaquina CURSOR FOR
	 SELECT id_insumo, consumo, unidad
	   FROM materiales
	  WHERE tipo_material = 8 AND marca = 0
		AND nivel like (SELECT nivel+'%' FROM materiales WHERE id_material = @id_material)

	OPEN  qryConsumosMaquina
	FETCH qryConsumosMaquina INTO @id_insumo, @consumo, @unidad

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			-- se genera el movimiento al concepto
			-- por el consumo inferido del uso
			INSERT INTO movimientos
			(
				id_concepto,
				id_item,
				id_material,
				cantidad,
				monto_total,
				monto_pagado
			)
			VALUES
			(
				@id_concepto,
				@id_item,
				@id_insumo,
				@cantidad*@consumo,
				0,
				0
			)

			-- se genera el movimiento al inventario
			-- en negativo, para la salida del insumo
			INSERT INTO inventarios
			(
				id_almacen,
				id_material,
				id_item,
				cantidad,
				saldo,
				monto_total,
				monto_pagado
			)
			VALUES
			(
				@id_almacen,
				@id_insumo,
				@id_item,
				@cantidad*@consumo*(-1),
				@cantidad*@consumo*(-1),
				0,
				0
			)

			-- ajustamos los consumos
			EXEC sp_entradas_salidas @id_almacen, @id_insumo

			FETCH qryConsumosMaquina INTO @id_insumo, @consumo, @unidad
		END

	CLOSE      qryConsumosMaquina
	DEALLOCATE qryCOnsumosMaquina
END

-- todo ok
RETURN (0)
GO
