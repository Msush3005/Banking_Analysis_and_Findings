/* ============================================================
   Q18. ACCOUNT TYPE PERFORMANCE
   ============================================================

   BUSINESS QUESTION:
   Which account types have the strongest balances and
   transaction activity?

   BUSINESS OBJECTIVE:
   Compare account products based on customer adoption,
   balance contribution and transaction activity.

   ACCOUNT TYPES:
       Savings
       Current
*/


USE banking_analytics_db;


/* ============================================================
   1. ACCOUNT TYPE PERFORMANCE
   ============================================================ */

WITH account_metrics AS
(
    SELECT

        a.Account_ID,
        a.Customer_ID,
        a.Account_Type,
        a.Balance,

        COUNT(t.Transaction_ID)
            AS Transaction_Count,

        COALESCE(
            SUM(t.Amount),
            0
        ) AS Transaction_Value

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

    Account_Type,

    COUNT(*) AS Account_Count,

    COUNT(DISTINCT Customer_ID)
        AS Customer_Count,

    ROUND(
        SUM(Balance),
        2
    ) AS Total_Balance,

    ROUND(
        AVG(Balance),
        2
    ) AS Average_Balance,

    SUM(Transaction_Count)
        AS Transaction_Count,

    ROUND(
        SUM(Transaction_Value),
        2
    ) AS Total_Transaction_Value,

    ROUND(
        AVG(
            CASE
                WHEN Transaction_Count > 0
                THEN Transaction_Value / Transaction_Count
            END
        ),
        2
    ) AS Average_Transaction_Value

FROM account_metrics

GROUP BY
    Account_Type

ORDER BY
    Total_Balance DESC;


/* ============================================================
   2. ACCOUNT TYPE SHARE
   ============================================================ */

WITH account_summary AS
(
    SELECT

        Account_Type,

        COUNT(*) AS Account_Count,

        SUM(Balance) AS Total_Balance,

        SUM(
            Transaction_Count
        ) AS Transaction_Count,

        SUM(
            Transaction_Value
        ) AS Transaction_Value

    FROM
    (
        SELECT

            a.Account_ID,
            a.Account_Type,
            a.Balance,

            COUNT(t.Transaction_ID)
                AS Transaction_Count,

            COALESCE(
                SUM(t.Amount),
                0
            ) AS Transaction_Value

        FROM accounts a

        LEFT JOIN transactions t
            ON a.Account_ID = t.Account_ID

        GROUP BY

            a.Account_ID,
            a.Account_Type,
            a.Balance
    ) x

    GROUP BY
        Account_Type
)

SELECT

    Account_Type,

    Account_Count,

    ROUND(
        Account_Count * 100.0
        / SUM(Account_Count) OVER (),
        2
    ) AS Account_Share_Percent,

    ROUND(
        Total_Balance,
        2
    ) AS Total_Balance,

    ROUND(
        Total_Balance * 100.0
        / SUM(Total_Balance) OVER (),
        2
    ) AS Balance_Share_Percent,

    Transaction_Count,

    ROUND(
        Transaction_Value,
        2
    ) AS Transaction_Value,

    ROUND(
        Transaction_Value * 100.0
        / SUM(Transaction_Value) OVER (),
        2
    ) AS Transaction_Value_Share_Percent

FROM account_summary

ORDER BY
    Total_Balance DESC;


/* ============================================================
   3. ACCOUNT TYPE TRANSACTION ENGAGEMENT
   ============================================================ */

SELECT

    a.Account_Type,

    COUNT(DISTINCT a.Account_ID)
        AS Account_Count,

    COUNT(t.Transaction_ID)
        AS Transaction_Count,

    COUNT(
        DISTINCT
        CASE
            WHEN t.Transaction_ID IS NOT NULL
            THEN a.Account_ID
        END
    ) AS Active_Accounts,

    ROUND(
        COUNT(
            DISTINCT
            CASE
                WHEN t.Transaction_ID IS NOT NULL
                THEN a.Account_ID
            END
        ) * 100.0
        /
        COUNT(DISTINCT a.Account_ID),
        2
    ) AS Account_Activity_Rate_Percent

FROM accounts a

LEFT JOIN transactions t
    ON a.Account_ID = t.Account_ID

GROUP BY
    a.Account_Type

ORDER BY
    Account_Activity_Rate_Percent DESC;


/* ============================================================
   4. VALIDATION
   ============================================================ */

SELECT

    COUNT(*) AS Total_Accounts,

    COUNT(DISTINCT Customer_ID)
        AS Customers_With_Accounts,

    ROUND(
        SUM(Balance),
        2
    ) AS Total_Account_Balance

FROM accounts;


/* ============================================================
   FINDINGS
   ============================================================

   Complete this section after executing the queries.

   Compare Savings and Current accounts across:

       - Account Count
       - Customer Count
       - Total Balance
       - Average Balance
       - Transaction Count
       - Transaction Value
       - Activity Rate

   IMPORTANT:

   The strongest account type depends on the metric.

   Example:

       Highest balance
           ≠
       Highest transaction activity

   Therefore, account performance should not be judged
   using a single KPI.


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   ACTION 1 — PRODUCT STRATEGY
   ---------------------------
   Identify which account type contributes the largest
   balance base and protect that customer relationship.


   ACTION 2 — CUSTOMER ENGAGEMENT
   ------------------------------
   If one account type has lower activity, investigate
   whether customers are underusing the product.


   ACTION 3 — CROSS-SELLING
   -------------------------
   Customers using one account type can be evaluated for
   complementary products where appropriate.


   ACTION 4 — DIGITAL ENGAGEMENT
   ------------------------------
   Account types with lower transaction activity may be
   candidates for digital banking activation campaigns.


   ACTION 5 — RETENTION
   --------------------
   Protect account types with large balance contributions
   because customer migration could affect the deposit base.


   FINAL BUSINESS DECISION:

   Account-product strategy should be based on both
   balance contribution and customer engagement rather
   than account volume alone.


/* ============================================================
   LIMITATIONS
   ============================================================

   1. Account balance is not equivalent to profitability.

   2. Transaction count is only a proxy for account engagement.

   3. The dataset contains only two account types:
          Savings
          Current

   4. The analysis does not include:
          - Account fees
          - Interest income
          - Cost to serve
          - Customer profitability
          - Account opening/closure dates

   Therefore, this analysis measures account activity and
   balance contribution rather than true product profitability.
*/