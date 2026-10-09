-- ============================================================
-- BANKING ANALYTICS PORTFOLIO
-- Q04: CUSTOMER CROSS-SELL OPPORTUNITY
-- ============================================================

USE banking_analytics_db;


-- ============================================================
-- BUSINESS QUESTION
-- ============================================================
--
-- Which customers have accounts but no approved loan,
-- and which customers represent stronger cross-sell
-- opportunities?
--
-- ============================================================


-- ============================================================
-- BUSINESS DEFINITIONS
-- ============================================================
--
-- CROSS-SELL POPULATION:
-- Customers with at least one account and no approved loan.
--
-- HIGH PRIORITY:
-- Customers with:
--   1. No approved loan
--   2. Strong account balance
--   3. Strong income
--   4. Good credit score
--
-- NOTE:
-- The dataset does not contain loan eligibility rules,
-- customer preferences, employment stability or debt
-- obligations. Therefore this is an opportunity ranking,
-- NOT a loan approval recommendation.
--
-- ============================================================


-- ============================================================
-- STEP 1: CUSTOMER ACCOUNT PROFILE
-- ============================================================

WITH customer_accounts AS (

    SELECT

        Customer_ID,

        COUNT(Account_ID) AS Account_Count,

        SUM(Balance) AS Total_Account_Balance,

        AVG(Balance) AS Average_Account_Balance,

        COUNT(
            DISTINCT Account_Type
        ) AS Distinct_Account_Types

    FROM accounts

    GROUP BY Customer_ID
),


-- ============================================================
-- STEP 2: LOAN PROFILE
-- ============================================================

customer_loans AS (

    SELECT

        Customer_ID,

        COUNT(Loan_ID) AS Total_Loan_Applications,

        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN 1
                ELSE 0
            END
        ) AS Approved_Loans,

        SUM(
            CASE
                WHEN Loan_Status = 'Rejected'
                THEN 1
                ELSE 0
            END
        ) AS Rejected_Loans,

        SUM(
            CASE
                WHEN Loan_Status = 'Pending'
                THEN 1
                ELSE 0
            END
        ) AS Pending_Loans

    FROM loans

    GROUP BY Customer_ID
)


-- ============================================================
-- STEP 3: IDENTIFY CROSS-SELL CUSTOMERS
-- ============================================================

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

    ca.Account_Count,

    ROUND(
        ca.Total_Account_Balance,
        2
    ) AS Total_Account_Balance,

    ROUND(
        ca.Average_Account_Balance,
        2
    ) AS Average_Account_Balance,

    ca.Distinct_Account_Types,

    COALESCE(
        cl.Total_Loan_Applications,
        0
    ) AS Total_Loan_Applications,

    COALESCE(
        cl.Rejected_Loans,
        0
    ) AS Rejected_Loans,

    COALESCE(
        cl.Pending_Loans,
        0
    ) AS Pending_Loans,


    CASE

        WHEN c.Credit_Score >= 750
         AND c.Annual_Income >= 2000000
         AND ca.Total_Account_Balance >= 1000000

            THEN 'High Priority'

        WHEN c.Credit_Score >= 700
         AND c.Annual_Income >= 1500000
         AND ca.Total_Account_Balance >= 500000

            THEN 'Medium Priority'

        ELSE 'Low Priority'

    END AS Cross_Sell_Priority


FROM customers c

INNER JOIN customer_accounts ca
    ON c.Customer_ID = ca.Customer_ID

LEFT JOIN customer_loans cl
    ON c.Customer_ID = cl.Customer_ID


WHERE NOT EXISTS (

    SELECT 1

    FROM loans l

    WHERE l.Customer_ID = c.Customer_ID

      AND l.Loan_Status = 'Approved'
)


ORDER BY

    CASE

        WHEN c.Credit_Score >= 750
         AND c.Annual_Income >= 2000000
         AND ca.Total_Account_Balance >= 1000000
            THEN 1

        WHEN c.Credit_Score >= 700
         AND c.Annual_Income >= 1500000
         AND ca.Total_Account_Balance >= 500000
            THEN 2

        ELSE 3

    END,

    ca.Total_Account_Balance DESC,

    c.Annual_Income DESC;


