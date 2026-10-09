/* ============================================================
   Q20. ACCOUNT CROSS-SELL OPPORTUNITY
   ============================================================

   BUSINESS QUESTION:
   Which existing account customers without an approved loan
   represent the strongest potential cross-sell opportunities?

   BUSINESS OBJECTIVE:
   Identify customers who already have a banking relationship
   but do not currently have an approved loan.

   PRIORITIZATION FACTORS:
       - Account balance
       - Annual income
       - Credit score
       - Transaction engagement

   IMPORTANT:
   This is a CROSS-SELL CANDIDATE analysis.
   It is NOT a loan approval model.
*/


USE banking_analytics_db;


/* ============================================================
   1. CUSTOMER CROSS-SELL PROFILE
   ============================================================ */

WITH customer_account_metrics AS
(
    SELECT

        c.Customer_ID,
        c.Name,
        c.Annual_Income,
        c.Credit_Score,

        COUNT(DISTINCT a.Account_ID)
            AS Account_Count,

        COUNT(DISTINCT a.Account_Type)
            AS Account_Type_Count,

        SUM(a.Balance)
            AS Total_Balance,

        COUNT(DISTINCT t.Transaction_ID)
            AS Transaction_Count,

        COALESCE(
            SUM(t.Amount),
            0
        ) AS Transaction_Value

    FROM customers c

    INNER JOIN accounts a
        ON c.Customer_ID = a.Customer_ID

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY

        c.Customer_ID,
        c.Name,
        c.Annual_Income,
        c.Credit_Score
),

approved_loan_customers AS
(
    SELECT DISTINCT
        Customer_ID
    FROM loans
    WHERE Loan_Status = 'Approved'
)

SELECT

    cam.Customer_ID,
    cam.Name,
    cam.Annual_Income,
    cam.Credit_Score,

    cam.Account_Count,
    cam.Account_Type_Count,

    ROUND(
        cam.Total_Balance,
        2
    ) AS Total_Balance,

    cam.Transaction_Count,

    ROUND(
        cam.Transaction_Value,
        2
    ) AS Transaction_Value,

    CASE

        WHEN cam.Credit_Score >= 750
             AND cam.Annual_Income >= 1500000
             AND cam.Total_Balance >= 500000
             AND cam.Transaction_Count >= 20

        THEN 'Priority Cross-Sell'

        WHEN cam.Credit_Score >= 700
             AND cam.Total_Balance >= 500000

        THEN 'High Potential'

        WHEN cam.Credit_Score >= 650
             AND cam.Total_Balance >= 250000

        THEN 'Medium Potential'

        ELSE 'Low Priority'

    END AS Cross_Sell_Priority

FROM customer_account_metrics cam

LEFT JOIN approved_loan_customers al
    ON cam.Customer_ID = al.Customer_ID

WHERE al.Customer_ID IS NULL

ORDER BY

    CASE

        WHEN cam.Credit_Score >= 750
             AND cam.Annual_Income >= 1500000
             AND cam.Total_Balance >= 500000
             AND cam.Transaction_Count >= 20
            THEN 1

        WHEN cam.Credit_Score >= 700
             AND cam.Total_Balance >= 500000
            THEN 2

        WHEN cam.Credit_Score >= 650
             AND cam.Total_Balance >= 250000
            THEN 3

        ELSE 4

    END,

    cam.Total_Balance DESC;


/* ============================================================
   2. CROSS-SELL OPPORTUNITY SUMMARY
   ============================================================ */

WITH customer_account_metrics AS
(
    SELECT

        c.Customer_ID,
        c.Annual_Income,
        c.Credit_Score,

        SUM(a.Balance)
            AS Total_Balance,

        COUNT(DISTINCT t.Transaction_ID)
            AS Transaction_Count

    FROM customers c

    INNER JOIN accounts a
        ON c.Customer_ID = a.Customer_ID

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY

        c.Customer_ID,
        c.Annual_Income,
        c.Credit_Score
),

approved_loan_customers AS
(
    SELECT DISTINCT
        Customer_ID
    FROM loans
    WHERE Loan_Status = 'Approved'
),

cross_sell_candidates AS
(
    SELECT
        cam.*

    FROM customer_account_metrics cam

    LEFT JOIN approved_loan_customers al
        ON cam.Customer_ID = al.Customer_ID

    WHERE al.Customer_ID IS NULL
)

SELECT

    CASE

        WHEN Credit_Score >= 750
             AND Annual_Income >= 1500000
             AND Total_Balance >= 500000
             AND Transaction_Count >= 20
            THEN 'Priority Cross-Sell'

        WHEN Credit_Score >= 700
             AND Total_Balance >= 500000
            THEN 'High Potential'

        WHEN Credit_Score >= 650
             AND Total_Balance >= 250000
            THEN 'Medium Potential'

        ELSE 'Low Priority'

    END AS Cross_Sell_Priority,

    COUNT(*) AS Customer_Count,

    ROUND(
        SUM(Total_Balance),
        2
    ) AS Total_Balance,

    ROUND(
        AVG(Total_Balance),
        2
    ) AS Average_Balance,

    ROUND(
        AVG(Credit_Score),
        2
    ) AS Average_Credit_Score,

    ROUND(
        AVG(Annual_Income),
        2
    ) AS Average_Income,

    ROUND(
        AVG(Transaction_Count),
        2
    ) AS Average_Transactions

