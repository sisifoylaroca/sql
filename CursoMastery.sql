-- FINDING all data about a customer's first order
-- Should have 1 row for each customer
-- the min is determined by the payment_date
SELECT
    *
FROM
    (
    SELECT
        p.*
    FROM
        payment p
    JOIN (
        SELECT
            p2.customer_id,
            MIN( p2.payment_date ) AS fo_date
        FROM
            payment p2
        GROUP BY
            1 
    ) zebra ON
        zebra.fo_date = p.payment_date
    ORDER BY
        2
) t
WHERE
    t.staff_id = 2;

-- row_number
-- can you get a list of orders by staff member, in reverse order?
-- get customer's most recent orders?

WITH first_orders AS (
    SELECT
        *
    FROM
        (
        SELECT
            p.*, 
            ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date )
        FROM
            payment p
        ORDER BY
            2
        ) t
    WHERE
        t.row_number = 1
    )
SELECT
    *
FROM
    first_orders;



-- CASE
WITH rando_nbrs AS (
SELECT
    random() * 100 AS val
FROM
    generate_series(1, 100)
)
SELECT
    rn.* ,
    CASE
        WHEN rn.val < 50 THEN 'lt_50'
        WHEN rn.val < 90 THEN 'lt_90'
        WHEN rn.val < 101 THEN 'gt_90'
        ELSE 'oops'
        -- filter on that later...
    END AS outcome
FROM
    rando_nbrs rn


WITH ranked_orders AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date )
    FROM
        payment p
    ORDER BY
        2
    )
SELECT
    ro.*,
    CASE
        WHEN ro.row_number = 1 THEN 'new_order'
        WHEN ro.row_number > 1 THEN 'rept_order'
        ELSE 'oops'
    END AS outcome
FROM
    ranked_orders ro;

-- buyerid, email, first order, recent order, total spend
WITH 
base_table AS (
    SELECT
        p.customer_id,
        p.payment_date,
        ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date ASC) AS early_order,
        ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date DESC) AS late_order
    FROM
        payment p
    ), 
second_table AS (
    SELECT
        *
    FROM
        base_table bt
    WHERE
        bt.early_order = 1
        OR bt.late_order = 1
    )
SELECT
    st.customer_id,
    max(st.payment_date) AS rec_order,
    min(st.payment_date) AS first_order,
    (
    SELECT
        SUM(p2.amount)
    FROM
        payment p2
    WHERE
        p2.customer_id = st.customer_id
) AS ltv_spend
FROM
    second_table st
GROUP BY
    1
ORDER BY
    1;

-- Preferred Rating need to figure out  how to get their ratings
SELECT
    *
FROM
    (
    SELECT
        t.customer_id,
        t.rating,
        COUNT(*) ,
        ROW_NUMBER() OVER(PARTITION BY t.customer_id ORDER BY COUNT(*) DESC)
    FROM
        (
        SELECT
            r.customer_id,
            r.inventory_id,
            i.film_id,
            f.rating
        FROM
            rental r
        JOIN inventory i
                USING(inventory_id)
        JOIN film f
                USING(film_id)
            ) t
    GROUP BY
        1,
        2
    ORDER BY
        1,
        3 DESC
) t2
WHERE
    t2.row_number = 1;
--------------------------------------------------------------
SELECT
    t.customer_id,
    COUNT(*),
    ARRAY_AGG(DISTINCT t.rating),
    ROW_NUMBER() OVER(PARTITION BY t.customer_id ORDER BY COUNT(*) DESC)
FROM
    (
        SELECT
                r.customer_id,
                r.inventory_id,
                i.film_id,
                f.rating
        FROM
                rental r
        JOIN inventory i
                USING(inventory_id)
        JOIN film f
                USING (film_id)
) t
GROUP BY
    1
ORDER BY
    1,
    3 DESC;






-- 3.1 WRITE A QUERY TO LIST ALL THE FILM TITLES

SELECT
    title
FROM
    film f;

-- 3.5 WRITE A QUERY TO OBTAIN THE LENGTH OF EACH CUSTOMER'S FIRST NAME (REMEMBER TO LOOK FOR STRING
-- FUNCTIONS IN THE DOCUMENTATION THAT CAN HELP)

SELECT
    first_name ,
    CHAR_LENGTH(first_name) AS lenght
FROM
    customer c;

SELECT
    first_name,
    last_name,
    UPPER(LEFT(first_name , 1) || LEFT(last_name, 1)) AS initial
FROM
    customer c;

-- 

SELECT
    title,
    rental_rate,
    replacement_cost,
    CEIL(replacement_cost / rental_rate) AS "# rentals to break-even"
FROM
    film f;

