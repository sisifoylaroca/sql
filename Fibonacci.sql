WITH RECURSIVE cte_Recursion (PrevNumber, "Number") AS
(
SELECT
    0, 1
UNION ALL
SELECT
    "Number",
    PrevNumber + "Number"
FROM
    cte_Recursion
WHERE
    "Number" < 1000000000
)
SELECT
    PrevNumber AS Fibonacci
FROM
    cte_Recursion;