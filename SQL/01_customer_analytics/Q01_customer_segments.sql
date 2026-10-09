-- ============================================================
-- BANKING ANALYTICS PORTFOLIO
-- Q01: CUSTOMER SEGMENT ANALYSIS
-- ============================================================

-- ============================================================
-- BUSINESS QUESTION
-- ============================================================
--
-- Which customer segments contribute the most total deposits
-- and transaction value?
--
-- ============================================================
-- BUSINESS DEFINITIONS
-- ============================================================
--
-- Customer Segment:
-- Income-based quartile segmentation.
--
-- Deposit Value:
-- Sum of transactions where Transaction_Type = 'Deposit'.
--
-- Transaction Value:
-- Sum of Amount across all transactions.
--
-- ============================================================
-- SEGMENT RULES
-- ============================================================
--
-- Lower Income      <= 917,407
-- Mid-Lower Income  > 917,407 AND <= 1,620,501
-- Mid-Upper Income  > 1,620,501 AND <= 2,321,894
-- Higher Income     > 2,321,894
--
-- ============================================================
-- ANALYSIS QUERY
-- ============================================================

WITH customer_segments AS (

    SELECT
        Customer_ID,
        Annual_Income,

        CASE
            WHEN Annual_Income <= 917407
                THEN 'Lower Income'

            WHEN Annual_Income <= 1620501
                THEN 'Mid-Lower Income'

            WHEN Annual_Income <= 2321894
                THEN 'Mid-Upper Income'

            ELSE 'Higher Income'
        END AS Income_Segment

    FROM customers
),

customer_deposits AS (

    SELECT
        a.Customer_ID,

        SUM(
            CASE
                WHEN t.Transaction_Type = 'Deposit'
                THEN t.Amount
                ELSE 0
            END
        ) AS Total_Deposits,

        SUM(t.Amount) AS Total_Transaction_Value,

        COUNT(t.Transaction_ID) AS Transaction_Count

    FROM accounts a

    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID

    GROUP BY a.Customer_ID
),

customer_balances AS (

    SELECT
        Customer_ID,
        SUM(Balance) AS Total_Account_Balance

    FROM accounts

    GROUP BY Customer_ID
)

SELECT
    cs.Income_Segment,

    COUNT(*) AS Customer_Count,

    ROUND(
        SUM(COALESCE(cd.Total_Deposits, 0)),
        2
    ) AS Total_Deposits,

    ROUND(
        SUM(COALESCE(cd.Total_Transaction_Value, 0)),
        2
    ) AS Total_Transaction_Value,

    ROUND(
        AVG(COALESCE(cb.Total_Account_Balance, 0)),
        2
    ) AS Average_Account_Balance,

    SUM(
        COALESCE(cd.Transaction_Count, 0)
    ) AS Total_Transactions,

    ROUND(
        AVG(cs.Annual_Income),
        2
    ) AS Average_Income

FROM customer_segments cs

LEFT JOIN customer_deposits cd
    ON cs.Customer_ID = cd.Customer_ID

LEFT JOIN customer_balances cb
    ON cs.Customer_ID = cb.Customer_ID

GROUP BY cs.Income_Segment

ORDER BY Total_Transaction_Value DESC;


-- ============================================================
-- VALIDATION
-- ============================================================
--
-- Purpose:
-- Confirm that the analysis accounts for the complete
-- transaction dataset.
--
-- ============================================================

SELECT
    COUNT(*) AS Total_Transactions,

    ROUND(
        SUM(Amount),
        2
    ) AS Total_Transaction_Value,

    ROUND(
        SUM(
            CASE
                WHEN Transaction_Type = 'Deposit'
                THEN Amount
                ELSE 0
            END
        ),
        2
    ) AS Total_Deposit_Value

FROM transactions;


-- ============================================================
-- VALIDATION RESULT
-- ============================================================
--
-- Total Transactions:       50,000
-- Total Transaction Value:  ₹13,264,263,398
-- Total Deposit Value:      ₹6,608,558,736
--
-- Validation Status: PASSED
--
-- ============================================================
-- BUSINESS FINDING
-- ============================================================
--
-- Lower-income customers generated the highest gross
-- transaction activity and deposit value, despite having
-- substantially lower average account balances than the
-- other income segments.
--
-- This indicates that transaction activity and account
-- wealth are not necessarily concentrated in the same
-- customer segment.
--
-- ============================================================
-- BUSINESS ACTION
-- ============================================================
--
-- The bank should not evaluate customer value using account
-- balance alone. Lower-income customers may represent an
-- important high-engagement segment for transaction-based
-- products and targeted financial services.
--
-- ============================================================
-- ANALYTICAL LIMITATION
-- ============================================================
--
-- Transaction Value represents gross transaction activity.
-- It is NOT net cash flow and should not be interpreted as
-- customer profitability.
--
-- ============================================================