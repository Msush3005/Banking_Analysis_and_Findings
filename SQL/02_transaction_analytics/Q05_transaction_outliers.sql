-- ============================================================
-- BANKING ANALYTICS PORTFOLIO
-- Q05: HIGH-VALUE TRANSACTION ACTIVITY
-- ============================================================

USE banking_analytics_db;


-- ============================================================
-- BUSINESS QUESTION
-- ============================================================
--
-- Which customers show unusually high transaction values
-- or high-value transaction activity?
--
-- ============================================================
-- ANALYTICAL APPROACH
-- ============================================================
--
-- The dataset contains an existing High_Value_Flag.
--
-- High_Value_Flag = 1 represents the high-value transaction
-- segment.
--
-- We also independently examine the transaction distribution
-- using the IQR method.
--
-- ============================================================


-- ============================================================
-- STEP 1: HIGH-VALUE TRANSACTION DISTRIBUTION
-- ============================================================

SELECT

    High_Value_Flag,

    COUNT(*) AS Transaction_Count,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS Transaction_Share_Percent,

    ROUND(
        SUM(Amount),
        2
    ) AS Total_Transaction_Value,

    ROUND(
        AVG(Amount),
        2
    ) AS Average_Transaction_Value,

    ROUND(
        MIN(Amount),
        2
    ) AS Minimum_Transaction_Value,

    ROUND(
        MAX(Amount),
        2
    ) AS Maximum_Transaction_Value

FROM transactions

GROUP BY High_Value_Flag

ORDER BY High_Value_Flag;


-- ============================================================
-- STEP 2: CUSTOMER-LEVEL HIGH-VALUE ACTIVITY
-- ============================================================
--
-- Identify customers generating high-value transactions.
--
-- ============================================================

WITH customer_transactions AS (

    SELECT

        a.Customer_ID,

        COUNT(t.Transaction_ID)
            AS Total_Transactions,

        SUM(t.Amount)
            AS Total_Transaction_Value,

        AVG(t.Amount)
            AS Average_Transaction_Value,

        MAX(t.Amount)
            AS Maximum_Transaction_Value,

        SUM(
            CASE
                WHEN t.High_Value_Flag = 1
                THEN 1
                ELSE 0
            END
        ) AS High_Value_Transaction_Count

    FROM accounts a

    INNER JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY a.Customer_ID
)

SELECT

    c.Customer_ID,

    c.Name,

    c.City,

    c.Occupation,

    ROUND(
        c.Annual_Income,
        2
    ) AS Annual_Income,

    c.Credit_Score,

    ct.Total_Transactions,

    ROUND(
        ct.Total_Transaction_Value,
        2
    ) AS Total_Transaction_Value,

    ROUND(
        ct.Average_Transaction_Value,
        2
    ) AS Average_Transaction_Value,

    ROUND(
        ct.Maximum_Transaction_Value,
        2
    ) AS Maximum_Transaction_Value,

    ct.High_Value_Transaction_Count,

    ROUND(

        ct.High_Value_Transaction_Count
        * 100.0
        / ct.Total_Transactions,

        2

    ) AS High_Value_Transaction_Share

FROM customer_transactions ct

INNER JOIN customers c
    ON ct.Customer_ID = c.Customer_ID

WHERE ct.High_Value_Transaction_Count > 0

ORDER BY

    ct.High_Value_Transaction_Count DESC,

    ct.Total_Transaction_Value DESC;


-- ============================================================
-- STEP 3: TOP CUSTOMERS BY TOTAL TRANSACTION VALUE
-- ============================================================

SELECT

    a.Customer_ID,

    c.Name,

    c.City,

    c.Occupation,

    COUNT(t.Transaction_ID)
        AS Transaction_Count,

    ROUND(
        SUM(t.Amount),
        2
    ) AS Total_Transaction_Value,

    ROUND(
        AVG(t.Amount),
        2
    ) AS Average_Transaction_Value,

    ROUND(
        MAX(t.Amount),
        2
    ) AS Maximum_Transaction_Value

FROM accounts a

INNER JOIN transactions t
    ON a.Account_ID = t.Account_ID

INNER JOIN customers c
    ON a.Customer_ID = c.Customer_ID

GROUP BY

    a.Customer_ID,
    c.Name,
    c.City,
    c.Occupation

ORDER BY Total_Transaction_Value DESC

LIMIT 20;


-- ============================================================
-- STEP 4: TOP CUSTOMERS BY HIGH-VALUE TRANSACTION COUNT
-- ============================================================

SELECT

    a.Customer_ID,

    c.Name,

    c.City,

    c.Occupation,

    COUNT(t.Transaction_ID)
        AS Total_Transactions,

    SUM(
        CASE
            WHEN t.High_Value_Flag = 1
            THEN 1
            ELSE 0
        END
    ) AS High_Value_Transaction_Count,

    ROUND(
        SUM(
            CASE
                WHEN t.High_Value_Flag = 1
                THEN t.Amount
                ELSE 0
            END
        ),
        2
    ) AS High_Value_Transaction_Total,

    ROUND(
        SUM(t.Amount),
        2
    ) AS Total_Transaction_Value

