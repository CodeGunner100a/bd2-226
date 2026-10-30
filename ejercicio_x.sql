--5

CREATE PROCEDURE dbo.pa_transferir
    @AlmacenOrigen INTEGER,
    @AlmacenDestino1 INTEGER,
    @AlmacenDestino2 INTEGER,
    @CantidadDestino1 DECIMAL(12,2),
    @CantidadDestino2 DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validar que los almacenes existan y sean diferentes
    IF @AlmacenOrigen IS NULL
       OR @AlmacenDestino1 IS NULL
       OR @AlmacenDestino2 IS NULL
       OR @AlmacenOrigen = @AlmacenDestino1
       OR @AlmacenOrigen = @AlmacenDestino2
       OR @AlmacenDestino1 = @AlmacenDestino2
       OR (SELECT COUNT(*)
           FROM dbo.alma
           WHERE calm IN (@AlmacenOrigen, @AlmacenDestino1, @AlmacenDestino2)) <> 3
    BEGIN
        THROW 51001, 'Los almacenes deben existir y ser diferentes.', 1;
    END;

    -- 2. Validar cantidades
    IF @CantidadDestino1 IS NULL
       OR @CantidadDestino2 IS NULL
       OR @CantidadDestino1 <= 0
       OR @CantidadDestino2 <= 0
    BEGIN
        THROW 51002, 'Las cantidades deben ser mayores que cero.', 1;
    END;

    -- 3. Validar proveedor de transferencia
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.prov
        WHERE cprv = 0
    )
    BEGIN
        THROW 51003, 'No existe el proveedor de transferencia 0.', 1;
    END;

    DECLARE
        @CodigoProducto INTEGER,
        @StockProducto DECIMAL(12,2),
        @PPP DECIMAL(12,2);

    -- 4. Declarar cursor
    DECLARE cur_lista CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            CodigoProducto,
            StockProducto,
            PrecioPromedioPonderado
        FROM dbo.fn_lista(@AlmacenOrigen);

    -- 5. Abrir cursor
    OPEN cur_lista;

    FETCH NEXT FROM cur_lista
    INTO @CodigoProducto, @StockProducto, @PPP;

    -- 6. Recorrer productos
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @StockProducto >= (@CantidadDestino1 + @CantidadDestino2)
        BEGIN
            -- 7. Registrar exactamente cuatro movimientos
            INSERT INTO dbo.sumi
                (cprv, calm, cprd, ftra, cant, prec, impt)
            VALUES
                (0, @AlmacenOrigen, @CodigoProducto,
                 CAST(GETDATE() AS DATE),
                 -@CantidadDestino1, @PPP,
                 ROUND(ABS(@CantidadDestino1) * @PPP, 2)),

                (0, @AlmacenDestino1, @CodigoProducto,
                 CAST(GETDATE() AS DATE),
                 @CantidadDestino1, @PPP,
                 ROUND(ABS(@CantidadDestino1) * @PPP, 2)),

                (0, @AlmacenOrigen, @CodigoProducto,
                 CAST(GETDATE() AS DATE),
                 -@CantidadDestino2, @PPP,
                 ROUND(ABS(@CantidadDestino2) * @PPP, 2)),

                (0, @AlmacenDestino2, @CodigoProducto,
                 CAST(GETDATE() AS DATE),
                 @CantidadDestino2, @PPP,
                 ROUND(ABS(@CantidadDestino2) * @PPP, 2));
        END;

        -- Siguiente producto
        FETCH NEXT FROM cur_lista
        INTO @CodigoProducto, @StockProducto, @PPP;
    END;

    -- 8. Cerrar y liberar cursor
    CLOSE cur_lista;
    DEALLOCATE cur_lista;
END;
GO