SELECT
    title,
    rating
FROM
    film f
WHERE
    rating = 'G';
-- 
SELECT
    title,
    f.'length' 
FROM
    film f
WHERE
    f.'lenght' > 120 ;
-- 
SELECT
    rental_id,
    rental_date
FROM
    rental f
WHERE
    rental_date <= '2005-06-1';
-- 
SELECT
    title,
    rental_rate,
    replacement_cost,
    CEIL(replacement_cost / rental_rate) AS "# rentals to break-even"
FROM
    film f
WHERE
    CEIL(replacement_cost / rental_rate) > 30;

SELECT
    rental_id,
    rental_date
FROM
    rental r
WHERE
    customer_id = 388 AND 
    DATE_PART('year', rental_date) = 2005 ;

-- 3.13 WE’RE TRYING TO LIST ALL FILMS WITH A LENGTH OF AN HOUR OR LESS. SHOW TWO DIFFERENT WAYS 
-- TO FIX OUR QUERY BELOW THAT ISN'T WORKING (ONE USING THE NOT KEYWORD, AND ONE WITHOUT)

select title, rental_duration, length from film where length <= 60 ;
select title, rental_duration, length from film where not length > 60 ;

-- 3.14 Explain what each of the two queries below are doing and why they generate different results. Which one is 
-- probably a mistake and why?
select title, rating from film where rating != 'G' and rating != 'PG';
select title, rating from film where rating != 'G' or rating != 'PG'; -- estan todas 

-- 3.15 Write a single query to show all rentals where the return date is greater than the rental date, or the return 
-- date is equal to the rental date, or the return date is less than the rental date. How many rows are returned? 
-- Why doesn't this match the number of rows in the table overall?

(
SELECT
    rental_id,
    rental_date ,
    return_date
FROM
    rental r
)

    EXCEPT 

(
SELECT
    rental_id,
    rental_date ,
    return_date
FROM
    rental r
WHERE
    rental_date < return_date
    OR rental_date = return_date
    OR rental_date > return_date
);


-- 3.16 Write a query to list the rentals that haven't been returned
SELECT
    rental_id ,
    rental_date
FROM
    rental r
WHERE
    return_date IS NULL ;

-- 3.17 Write a query to list the films that have a rating that is not 'G' or 'PG'
select title, rating from film f where rating not in ('G', 'PG') ; 

-- 3.18 Write a query to return the films with a rating of 'PG', 'G', or 'PG-13'
select title, rating from film f where rating in ('PG', 'G', 'PG-13') ;

-- 3.19 Write a query equivalent to the one below using BETWEEN.
select title, length from film f where length between 90 and 120;

-- 3.20 Write a query to return all film titles that end with the word "GRAFFITI"

select title from film f where title like '%GRAFFITI' ;

-- 3.21 In exercise 3.17 you wrote a query to list the films that have a rating that is 
-- not 'G' or 'PG'. Re-write this query using NOT IN. Do your results include films with
-- a NULL rating?
HECHO

-- 3.22 Write a query to list all the customers with an email address. Order the customers
-- by last name descending

select first_name ,last_name , email from customer c where email is not null order by last_name desc;

-- 3.23 Write a query to list the country id's and cities from the city table, 
-- first ordered by country id ascending, then by city alphabetically.
select country_id , city from city c order by country_id , city 

-- 3.24 Write a query to list actors ordered by the length of their full name 
-- ("[first_name] [last_name]") descending.
select
    first_name ,
    last_name ,
    character_length(first_name || ' ' || last_name)
from
    actor a
order by
    character_length(first_name || ' ' || last_name) desc ;
    
