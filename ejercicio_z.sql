-- ejercicio 2

CREATE FUNCTION dbo.fn_PPP
(
    @calm INTEGER,
    @cprd INTEGER
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @PPP DECIMAL(12,2);

    SELECT @PPP = COALESCE(
        ROUND(
            SUM(cant * prec) / NULLIF(SUM(cant), 0),
            2
        ),
        0
    )
    FROM dbo.sumi
    WHERE calm = @calm
      AND cprd = @cprd
      AND cant > 0;

    RETURN @PPP;
END;
GO
