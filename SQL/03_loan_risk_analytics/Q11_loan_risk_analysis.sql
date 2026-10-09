USE banking_analytics_db;

-- ============================================================
-- Q11: LOAN RISK ANALYSIS
--
-- Business Question:
-- What share of approved loans are in High/Critical
-- risk bands?
--
-- IMPORTANT:
-- The source loans table does NOT contain a risk-band field.
-- Risk is therefore derived using:
--   1. Credit Score
--   2. Loan-to-Income Ratio
--
-- This is an analytical screening model, NOT a production
-- credit-underwriting model.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Build Risk Profile for Approved Loans
-- ------------------------------------------------------------

WITH loan_risk_profile AS (

    SELECT

        l.Loan_ID,

        l.Customer_ID,

        l.Loan_Type,

        l.Loan_Amount,

        l.Interest_Rate,

        c.Annual_Income,

        c.Credit_Score,

        ROUND(
            l.Loan_Amount / NULLIF(c.Annual_Income, 0),
            4
        ) AS Loan_to_Income_Ratio,

        -- Credit Score Risk Points
        CASE

            WHEN c.Credit_Score >= 750
                THEN 0

            WHEN c.Credit_Score >= 700
                THEN 1

            WHEN c.Credit_Score >= 650
                THEN 2

            ELSE 3

        END AS Credit_Risk_Points,

        -- Loan-to-Income Risk Points
        CASE

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 1
                THEN 0

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 2
                THEN 1

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 3
                THEN 2

            ELSE 3

        END AS LTI_Risk_Points

    FROM loans l

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE l.Loan_Status = 'Approved'
),


-- ------------------------------------------------------------
-- 2. Calculate Total Risk Score
-- ------------------------------------------------------------

risk_scored AS (

    SELECT

        *,

        Credit_Risk_Points
        + LTI_Risk_Points AS Total_Risk_Score

    FROM loan_risk_profile
),


-- ------------------------------------------------------------
-- 3. Assign Risk Bands
-- ------------------------------------------------------------

risk_banded AS (

    SELECT

        *,

        CASE

            WHEN Total_Risk_Score >= 6
                THEN 'Critical'

            WHEN Total_Risk_Score >= 4
                THEN 'High'

            WHEN Total_Risk_Score >= 2
                THEN 'Medium'

            ELSE 'Low'

        END AS Risk_Band

    FROM risk_scored
)


-- ------------------------------------------------------------
-- 4. Overall Risk Distribution
-- ------------------------------------------------------------

SELECT

    Risk_Band,

    COUNT(*) AS Approved_Loan_Count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS Loan_Share_Percent,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        SUM(Loan_Amount) * 100.0
        / SUM(SUM(Loan_Amount)) OVER (),
        2
    ) AS Exposure_Share_Percent,

    ROUND(
        AVG(Loan_to_Income_Ratio),
        4
    ) AS Average_LTI,

    ROUND(
        AVG(Credit_Score),
        2
    ) AS Average_Credit_Score

FROM risk_banded

GROUP BY
    Risk_Band

ORDER BY

    CASE Risk_Band
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END;


-- ------------------------------------------------------------
-- 5. High/Critical Risk Share
-- ------------------------------------------------------------

WITH loan_risk_profile AS (

    SELECT

        l.Loan_ID,
        l.Loan_Amount,
        c.Annual_Income,
        c.Credit_Score,

        CASE

            WHEN c.Credit_Score >= 750
                THEN 0

            WHEN c.Credit_Score >= 700
                THEN 1

            WHEN c.Credit_Score >= 650
                THEN 2

            ELSE 3

        END

        +

        CASE

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 1
                THEN 0

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 2
                THEN 1

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 3
                THEN 2

            ELSE 3

        END AS Risk_Score

    FROM loans l

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE l.Loan_Status = 'Approved'
)

SELECT

    COUNT(*) AS Total_Approved_Loans,

    SUM(
        CASE
            WHEN Risk_Score >= 4
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Loans,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS High_Critical_Risk_Share_Percent,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS High_Critical_Loan_Exposure

FROM loan_risk_profile;


-- ------------------------------------------------------------
-- 6. Highest-Risk Approved Loans
-- ------------------------------------------------------------

WITH loan_risk_profile AS (

    SELECT

        l.Loan_ID,

        l.Customer_ID,

        l.Loan_Type,

        l.Loan_Amount,

        l.Interest_Rate,

        c.Annual_Income,

        c.Credit_Score,

        ROUND(
            l.Loan_Amount / NULLIF(c.Annual_Income, 0),
            4
        ) AS Loan_to_Income_Ratio,

        CASE

            WHEN c.Credit_Score >= 750
                THEN 0

            WHEN c.Credit_Score >= 700
                THEN 1

            WHEN c.Credit_Score >= 650
                THEN 2

            ELSE 3

        END

        +

        CASE

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 1
                THEN 0

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 2
                THEN 1

            WHEN l.Loan_Amount / NULLIF(c.Annual_Income, 0) < 3
                THEN 2

            ELSE 3

        END AS Risk_Score

    FROM loans l

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE l.Loan_Status = 'Approved'
)

SELECT

    Loan_ID,

    Customer_ID,

    Loan_Type,

    ROUND(Loan_Amount, 2) AS Loan_Amount,

    ROUND(Annual_Income, 2) AS Annual_Income,

    Credit_Score,

    Loan_to_Income_Ratio,

    Risk_Score,

    CASE

        WHEN Risk_Score >= 6
            THEN 'Critical'

        WHEN Risk_Score >= 4
            THEN 'High'

        WHEN Risk_Score >= 2
            THEN 'Medium'

        ELSE 'Low'

    END AS Risk_Band

FROM loan_risk_profile

ORDER BY
    Risk_Score DESC,
    Loan_to_Income_Ratio DESC

LIMIT 20;


-- ------------------------------------------------------------
-- 7. Validation
-- ------------------------------------------------------------

SELECT

    COUNT(*) AS Approved_Loan_Count,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Approved_Loan_Exposure

FROM loans

WHERE Loan_Status = 'Approved';


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- Complete after executing the queries.
--
-- Report:
--
-- 1. Percentage of approved loans classified as High/Critical.
-- 2. High/Critical loan exposure.
-- 3. Average LTI of High/Critical loans.
-- 4. Average credit score of High/Critical loans.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- High/Critical segments can be prioritized for:
--
-- - Additional credit review
-- - Portfolio monitoring
-- - Exposure monitoring
-- - Risk-policy review
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Risk bands are derived because the source dataset does not
-- contain an explicit risk classification.
--
-- The model uses only Credit Score and Loan-to-Income Ratio.
--
-- It does NOT include:
--
-- - Existing debt
-- - Monthly EMI
-- - Debt-service ratio
-- - Repayment history
-- - Delinquency
-- - Default history
-- - Employment stability
-- - Household expenses
--
-- Therefore these risk bands should NOT be interpreted as
-- actual probability of default or bank underwriting decisions.
--
-- ============================================================