FROM cross_sell_candidates

GROUP BY

    CASE

        WHEN Credit_Score >= 750
             AND Annual_Income >= 1500000
             AND Total_Balance >= 500000
             AND Transaction_Count >= 20
            THEN 'Priority Cross-Sell'

        WHEN Credit_Score >= 700
             AND Total_Balance >= 500000
            THEN 'High Potential'

        WHEN Credit_Score >= 650
             AND Total_Balance >= 250000
            THEN 'Medium Potential'

        ELSE 'Low Priority'

    END

ORDER BY
    Customer_Count DESC;


/* ============================================================
   3. TOP CROSS-SELL TARGETS
   ============================================================ */

WITH customer_metrics AS
(
    SELECT

        c.Customer_ID,
        c.Name,
        c.Annual_Income,
        c.Credit_Score,

        SUM(a.Balance)
            AS Total_Balance,

        COUNT(DISTINCT t.Transaction_ID)
            AS Transaction_Count

    FROM customers c

    INNER JOIN accounts a
        ON c.Customer_ID = a.Customer_ID

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY

        c.Customer_ID,
        c.Name,
        c.Annual_Income,
        c.Credit_Score
)

SELECT

    cm.Customer_ID,
    cm.Name,
    cm.Annual_Income,
    cm.Credit_Score,

    ROUND(
        cm.Total_Balance,
        2
    ) AS Total_Balance,

    cm.Transaction_Count

FROM customer_metrics cm

WHERE NOT EXISTS
(
    SELECT 1
    FROM loans l
    WHERE l.Customer_ID = cm.Customer_ID
      AND l.Loan_Status = 'Approved'
)

AND cm.Credit_Score >= 700
AND cm.Total_Balance >= 500000

ORDER BY
    cm.Total_Balance DESC,
    cm.Credit_Score DESC;


/* ============================================================
   4. VALIDATION
   ============================================================ */

SELECT

    COUNT(DISTINCT a.Customer_ID)
        AS Total_Account_Customers,

    COUNT(
        DISTINCT
        CASE
            WHEN l.Loan_Status = 'Approved'
            THEN a.Customer_ID
        END
    ) AS Customers_With_Approved_Loan,

    COUNT(
        DISTINCT
        CASE
            WHEN l.Customer_ID IS NULL
            THEN a.Customer_ID
        END
    ) AS Customers_With_No_Loan_Record

FROM accounts a

LEFT JOIN loans l
    ON a.Customer_ID = l.Customer_ID;


/* ============================================================
   FINDINGS
   ============================================================

   The analysis identifies existing account customers who do
   not currently have an approved loan.

   Cross-sell potential is prioritized using:

       1. Credit Score
       2. Annual Income
       3. Account Balance
       4. Transaction Engagement

   The strongest candidate segment is:

       High Credit Score
       +
       High Income
       +
       High Account Balance
       +
       Strong Transaction Activity
       +
       No Approved Loan


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   ACTION 1 — PRIORITY CROSS-SELL
   -------------------------------
   Approach high-potential customers with personalized,
   pre-qualified loan information where appropriate.


   ACTION 2 — USE EXISTING RELATIONSHIP
   -------------------------------------
   Existing balances and transaction behavior can be used
   to personalize the customer approach.


   ACTION 3 — DO NOT MASS-MARKET
   -----------------------------
   Do not send the same loan offer to every customer without
   an approved loan.

   Prioritize customers using their financial profile.


   ACTION 4 — SEPARATE MARKETING FROM UNDERWRITING
   ------------------------------------------------
   The output should be used to identify potential marketing
   candidates.

   Final loan approval must still use the bank's formal
   credit-underwriting process.


   ACTION 5 — MEASURE CONVERSION
   -----------------------------
   In a production environment, track:

       Candidates contacted
             ↓
       Applications
             ↓
       Approvals
             ↓
       Disbursed loans
             ↓
       Loan profitability


   FINAL BUSINESS DECISION:

   Existing deposit customers without approved loans represent
   a potential cross-selling pool, but targeting should be
   prioritized using customer value, credit quality, income
   and engagement rather than loan status alone.


/* ============================================================
   LIMITATIONS
   ============================================================

   1. Cross-sell thresholds are analytical rules created for
      this portfolio project.

   2. They are NOT official bank lending criteria.

   3. Credit approval cannot be determined from this analysis.

   4. The dataset does not include:
          - Debt-service ratio
          - Existing external loans
          - Monthly expenses
          - Employment stability
          - Loan purpose
          - Repayment history

   5. "No approved loan" does not necessarily mean the customer
      has never applied for a loan.

   6. The analysis identifies marketing opportunities, not
      credit-approved customers.
*/