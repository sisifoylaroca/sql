WITH RECURSIVE padres AS (
    SELECT
        proyecto_padre,
        Id,
        proyecto,
        fecha_alta,
        1 nivel,
        Id_utillaje,
        Id_cliente,
        Id_departamento
    FROM
        proyectos
    WHERE
        proyecto_padre = 0
    UNION ALL
    SELECT
        pr.proyecto_padre,
        pr.Id,
        pr.proyecto,
        pr.fecha_alta,
        nivel + 1,
        pr.Id_utillaje,
        pr.Id_cliente,
        pr.Id_departamento
    FROM
        proyectos pr
    JOIN padres pa ON
        pa.Id = pr.proyecto_padre )
SELECT
    proyecto_padre AS PADRE,
    Id AS HIJO,
    proyecto ,
    fecha_alta ,
    nivel
FROM
    padres
-- WHERE
--     proyecto_padre <> 0
ORDER BY
    proyecto_padre,
    Id ;


SELECT
    IDPROYECTO,
    IDSUBPROYECTO,
    sq.proyecto AS PROYECTO,
    sq.fecha_alta AS FECHA_ALTA,
    sq.Id_utillaje AS ID_UTILLAJE,
    sq.Id_cliente AS ID_CLIENTE, 
    sq.Id_departamento AS ID_DEPARTAMENTO
FROM
    (
    SELECT
        COALESCE (NULLIF (proyecto_padre, 0), id) AS IDPROYECTO ,
        id AS IDSUBPROYECTO,
        COUNT(*) OVER(PARTITION BY COALESCE (NULLIF (proyecto_padre, 0), id) ) AS REGISTROS,
        pr.proyecto ,
        pr.fecha_alta,
        pr.Id_utillaje,
        pr.Id_cliente,
        pr.Id_departamento
    FROM
        proyectos pr 
    ORDER BY
        IDPROYECTO,
        IDSUBPROYECTO ) AS sq
WHERE
    NOT ( IDPROYECTO = IDSUBPROYECTO AND REGISTROS > 1 );

SELECT DISTINCT proyecto_padre FROM proyectos ORDER BY proyecto_padre ;

SELECT
    proyecto_padre ,
    Id,
    count(*) over(PARTITION BY proyecto_padre)
FROM
    proyectos
ORDER BY
    id;
 