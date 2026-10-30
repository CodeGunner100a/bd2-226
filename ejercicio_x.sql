-- Esta solo es una prueba x
USE Demo;
GO

CREATE TRIGGER tr_ImporteCorrecto
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
           OR ABS(impt - ROUND(ABS(cant) * prec, 2)) > 0.01
    )
    BEGIN
        THROW 50001, 'Importe o datos incorrectos', 1;
    END;
END;
GO
