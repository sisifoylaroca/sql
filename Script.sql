WITH valores AS 
            (
            SELECT
                FirstName AS nombre,
                count(*) AS valores
            FROM
                SalesLT.Customer c
            WHERE
                Title = 'Ms.'
            GROUP BY
                FirstName
                )
SELECT
    nombre,
    valores,
    sum(valores) over() AS total,
    valores / CAST(sum(valores) over() AS decimal(5,2))
FROM
    valores
ORDER BY
    valores DESC;