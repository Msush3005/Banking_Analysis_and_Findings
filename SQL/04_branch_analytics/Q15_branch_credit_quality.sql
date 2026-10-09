/* ============================================================
   Q15. BRANCH CREDIT QUALITY
   ============================================================

   BUSINESS QUESTION:
   Which branches have high loan exposure but weaker
   credit quality?

   BUSINESS OBJECTIVE:
   Identify branches where significant approved loan exposure
   is combined with relatively weaker borrower credit profiles.

   CREDIT QUALITY INDICATOR:
   Credit Score

   For this analysis:
       Credit Score < 650
       = Lower Credit Quality Indicator

   IMPORTANT:
   This is an analytical screening threshold, not a bank's
   official underwriting policy.
*/


USE banking_analytics_db;


/* ============================================================
   SQL ANALYSIS
   ============================================================ */

WITH customer_branch AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Branch_ID) AS Branch_Count,
        MIN(Branch_ID) AS Branch_ID
    FROM accounts
    GROUP BY Customer_ID
),

branch_credit_quality AS
(
    SELECT

        cb.Branch_ID,

        COUNT(l.Loan_ID)
            AS Approved_Loan_Count,

        SUM(l.Loan_Amount)
            AS Total_Loan_Exposure,

        AVG(c.Credit_Score)
            AS Average_Credit_Score,

        SUM(
            CASE
                WHEN c.Credit_Score < 650
                THEN 1
                ELSE 0
            END
        ) AS Low_Credit_Score_Loans

    FROM customer_branch cb

    INNER JOIN loans l
        ON cb.Customer_ID = l.Customer_ID

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE cb.Branch_Count = 1
      AND l.Loan_Status = 'Approved'

    GROUP BY
        cb.Branch_ID
)

SELECT

    b.Branch_ID,

    b.Branch_Name,

    b.City,

    COALESCE(
        cq.Approved_Loan_Count,
        0
    ) AS Approved_Loan_Count,

    ROUND(
        COALESCE(
            cq.Total_Loan_Exposure,
            0
        ),
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        COALESCE(
            cq.Average_Credit_Score,
            0
        ),
        2
    ) AS Average_Credit_Score,

    COALESCE(
        cq.Low_Credit_Score_Loans,
        0
    ) AS Low_Credit_Score_Loans,

    ROUND(

        COALESCE(
            cq.Low_Credit_Score_Loans,
            0
        ) * 100.0

        /

        NULLIF(
            cq.Approved_Loan_Count,
            0
        ),

        2

    ) AS Low_Credit_Score_Percent

FROM branches b

LEFT JOIN branch_credit_quality cq

    ON b.Branch_ID = cq.Branch_ID

ORDER BY

    Low_Credit_Score_Percent DESC,

    Total_Loan_Exposure DESC;


/* ============================================================
   HIGH-EXPOSURE + WEAKER-CREDIT BRANCHES
   ============================================================

   This identifies branches that simultaneously have:

       - Significant loan exposure
       - Relatively high proportion of lower-credit borrowers

   The thresholds below are analytical screening rules.
*/


WITH customer_branch AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Branch_ID) AS Branch_Count,
        MIN(Branch_ID) AS Branch_ID
    FROM accounts
    GROUP BY Customer_ID
),

branch_credit_quality AS
(
    SELECT

        cb.Branch_ID,

        COUNT(l.Loan_ID)
            AS Approved_Loan_Count,

        SUM(l.Loan_Amount)
            AS Total_Loan_Exposure,

        AVG(c.Credit_Score)
            AS Average_Credit_Score,

        SUM(
            CASE
                WHEN c.Credit_Score < 650
                THEN 1
                ELSE 0
            END
        ) AS Low_Credit_Score_Loans

    FROM customer_branch cb

    INNER JOIN loans l
        ON cb.Customer_ID = l.Customer_ID

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE cb.Branch_Count = 1
      AND l.Loan_Status = 'Approved'

    GROUP BY
        cb.Branch_ID
)

SELECT

    b.Branch_ID,
    b.Branch_Name,
    b.City,

    cq.Approved_Loan_Count,

    ROUND(
        cq.Total_Loan_Exposure,
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        cq.Average_Credit_Score,
        2
    ) AS Average_Credit_Score,

    cq.Low_Credit_Score_Loans,

    ROUND(
        cq.Low_Credit_Score_Loans * 100.0
        / NULLIF(cq.Approved_Loan_Count, 0),
        2
    ) AS Low_Credit_Score_Percent

FROM branches b

INNER JOIN branch_credit_quality cq
    ON b.Branch_ID = cq.Branch_ID

WHERE cq.Total_Loan_Exposure >=
(
    SELECT
        AVG(Total_Loan_Exposure)
    FROM branch_credit_quality
)

AND
(
    cq.Low_Credit_Score_Loans * 100.0
    / NULLIF(cq.Approved_Loan_Count, 0)
) >= 25

ORDER BY
    Total_Loan_Exposure DESC;


/* ============================================================
   VALIDATION
   ============================================================ */

SELECT

    COUNT(*) AS Approved_Loan_Count,

    ROUND(
        SUM(Loan_Amount),
        2
    ) AS Approved_Loan_Exposure,

    ROUND(
        AVG(c.Credit_Score),
        2
    ) AS Overall_Average_Credit_Score

FROM loans l

INNER JOIN customers c
    ON l.Customer_ID = c.Customer_ID

WHERE l.Loan_Status = 'Approved';


/* ============================================================
   FINDINGS
   ============================================================

   Complete this section AFTER executing the analysis.

   The analysis identifies:

       1. Branches with the highest loan exposure.
       2. Branches with lower average credit scores.
       3. Branches with a high percentage of lower-credit
          borrowers.
       4. Branches where high exposure and weaker credit
          quality overlap.

   IMPORTANT:

   Do not automatically label a branch as "bad" because it
   has a lower average credit score.

   The analysis identifies branches requiring further review.


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   ACTION 1 — RISK MONITORING
   --------------------------
   Prioritize high-exposure branches with weaker borrower
   credit profiles for portfolio monitoring.


   ACTION 2 — CREDIT REVIEW
   ------------------------
   Review underwriting patterns in branches with elevated
   lower-credit-score loan concentration.


   ACTION 3 — EXPOSURE MANAGEMENT
   -------------------------------
   Monitor whether high loan exposure is concentrated in
   branches with weaker credit quality.


   ACTION 4 — TARGETED REVIEW
   --------------------------
   Do not apply blanket restrictions to an entire branch.

   Investigate:
       - Loan type
       - Loan size
       - Customer income
       - Loan-to-income ratio
       - Credit score
       - Approval patterns


   FINAL BUSINESS DECISION:

   Branches with BOTH high loan exposure and weaker credit
   quality should receive higher monitoring priority than
   branches with high exposure alone.


/* ============================================================
   LIMITATIONS
   ============================================================

   1. Credit score is only one indicator of credit quality.

   2. Credit Score < 650 is an analytical threshold and may
      not represent the bank's actual risk policy.

   3. The dataset does not contain:
          - Default history
          - Delinquency
          - EMI payment history
          - Debt-service ratio
          - Existing external debt

   4. Therefore this analysis identifies potential
      concentration and monitoring areas rather than actual
      probability of default.

   5. Customers associated with multiple branches are excluded
      from branch-level loan allocation because the dataset
      does not identify a primary loan branch.
*/