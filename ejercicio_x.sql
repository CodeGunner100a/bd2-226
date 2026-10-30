CREATE FUNCTION dbo.fn_Stock
(
    @calm INTEGER,
    @cprd INTEGER
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Stock DECIMAL(12,2);

    SELECT @Stock = ISNULL(SUM(cant), 0)
    FROM dbo.sumi
    WHERE calm = @calm
      AND cprd = @cprd;

    RETURN @Stock;
END;
GO
