/* ============================================================
   Q19. CUSTOMER PRODUCT PENETRATION
   ============================================================

   BUSINESS QUESTION:
   Which customers have strong existing relationships with
   the bank but low account-product penetration?

   BUSINESS OBJECTIVE:
   Identify customers who may represent cross-selling
   opportunities because they have an existing banking
   relationship but use a limited number of account products.

   PRODUCT PENETRATION MEASURE:
   Number of distinct account types held by a customer.

   Available account types:
       - Savings
       - Current
*/


USE banking_analytics_db;


/* ============================================================
   1. CUSTOMER PRODUCT PENETRATION
   ============================================================ */

WITH customer_products AS
(
    SELECT

        c.Customer_ID,
        c.Name,
        c.Annual_Income,
        c.Credit_Score,

        COUNT(DISTINCT a.Account_Type)
            AS Distinct_Account_Types,

        COUNT(DISTINCT a.Account_ID)
            AS Account_Count,

        COALESCE(
            SUM(a.Balance),
            0
        ) AS Total_Balance,

        COUNT(DISTINCT t.Transaction_ID)
            AS Transaction_Count,

        COALESCE(
            SUM(t.Amount),
            0
        ) AS Transaction_Value

    FROM customers c

    LEFT JOIN accounts a
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

    Customer_ID,
    Name,
    Annual_Income,
    Credit_Score,

    Distinct_Account_Types,
    Account_Count,

    ROUND(
        Total_Balance,
        2
    ) AS Total_Balance,

    Transaction_Count,

    ROUND(
        Transaction_Value,
        2
    ) AS Transaction_Value,

    CASE

        WHEN Distinct_Account_Types = 1
             AND Total_Balance >= 500000

        THEN 'High Value - Low Product Penetration'

        WHEN Distinct_Account_Types = 1
             AND Transaction_Count >= 30

        THEN 'Highly Engaged - Low Product Penetration'

        WHEN Distinct_Account_Types = 1

        THEN 'Single Product Customer'

        WHEN Distinct_Account_Types >= 2

        THEN 'Multi Product Customer'

        ELSE 'No Account'

    END AS Product_Penetration_Segment

FROM customer_products

ORDER BY

    CASE
        WHEN Distinct_Account_Types = 1
             AND Total_Balance >= 500000
            THEN 1

        WHEN Distinct_Account_Types = 1
             AND Transaction_Count >= 30
            THEN 2

        WHEN Distinct_Account_Types = 1
            THEN 3

        WHEN Distinct_Account_Types >= 2
            THEN 4

        ELSE 5
    END,

    Total_Balance DESC;


/* ============================================================
   2. PRODUCT PENETRATION SUMMARY
   ============================================================ */

WITH customer_products AS
(
    SELECT

        c.Customer_ID,

        COUNT(DISTINCT a.Account_Type)
            AS Distinct_Account_Types,

        COALESCE(
            SUM(a.Balance),
            0
        ) AS Total_Balance,

        COUNT(DISTINCT t.Transaction_ID)
            AS Transaction_Count

    FROM customers c

    LEFT JOIN accounts a
        ON c.Customer_ID = a.Customer_ID

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY
        c.Customer_ID
)

SELECT

    CASE

        WHEN Distinct_Account_Types = 0
            THEN 'No Account'

        WHEN Distinct_Account_Types = 1
            THEN 'Single Product'

        ELSE 'Multi Product'

    END AS Product_Segment,

    COUNT(*) AS Customer_Count,

    ROUND(
        AVG(Total_Balance),
        2
    ) AS Average_Balance,

    ROUND(
        AVG(Transaction_Count),
        2
    ) AS Average_Transactions,

    ROUND(
        SUM(Total_Balance),
        2
    ) AS Total_Balance

FROM customer_products

GROUP BY

    CASE

        WHEN Distinct_Account_Types = 0
            THEN 'No Account'

        WHEN Distinct_Account_Types = 1
            THEN 'Single Product'

        ELSE 'Multi Product'

    END

ORDER BY
    Total_Balance DESC;


/* ============================================================
   3. HIGH-VALUE SINGLE-PRODUCT CUSTOMERS
   ============================================================

   These customers are particularly important because they
   already have meaningful balances but hold only one account
   product.
*/

WITH customer_products AS
(
    SELECT

        c.Customer_ID,
        c.Name,

        COUNT(DISTINCT a.Account_Type)
            AS Distinct_Account_Types,

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
        c.Name
)

SELECT

    Customer_ID,
    Name,

    Distinct_Account_Types,

    ROUND(
        Total_Balance,
        2
    ) AS Total_Balance,

    Transaction_Count

FROM customer_products

WHERE Distinct_Account_Types = 1

  AND Total_Balance >= 500000

ORDER BY
    Total_Balance DESC;


/* ============================================================
   4. VALIDATION
   ============================================================ */

SELECT

    COUNT(DISTINCT Customer_ID)
        AS Customers_With_Accounts,

    COUNT(
        DISTINCT Account_Type
    ) AS Available_Account_Types

FROM accounts;


/* ============================================================
   FINDINGS
   ============================================================

   The analysis separates customers into:

       No Product
       Single Product
       Multi Product

   The most important cross-selling segment is:

       Single Product
       +
       High Balance

   These customers already demonstrate a meaningful financial
   relationship with the bank but use only one account type.

   Another useful segment is:

       Single Product
       +
       High Transaction Activity

   These customers demonstrate strong engagement but have
   limited product penetration.

   IMPORTANT:

   Do not assume every single-product customer needs another
   product. Cross-selling should be based on suitability,
   customer profile and actual financial needs.


/* ============================================================
   FINAL BUSINESS ACTIONS
   ============================================================

   ACTION 1 — HIGH-VALUE CROSS-SELL
   ---------------------------------
   Prioritize high-balance customers holding only one account
   type for personalized product recommendations.


   ACTION 2 — ENGAGED CUSTOMER CROSS-SELL
   --------------------------------------
   Customers with high transaction activity but only one
   account type can be evaluated for complementary products.


   ACTION 3 — PRODUCT BUNDLING
   ---------------------------
   Consider appropriate combinations of:
       - Savings
       - Current
       - Deposit products
       - Loan products

   where supported by customer eligibility and needs.


   ACTION 4 — CUSTOMER PRIORITIZATION
   ----------------------------------
   Do not target all single-product customers equally.

   Prioritize using:

       Customer Value
             +
       Engagement
             +
       Credit Profile
             +
       Income
             +
       Existing Product Usage


   FINAL BUSINESS DECISION:

   Product penetration should be used to identify
   cross-selling opportunities, but recommendations should
   be personalized rather than based solely on account count.


/* ============================================================
   LIMITATIONS
   ============================================================

   1. The dataset contains only two account types:
          Savings
          Current

   2. Therefore, product penetration is limited to these
      account types.

   3. The analysis does not include:
          - Credit cards
          - Insurance
          - Investments
          - Fixed deposits
          - Other banking products

   4. Holding one product does not necessarily mean the
      customer is under-served.

   5. Product suitability cannot be determined solely from
      balance, income and transaction activity.
*/