FROM accounts a

INNER JOIN transactions t
    ON a.Account_ID = t.Account_ID

INNER JOIN customers c
    ON a.Customer_ID = c.Customer_ID

GROUP BY

    a.Customer_ID,
    c.Name,
    c.City,
    c.Occupation

HAVING High_Value_Transaction_Count > 0

ORDER BY

    High_Value_Transaction_Count DESC,

    High_Value_Transaction_Total DESC

LIMIT 20;


-- ============================================================
-- VALIDATION 1
-- ============================================================
--
-- Verify total transaction count.
--
-- ============================================================

SELECT

    COUNT(*) AS Total_Transactions,

    SUM(
        CASE
            WHEN High_Value_Flag = 1
            THEN 1
            ELSE 0
        END
    ) AS High_Value_Transactions,

    SUM(
        CASE
            WHEN High_Value_Flag = 0
            THEN 1
            ELSE 0
        END
    ) AS Normal_Transactions

FROM transactions;


-- Expected:
--
-- Total Transactions       = 50,000
-- High-Value Transactions  = 500
-- Normal Transactions      = 49,500
--
-- ============================================================


-- ============================================================
-- VALIDATION 2
-- ============================================================
--
-- Check whether the high-value flag corresponds to the
-- upper end of the transaction distribution.
--
-- ============================================================

SELECT

    MIN(
        CASE
            WHEN High_Value_Flag = 1
            THEN Amount
        END
    ) AS Minimum_High_Value_Transaction,

    MAX(
        CASE
            WHEN High_Value_Flag = 0
            THEN Amount
        END
    ) AS Maximum_Normal_Transaction,

    MAX(Amount)
        AS Maximum_Transaction

FROM transactions;


-- ============================================================
-- VALIDATION 3
-- ============================================================
--
-- Independent IQR outlier check.
--
-- ============================================================

WITH quartiles AS (

    SELECT

        (
            SELECT Amount
            FROM transactions
            ORDER BY Amount
            LIMIT 1 OFFSET 12499
        ) AS Q1,

        (
            SELECT Amount
            FROM transactions
            ORDER BY Amount
            LIMIT 1 OFFSET 37499
        ) AS Q3
),

threshold AS (

    SELECT

        Q1,

        Q3,

        Q3 - Q1 AS IQR,

        Q3 + 1.5 * (Q3 - Q1)
            AS Upper_Outlier_Threshold

    FROM quartiles
)

SELECT

    ROUND(Q1, 2) AS Q1,

    ROUND(Q3, 2) AS Q3,

    ROUND(IQR, 2) AS IQR,

    ROUND(
        Upper_Outlier_Threshold,
        2
    ) AS Upper_Outlier_Threshold,

    (
        SELECT COUNT(*)
        FROM transactions t
        WHERE t.Amount > threshold.Upper_Outlier_Threshold
    ) AS Statistical_Outlier_Count

FROM threshold;


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- The dataset contains 50,000 transactions.
--
-- 500 transactions (1%) are flagged as high-value.
--
-- High-value transactions have an average value of
-- approximately ₹990,451.81 compared with approximately
-- ₹257,960.35 for non-high-value transactions.
--
-- The high-value segment represents approximately
-- ₹495.23 million in transaction value.
--
-- An independent IQR analysis produces an upper outlier
-- threshold of approximately ₹1.224 million.
--
-- Since the maximum transaction is approximately
-- ₹1.0 million, the dataset does not contain statistical
-- IQR outliers under the 1.5 × IQR rule.
--
-- Therefore, the analysis uses the dataset's High_Value_Flag
-- as the operational definition of high-value activity rather
-- than incorrectly labeling transactions as statistical
-- outliers.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- Customers with repeated high-value transactions should
-- receive additional relationship and risk review.
--
-- Potential actions include:
--
-- 1. Premium relationship management
-- 2. Transaction monitoring
-- 3. Customer profiling
-- 4. Large-value transaction alerts
-- 5. Personalized banking services
--
-- High-value activity alone must NOT be interpreted as fraud.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Transaction amount alone does not establish fraudulent
-- behavior.
--
-- The High_Value_Flag is treated as an existing dataset
-- classification.
--
-- The dataset does not provide:
--
-- - Merchant information
-- - Customer transaction history outside the dataset
-- - Device information
-- - Geographic transaction details
-- - Fraud labels
-- - Authentication information
--
-- Therefore this analysis identifies high-value behavior,
-- not fraudulent transactions.
--
-- ============================================================
-- VALIDATION STATUS
-- ============================================================
--
-- Total transactions: 50,000
-- High-value transactions: 500
-- Normal transactions: 49,500
--
-- IQR statistical outliers: expected 0
--
-- Validation: PASSED
--
-- ============================================================