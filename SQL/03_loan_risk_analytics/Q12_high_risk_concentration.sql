USE banking_analytics_db;

-- ============================================================
-- Q12: HIGH-RISK LOAN CONCENTRATION
--
-- Business Question:
-- Are high-risk loans concentrated in particular cities,
-- occupations or loan types?
--
-- Risk methodology is the same as Q11.
-- Risk Score = Credit Risk Points + LTI Risk Points
--
-- High/Critical = Risk Score >= 4
-- ============================================================


-- ------------------------------------------------------------
-- 1. Create Risk Profile
-- ------------------------------------------------------------

WITH loan_risk_profile AS (

    SELECT

        l.Loan_ID,
        l.Customer_ID,
        l.Loan_Type,
        l.Loan_Amount,
        l.Interest_Rate,

        c.City,
        c.Occupation,
        c.Annual_Income,
        c.Credit_Score,

        l.Loan_Amount
        / NULLIF(c.Annual_Income, 0)
        AS Loan_to_Income_Ratio,

        (
            CASE
                WHEN c.Credit_Score >= 750 THEN 0
                WHEN c.Credit_Score >= 700 THEN 1
                WHEN c.Credit_Score >= 650 THEN 2
                ELSE 3
            END
            +
            CASE
                WHEN l.Loan_Amount
                     / NULLIF(c.Annual_Income, 0) < 1
                    THEN 0

                WHEN l.Loan_Amount
                     / NULLIF(c.Annual_Income, 0) < 2
                    THEN 1

                WHEN l.Loan_Amount
                     / NULLIF(c.Annual_Income, 0) < 3
                    THEN 2

                ELSE 3
            END
        ) AS Risk_Score

    FROM loans l

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE l.Loan_Status = 'Approved'
),

risk_banded AS (

    SELECT

        *,

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
)


-- ------------------------------------------------------------
-- 2. High-Risk Concentration by City
-- ------------------------------------------------------------

SELECT

    City,

    COUNT(*) AS Approved_Loan_Count,

    SUM(
        CASE
            WHEN Risk_Score >= 4
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Loan_Count,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS High_Critical_Rate_Percent,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS High_Critical_Exposure

FROM risk_banded

GROUP BY
    City

ORDER BY
    High_Critical_Rate_Percent DESC;


-- ------------------------------------------------------------
-- 3. High-Risk Concentration by Occupation
-- ------------------------------------------------------------

SELECT

    Occupation,

    COUNT(*) AS Approved_Loan_Count,

    SUM(
        CASE
            WHEN Risk_Score >= 4
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Loan_Count,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS High_Critical_Rate_Percent,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS High_Critical_Exposure

FROM risk_banded

GROUP BY
    Occupation

ORDER BY
    High_Critical_Rate_Percent DESC;


-- ------------------------------------------------------------
-- 4. High-Risk Concentration by Loan Type
-- ------------------------------------------------------------

SELECT

    Loan_Type,

    COUNT(*) AS Approved_Loan_Count,

    SUM(
        CASE
            WHEN Risk_Score >= 4
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Loan_Count,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS High_Critical_Rate_Percent,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS High_Critical_Exposure

FROM risk_banded

GROUP BY
    Loan_Type

ORDER BY
    High_Critical_Rate_Percent DESC;


-- ------------------------------------------------------------
-- 5. Overall High-Risk Concentration
-- ------------------------------------------------------------

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
    ) AS High_Critical_Rate_Percent,

    ROUND(
        SUM(
            CASE
                WHEN Risk_Score >= 4
                THEN Loan_Amount
                ELSE 0
            END
        ),
        2
    ) AS High_Critical_Exposure

FROM risk_banded;


-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- Identify:
--
-- 1. City with the highest High/Critical rate.
-- 2. Occupation with the highest High/Critical rate.
-- 3. Loan type with the highest High/Critical rate.
-- 4. Segment with the largest High/Critical exposure.
--
-- Do NOT judge a segment using rate alone.
-- A small segment can have a high rate but very little
-- absolute exposure.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- Potential actions:
--
-- - Increase monitoring in concentrated risk segments.
-- - Review underwriting characteristics for high-risk
--   loan categories.
-- - Investigate geographic or occupational concentration.
-- - Prioritize segments with BOTH high risk rate and
--   meaningful loan exposure.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- The risk classification is derived from Credit Score and
-- Loan-to-Income Ratio because the source data has no
-- explicit risk-band field.
--
-- This analysis identifies concentration patterns.
-- It does NOT establish that city, occupation or loan type
-- causes higher credit risk.
--
-- ============================================================