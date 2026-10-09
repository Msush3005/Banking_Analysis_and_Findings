USE banking_analytics_db;

-- ============================================================
-- Q10: LOAN-TO-INCOME RATIO ANALYSIS
-- Business Question:
-- How does loan-to-income ratio vary across income bands
-- and occupations?
-- ============================================================


-- ------------------------------------------------------------
-- 1. Customer Income Bands + Approved Loan Exposure
-- ------------------------------------------------------------

WITH customer_loan_profile AS (

    SELECT

        l.Customer_ID,

        SUM(
            CASE
                WHEN l.Loan_Status = 'Approved'
                THEN l.Loan_Amount
                ELSE 0
            END
        ) AS Approved_Loan_Amount,

        COUNT(
            CASE
                WHEN l.Loan_Status = 'Approved'
                THEN l.Loan_ID
            END
        ) AS Approved_Loan_Count

    FROM loans l

    GROUP BY
        l.Customer_ID
),

customer_profile AS (

    SELECT

        c.Customer_ID,

        c.Occupation,

        c.Annual_Income,

        c.Credit_Score,

        COALESCE(
            clp.Approved_Loan_Amount,
            0
        ) AS Approved_Loan_Amount,

        COALESCE(
            clp.Approved_Loan_Count,
            0
        ) AS Approved_Loan_Count

    FROM customers c

    LEFT JOIN customer_loan_profile clp
        ON c.Customer_ID = clp.Customer_ID
)

SELECT

    CASE

        WHEN Annual_Income <= 917407
            THEN 'Lower Income'

        WHEN Annual_Income <= 1620501
            THEN 'Mid-Lower Income'

        WHEN Annual_Income <= 2321894
            THEN 'Mid-Upper Income'

        ELSE 'Higher Income'

    END AS Income_Band,

    COUNT(*) AS Customer_Count,

    SUM(Approved_Loan_Count)
        AS Approved_Loan_Count,

    ROUND(
        SUM(Approved_Loan_Amount),
        2
    ) AS Total_Approved_Loan_Amount,

    ROUND(
        AVG(
            CASE
                WHEN Approved_Loan_Count > 0
                THEN Approved_Loan_Amount / Annual_Income
            END
        ),
        4
    ) AS Average_Loan_to_Income_Ratio,

    ROUND(
        MAX(
            CASE
                WHEN Approved_Loan_Count > 0
                THEN Approved_Loan_Amount / Annual_Income
            END
        ),
        4
    ) AS Maximum_Loan_to_Income_Ratio

FROM customer_profile

GROUP BY Income_Band

ORDER BY
    Average_Loan_to_Income_Ratio DESC;


-- ------------------------------------------------------------
-- 2. Loan-to-Income Ratio by Occupation
-- ------------------------------------------------------------

WITH customer_loan_profile AS (

    SELECT

        Customer_ID,

        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Loan_Amount
                ELSE 0
            END
        ) AS Approved_Loan_Amount,

        COUNT(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Loan_ID
            END
        ) AS Approved_Loan_Count

    FROM loans

    GROUP BY Customer_ID
)

SELECT

    c.Occupation,

    COUNT(*) AS Customer_Count,

    SUM(
        COALESCE(
            clp.Approved_Loan_Count,
            0
        )
    ) AS Approved_Loan_Count,

    ROUND(
        SUM(
            COALESCE(
                clp.Approved_Loan_Amount,
                0
            )
        ),
        2
    ) AS Total_Approved_Loan_Amount,

    ROUND(
        AVG(
            CASE
                WHEN COALESCE(
                    clp.Approved_Loan_Count,
                    0
                ) > 0

                THEN clp.Approved_Loan_Amount
                     / c.Annual_Income
            END
        ),
        4
    ) AS Average_Loan_to_Income_Ratio,

    ROUND(
        MAX(
            CASE
                WHEN COALESCE(
                    clp.Approved_Loan_Count,
                    0
                ) > 0

                THEN clp.Approved_Loan_Amount
                     / c.Annual_Income
            END
        ),
        4
    ) AS Maximum_Loan_to_Income_Ratio

FROM customers c

LEFT JOIN customer_loan_profile clp
    ON c.Customer_ID = clp.Customer_ID

GROUP BY
    c.Occupation

ORDER BY
    Average_Loan_to_Income_Ratio DESC;


-- ------------------------------------------------------------
-- 3. Customer-Level Highest Loan-to-Income Ratios
-- ------------------------------------------------------------

SELECT

    c.Customer_ID,

    c.Name,

    c.Occupation,

    ROUND(
        c.Annual_Income,
        2
    ) AS Annual_Income,

    ROUND(
        SUM(l.Loan_Amount),
        2
    ) AS Approved_Loan_Amount,

    ROUND(
        SUM(l.Loan_Amount)
        / c.Annual_Income,
        4
    ) AS Loan_to_Income_Ratio,

    c.Credit_Score

FROM customers c

INNER JOIN loans l
    ON c.Customer_ID = l.Customer_ID

WHERE l.Loan_Status = 'Approved'

GROUP BY

    c.Customer_ID,
    c.Name,
    c.Occupation,
    c.Annual_Income,
    c.Credit_Score

ORDER BY
    Loan_to_Income_Ratio DESC

LIMIT 20;


-- ------------------------------------------------------------
-- 4. Validation
-- ------------------------------------------------------------

SELECT

    COUNT(*) AS Approved_Loan_Count,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Total_Approved_Loan_Exposure,

    ROUND(
        MIN(Loan_Amount),
        2
    ) AS Minimum_Approved_Loan,

    ROUND(
        MAX(Loan_Amount),
        2
    ) AS Maximum_Approved_Loan

FROM loans

WHERE Loan_Status = 'Approved';


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- To be completed after executing the analysis.
--
-- Loan-to-income ratio measures approved loan exposure
-- relative to annual income.
--
-- Higher ratios indicate greater loan exposure relative
-- to reported annual income.
--
-- The analysis compares this ratio across income bands
-- and occupations to identify where loan exposure is
-- relatively higher.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- Management can use the analysis to:
--
-- 1. Identify income segments with relatively high
--    loan exposure.
--
-- 2. Investigate occupations with elevated average
--    loan-to-income ratios.
--
-- 3. Prioritize those segments for credit-risk monitoring.
--
-- 4. Combine LTI with credit score and other risk
--    indicators before making lending decisions.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Loan-to-income ratio is NOT the same as debt-service
-- ratio or probability of default.
--
-- The dataset does not provide:
--
-- - Existing debt outside the bank
-- - Monthly EMI
-- - Household expenses
-- - Other financial obligations
-- - Employment stability
-- - Actual repayment behavior
--
-- Therefore LTI should be treated as an exposure indicator,
-- not a standalone credit-risk decision metric.
--
-- ============================================================
-- VALIDATION STATUS
-- ============================================================
--
-- The approved loan count and total approved exposure from
-- the analysis should reconcile with the validation query.
--
-- ============================================================