-- Question
-- How can you retrieve all the information from the cd.facilities table?
SELECT * FROM cd.facilities f ;

-- Question
-- You want to print out a list of all of the facilities and their cost 
-- to members. How would you retrieve a list of only facility names and costs?
SELECT f."name" , f.membercost FROM cd.facilities f ;

-- Question
-- How can you produce a list of facilities that charge a fee to members?
SELECT f.* FROM cd.facilities f WHERE membercost <> 0 ;

-- Question
-- How can you produce a list of facilities that charge a fee to members, and
-- that fee is less than 1/50th of the monthly maintenance cost? 
-- Return the facid, facility name, member cost, and monthly maintenance of the
-- facilities in question.

SELECT
    b.memid ,
    round( avg (b.slots), 2)
FROM
    cd.bookings b
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT 5 ;

SELECT
    m.memid ,
    m.recommendedby ,
    m.firstname ,
    m.surname
FROM
    cd.members m ;

-- Question
-- Find the upward recommendation chain for member ID 27: that is, the member who recommended
-- them, and the member who recommended that member, and so on. Return member ID, first name,
-- and surname. Order by descending member id.
SELECT
    m2.memid ,
    m2.firstname ,
    m2.recommendedby
FROM
    cd.members m2
ORDER BY
    1;

WITH RECURSIVE recommenders(recommender) AS 
    (
        SELECT
                    m.recommendedby
        FROM
                    cd.members m
        WHERE
                    m.memid = 27
    UNION ALL
        SELECT
                    mems.recommendedby
        FROM
                    recommenders recs
        INNER JOIN cd.members mems ON
            mems.memid = recs.recommender
    )
    SELECT
        recommender,
        m.firstname ,
        m.surname
    FROM
        recommenders r
    INNER JOIN cd.members m ON
        r.recommender = m.memid ;
    
-- Question
-- Find the downward recommendation chain for member ID 1: that is, the members they
-- recommended, the members those members recommended, and so on. Return member ID and name,
-- and order by ascending member id.
WITH RECURSIVE origen(memid, firstname, surname) AS
    (
        SELECT
                    m1.memid,
                    m1.firstname ,
                    m1.surname
        FROM
                    cd.members m1
        WHERE
                    m1.memid = 1
        UNION ALL
        SELECT
            m.memid,
            m.firstname ,
            m.surname
        FROM
            origen o
        INNER JOIN cd.members m ON 
                    o.memid = m.recommendedby
    )
    SELECT
        o.*
    FROM
        origen o
    ORDER BY
        1 
    OFFSET
        1 ;
        
-- Question
-- Produce a CTE that can return the upward recommendation chain for any member. You should be
-- able to select recommender from recommenders where member=x. Demonstrate it by getting the
-- chains for members 12 and 22. Results table should have member and recommender, ordered by
-- member ascending, recommender descending.   
WITH RECURSIVE recommenders(recommender, member, vector) AS 
    (
    SELECT
        recommendedby,
        memid,
        ARRAY [0]
    FROM
        cd.members
    UNION ALL
    SELECT
        mems.recommendedby,
        recs.MEMBER,
        array_append(recs.vector, mems.memid) 
    FROM
        recommenders recs
    INNER JOIN cd.members mems
                ON
        mems.memid = recs.recommender
    )
SELECT
    recs.member,
    recs.vector,
    recs.recommender,
    mems.firstname,
    mems.surname
FROM
    recommenders recs
INNER JOIN cd.members mems ON
    recs.recommender = mems.memid
WHERE
    recs.member IN (12, 22, 24, 26, 27)
ORDER BY
    recs.member ASC,
    recs.recommender DESC; 