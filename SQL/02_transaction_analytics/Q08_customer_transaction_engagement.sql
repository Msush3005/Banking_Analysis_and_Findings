USE banking_analytics_db;

-- ============================================================
-- Q08: CUSTOMER TRANSACTION ENGAGEMENT
-- Business Question:
-- Which customers show unusually high or low transaction activity?
-- ============================================================


-- ------------------------------------------------------------
-- 1. Customer Transaction Engagement
-- ------------------------------------------------------------

SELECT
    a.Customer_ID,

    COUNT(DISTINCT a.Account_ID) AS Account_Count,

    COUNT(t.Transaction_ID) AS Transaction_Count,

    ROUND(COALESCE(SUM(t.Amount), 0), 2)
        AS Total_Transaction_Value,

    ROUND(
        COALESCE(AVG(t.Amount), 0),
        2
    ) AS Average_Transaction_Value

FROM accounts a

LEFT JOIN transactions t
    ON a.Account_ID = t.Account_ID

GROUP BY
    a.Customer_ID

ORDER BY
    Transaction_Count DESC;


-- ------------------------------------------------------------
-- 2. Transaction Engagement Distribution
-- ------------------------------------------------------------

WITH customer_engagement AS (

    SELECT
        a.Customer_ID,
        COUNT(t.Transaction_ID) AS Transaction_Count

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY
        a.Customer_ID
)

SELECT
    MIN(Transaction_Count) AS Minimum_Transactions,

    ROUND(AVG(Transaction_Count), 2)
        AS Average_Transactions,

    MAX(Transaction_Count) AS Maximum_Transactions,

    ROUND(
        (
            SELECT Transaction_Count
            FROM customer_engagement
            ORDER BY Transaction_Count
            LIMIT 1 OFFSET 3749
        ),
        2
    ) AS Q1_Transactions,

    (
        SELECT Transaction_Count
        FROM customer_engagement
        ORDER BY Transaction_Count
        LIMIT 1 OFFSET 2499
    ) AS Median_Transactions,

    (
        SELECT Transaction_Count
        FROM customer_engagement
        ORDER BY Transaction_Count
        LIMIT 1 OFFSET 1249
    ) AS Q3_Transactions

FROM customer_engagement;


-- ------------------------------------------------------------
-- 3. Customer Engagement Segmentation
-- ------------------------------------------------------------

WITH customer_engagement AS (

    SELECT
        a.Customer_ID,

        COUNT(t.Transaction_ID) AS Transaction_Count,

        ROUND(
            COALESCE(SUM(t.Amount), 0),
            2
        ) AS Total_Transaction_Value

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY
        a.Customer_ID
)

SELECT
    CASE

        WHEN Transaction_Count = 0
            THEN 'No Activity'

        WHEN Transaction_Count <= 8
            THEN 'Low Engagement'

        WHEN Transaction_Count <= 30
            THEN 'Medium Engagement'

        ELSE 'High Engagement'

    END AS Engagement_Group,

    COUNT(*) AS Customer_Count,

    ROUND(
        AVG(Transaction_Count),
        2
    ) AS Average_Transactions,

    ROUND(
        SUM(Total_Transaction_Value),
        2
    ) AS Total_Transaction_Value

FROM customer_engagement

GROUP BY
    Engagement_Group

ORDER BY
    Customer_Count DESC;


-- ------------------------------------------------------------
-- 4. Highest-Activity Customers
-- ------------------------------------------------------------

SELECT
    a.Customer_ID,

    COUNT(t.Transaction_ID) AS Transaction_Count,

    ROUND(
        SUM(t.Amount),
        2
    ) AS Total_Transaction_Value

FROM accounts a

JOIN transactions t
    ON a.Account_ID = t.Account_ID

GROUP BY
    a.Customer_ID

ORDER BY
    Transaction_Count DESC

LIMIT 10;


-- ------------------------------------------------------------
-- 5. Low-Engagement Customers
-- ------------------------------------------------------------

SELECT
    a.Customer_ID,

    COUNT(t.Transaction_ID) AS Transaction_Count,

    ROUND(
        COALESCE(SUM(t.Amount), 0),
        2
    ) AS Total_Transaction_Value

FROM accounts a

LEFT JOIN transactions t
    ON a.Account_ID = t.Account_ID

GROUP BY
    a.Customer_ID

HAVING
    Transaction_Count <= 2

ORDER BY
    Transaction_Count ASC,
    Total_Transaction_Value ASC;


-- ------------------------------------------------------------
-- 6. Validation
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT Customer_ID) AS Customers_With_Transactions

FROM (

    SELECT
        a.Customer_ID

    FROM accounts a

    JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY
        a.Customer_ID

) x;