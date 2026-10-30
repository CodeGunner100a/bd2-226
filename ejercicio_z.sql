-- ejercicio 4

CREATE TRIGGER dbo.tr_ValidarSuministro
ON dbo.sumi
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE cant = 0
           OR prec <= 0
           OR impt <= 0
    )
    BEGIN
        THROW 51001, 'Cantidad, precio o importe invalido.', 1;
    END
END;
GO
