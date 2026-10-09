USE banking_analytics_db;

-- ============================================================
-- Q09: LOAN TYPE PERFORMANCE
-- Business Question:
-- Which loan types have the highest approval volume
-- and loan exposure?
-- ============================================================


-- ------------------------------------------------------------
-- 1. Loan Type Overview
-- ------------------------------------------------------------

SELECT

    Loan_Type,

    COUNT(*) AS Total_Applications,

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
    ) AS Pending_Loans,

    ROUND(
        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Approval_Rate_Percent,

    ROUND(
        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS Approved_Loan_Exposure,

    ROUND(
        AVG(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Loan_Amount
            END
        ),
        2
    ) AS Average_Approved_Loan,

    ROUND(
        AVG(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Interest_Rate
            END
        ),
        2
    ) AS Average_Approved_Interest_Rate

FROM loans

GROUP BY
    Loan_Type

ORDER BY
    Approved_Loan_Exposure DESC;


-- ------------------------------------------------------------
-- 2. Loan Type Exposure Share
-- ------------------------------------------------------------

WITH loan_type_summary AS (

    SELECT

        Loan_Type,

        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Loan_Amount
                ELSE 0
            END
        ) AS Approved_Exposure

    FROM loans

    GROUP BY
        Loan_Type
)

SELECT

    Loan_Type,

    ROUND(
        Approved_Exposure,
        2
    ) AS Approved_Loan_Exposure,

    ROUND(
        Approved_Exposure * 100.0
        / SUM(Approved_Exposure) OVER (),
        2
    ) AS Exposure_Share_Percent

FROM loan_type_summary

ORDER BY
    Approved_Exposure DESC;


-- ------------------------------------------------------------
-- 3. Loan Type Approval Ranking
-- ------------------------------------------------------------

SELECT

    Loan_Type,

    COUNT(*) AS Total_Applications,

    SUM(
        CASE
            WHEN Loan_Status = 'Approved'
            THEN 1
            ELSE 0
        END
    ) AS Approved_Loans,

    ROUND(
        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Approval_Rate_Percent

FROM loans

GROUP BY
    Loan_Type

ORDER BY
    Approval_Rate_Percent DESC;


-- ------------------------------------------------------------
-- 4. Overall Loan Validation
-- ------------------------------------------------------------

SELECT

    COUNT(*) AS Total_Loan_Applications,

    SUM(
        CASE
            WHEN Loan_Status = 'Approved'
            THEN 1
            ELSE 0
        END
    ) AS Total_Approved_Loans,

    SUM(
        CASE
            WHEN Loan_Status = 'Rejected'
            THEN 1
            ELSE 0
        END
    ) AS Total_Rejected_Loans,

    SUM(
        CASE
            WHEN Loan_Status = 'Pending'
            THEN 1
            ELSE 0
        END
    ) AS Total_Pending_Loans,

    ROUND(
        SUM(
            CASE
                WHEN Loan_Status = 'Approved'
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS Total_Approved_Exposure

FROM loans;


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- To be completed after executing the analysis.
--
-- The analysis compares loan types by approval volume,
-- approval rate and approved loan exposure.
--
-- The loan type with the highest exposure represents the
-- largest concentration of approved lending capital.
--
-- The loan type with the highest approval rate indicates
-- stronger approval conversion within the observed dataset.
--
-- These are different measures and should not be treated
-- as the same indicator of loan performance.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- Management can use the analysis to:
--
-- 1. Monitor concentration of lending exposure.
-- 2. Compare approval rates across loan products.
-- 3. Review products with unusually high rejection rates.
-- 4. Assess whether lending exposure is concentrated in
--    a particular loan category.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Approval rate does not measure loan profitability,
-- repayment performance or default risk.
--
-- Loan exposure represents approved principal amounts and
-- does not represent expected losses or revenue.
--
-- ============================================================
-- VALIDATION
-- ============================================================
--
-- Loan-type totals must reconcile to the overall loan totals
-- returned by the validation query.
--
-- ============================================================