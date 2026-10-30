--3

CREATE FUNCTION dbo.fn_lista
(
    @AlmacenOrigen INTEGER
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.cprd AS CodigoProducto,
        dbo.fn_Stock(@AlmacenOrigen, p.cprd) AS StockProducto,
        dbo.fn_PPP(@AlmacenOrigen, p.cprd) AS PrecioPromedioPonderado
    FROM dbo.prod p
    WHERE p.colo = 'ROJO'
      AND dbo.fn_Stock(@AlmacenOrigen, p.cprd) > 0
);
GO