-- 3.25 Describe the difference between ORDER BY x, y DESC 
-- and ORDER BY x DESC, y DESC (where x and y are columns in some imaginary
-- table you're querying)

-- 3.26 Fix the query below, which we wanted to use to list all the rentals 
-- that happened after 10pm at night.
 select
    rental_id,
    date_part('hour', rental_date) as "rental hour"
from
    rental
where
    date_part('hour', rental_date) >= 22 ;

-- 3.27 Write a query to return the 3 most recent payments received
select payment_id, payment_date from payment p order by payment_date desc limit 3 ;

-- 3.28 Return the 4 films with the shortest length that are not R rated. 
-- For films with the same length, order them alphabetically
select title, length, rating from film f where rating != 'R' order by length, title limit 4;

-- 3.29 Write a query to return the last 3 payments made in January, 2007
select
    payment_id ,
    amount ,
    payment_date
from
    payment p
where
    date_part('year', payment_date) = 2007
    and date_part('month', payment_date) = 1
order by
    payment_date DESC
limit 3 ;

-- 3.30 Can you think of a way you could, as in the previous exercise, return the last 3 payments 
-- made in January, 2007 but have those same 3 output rows ordered by date ascending? 
-- (Don't spend too long on this...)
select *
from
    (
        select
            payment_id ,
            amount ,
            payment_date
        from
            payment p
        where
            date_part('year', payment_date) = 2007
            and date_part('month', payment_date) = 1
        order by
            payment_date desc
        limit 3 
    ) A
order by
payment_date ;

-- 3.31 Write a query to return all the unique 
-- ratings films can have, ordered alphabetically (not including NULL)
select distinct rating from film f where rating is not null order by rating  ;

-- 3.32 Write a query to help us quickly see if there is any hour of the day 
-- that we have never rented a film out on (maybe the staff always head out for lunch?)
select distinct date_part('hour', return_date) from rental r order by date_part('hour', return_date) ;

-- 3.33 Write a query to help quickly check whether the same rental rate is used for each rental 
-- duration (for example - is the rental rate always 4.99 when the rental duration is 3?)
select distinct rental_duration,  rental_rate from film f order by rental_duration ;

-- 3.34 Can you explain why the first query below works, but the second one, which simply 
-- adds the DISTINCT keyword, doesn't? (this is quite challenging)
select
    first_name
from
    actor
order by
    last_name;

select
    distinct first_name, last_name 
from
    actor
order by
    last_name ;

-- 3.35 Write a query to return an ordered list of distinct ratings for films in 
-- our films table along with their descriptions (you will have to type in the descriptions yourself)
 select
    distinct rating,
    case
        rating when 'G' then 'Patata'
        when 'PG' then 'Tomate'
        when 'PG-13' then 'Cebolla'
        when 'R' then 'Pimiento'
        when 'NC-17' then 'Judia'
    end as "rating description"
from
    film f
where
    rating is not null
order by
    rating ;

-- 3.36 Write a query to output 'Returned' for returned rentals and 'Not Returned' 
-- for rentals that haven't been returned. Order the output to show those not returned first.
 select
    rental_id ,
    rental_date ,
    return_date,
    case
        when return_date is null then 'Not Returned'
        else 'Returned'
    end as Status
from
    rental r
order by
    return_date desc ;

-- 3.37 Imagine you were asked to write a query to populate a 'country picker' for some internal 
-- company dashboard. Write a query to return the countries in alphabetical order, but also with 
-- the twist that the first 3 countries in the list must be 1) Australia 2) United Kingdom 3) 
-- United States and then normal alphabetical order after that (maybe you want them first because, 
-- for example, most of your customers come from these countries)


-- 4.1 Write a query to return the total count of customers in the customer table and the count 
-- of how many customers provided an email address
 select
    count(*) "# customers",
    count(email) "# customer with email"
from
    customer c ;

-- 6.1 Write a query to return a list of all the films rented by PETER MENARD showing the most 
-- recent first

select
    rental_date,
    title
from
    rental r
inner join customer c
        using(customer_id)
inner join inventory i
        using(inventory_id)
inner join film f
        using(film_id)
where
    first_name = 'PETER'
    and last_name = 'MENARD'
order by
    rental_date desc;

-- 6.2 Write a query to list the full names and contact details for the manager of each
-- store
 select
    s.store_id,
    s2.first_name || ' ' || s2.last_name as "Manager",
    s2.email
from
    store s
inner join staff s2 on
    s.manager_staff_id = s2.staff_id ;  

-- 6.3 Write a query to return the top 3 most rented out films and how many
-- times they've been rented out
 select
 film_id,
 title,
 count(*) as counter
from
    rental r
inner join inventory i
    using(inventory_id)
inner join film f 
    using(film_id)
group by
    film_id,
    f.title
order by
    counter desc
limit 3

-- 6.4 Write a query to show for each customer how many different (unique) films they've rented and
-- how many different (unique) actors they've seen in films they've rented
 select
    customer_id,
    count(distinct film_id) numoffilms,
    count(distinct actor_id) numofactors
from
    rental r
inner join inventory i2
    using(inventory_id)
inner join film f   
    using(film_id)
inner join film_actor fa 
    using(film_id)
group by
    customer_id;

/*
6.5 Re-write the query below written in the older style of inner joins 
(which you still encounter surprisingly often online) using the more modern style.
Re-write it once using ON to establish the join condition and the second time with 
USING.
    select film.title, language.name as "language"
    from film, language
    where film.language_id = language.language_id;
*/

select
    title,
    "name"
from
    film f
inner join "language" l
        using(language_id)


