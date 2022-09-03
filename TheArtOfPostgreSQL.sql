-- Prueba
SELECT
    name
FROM
    track
WHERE
    albumid = 193
ORDER BY
    trackid ;
--------------------------------    
SELECT
    track.name AS track,
    genre.name AS genre
FROM
    track
JOIN genre
        USING( genreid )
WHERE
    albumid = 193
ORDER BY
    trackid ;
--------------------------------    
SELECT
    name,
    milliseconds * INTERVAL '1 ms' AS duration,
    pg_size_pretty( bytes ) AS bytes
FROM
    track
WHERE
    albumid = 193
ORDER BY
    trackid ;
--------------------------------    
SELECT
    a.title AS album,
    SUM ( milliseconds ) * INTERVAL '1 ms' AS duration
FROM
    album a
JOIN artist
        USING ( artistid )
LEFT JOIN track
        USING ( albumid )
WHERE
    artist.name = 'Red Hot Chili Peppers'
GROUP BY
    1
ORDER BY
    1;