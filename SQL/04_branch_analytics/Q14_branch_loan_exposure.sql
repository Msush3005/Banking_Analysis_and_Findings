/* ============================================================
   Q14. BRANCH LOAN EXPOSURE
   ============================================================

   BUSINESS QUESTION:
   Which branches have the highest loan exposure, and where
   is the bank's lending portfolio most concentrated?

   BUSINESS OBJECTIVE:
   Identify branches carrying the largest approved loan amounts
   so management can focus on portfolio monitoring, risk
   management and branch-level lending strategy.

   IMPORTANT:
   Loan exposure is measured using Loan_Amount for approved
   loans.

   To avoid double-counting loans, customers associated with
   multiple branches are excluded from the branch-level
   allocation because the dataset does not identify a
   customer's primary loan branch.
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

branch_loan_exposure AS
(
    SELECT
        cb.Branch_ID,

        COUNT(l.Loan_ID) AS Approved_Loan_Count,

        ROUND(
            SUM(l.Loan_Amount),
            2
        ) AS Total_Loan_Exposure,

        ROUND(
            AVG(l.Loan_Amount),
            2
        ) AS Average_Loan_Amount

    FROM customer_branch cb

    INNER JOIN loans l
        ON cb.Customer_ID = l.Customer_ID

    WHERE cb.Branch_Count = 1
      AND l.Loan_Status = 'Approved'

    GROUP BY cb.Branch_ID
)

SELECT
    b.Branch_ID,
    b.Branch_Name,
    b.City,

    COALESCE(e.Approved_Loan_Count, 0)
        AS Approved_Loan_Count,

    COALESCE(e.Total_Loan_Exposure, 0)
        AS Total_Loan_Exposure,

    COALESCE(e.Average_Loan_Amount, 0)
        AS Average_Loan_Amount

FROM branches b

LEFT JOIN branch_loan_exposure e
    ON b.Branch_ID = e.Branch_ID

ORDER BY Total_Loan_Exposure DESC;


/* ============================================================
   FINDINGS
   ============================================================

   The query ranks branches according to the total amount of
   approved loans associated with their customers.

   KEY METRICS:

       1. Approved_Loan_Count
          Number of approved loans.

       2. Total_Loan_Exposure
          Total approved loan amount associated with the branch.

       3. Average_Loan_Amount
          Average approved loan size.

   BUSINESS FINDING:

   Branches with higher Total_Loan_Exposure represent branches
   associated with a larger outstanding/approved lending
   exposure in this dataset.

   A branch with:
       High loan count + High exposure
   indicates broad lending activity.

   A branch with:
       Low loan count + High exposure
   indicates fewer but potentially larger loans.

   A branch with:
       High loan count + Low exposure
   indicates a larger number of relatively smaller loans.
*/


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   ACTION 1 — RISK MONITORING
   --------------------------
   Prioritize branches with the highest loan exposure for
   portfolio monitoring and credit-risk review.


   ACTION 2 — CONCENTRATION MONITORING
   -----------------------------------
   If a small number of branches account for a large share
   of total loan exposure, management should monitor lending
   concentration.


   ACTION 3 — BRANCH STRATEGY
   --------------------------
   Compare high-exposure branches with their:
       - Customer base
       - Average loan size
       - Approval rate
       - Customer income
       - Credit-score distribution


   ACTION 4 — LENDING OPPORTUNITY
   ------------------------------
   Branches with relatively low loan exposure but strong
   customer relationships may represent opportunities for
   responsible lending growth.


   ACTION 5 — AVOID BLIND EXPANSION
   --------------------------------
   Do NOT simply increase lending in branches with low
   exposure.

   First determine whether low exposure is caused by:
       - Low customer demand
       - Low approval rates
       - Lower-income customer base
       - Lower credit scores
       - Product mismatch


   FINAL BUSINESS DECISION:

   Use branch-level loan exposure as a portfolio-concentration
   indicator, then combine it with credit quality and customer
   characteristics before changing branch lending strategy.
*/


/* ============================================================
   LIMITATIONS
   ============================================================

   1. The dataset does not contain a dedicated Loan_Branch_ID.

   2. Some customers have accounts across multiple branches.

   3. Therefore, customers associated with multiple branches are
      excluded from this branch allocation to prevent assigning
      the same loan to multiple branches.

   4. Loan exposure here represents approved Loan_Amount in the
      dataset. It should NOT automatically be interpreted as
      current outstanding balance unless the dataset explicitly
      defines Loan_Amount that way.

   5. High branch exposure does not automatically mean high risk.
      Exposure must be evaluated together with credit quality,
      repayment information and portfolio performance.
*/