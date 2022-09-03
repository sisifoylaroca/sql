----------------------------------
-- Para ver los campos
----------------------------------
SELECT
    host,    
    time_bucket('1 day',
    time),
    count(*)
FROM
    cpu
GROUP BY
    1,
    2
ORDER BY
    1,
    2;
----------------------------------
-- Conteo de registros
----------------------------------
SELECT
    host,
    time_bucket ('15 minutes',
    time) AS intervalos,
    count(*)
FROM
    cpu
GROUP BY
    2,
    1
ORDER BY 
    1,
    2;

--------------------------------
-- Promedio de uso
--------------------------------
SELECT
    host,
    count(*) AS registros,
    to_char( AVG(usage_user), '0.999') AS promedio,
    max(usage_user) AS maximo,
    min(usage_user) AS minimo
FROM
    cpu
WHERE
    time > now() - INTERVAL '6 month'
GROUP BY
    host;

-----------------------------------
-- time_bucket
-----------------------------------
SELECT
    host,
    time_bucket('1 day',
    time) AS "bucket",
    avg(usage_user)
FROM
    cpu
WHERE
    time > now() - (6 * INTERVAL '1 month')
GROUP BY
    bucket,
    host
ORDER BY
    1,
    2;
    
----------------------------------
-- Registros totales
----------------------------------   
SELECT
    count(*)
FROM
    cpu;
    
SELECT
    host,
    histogram(usage_idle,
    1,
    100,
    10)
FROM
    cpu
GROUP BY
    host;

    
SELECT
    *
FROM
    cpu
LIMIT 10;