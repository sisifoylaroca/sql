-- Nombre de las tablas
SELECT
    table_name
FROM
    information_schema."tables" t
WHERE
    table_schema = 'public';

SELECT
    i.*, i2.customerid 
FROM
    invoiceline i
JOIN invoice i2 ON
    i.invoiceid = i2.invoiceid;
----------------------    
SELECT
    genre.name,
    count(*) AS count
FROM
    genre
LEFT JOIN track
        USING(genreid)
GROUP BY
    genre.name
ORDER BY
    count DESC;



SELECT
    *
FROM
    customer c ;
    

SELECT
    a."name",
    sum(i.unitprice * i.quantity) AS total
FROM
    artist a
LEFT JOIN album a2
        USING(artistid)
LEFT JOIN track t
        USING(albumid)
LEFT JOIN invoiceline i
        USING(trackid)
GROUP BY
    1
HAVING
    sum(i.unitprice * i.quantity) > 0
ORDER BY
    2 DESC ;
    


-- name: genre-top-n
-- Get the N top tracks by genre

SELECT
    genre.name AS genre,
    CASE
        WHEN length(ss.name) > 15
        THEN substring(ss.name FROM 1 FOR 15) || '…'
        ELSE ss.name
    END AS track,
    artist.name AS artist
FROM
    genre
LEFT JOIN LATERAL
/*
* the lateral left join implements a nested loop over
* the genres and allows to fetch our Top-N tracks per
* genre, applying the order by desc limit n clause.
*
* here we choose to weight the tracks by how many
* times they appear in a playlist, so we join against
* the playlisttrack table and count appearances.
*/
    (
    SELECT
        track.name,
        track.albumid,
        count(playlistid)
    FROM
        track
    LEFT JOIN playlisttrack
            USING (trackid)
    WHERE
        track.genreid = genre.genreid
    GROUP BY
        track.trackid
    ORDER BY
        count DESC
    LIMIT :n
)
/*
* the join happens in the subquery's where clause, so
* we don't need to add another one at the outer join
* level, hence the "on true" spelling.
*/
    ss(name, albumid, count) ON TRUE
JOIN album
        USING(albumid)
JOIN artist
        USING(artistid)
ORDER BY
    genre.name,
    ss.count DESC;