-- ============================================================
-- VALIDATION 1
-- ============================================================
-- Count customers by cross-sell priority.
-- ============================================================

WITH customer_accounts AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Account_Balance
    FROM accounts
    GROUP BY Customer_ID
)

SELECT

    CASE

        WHEN c.Credit_Score >= 750
         AND c.Annual_Income >= 2000000
         AND ca.Total_Account_Balance >= 1000000
            THEN 'High Priority'

        WHEN c.Credit_Score >= 700
         AND c.Annual_Income >= 1500000
         AND ca.Total_Account_Balance >= 500000
            THEN 'Medium Priority'

        ELSE 'Low Priority'

    END AS Cross_Sell_Priority,

    COUNT(*) AS Customer_Count

FROM customers c

INNER JOIN customer_accounts ca
    ON c.Customer_ID = ca.Customer_ID

WHERE NOT EXISTS (

    SELECT 1
    FROM loans l
    WHERE l.Customer_ID = c.Customer_ID
      AND l.Loan_Status = 'Approved'
)

GROUP BY Cross_Sell_Priority

ORDER BY Customer_Count DESC;


-- ============================================================
-- VALIDATION 2
-- ============================================================
-- Validate that no returned customer has an approved loan.
-- ============================================================

SELECT

    COUNT(*) AS Customers_With_Approved_Loan

FROM customers c

INNER JOIN accounts a
    ON c.Customer_ID = a.Customer_ID

WHERE NOT EXISTS (

    SELECT 1

    FROM loans l

    WHERE l.Customer_ID = c.Customer_ID

      AND l.Loan_Status = 'Approved'
);


-- Expected:
-- This count represents the complete cross-sell population.
-- It should match the 3,441 customers identified earlier.
--
-- ============================================================


-- ============================================================
-- VALIDATION 3
-- ============================================================
-- Financial size of cross-sell population.
-- ============================================================

SELECT

    COUNT(DISTINCT a.Customer_ID)
        AS Cross_Sell_Customers,

    ROUND(
        SUM(a.Balance),
        2
    ) AS Total_Balance,

    ROUND(
        AVG(a.Balance),
        2
    ) AS Average_Account_Balance,

    ROUND(
        MIN(a.Balance),
        2
    ) AS Minimum_Account_Balance,

    ROUND(
        MAX(a.Balance),
        2
    ) AS Maximum_Account_Balance

FROM accounts a

WHERE NOT EXISTS (

    SELECT 1

    FROM loans l

    WHERE l.Customer_ID = a.Customer_ID

      AND l.Loan_Status = 'Approved'
);


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- Initial analysis identified 3,441 customers with accounts
-- but no approved loan.
--
-- These customers collectively represent approximately
-- ₹5.55 billion in account balances.
--
-- This indicates a potentially significant cross-sell
-- population for loan products.
--
-- However, the population should not be treated as uniformly
-- eligible or equally valuable.
--
-- Customers should be prioritized using observable indicators
-- such as income, credit score and existing account balances.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- 1. Prioritize financially stronger customers for
--    personalized loan-product campaigns.
--
-- 2. Separate customers with rejected or pending loan
--    applications from customers with no loan history.
--
-- 3. Investigate whether high-balance customers are
--    underserved by current product offerings.
--
-- 4. Use customer occupation, city and income to tailor
--    appropriate loan-product campaigns.
--
-- 5. Do not automatically target rejected customers with
--    another loan offer without understanding the reason
--    for rejection.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Cross-sell priority is an analytical opportunity score,
-- not a credit underwriting decision.
--
-- The dataset does not provide:
--
-- - Debt obligations
-- - Existing loans outside the bank
-- - Customer loan preferences
-- - Employment stability
-- - Loan eligibility rules
-- - Customer consent
-- - Risk policy thresholds
--
-- Therefore the analysis identifies potential opportunities
-- rather than recommending actual loan approvals.
--
-- ============================================================
-- VALIDATION STATUS
-- ============================================================
--
-- Cross-sell population identified: 3,441
-- Total balance represented: ₹5,551,074,594
-- Average account balance: ₹835,501.90
--
-- Further validation:
-- Priority distribution
-- Approved-loan exclusion
-- Financial exposure
--
-- ============================================================