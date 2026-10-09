USE banking_analytics_db;

-- ============================================================
-- Q13: BRANCH PERFORMANCE ANALYSIS
-- ============================================================
-- Business Question:
-- Which branches have the strongest customer base,
-- account balances and transaction activity?
--
-- Metrics:
-- 1. Customer Count
-- 2. Account Count
-- 3. Total Account Balance
-- 4. Average Account Balance
-- 5. Transaction Count
-- 6. Total Transaction Value
-- 7. Average Transaction Value
--
-- Important:
-- Transactions are aggregated separately before joining
-- to accounts to avoid double-counting balances.
-- ============================================================


WITH branch_accounts AS
(
    SELECT
        a.Branch_ID,
        COUNT(DISTINCT a.Account_ID) AS Account_Count,
        COUNT(DISTINCT a.Customer_ID) AS Customer_Count,
        SUM(a.Balance) AS Total_Balance,
        AVG(a.Balance) AS Average_Balance
    FROM accounts a
    GROUP BY a.Branch_ID
),

branch_transactions AS
(
    SELECT
        a.Branch_ID,
        COUNT(t.Transaction_ID) AS Transaction_Count,
        SUM(t.Amount) AS Total_Transaction_Value,
        AVG(t.Amount) AS Average_Transaction_Value
    FROM accounts a
    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID
    GROUP BY a.Branch_ID
)

SELECT
    b.Branch_ID,
    b.Branch_Name,
    b.City,

    COALESCE(ba.Customer_Count, 0) AS Customer_Count,
    COALESCE(ba.Account_Count, 0) AS Account_Count,

    ROUND(COALESCE(ba.Total_Balance, 0), 2)
        AS Total_Balance,

    ROUND(COALESCE(ba.Average_Balance, 0), 2)
        AS Average_Balance,

    COALESCE(bt.Transaction_Count, 0)
        AS Transaction_Count,

    ROUND(COALESCE(bt.Total_Transaction_Value, 0), 2)
        AS Total_Transaction_Value,

    ROUND(COALESCE(bt.Average_Transaction_Value, 0), 2)
        AS Average_Transaction_Value

FROM branches b

LEFT JOIN branch_accounts ba
    ON b.Branch_ID = ba.Branch_ID

LEFT JOIN branch_transactions bt
    ON b.Branch_ID = bt.Branch_ID

ORDER BY
    Total_Balance DESC,
    Total_Transaction_Value DESC;