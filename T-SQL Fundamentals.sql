-- Capitulo 01
-- Ejercicio 01. Consulta que obtenga los pedidos de junio de 2015.
SELECT
    orderid,
    orderdate,
    custid,
    empid
FROM
    Sales.Orders o
WHERE
    YEAR(orderdate) = 2015
    AND MONTH(orderdate) = 6 ;

-- Ejercicio 02. Consulta que obtenga los pedidos realizados en los ultimos días del mes.

SELECT
    orderid,
    orderdate,
    custid,
    empid
FROM
    Sales.Orders o
WHERE
    orderdate = EOMONTH(orderdate, 0) ;

-- Ejercicio 03. Consulta sobre la tabla empleados cuyo nombre contenga una o mas e

SELECT
    empid,
    firstname,
    lastname
FROM 
    HR.Employees e
WHERE
    lastname like N'%e%e%' ;

-- Ejercicio 04. Lineas de OrderDetails con el valor total mayor de 10.000

SELECT
    orderid,
    sum(qty * unitprice) as totalvalue
FROM
    Sales.OrderDetails od
GROUP BY
    orderid
HAVING
    sum(qty * unitprice) > 10000
ORDER BY
    totalvalue;

-- Ejercicio 05. 

-- Ejercicio 06


-- Ejercicio 07. Consulta que devuelva los tres paises con la media mas alta de gastos de viajes.
DECLARE @año AS int=2016 
SELECT
    TOP 3 shipcountry,
    AVG(freight) AS avgfreight
FROM
    Sales.Orders o
WHERE 
    YEAR(orderdate) = @año
GROUP BY
    shipcountry
ORDER BY
    avgfreight DESC;

-- Ejercicio 08. 

-- Ejercicio 09

-- Ejercicio 10


-- Capitulo 02