-----------------------------------------------
-- Numero total de clientes en fact_diario_bi 
-----------------------------------------------
SELECT
    COUNT( DISTINCT ("CODCLIENTE") ) clientes,
    COUNT(*) filas
FROM
    fact_diario_bi fdb ;

-- Clientes distintos de la tabla cliente con registros en fact_diario_bi 
SELECT
    "CODCLIENTE" AS código,
    UPPER("CLIENTE") cliente
FROM
    dim_cliente dc
WHERE
    "CODCLIENTE" IN (
    SELECT
        DISTINCT ("CODCLIENTE") 
    FROM
        fact_diario_bi fdb ) 
    ORDER BY 1 ;

-- Numero de filas por cliente
SELECT
    fdb."CODCLIENTE" AS IdCliente,
    UPPER(dc."CLIENTE") AS Cliente,
    COUNT(*) AS numfilas, 
    round(date_part('day', MAX("FECHA")::timestamp - MIN("FECHA")::timestamp) / 365, 2) años
FROM
    fact_diario_bi fdb
JOIN dim_cliente dc ON
    fdb."CODCLIENTE" = dc."CODCLIENTE"
GROUP BY
    1,
    2
ORDER BY
    3 DESC ;

-- 
SELECT
    dc."CLIENTE",
    "ATRIBUTO",
    SUM("VALOR") as Valor
FROM
    fact_diario_bi fdbi
JOIN 
    dim_cliente dc 
    ON fdbi."CODCLIENTE" = dc."CODCLIENTE"
GROUP BY
    1,
    2
ORDER BY
    1,
    2;
-- Debe y haber sin más.
SELECT
    DISTINCT fdb."ATRIBUTO"
FROM
    fact_diario_bi fdb ;


SELECT *, ABS("DEBE" - "HABER") AS "CUADRE" FROM (SELECT
    *
FROM
    CROSSTAB(
        'SELECT
            UPPER(dc."CLIENTE"),
            "ATRIBUTO",
            sum("VALOR") as valor
        FROM
            fact_diario_bi fdbi
        JOIN 
            dim_cliente dc 
            ON fdbi."CODCLIENTE"= dc."CODCLIENTE"
        GROUP BY
            1,
            2
        ORDER BY
            1,
            2',
        'SELECT 
            DISTINCT "ATRIBUTO" 
        FROM 
            fact_diario_bi fdbi') 
AS valor( codcliente TEXT,
    "DEBE" NUMERIC,
    "HABER" NUMERIC ) 
    ) pivotable
    ORDER BY 4 DESC;
    
-- Vista de comprobación    
SELECT
    *
FROM
    verificacion;

SELECT
    *
FROM
    verificar;

-- Cuentas de resultados
SELECT
    dcp."CLIENTE",
    EXTRACT (YEAR FROM fdb."FECHA") AS año, 
    dcp."SUBEPIGRAFE" ,
    dcp."CODSUBCUENTA",
    CASE 
        WHEN LEFT("CODSUBCUENTA"::TEXT, 1) = '7' THEN sum(fdb."VALOR")
        WHEN LEFT("CODSUBCUENTA"::TEXT, 1) = '6' THEN -1 * sum(fdb."VALOR")
    END valor
FROM
    fact_diario_bi fdb
JOIN dim_cuenta_pyg dcp ON
    fdb."CODCLIENTE_CODSUBCUENTA" = dcp."CODCLIENTE_CODSUBCUENTA"
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    1,
    2,
    3,
    4; 

-- Balances
SELECT
    dc."CLIENTE",
    date_trunc('year', fdb."FECHA") "AÑO", 
    dcb."ESTADO_FINANCIERO",
    dcb."GRAN_MASA_PATRIMONIAL",
    SUM( fdb."VALOR" ) "IMPORTE"
FROM
    fact_diario_bi fdb
JOIN dim_cuenta_balance dcb ON
    fdb."CODCLIENTE_CODSUBCUENTA" = dcb."CODCLIENTE_CODSUBCUENTA"
JOIN dim_cliente dc ON 
    dcb."CODCLIENTE" = dc."CODCLIENTE"
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    1,
    2,
    3,
    4; 

-- Maximo y minimo de la fecha
SELECT
    MIN("FECHA"),
    MAX("FECHA")
FROM
    fact_diario_bi fdb;

-- Años y meses con numero de registros, permite ver los meses
-- cubiertos por la mayoria de los clientes.
SELECT
    date_trunc('month', "FECHA") "AÑOS",
    count(*) "LINEAS"
FROM
    fact_diario_bi fdbi
GROUP BY
    1
ORDER BY
    1 DESC;

-- Para ver las columnas
SELECT
    *
FROM
    fact_diario_bi fdb LIMIT 10 ;
    
-----------------------------
----Perdidas y ganancias-----
-----------------------------
SELECT
    DATE_TRUNC('year', "FECHA")  "AÑO",
    "CLIENTE",
    "EPIGRAFE",
    "SUBEPIGRAFE", 
    SUM(fdb."VALOR")  "TOTAL"
FROM
    dim_cuenta_balance dcb
JOIN fact_diario_bi fdb ON
    dcb."CODCLIENTE_CODSUBCUENTA" = fdb."CODCLIENTE_CODSUBCUENTA"
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    1,
    2,
    3,
    4;