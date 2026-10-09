/* ============================================================
   Q16. BRANCH ACTION PRIORITY
   ============================================================

   BUSINESS QUESTION:
   Which branches should receive retention, cross-sell,
   or risk-monitoring attention?

   BUSINESS OBJECTIVE:
   Combine branch customer activity, account balances,
   transaction activity, loan exposure and credit quality
   to identify branches requiring different business actions.

   ACTION CATEGORIES:
       1. Risk Monitoring
       2. Retention
       3. Cross-Sell
       4. Growth Opportunity
       5. Standard Monitoring

   IMPORTANT:
   These classifications are analytical decision rules,
   not official bank policies.
*/


USE banking_analytics_db;


/* ============================================================
   BRANCH PERFORMANCE PROFILE
   ============================================================ */

WITH branch_accounts AS
(
    SELECT

        a.Branch_ID,

        COUNT(DISTINCT a.Customer_ID)
            AS Customer_Count,

        COUNT(DISTINCT a.Account_ID)
            AS Account_Count,

        SUM(a.Balance)
            AS Total_Balance,

        AVG(a.Balance)
            AS Average_Balance

    FROM accounts a

    GROUP BY
        a.Branch_ID
),

branch_transactions AS
(
    SELECT

        a.Branch_ID,

        COUNT(t.Transaction_ID)
            AS Transaction_Count,

        SUM(t.Amount)
            AS Total_Transaction_Value

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY
        a.Branch_ID
),

customer_branch AS
(
    SELECT

        Customer_ID,

        COUNT(DISTINCT Branch_ID)
            AS Branch_Count,

        MIN(Branch_ID)
            AS Branch_ID

    FROM accounts

    GROUP BY Customer_ID
),

branch_loans AS
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
        ) AS Low_Credit_Loans

    FROM customer_branch cb

    INNER JOIN loans l
        ON cb.Customer_ID = l.Customer_ID

    INNER JOIN customers c
        ON l.Customer_ID = c.Customer_ID

    WHERE cb.Branch_Count = 1
      AND l.Loan_Status = 'Approved'

    GROUP BY
        cb.Branch_ID
),

branch_profile AS
(
    SELECT

        b.Branch_ID,
        b.Branch_Name,
        b.City,

        COALESCE(
            ba.Customer_Count,
            0
        ) AS Customer_Count,

        COALESCE(
            ba.Account_Count,
            0
        ) AS Account_Count,

        COALESCE(
            ba.Total_Balance,
            0
        ) AS Total_Balance,

        COALESCE(
            ba.Average_Balance,
            0
        ) AS Average_Balance,

        COALESCE(
            bt.Transaction_Count,
            0
        ) AS Transaction_Count,

        COALESCE(
            bt.Total_Transaction_Value,
            0
        ) AS Total_Transaction_Value,

        COALESCE(
            bl.Approved_Loan_Count,
            0
        ) AS Approved_Loan_Count,

        COALESCE(
            bl.Total_Loan_Exposure,
            0
        ) AS Total_Loan_Exposure,

        COALESCE(
            bl.Average_Credit_Score,
            0
        ) AS Average_Credit_Score,

        COALESCE(
            bl.Low_Credit_Loans,
            0
        ) AS Low_Credit_Loans

    FROM branches b

    LEFT JOIN branch_accounts ba
        ON b.Branch_ID = ba.Branch_ID

    LEFT JOIN branch_transactions bt
        ON b.Branch_ID = bt.Branch_ID

    LEFT JOIN branch_loans bl
        ON b.Branch_ID = bl.Branch_ID
)


/* ============================================================
   BRANCH PRIORITY CLASSIFICATION
   ============================================================ */

SELECT

    Branch_ID,
    Branch_Name,
    City,

    Customer_Count,
    Account_Count,

    ROUND(
        Total_Balance,
        2
    ) AS Total_Balance,

    Transaction_Count,

    ROUND(
        Total_Transaction_Value,
        2
    ) AS Total_Transaction_Value,

    Approved_Loan_Count,

    ROUND(
        Total_Loan_Exposure,
        2
    ) AS Total_Loan_Exposure,

    ROUND(
        Average_Credit_Score,
        2
    ) AS Average_Credit_Score,

    Low_Credit_Loans,

    ROUND(

        Low_Credit_Loans * 100.0
        /
        NULLIF(
            Approved_Loan_Count,
            0
        ),

        2

    ) AS Low_Credit_Loan_Percent,


    CASE

        /* --------------------------------------------
           RISK MONITORING
           -------------------------------------------- */

        WHEN Total_Loan_Exposure >
             (
                 SELECT AVG(Total_Loan_Exposure)
                 FROM branch_profile
             )

        AND Average_Credit_Score < 700

        THEN 'Risk Monitoring'


        /* --------------------------------------------
           RETENTION
           -------------------------------------------- */

        WHEN Total_Balance >
             (
                 SELECT AVG(Total_Balance)
                 FROM branch_profile
             )

        AND Transaction_Count <
            (
                SELECT AVG(Transaction_Count)
                FROM branch_profile
            )

        THEN 'Retention'


        /* --------------------------------------------
           CROSS-SELL
           -------------------------------------------- */

        WHEN Total_Balance >
             (
                 SELECT AVG(Total_Balance)
                 FROM branch_profile
             )

        AND Approved_Loan_Count = 0

        THEN 'Cross-Sell'


        /* --------------------------------------------
           GROWTH OPPORTUNITY
           -------------------------------------------- */

        WHEN Customer_Count <
             (
                 SELECT AVG(Customer_Count)
                 FROM branch_profile
             )

        AND Total_Balance <
            (
                SELECT AVG(Total_Balance)
                FROM branch_profile
            )

        AND Transaction_Count <
            (
                SELECT AVG(Transaction_Count)
                FROM branch_profile
            )

        THEN 'Growth Opportunity'


        ELSE 'Standard Monitoring'

    END AS Action_Priority

