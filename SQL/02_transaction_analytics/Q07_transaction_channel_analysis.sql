USE banking_analytics_db;

-- ============================================================
-- Q06: MONTHLY TRANSACTION TRENDS
-- Business Question:
-- How do transaction volumes and values change month by month?
-- ============================================================


-- ------------------------------------------------------------
-- 1. Monthly Transaction Performance
-- ------------------------------------------------------------

SELECT
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS Transaction_Month,
    COUNT(*) AS Transaction_Count,
    ROUND(SUM(Amount), 2) AS Total_Transaction_Value,
    ROUND(AVG(Amount), 2) AS Average_Transaction_Value,
    ROUND(MIN(Amount), 2) AS Minimum_Transaction_Value,
    ROUND(MAX(Amount), 2) AS Maximum_Transaction_Value

FROM transactions

GROUP BY
    DATE_FORMAT(Transaction_Date, '%Y-%m')

ORDER BY
    Transaction_Month;


-- ------------------------------------------------------------
-- 2. Month-over-Month Growth Analysis
-- ------------------------------------------------------------

WITH monthly AS (

    SELECT
        DATE_FORMAT(Transaction_Date, '%Y-%m')
            AS Transaction_Month,

        COUNT(*) AS Transaction_Count,

        SUM(Amount) AS Total_Transaction_Value

    FROM transactions

    GROUP BY
        DATE_FORMAT(Transaction_Date, '%Y-%m')
)

SELECT
    Transaction_Month,

    Transaction_Count,

    ROUND(Total_Transaction_Value, 2)
        AS Total_Transaction_Value,

    LAG(Transaction_Count)
        OVER (
            ORDER BY Transaction_Month
        ) AS Previous_Month_Transactions,

    ROUND(
        (
            Transaction_Count
            - LAG(Transaction_Count)
                OVER (
                    ORDER BY Transaction_Month
                )
        ) * 100.0
        /
        NULLIF(
            LAG(Transaction_Count)
                OVER (
                    ORDER BY Transaction_Month
                ),
            0
        ),
        2
    ) AS Transaction_Growth_Percent,

    ROUND(
        (
            Total_Transaction_Value
            - LAG(Total_Transaction_Value)
                OVER (
                    ORDER BY Transaction_Month
                )
        ) * 100.0
        /
        NULLIF(
            LAG(Total_Transaction_Value)
                OVER (
                    ORDER BY Transaction_Month
                ),
            0
        ),
        2
    ) AS Value_Growth_Percent

FROM monthly

ORDER BY
    Transaction_Month;


-- ------------------------------------------------------------
-- 3. Highest Transaction Volume Month
-- ------------------------------------------------------------

WITH monthly AS (

    SELECT
        DATE_FORMAT(Transaction_Date, '%Y-%m')
            AS Transaction_Month,

        COUNT(*) AS Transaction_Count,

        SUM(Amount) AS Total_Transaction_Value

    FROM transactions

    GROUP BY
        DATE_FORMAT(Transaction_Date, '%Y-%m')
)

SELECT
    Transaction_Month,
    Transaction_Count,
    ROUND(Total_Transaction_Value, 2)
        AS Total_Transaction_Value

FROM monthly

ORDER BY
    Transaction_Count DESC

LIMIT 1;


-- ------------------------------------------------------------
-- 4. Highest Transaction Value Month
-- ------------------------------------------------------------

WITH monthly AS (

    SELECT
        DATE_FORMAT(Transaction_Date, '%Y-%m')
            AS Transaction_Month,

        COUNT(*) AS Transaction_Count,

        SUM(Amount) AS Total_Transaction_Value

    FROM transactions

    GROUP BY
        DATE_FORMAT(Transaction_Date, '%Y-%m')
)

SELECT
    Transaction_Month,
    Transaction_Count,
    ROUND(Total_Transaction_Value, 2)
        AS Total_Transaction_Value

FROM monthly

ORDER BY
    Total_Transaction_Value DESC

LIMIT 1;


-- ------------------------------------------------------------
-- 5. Data Validation
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS Total_Transactions,
    COUNT(DISTINCT Transaction_Date) AS Transaction_Days,
    MIN(Transaction_Date) AS First_Transaction_Date,
    MAX(Transaction_Date) AS Last_Transaction_Date

FROM transactions;