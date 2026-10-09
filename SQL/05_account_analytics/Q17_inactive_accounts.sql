/* ============================================================
   Q17. INACTIVE ACCOUNTS WITH MEANINGFUL BALANCES
   ============================================================

   BUSINESS QUESTION:
   Which accounts have low transaction activity but maintain
   meaningful balances?

   BUSINESS OBJECTIVE:
   Identify potentially under-engaged deposit accounts where
   customers maintain balances but show limited transaction
   activity.

   IMPORTANT:
   "Inactive" in this analysis means no transactions during
   the available transaction period.

   It does NOT mean officially dormant according to a bank's
   regulatory or operational definition.
*/


USE banking_analytics_db;


/* ============================================================
   SQL ANALYSIS
   ============================================================ */

WITH account_activity AS
(
    SELECT

        a.Account_ID,
        a.Customer_ID,
        a.Account_Type,
        a.Balance,

        COUNT(t.Transaction_ID)
            AS Transaction_Count,

        MAX(t.Transaction_Date)
            AS Last_Transaction_Date,

        MIN(t.Transaction_Date)
            AS First_Transaction_Date,

        COALESCE(
            SUM(t.Amount),
            0
        ) AS Total_Transaction_Value

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY

        a.Account_ID,
        a.Customer_ID,
        a.Account_Type,
        a.Balance
)

SELECT

    Account_ID,
    Customer_ID,
    Account_Type,

    ROUND(
        Balance,
        2
    ) AS Balance,

    Transaction_Count,

    First_Transaction_Date,

    Last_Transaction_Date,

    ROUND(
        Total_Transaction_Value,
        2
    ) AS Total_Transaction_Value,

    CASE

        WHEN Transaction_Count = 0
             AND Balance > 0

        THEN 'No Transaction Activity'

        WHEN Transaction_Count <= 2
             AND Balance > 0

        THEN 'Low Activity'

        ELSE 'Active'

    END AS Activity_Status

FROM account_activity

ORDER BY

    CASE
        WHEN Transaction_Count = 0
             AND Balance > 0
            THEN 1

        WHEN Transaction_Count <= 2
             AND Balance > 0
            THEN 2

        ELSE 3
    END,

    Balance DESC;


/* ============================================================
   HIGH-VALUE INACTIVE ACCOUNTS
   ============================================================

   Identify accounts with meaningful balances but
   zero transaction activity.
*/

WITH account_activity AS
(
    SELECT

        a.Account_ID,
        a.Customer_ID,
        a.Account_Type,
        a.Balance,

        COUNT(t.Transaction_ID)
            AS Transaction_Count,

        MAX(t.Transaction_Date)
            AS Last_Transaction_Date

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY

        a.Account_ID,
        a.Customer_ID,
        a.Account_Type,
        a.Balance
)

SELECT

    Account_ID,
    Customer_ID,
    Account_Type,

    ROUND(
        Balance,
        2
    ) AS Balance,

    Transaction_Count,

    Last_Transaction_Date

FROM account_activity

WHERE Transaction_Count = 0
  AND Balance > 0

ORDER BY
    Balance DESC;


/* ============================================================
   ACCOUNT-LEVEL SUMMARY
   ============================================================ */

WITH account_activity AS
(
    SELECT

        a.Account_ID,
        a.Balance,

        COUNT(t.Transaction_ID)
            AS Transaction_Count

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY

        a.Account_ID,
        a.Balance
)

SELECT

    CASE

        WHEN Transaction_Count = 0
            THEN 'No Activity'

        WHEN Transaction_Count <= 2
            THEN 'Low Activity'

        ELSE 'Active'

    END AS Activity_Status,

    COUNT(*) AS Account_Count,

    ROUND(
        SUM(Balance),
        2
    ) AS Total_Balance,

    ROUND(
        AVG(Balance),
        2
    ) AS Average_Balance

FROM account_activity

GROUP BY

    CASE

        WHEN Transaction_Count = 0
            THEN 'No Activity'

        WHEN Transaction_Count <= 2
            THEN 'Low Activity'

        ELSE 'Active'

    END

ORDER BY
    Total_Balance DESC;


/* ============================================================
   VALIDATION
   ============================================================ */

SELECT

    COUNT(*) AS Total_Accounts,

    ROUND(
        SUM(Balance),
        2
    ) AS Total_Account_Balance

FROM accounts;


/* ============================================================
   FINDINGS
   ============================================================

   Complete this section using the actual SQL output.

   The analysis identifies accounts that:

       1. Have no recorded transaction activity.
       2. Have very low transaction activity.
       3. Still maintain positive account balances.

   The most important segment is:

       No Transaction Activity
       +
       Positive Balance

   These accounts represent potentially under-engaged
   deposit relationships.


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   ACTION 1 — CUSTOMER RE-ENGAGEMENT
   ----------------------------------
   Contact customers with meaningful balances but no recent
   transaction activity.

   Possible actions:
       - Digital banking activation
       - Mobile banking education
       - Card usage campaigns
       - Personalized banking offers


   ACTION 2 — RETENTION
   --------------------
   Monitor high-balance inactive accounts because losing
   these relationships could affect the deposit base.


   ACTION 3 — PRODUCT CROSS-SELL
   -----------------------------
   Evaluate whether inactive high-balance customers are
   suitable for:
       - Fixed deposits
       - Recurring deposits
       - Investment products
       - Premium banking services


   ACTION 4 — CUSTOMER PRIORITIZATION
   ----------------------------------
   Do not treat every inactive account equally.

   Prioritize according to:

       High Balance
             +
       Low/No Activity
             +
       Strong Customer Profile


   FINAL BUSINESS DECISION:

   High-balance accounts with little or no transaction
   activity should be treated as a customer-engagement
   and retention opportunity rather than automatically
   classified as churned or dormant.


/* ============================================================
   LIMITATIONS
   ============================================================

   1. The dataset contains a finite transaction period.

   2. An account with zero transactions may not actually be
      dormant; the customer could simply have used another
      account or channel.

   3. No official bank dormancy indicator is available.

   4. "Low Activity" thresholds are analytical rules:
          0 transactions  = No Activity
          1–2 transactions = Low Activity

   5. Balance does not represent customer profitability.

   Therefore this analysis should be treated as an
   engagement-screening analysis, not a formal dormancy model.
*/