FROM branch_profile

ORDER BY

    CASE Action_Priority
        WHEN 'Risk Monitoring' THEN 1
        WHEN 'Retention' THEN 2
        WHEN 'Cross-Sell' THEN 3
        WHEN 'Growth Opportunity' THEN 4
        ELSE 5
    END,

    Total_Loan_Exposure DESC;


/* ============================================================
   ACTION SUMMARY
   ============================================================ */

WITH branch_accounts AS
(
    SELECT
        Branch_ID,
        COUNT(DISTINCT Customer_ID) AS Customer_Count,
        SUM(Balance) AS Total_Balance
    FROM accounts
    GROUP BY Branch_ID
),

branch_transactions AS
(
    SELECT
        a.Branch_ID,
        COUNT(t.Transaction_ID) AS Transaction_Count
    FROM accounts a
    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID
    GROUP BY a.Branch_ID
)

SELECT

    CASE

        WHEN ba.Total_Balance >
             (
                 SELECT AVG(Total_Balance)
                 FROM branch_accounts
             )

        AND bt.Transaction_Count <
            (
                SELECT AVG(Transaction_Count)
                FROM branch_transactions
            )

        THEN 'Retention'

        ELSE 'Other'

    END AS Action_Category,

    COUNT(*) AS Branch_Count

FROM branch_accounts ba

INNER JOIN branch_transactions bt
    ON ba.Branch_ID = bt.Branch_ID

GROUP BY Action_Category;


/* ============================================================
   VALIDATION
   ============================================================ */

SELECT

    COUNT(*) AS Total_Branches

FROM branches;


/* ============================================================
   FINDINGS
   ============================================================

   Complete this section using the actual output.

   The analysis classifies branches into:

       Risk Monitoring
       Retention
       Cross-Sell
       Growth Opportunity
       Standard Monitoring

   The classification is based on multiple branch-level
   indicators rather than a single KPI.

   DO NOT claim a branch requires a specific action until
   the actual result confirms the classification.


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   RISK MONITORING
   ----------------
   Branches with relatively high loan exposure and weaker
   average credit quality should receive additional portfolio
   monitoring.


   RETENTION
   ---------
   Branches with high balances but relatively weak transaction
   activity should focus on customer engagement and retention.


   CROSS-SELL
   ---------
   Branches with strong deposit balances but no approved loan
   exposure may have opportunities to cross-sell suitable
   lending products.


   GROWTH OPPORTUNITY
   ------------------
   Branches below the portfolio average across customer base,
   balances and transaction activity may require investigation
   before deciding whether additional growth investment is
   justified.


   STANDARD MONITORING
   -------------------
   Branches that do not meet the above conditions remain under
   normal performance monitoring.


   FINAL BUSINESS DECISION:

   Branch strategy should differ by branch.

   A bank should not apply the same strategy to every branch.

   High-risk branches need monitoring.
   High-balance/low-engagement branches need retention.
   Strong deposit/low-loan branches need cross-selling.
   Low-activity branches require growth diagnosis.
*/


/* ============================================================
   LIMITATIONS
   ============================================================

   1. Thresholds are relative to the average of the 10 branches.

   2. These rules are analytical decision rules and not
      official banking policies.

   3. Credit score is only one measure of credit quality.

   4. Loan exposure is based on approved Loan_Amount.

   5. Customers associated with multiple branches are excluded
      from branch-level loan attribution to prevent duplication.

   6. The analysis does not measure:
          - Branch profitability
          - Operating costs
          - Employee productivity
          - Customer satisfaction
          - Default rates
          - Actual loan losses

   Therefore, management should use these results as a
   prioritization framework rather than an automatic decision
   system.
*/