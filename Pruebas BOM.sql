-- Creación de tabla escandallo
--DROP TABLE IF EXISTS  public.escandallo ;
--CREATE TABLE public.escandallo (
--    padre varchar NULL,
--    hijo varchar NULL,
--    cantidad int4 NULL
--);
--
--INSERT INTO public.escandallo (padre,hijo,cantidad) VALUES
--     ('1','2',2),
--     ('1','3',3),
--     ('1','4',4),
--     ('1','6',3),
--     ('2','5',7),
--     ('2','6',6),
--     ('3','7',6),
--     ('4','8',10),
--     ('4','9',11),
--     ('5','10',10);
--     ('5','11',10),
--     ('6','12',10),
--     ('6','13',10),
--     ('7','14',8),
--     ('7','12',8),
--     ('15','16',2),
--     ('16','2',3);


-- Visualización de la tabla
SELECT
    e.padre ,
    e.hijo ,
    e.cantidad
FROM
    escandallo e ;

-- VISTA CON FUNCION RECURSIVA QUE REALIZA LA EXPLOSIÓN DEL BOM -----
--DROP VIEW IF EXISTS expl_escan;
--CREATE OR REPLACE VIEW expl_escan AS 
--(

WITH RECURSIVE cebador(nodo, ruta, padre, hijo, cantidad, cantidadtotal, nivel) AS 
    (
--  Bloque en el que localizo todos los productos posibles
--  para cebar el proceso de búsqueda de rutas. BOMIni
            SELECT
                DISTINCT padre::varchar AS nodo,
                padre::varchar AS ruta, 
                '0'::varchar AS padre,
                padre::varchar AS hijo,
                1 AS cantidad, 
                1 AS cantidadtotal,
                0 AS nivel
            FROM
                escandallo e
            UNION 
            SELECT
                DISTINCT hijo::varchar AS nodo,
                hijo::varchar AS ruta,
                '0'::varchar AS padre,
                hijo::varchar AS hijo,
                1 AS cantidad, 
                1 AS cantidadtotal,
                0 AS nivel
            FROM
                escandallo e),    
    salida(nodo, ruta, padre, hijo, cantidad, cantidadtotal, nivel) AS 
        (
        SELECT * FROM cebador c
        UNION ALL
            SELECT
                s.nodo,
                s.ruta || '/' || e.hijo::varchar AS ruta,
                e.padre ,
                e.hijo ,
                e.cantidad , 
                s.cantidadtotal * e.cantidad ,
                s.nivel + 1
            FROM
                salida s
            JOIN escandallo e ON 
                s.hijo = e.padre
        )
        SELECT
            a.nodo::int ,
            a.ruta , 
            a.padre ,
            a.hijo ,
            a.cantidad ,
            a.cantidadtotal ,
            a.nivel ,
            t.hoja
        FROM
            salida a
        LEFT JOIN ( -- Nos permite conocer los padres
                    SELECT
                        hijo AS hoja
                    FROM
                        escandallo
                EXCEPT
                    SELECT
                        padre AS hoja
                    FROM
                    escandallo
        ) t ON t.hoja = a.hijo    
       ORDER BY
            1 ,
            6 ;

-- prueba de escandallo
SELECT * FROM expl_escan;


SELECT
    COUNT(*) - COUNT(DISTINCT ruta) repetidos
FROM
    expl_escan ee ;





-- Pruebas Ltree

--CREATE EXTENSION ltree;
--CREATE TABLE test (path ltree);
--INSERT INTO test VALUES ('Top');
--INSERT INTO test VALUES ('Top.Science');
--INSERT INTO test VALUES ('Top.Science.Astronomy');
--INSERT INTO test VALUES ('Top.Science.Astronomy.Astrophysics');
--INSERT INTO test VALUES ('Top.Science.Astronomy.Cosmology');
--INSERT INTO test VALUES ('Top.Hobbies');
--INSERT INTO test VALUES ('Top.Hobbies.Amateurs_Astronomy');
--INSERT INTO test VALUES ('Top.Collections');
--INSERT INTO test VALUES ('Top.Collections.Pictures');
--INSERT INTO test VALUES ('Top.Collections.Pictures.Astronomy');
--INSERT INTO test VALUES ('Top.Collections.Pictures.Astronomy.Stars');
--INSERT INTO test VALUES ('Top.Collections.Pictures.Astronomy.Galaxies');
--INSERT INTO test VALUES ('Top.Collections.Pictures.Astronomy.Astronauts');
--CREATE INDEX path_gist_idx ON test USING GIST (path);
--CREATE INDEX path_idx ON test USING BTREE (path);

SELECT
    path
FROM
    test
WHERE
    path ~ '*.Hobbies.*';