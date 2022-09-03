--------------------------------------
SELECT
    LEFT(cod, 1) AS primeraletra,
    count( DISTINCT CODART)
FROM
    atenea.dbo.esclin e
GROUP BY
    LEFT(cod, 1)
ORDER BY 
    2 desc;

--------------------------------------

SELECT
    TOP(20) CODART ,
    COD,
    CANLIN
FROM
    esclin e
WHERE
    LEFT(CODART,
    1) = 'Y';

--------------------------------------

WITH
cebador( hijo, padre ) AS 
    (
    SELECT
        DISTINCT(e.CODART) AS hijo,
        '0' AS padre 
    FROM
        esclin e
    UNION 
    SELECT 
        DISTINCT(e.COD) AS hijo,
        '0' AS padre
    FROM 
        esclin e 
        ), 
bomex(hijo, padre, cantidad, cantidadtotal, nivel) AS
    (
        SELECT 
            CAST('Y0001' AS CHAR(20) ) COLLATE Modern_Spanish_CS_AS,
            CAST('0' AS CHAR(20) ) COLLATE Modern_Spanish_CS_AS, 
            CAST(1.0 AS NUMERIC(10,2)),
            CAST(1.0 AS NUMERIC(10,2)),
            CAST(0 AS INT)
    UNION ALL
        SELECT
            e.COD,
            e.CODART,
            CAST( e.CANLIN AS NUMERIC(10, 2) ),
            CAST( b.cantidadtotal * e.CANLIN AS NUMERIC(10, 2) ),
            CAST(b.nivel + 1 AS INT)
        FROM
            bomex b
        JOIN esclin e ON b.hijo = e.CODART 
        )
SELECT * FROM bomex b ;
SELECT * FROM cebador c ;