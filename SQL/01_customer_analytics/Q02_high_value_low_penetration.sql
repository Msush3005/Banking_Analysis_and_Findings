-- ============================================================
-- BANKING ANALYTICS PORTFOLIO
-- Q02: HIGH-VALUE CUSTOMERS WITH LOW PRODUCT PENETRATION
-- ============================================================

-- ============================================================
-- BUSINESS QUESTION
-- ============================================================
--
-- Which customers are high-value but have low product
-- penetration?
--
-- ============================================================
-- BUSINESS DEFINITIONS
-- ============================================================
--
-- HIGH-VALUE CUSTOMER:
--
-- Customer's total account balance is in the top 25%
-- of customers with accounts.
--
-- Q3 balance threshold:
-- 4,599,464
--
--
-- LOW PRODUCT PENETRATION:
--
-- Customer has:
--
-- 1. Exactly one distinct account type
-- 2. No approved loan
--
-- Account types:
-- Savings
-- Current
--
-- Loan product:
-- Approved loan
--
-- ============================================================
-- BUSINESS PURPOSE
-- ============================================================
--
-- Identify financially valuable customers who currently
-- use a limited number of banking products.
--
-- These customers represent potential cross-sell targets.
--
-- ============================================================


USE banking_analytics_db;


-- ============================================================
-- STEP 1: CALCULATE CUSTOMER ACCOUNT BALANCES
-- ============================================================

WITH customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Balance
    FROM accounts
    GROUP BY Customer_ID
),


-- ============================================================
-- STEP 2: CALCULATE ACCOUNT PRODUCT PENETRATION
-- ============================================================

account_products AS (

    SELECT
        Customer_ID,

        COUNT(DISTINCT Account_Type)
            AS Distinct_Account_Types,

        COUNT(*) AS Total_Accounts

    FROM accounts

    GROUP BY Customer_ID
),


-- ============================================================
-- STEP 3: CALCULATE APPROVED LOANS
-- ============================================================

approved_loans AS (

    SELECT
        Customer_ID,

        COUNT(*) AS Approved_Loan_Count

    FROM loans

    WHERE Loan_Status = 'Approved'

    GROUP BY Customer_ID
)


-- ============================================================
-- STEP 4: IDENTIFY HIGH-VALUE / LOW-PENETRATION CUSTOMERS
-- ============================================================

SELECT

    c.Customer_ID,

    c.Name,

    c.City,

    c.Occupation,

    c.Annual_Income,

    c.Credit_Score,

    ROUND(cb.Total_Balance, 2)
        AS Total_Account_Balance,

    ap.Total_Accounts,

    ap.Distinct_Account_Types,

    COALESCE(
        al.Approved_Loan_Count,
        0
    ) AS Approved_Loan_Count,

    CASE

        WHEN ap.Distinct_Account_Types = 1
             AND COALESCE(al.Approved_Loan_Count, 0) = 0

        THEN 'Low Product Penetration'

        ELSE 'Higher Product Penetration'

    END AS Product_Penetration_Status

FROM customers c

INNER JOIN customer_balances cb

    ON c.Customer_ID = cb.Customer_ID

INNER JOIN account_products ap

    ON c.Customer_ID = ap.Customer_ID

LEFT JOIN approved_loans al

    ON c.Customer_ID = al.Customer_ID


WHERE cb.Total_Balance >= 4599464

  AND ap.Distinct_Account_Types = 1

  AND COALESCE(
        al.Approved_Loan_Count,
        0
      ) = 0


ORDER BY
    cb.Total_Balance DESC;


-- ============================================================
-- VALIDATION 1
-- ============================================================
--
-- Count identified high-value / low-penetration customers.
--
-- ============================================================

WITH customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Balance
    FROM accounts
    GROUP BY Customer_ID
),

account_products AS (

    SELECT
        Customer_ID,
        COUNT(DISTINCT Account_Type)
            AS Distinct_Account_Types
    FROM accounts
    GROUP BY Customer_ID
),

approved_loans AS (

    SELECT
        Customer_ID,
        COUNT(*) AS Approved_Loan_Count
    FROM loans
    WHERE Loan_Status = 'Approved'
    GROUP BY Customer_ID
)

SELECT

    COUNT(*) AS High_Value_Low_Penetration_Customers,

    ROUND(
        SUM(cb.Total_Balance),
        2
    ) AS Total_Balance_Represented

FROM customer_balances cb

INNER JOIN account_products ap
    ON cb.Customer_ID = ap.Customer_ID

LEFT JOIN approved_loans al
    ON cb.Customer_ID = al.Customer_ID

WHERE cb.Total_Balance >= 4599464

  AND ap.Distinct_Account_Types = 1

  AND COALESCE(
        al.Approved_Loan_Count,
        0
      ) = 0;


-- ============================================================
-- VALIDATION 2
-- ============================================================
--
-- Confirm that every returned customer satisfies the
-- business rules.
--
-- Expected:
--
-- Total_Balance >= 4,599,464
-- Distinct_Account_Types = 1
-- Approved_Loan_Count = 0
--
-- ============================================================

WITH customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Balance
    FROM accounts
    GROUP BY Customer_ID
),

account_products AS (

    SELECT
        Customer_ID,
        COUNT(DISTINCT Account_Type)
            AS Distinct_Account_Types
    FROM accounts
    GROUP BY Customer_ID
),

approved_loans AS (

    SELECT
        Customer_ID,
        COUNT(*) AS Approved_Loan_Count
    FROM loans
    WHERE Loan_Status = 'Approved'
    GROUP BY Customer_ID
)

SELECT

    MIN(cb.Total_Balance) AS Minimum_Returned_Balance,

    MIN(ap.Distinct_Account_Types)
        AS Minimum_Account_Product_Count,

    MAX(ap.Distinct_Account_Types)
        AS Maximum_Account_Product_Count,

    MIN(
        COALESCE(al.Approved_Loan_Count, 0)
    ) AS Minimum_Approved_Loans,

    MAX(
        COALESCE(al.Approved_Loan_Count, 0)
    ) AS Maximum_Approved_Loans

FROM customer_balances cb

INNER JOIN account_products ap
    ON cb.Customer_ID = ap.Customer_ID

LEFT JOIN approved_loans al
    ON cb.Customer_ID = al.Customer_ID

WHERE cb.Total_Balance >= 4599464

  AND ap.Distinct_Account_Types = 1

  AND COALESCE(
        al.Approved_Loan_Count,
        0
      ) = 0;


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- To be completed after executing the analysis.
--
-- The analysis identifies customers holding at least
-- ₹4,599,464 in account balances while using only one
-- distinct account product and having no approved loan.
--
-- These customers represent potential cross-sell opportunities.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- Consider targeted offers for suitable products such as:
--
-- - Personal loans
-- - Home loans
-- - Car loans
-- - Additional account products
--
-- Any actual product recommendation should consider
-- customer credit quality, eligibility and affordability.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Product penetration is inferred from account types and
-- approved loans available in this dataset.
--
-- Other banking products such as credit cards, insurance,
-- investments or deposits outside the accounts table are
-- not available and therefore are not included.
--
-- High-value is based on account balance, not profitability,
-- revenue or customer lifetime value.
--
-- ============================================================