-- ============================================================
-- BANKING ANALYTICS PORTFOLIO
-- Q03: HIGH-INCOME CUSTOMERS WITH LOW BALANCE
--     OR LOW TRANSACTION ENGAGEMENT
-- ============================================================

-- ============================================================
-- BUSINESS QUESTION
-- ============================================================
--
-- Which customers have high income but low account balances
-- or low engagement?
--
-- ============================================================
-- BUSINESS DEFINITIONS
-- ============================================================
--
-- HIGH INCOME:
-- Annual_Income > 2,321,894
--
-- This represents the top income quartile identified from
-- the customer income distribution.
--
--
-- LOW ACCOUNT BALANCE:
-- Total account balance <= 674,905
--
-- This represents the bottom balance quartile among
-- customers with accounts.
--
--
-- LOW ENGAGEMENT:
-- Total transaction count <= 8
--
-- This represents the bottom transaction quartile.
--
-- Customers with zero transactions are included.
--
-- ============================================================
-- BUSINESS LOGIC
-- ============================================================
--
-- Identify customers who satisfy:
--
-- High Income
-- AND
-- (
--      Low Balance
--      OR
--      Low Transaction Engagement
-- )
--
-- ============================================================


USE banking_analytics_db;


-- ============================================================
-- STEP 1: CUSTOMER ACCOUNT BALANCES
-- ============================================================

WITH customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Account_Balance,
        COUNT(Account_ID) AS Account_Count

    FROM accounts

    GROUP BY Customer_ID
),


-- ============================================================
-- STEP 2: CUSTOMER TRANSACTION ENGAGEMENT
-- ============================================================

customer_engagement AS (

    SELECT
        a.Customer_ID,
        COUNT(t.Transaction_ID) AS Transaction_Count,
        COALESCE(SUM(t.Amount), 0) AS Total_Transaction_Value

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY a.Customer_ID
)


-- ============================================================
-- STEP 3: IDENTIFY TARGET CUSTOMERS
-- ============================================================

SELECT

    c.Customer_ID,

    c.Name,

    c.City,

    c.Occupation,

    ROUND(c.Annual_Income, 2)
        AS Annual_Income,

    c.Credit_Score,

    ROUND(
        COALESCE(cb.Total_Account_Balance, 0),
        2
    ) AS Total_Account_Balance,

    COALESCE(
        cb.Account_Count,
        0
    ) AS Account_Count,

    COALESCE(
        ce.Transaction_Count,
        0
    ) AS Transaction_Count,

    ROUND(
        COALESCE(
            ce.Total_Transaction_Value,
            0
        ),
        2
    ) AS Total_Transaction_Value,

    CASE

        WHEN COALESCE(cb.Total_Account_Balance, 0)
             <= 674905

             AND COALESCE(ce.Transaction_Count, 0)
             <= 8

            THEN 'Low Balance + Low Engagement'

        WHEN COALESCE(cb.Total_Account_Balance, 0)
             <= 674905

            THEN 'Low Balance'

        WHEN COALESCE(ce.Transaction_Count, 0)
             <= 8

            THEN 'Low Engagement'

        ELSE 'Neither'

    END AS Customer_Risk_Flag

FROM customers c

LEFT JOIN customer_balances cb
    ON c.Customer_ID = cb.Customer_ID

LEFT JOIN customer_engagement ce
    ON c.Customer_ID = ce.Customer_ID


WHERE c.Annual_Income > 2321894

  AND (
        COALESCE(cb.Total_Account_Balance, 0)
            <= 674905

        OR

        COALESCE(ce.Transaction_Count, 0)
            <= 8
      )


ORDER BY
    c.Annual_Income DESC;


-- ============================================================
-- VALIDATION 1
-- ============================================================
--
-- Count customers by the identified issue.
--
-- ============================================================

WITH customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Account_Balance
    FROM accounts
    GROUP BY Customer_ID
),

customer_engagement AS (

    SELECT
        a.Customer_ID,
        COUNT(t.Transaction_ID) AS Transaction_Count
    FROM accounts a
    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID
    GROUP BY a.Customer_ID
),

target_customers AS (

    SELECT

        c.Customer_ID,

        COALESCE(
            cb.Total_Account_Balance,
            0
        ) AS Total_Account_Balance,

        COALESCE(
            ce.Transaction_Count,
            0
        ) AS Transaction_Count

    FROM customers c

    LEFT JOIN customer_balances cb
        ON c.Customer_ID = cb.Customer_ID

    LEFT JOIN customer_engagement ce
        ON c.Customer_ID = ce.Customer_ID

    WHERE c.Annual_Income > 2321894

      AND (
            COALESCE(cb.Total_Account_Balance, 0)
                <= 674905

            OR

            COALESCE(ce.Transaction_Count, 0)
                <= 8
          )
)

SELECT

    COUNT(*) AS Target_Customer_Count,

    SUM(
        CASE
            WHEN Total_Account_Balance <= 674905
            THEN 1
            ELSE 0
        END
    ) AS Low_Balance_Customers,

    SUM(
        CASE
            WHEN Transaction_Count <= 8
            THEN 1
            ELSE 0
        END
    ) AS Low_Engagement_Customers,

    SUM(
        CASE
            WHEN Total_Account_Balance <= 674905
             AND Transaction_Count <= 8
            THEN 1
            ELSE 0
        END
    ) AS Both_Low_Balance_And_Engagement

FROM target_customers;


-- ============================================================
-- VALIDATION 2
-- ============================================================
--
-- Confirm that all returned customers satisfy the
-- high-income condition.
--
-- ============================================================

WITH customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Account_Balance
    FROM accounts
    GROUP BY Customer_ID
),

customer_engagement AS (

    SELECT
        a.Customer_ID,
        COUNT(t.Transaction_ID) AS Transaction_Count
    FROM accounts a
    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID
    GROUP BY a.Customer_ID
)

SELECT

    MIN(c.Annual_Income)
        AS Minimum_Returned_Income,

    MAX(c.Annual_Income)
        AS Maximum_Returned_Income,

    MIN(
        COALESCE(cb.Total_Account_Balance, 0)
    ) AS Minimum_Returned_Balance,

    MIN(
        COALESCE(ce.Transaction_Count, 0)
    ) AS Minimum_Returned_Transactions

FROM customers c

LEFT JOIN customer_balances cb
    ON c.Customer_ID = cb.Customer_ID

LEFT JOIN customer_engagement ce
    ON c.Customer_ID = ce.Customer_ID

WHERE c.Annual_Income > 2321894

  AND (
        COALESCE(cb.Total_Account_Balance, 0)
            <= 674905

        OR

        COALESCE(ce.Transaction_Count, 0)
            <= 8
      );


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- To be completed after executing the analysis.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- High-income customers with low balances or low engagement
-- should be investigated for:
--
-- - Dormant or underutilized relationships
-- - Salary/account migration opportunities
-- - Investment or savings opportunities
-- - Personalized account products
-- - Digital engagement campaigns
--
-- The appropriate action should depend on the customer's
-- actual behavior and financial profile.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- High income does not necessarily mean high customer value.
--
-- Low engagement is measured using transaction count only.
-- It does not capture login frequency, card usage, digital
-- activity, customer service interactions or other behaviors
-- not present in the dataset.
--
-- Low balance is based on current account balance and does
-- not measure assets held outside the bank.
--
-- ============================================================