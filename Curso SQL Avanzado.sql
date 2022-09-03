-- FINDING all data about a customer's first order
-- Should have 1 row for each customer
-- the min is determined by the payment_date
SELECT p.* FROM payment p ORDER BY 2, 6;

WITH consulta AS (
    SELECT * FROM
        (
        SELECT p.* FROM payment p JOIN (
            SELECT
                p2.customer_id,
                MIN ( p2.payment_date ) AS payment_date
            FROM
                payment p2
            GROUP BY
                1 
        ) z USING ( payment_date )
        ORDER BY
            2
        ) t
    )
SELECT * FROM consulta c WHERE c.staff_id = 2;

-- row_number
-- can you get a list of orders by staff member, in reverse order?
-- get customer's most recent orders?

WITH first_orders AS (
    SELECT * FROM
        (
        SELECT
            p.*, 
            ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date)
        FROM
            payment p
        ORDER BY
            2
        ) t
    WHERE
        t.row_number = 1
    )
SELECT * FROM first_orders;

-- Ejemplo de uso de CASE para poder crear una columna de etiquetas de clasificación.
WITH rando_nbrs AS (
    SELECT
        (random() * 100)::numeric(10,2) AS val
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
    rando_nbrs rn;

--- Uso real de CASE utilizando ROW_NUMBER para poder filtrar los pagos -----
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
WITH base_table AS (
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

-- Preferred Rating need to figure out how to get their ratings
SELECT * FROM
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
            USING( inventory_id )
        JOIN film f 
            USING( film_id )
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

----------
SELECT
    t.customer_id,
    COUNT(*) ,
    ARRAY_AGG(DISTINCT t.rating),
    ROW_NUMBER() OVER(PARTITION BY t.customer_id
ORDER BY
    COUNT(*) DESC)
FROM
    (
    SELECT
        r.customer_id,
        r.inventory_id,
        i.film_id,
        f.rating
    FROM
        rental r
    JOIN inventory i ON
        r.inventory_id = i.inventory_id
    JOIN film f ON
        f.film_id = i.film_id
) t
GROUP BY
    1
ORDER BY
    1,
    3 DESC;

-------------------- Sección 3.1 --------------------------
SELECT
    t.*,
    t.payment_date - t.prior_order AS some_interval,
    -- raw interval
 EXTRACT(epoch FROM t.payment_date - t.prior_order ) / 3600 AS hours_since
    -- interval to hours
 FROM (
    SELECT 
        p.*, 
        LAG(p.payment_date) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) as prior_order
    FROM payment p
) t

-------------------- Sección 3.2 --------------------------

SELECT t.*, 
 t.payment_date - t.prior_order as some_interval, -- raw interval
 EXTRACT(epoch FROM t.payment_date - t.prior_order ) / 3600 as hours_since-- interval to hours
 FROM (
    SELECT p.*, 
        lag(p.payment_date) OVER (PARTITION BY p.customer_id) as prior_order
    FROM payment p
)t

-- Alternate Syntax and Some Moving Calculations

SELECT
    p.* , 
    avg(p.amount) OVER w1 AS avg_over_prior7,
    avg(p.amount) OVER w2 AS back3_fwd_3_avg
FROM
    payment p
WINDOW 
    w1 AS (PARTITION BY p.customer_id ORDER BY p.payment_id ROWS BETWEEN 7 PRECEDING AND 0 FOLLOWING),
    w2 AS (PARTITION BY p.customer_id ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING);

-------------------- Sección 3.3 --------------------------    

SELECT
    t.*,
    t.payment_date - t.prior_order AS some_interval,
    -- raw interval
 EXTRACT(epoch
FROM
    t.payment_date - t.prior_order ) / 3600 AS hours_since
 FROM (
    SELECT p.*, 
        lag(p.payment_date) OVER (PARTITION BY p.customer_id) as prior_order,
        row_number() over(partition by p.customer_id order by p.payment_date) as order_rank
    FROM payment p
) t;

-------------------- Sección 3.4 --------------------------    
-- I want the top 10% of movies by dollar value rented

SELECT
    f.film_id,
    f.title,
    SUM(p.amount) AS sales,
    NTILE(100) OVER( ORDER BY SUM(p.amount) DESC) AS p_rank,
    SUM( SUM(p.amount) ) OVER () AS global_sales
FROM
    rental r
JOIN inventory i
        USING (inventory_id)
JOIN film f
        USING (film_id)
JOIN payment p
        USING (rental_id)
GROUP BY
    1,
    2
ORDER BY
    3 DESC;