-- 7.1 Write a query to return all the customers who made a rental on the first day of 
-- rentals (without hardcoding the date for the first day of rentals in your query)
select
    distinct c.first_name,
    c.last_name
from
    rental r
inner join customer c
        using(customer_id)
where
    r.rental_date::date = (
    select
        min(rental_date::date)
    from
        rental) ;


-- 7.2 Using a subquery, return the films that don't have any actors. Now write the 
-- same query using a left join. Which solution do you think is better? Easier to read?
 select
    film_id,
    title
from
    film
where
    film_id not in (
    select
        film_id
    from
        film_actor)
order by film_id ;

select
    film_id,
    title
from
    film f
left join film_actor fa
        using(film_id)
where
    actor_id is null
order by film_id ;

-- 7.3 You intend to write a humorous email to congratulate some customers on their 
-- poor taste in films. To that end, write a query to return the customers who rented 
-- out the least popular film (that is, the film least rented out - if there is more 
-- than one, pick the one with the lowest film ID)

 select
 film_id,
 title,
 count(*) as counter
from
    rental r
inner join inventory i
    using(inventory_id)
inner join film f 
    using(film_id)
group by
    film_id,
    f.title
order by
    counter, film_id;

-- 7.4 Write a query to return the countries in our database that have more
-- than 15 cities

select
    c.country as "Country"
from
    country as c
where
    (
    select
        count(*)
    from
        city ct
    where
        ct.country_id = c.country_id 
group by
    country_id) > 15;

-- 7.5 Write a query to return for each customer the store they most commonly 
-- rent from

 select
    customer_id,
    first_name,
    last_name,
    (
    select
        i.store_id
    from
        rental r
    inner join inventory i
            using(inventory_id)
    where
        r.customer_id = c.customer_id
    group by i.store_id
    order by count(*) DESC
    limit 1)
from
    customer c 


-- 7.6 In the customer table, each customer has a store ID which is the store they
-- originally registered at. Write a query to list for each customer whether they have
-- ever rented from a different store than that one they registered at. Return 'Y' if
-- they have, and 'N' if they haven't.  

select
    c.first_name,
    c.last_name,
    case
        when exists (
        select
            *
        from
            rental as r
        inner join inventory as i
                using (inventory_id)
        where
            r.customer_id = c.customer_id
            and i.store_id != c.store_id) then 'Y'
        else 'N'
    end as "HasRentedOtherStore"
from
    customer as c
order by "HasRentedOtherStore" DESC;
 
-- 7.9 Write a query to return for each customer the first 'PG' film that they rented 
-- (include customers who have never rented a 'PG' film as well)
select
    c.first_name,
    c.last_name,
    d.title,
    d.rental_date
from
    customer as c
left join lateral (
    select
        r.customer_id,
        f.title,
        r.rental_date
    from
        rental as r
    inner join inventory as i
            using (inventory_id)
    inner join film as f
            using (film_id)
    where
        r.customer_id = c.customer_id
        and f.rating = 'PG'
    order by
        r.rental_date
    limit 1) as d on
    c.customer_id = d.customer_id ;

-- 8.1 Write a query to return the 3 most recent rentals for each customer. 
-- Earlier you did this with a lateral join - this time do it with window functions
with consulta as 
 (select
    rental_id,
    customer_id,
    rental_date,
    rank() over(partition by customer_id order by rental_date desc) as Rank
    from
        rental r)
select 
    rental_id,
    customer_id,
    rental_date
from consulta where Rank <= 3 ;

-- 8.2 We want to re-do exercise 7.3, where we wrote a query to return the customers 
-- who rented out the least popular film (that is, the film least rented out). This 
-- time though we want to be able to handle if there is more than one film that is 
-- least popular. So if several films are each equally unpopular, return the customers
-- who rented out any of those films.

-- 8.3 Write a query to return all the distinct film ratings without using the DISTINCT
-- keyword

-- 9.1 Write a query to list out all the distinct dates there was some sort of customer
-- interaction (a rental or a payment) and order by output date

-- 9.2 Write a query to find the actors that are also customers 
-- (assuming same name = same person)

-- 9.3 Have the actors with IDs 49 (Anne Cronyn), 152 (Ben Harris), and 180 
-- (Jeff Silverstone) ever appeared in any films together? Which ones?



-- 9.4 The missing rental IDs problem that we've encountered several times now is the 
-- perfect place to use EXCEPT. Write a query using the generate_series function and 
-- EXCEPT to find missing rental IDs (The rental table has 16,044 rows but the maximum 
-- rental ID is 16,049 - some IDs are missing)

-- 9.5 Write a query to list all the customers who have rented out a film on a Saturday
-- but never on a Sunday. Order the customers by first name.
