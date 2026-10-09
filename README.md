<img width="1024" height="1536" alt="ChatGPT Image Aug 24, 2026, 09_47_39 PM" src="https://github.com/user-attachments/assets/06c8ef82-8d0e-4ffd-ab9d-b913da4d3748" /># Banking Analytics — End-to-End SQL & Power BI

A practical banking analytics project built to answer business questions, not just produce charts.

I built this project around a simple idea: **the dashboard is only the last layer**. Before a number reaches Power BI, it should have a clear definition, a reliable SQL calculation, and a validation step behind it.

The project starts with a normalized MySQL database, moves through SQL analysis and reporting views, and ends with a Power BI model containing six business-focused dashboards.

> **Attribution:** This project is based on the work of [Vasanth Kumar (`Vasanthq121`)](https://github.com/Vasanthq121/banking_analysis_and_findings). The source README and author credit are retained. The source repository does not include a `LICENSE` file, so no license is implied or added here.

The included CSV datasets are synthetic and generated with Faker. Do not replace them with real customer or production banking data.

---

## Dashboard Preview

### 1. Bank Performance Overview

<img width="1920" height="1080" alt="Screenshot (138)" src="https://github.com/user-attachments/assets/90b8132c-95b2-4516-863a-6ddac029d785" />


The executive page gives a quick view of the bank's scale, deposits, loan exposure, transaction volume and activity trends.

**Questions this page answers**

- How large is the customer and account base?
- How much money is held as deposits?
- What is the current loan exposure?
- How is transaction activity changing over time?
- Which loan types contribute most to exposure?

---

### 2. Customer Analytics

<img width="1920" height="1080" alt="Screenshot (139)" src="https://github.com/user-attachments/assets/3f2b3113-407e-4164-bfa8-df2f573bbbf4" />


This page looks at customers from both a value and engagement perspective.

**Questions this page answers**

- How many customers are active vs inactive?
- Which cities have the largest customer base?
- Which customers have higher balances and transaction values?
- How are customers distributed across value/activity segments?
- Which customer groups should relationship teams prioritize?

---

### 3. Loan Risk

<img width="1920" height="1080" alt="Screenshot (140)" src="https://github.com/user-attachments/assets/3b6fbbdb-e9b0-4da1-bab8-b41390023a4c" />


The loan page separates portfolio analysis from risk analysis and uses a Loan-to-Income (LTI) based risk classification.

**Questions this page answers**

- How many loans fall into each risk category?
- What is the average LTI ratio?
- Which loan types have higher LTI values?
- How much exposure sits in each risk category?
- How many loans have been approved?

---

### 4. Branch Performance

<img width="1920" height="1080" alt="Screenshot (141)" src="https://github.com/user-attachments/assets/0e855561-94ef-455d-959a-07ca88391860" />


The branch page compares customer count, deposits, transactions and loan exposure across the physical branch network.

**Questions this page answers**

- Which branches have the largest deposit base?
- Which branches serve the most customers?
- Which branches generate the most transaction activity?
- Where is loan exposure concentrated?
- Which locations deserve closer operational review?

---

### 5. Product Analysis

<img width="1920" height="1080" alt="Screenshot (142)" src="https://github.com/user-attachments/assets/746cc6e8-d25b-4cc9-8272-0f4e4e926f72" />


This page compares account and loan products from an adoption and financial-contribution perspective.

**Questions this page answers**

- How are Savings and Current accounts distributed?
- Which loan products have the largest exposure?
- How many loans have been approved by product?
- Which account products contribute the most deposits?
- Where could product teams investigate cross-selling opportunities?

---

### 6. Transaction Activity

<img width="1920" height="1080" alt="Screenshot (143)" src="https://github.com/user-attachments/assets/36b81c6f-1dd0-4186-a50c-d97107ecea19" />


This page focuses on transaction volume, transaction value, active accounts and monthly movement.

**Questions this page answers**

- How much transaction activity is the bank processing?
- What is the average transaction value?
- How are deposits and withdrawals split?
- Which months have higher transaction activity?
- How many accounts are actively transacting?

---

# 1. What I Built

The project simulates the analytics environment of a retail bank with:

- **5,000 customers**
- **7,500 accounts**
- **50,000 transactions**
- **2,000 loan records**
- **10 branch IDs**
- **6 Power BI dashboards**

The data is synthetic and was generated with Python/Faker before being loaded into MySQL.

The important part of the project is not the synthetic data itself. It is the analytical workflow built on top of it:
<img width="1024" height="1536" alt="ChatGPT Image Aug 24, 2026, 09_47_39 PM" src="https://github.com/user-attachments/assets/06c2bcb6-5e6f-45ab-baa8-df6df8008a75" />



# 2. Business Problem

A bank can have customer, account, transaction, loan and branch data in separate tables. The difficult part is combining those datasets without producing misleading numbers.

For this project I focused on five practical areas:

1. **Customer understanding** — who are the valuable, active and inactive customers?
2. **Credit risk** — which borrowers have relatively high loan exposure compared with income?
3. **Branch performance** — which branches are contributing most to deposits, customers and activity?
4. **Product performance** — which account and loan products are being used and generating exposure?
5. **Transaction monitoring** — how much money is moving through the bank and how does activity change over time?

---

# 3. Architecture

The architecture intentionally keeps the operational database normalized while creating a reporting layer for analytics.

```text
                    ┌──────────────────────┐
                    │   Python + Faker     │
                    │ Synthetic Data       │
                    └──────────┬───────────┘
                               │ CSV
                               ▼
                    ┌──────────────────────┐
                    │       MySQL          │
                    │ Normalized RDBMS     │
                    │                      │
                    │ Customers            │
                    │ Accounts             │
                    │ Transactions         │
                    │ Loans                │
                    │ Branches             │
                    └──────────┬───────────┘
                               │
                               ▼
              ┌────────────────────────────────┐
              │ SQL Analytical / Reporting     │
              │ Views                          │
              │                                │
              │ Customer 360                   │
              │ Customer Segmentation          │
              │ Loan Risk                      │
              │ Branch Performance             │
              │ Product Analysis               │
              │ Transaction KPIs               │
              └────────────────┬───────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      Power BI        │
                    │ Hybrid Model         │
                    │ Star Schema + DAX    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Six Business         │
                    │ Dashboards            │
                    └──────────────────────┘
```

### Diagram placeholder

I want the repository to contain the final diagrams rather than making the README depend on text alone.

<img width="1536" height="1024" alt="ChatGPT Image Aug 24, 2026, 09_53_58 PM" src="https://github.com/user-attachments/assets/b0571fde-5402-4fa6-b914-2c36f8437816" />


# 4. Database Design

The operational database follows a normalized relational design.

### Main entities

```text
Customers
   │
   ├──────────── Accounts
   │                 │
   │                 └──────── Transactions
   │
   └──────────── Loans

Branches
   │
   └──────────── Accounts
```

<img width="701" height="1085" alt="ERRD" src="https://github.com/user-attachments/assets/f2776b0f-a190-4de7-a72f-23701aa4e6a6" />


The ERD should show the actual primary-key / foreign-key relationships used in the MySQL database.

---

# 5. Power BI Star Schema

The source database is normalized because it is an operational system. Power BI does not necessarily need to consume that structure exactly as-is.

For reporting, I used a hybrid approach:

- SQL views handle complex business logic and pre-aggregation.
- Dimensions and relationships support filtering and reusable DAX.
- Power BI follows Star Schema principles where they improve reporting clarity and performance.

### Star Schema placeholder

> **Insert Power BI Star Schema here:**
> <img width="1920" height="1080" alt="Screenshot (145)" src="https://github.com/user-attachments/assets/0b6ae876-5cb9-4962-9c80-aca710973ae2" />

A typical reporting structure is:

```text
                  Dim_Date
                     │
                     ▼
Dim_Customer ─── Fact / Analytical Views ─── Dim_Product
                     │
                     ├── Dim_Branch
                     │
                     └── Loan / Transaction analysis
```

Use the actual Power BI model screenshot in this section once the final model diagram is exported.

---

# 6. Why the SQL Reporting Layer Matters

One of the main technical problems in the project was **join multiplication**.

Suppose a customer has:

```text
2 accounts
2 loans
```

A direct join can produce:

```text
2 × 2 = 4 rows
```

If balances and loan amounts are summed after that join, the numbers can be overstated.

Instead of accepting that result, I changed the query design.

```text
Accounts       → aggregate by Customer
Transactions   → aggregate by Customer
Loans          → aggregate by Customer
                       ↓
                 Join summaries
                       ↓
                  Customer 360
```

This keeps the final customer-level grain controlled.

The same principle was used when designing branch and product reporting.

---

# 7. SQL Analysis

The project uses more than basic `SELECT` statements.

### SQL techniques used

- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `CASE`
- `COALESCE`
- Common Table Expressions (CTEs)
- Window functions
- `RANK() OVER()`
- `SUM() OVER()`
- Aggregation and pre-aggregation
- Analytical views
- Stored procedures
- Data validation queries
- KPI-specific reporting views

---

## Representative SQL

### Customer 360 pattern

The important part is aggregating each one-to-many area before joining:

```sql
WITH account_summary AS (
    SELECT
        Customer_ID,
        COUNT(*) AS Number_of_Accounts,
        SUM(Balance) AS Total_Balance
    FROM accounts
    GROUP BY Customer_ID
),
transaction_summary AS (
    SELECT
        a.Customer_ID,
        COUNT(t.Transaction_ID) AS Total_Transactions,
        COALESCE(SUM(t.Amount), 0) AS Total_Transaction_Value
    FROM accounts a
    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID
    GROUP BY a.Customer_ID
),
loan_summary AS (
    SELECT
        Customer_ID,
        COUNT(*) AS Total_Approved_Loans,
        SUM(Loan_Amount) AS Total_Loan_Exposure
    FROM loans
    WHERE Loan_Status = 'Approved'
    GROUP BY Customer_ID
)
SELECT
    c.Customer_ID,
    c.Name,
    c.City,
    c.Occupation,
    c.Annual_Income,
    COALESCE(a.Number_of_Accounts, 0) AS Number_of_Accounts,
    COALESCE(a.Total_Balance, 0) AS Total_Balance,
    COALESCE(t.Total_Transactions, 0) AS Total_Transactions,
    COALESCE(t.Total_Transaction_Value, 0) AS Total_Transaction_Value,
    COALESCE(l.Total_Approved_Loans, 0) AS Total_Approved_Loans,
    COALESCE(l.Total_Loan_Exposure, 0) AS Total_Loan_Exposure
FROM customers c
LEFT JOIN account_summary a
    ON c.Customer_ID = a.Customer_ID
LEFT JOIN transaction_summary t
    ON c.Customer_ID = t.Customer_ID
LEFT JOIN loan_summary l
    ON c.Customer_ID = l.Customer_ID;
```

---

## Loan Risk Logic

The project uses:

```text
LTI = Loan Amount / Annual Income
```

Risk tiers:

| LTI | Category |
|---:|---|
| `< 2` | Low Risk |
| `2 – <5` | Medium Risk |
| `5 – <10` | High Risk |
| `>= 10` | Critical Risk |

Example:

```sql
CASE
    WHEN Loan_Amount / NULLIF(Annual_Income, 0) < 2
        THEN 'Low Risk'
    WHEN Loan_Amount / NULLIF(Annual_Income, 0) < 5
        THEN 'Medium Risk'
    WHEN Loan_Amount / NULLIF(Annual_Income, 0) < 10
        THEN 'High Risk'
    ELSE 'Critical Risk'
END AS Risk_Category
```

---

## Branch Ranking

Window functions were used where ranking was more appropriate than a simple aggregate:

```sql
WITH branch_summary AS (
    SELECT
        b.Branch_ID,
        b.Branch_Name,
        SUM(a.Balance) AS Total_Deposits,
        COUNT(DISTINCT a.Customer_ID) AS Customer_Count
    FROM branches b
    LEFT JOIN accounts a
        ON b.Branch_ID = a.Branch_ID
    GROUP BY b.Branch_ID, b.Branch_Name
)
SELECT
    *,
    RANK() OVER (
        ORDER BY Total_Deposits DESC
    ) AS Deposit_Rank
FROM branch_summary;
```

---

## Transaction Analysis

```sql
SELECT
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS Year_Month,
    Transaction_Type,
    COUNT(*) AS Total_Transactions,
    SUM(Amount) AS Transaction_Value,
    AVG(Amount) AS Average_Transaction_Value
FROM transactions
GROUP BY
    DATE_FORMAT(Transaction_Date, '%Y-%m'),
    Transaction_Type
ORDER BY Year_Month, Transaction_Type;
```

This monthly aggregation is also useful for keeping Power BI trend visuals lighter than repeatedly calculating everything from the raw transaction table.

---

# 8. Analytical Views

The reporting layer contains business-oriented views such as:

```text
vw_customer_360
vw_customer_activity
vw_customer_primary_branch
vw_customer_value_segment
vw_high_value_customers

vw_approved_loan_portfolio
vw_loan_application_risk
vw_loan_product_analysis
vw_loan_product_risk_analysis
vw_loan_risk_analysis
vw_credit_risk_summary

vw_branch_performance
vw_branch_loan_reconciliation

vw_transaction_activity
vw_transaction_kpis

vw_account_product_analysis
vw_executive_kpis
```

The idea was to make the SQL layer understandable to the BI layer: each view answers a particular reporting requirement instead of making Power BI work directly with every raw-table relationship.

---

# 9. Power BI / DAX

Power BI was used for:

- Data modeling
- Interactive filtering
- KPI cards
- Trend analysis
- Ranking
- Customer segmentation
- Risk analysis
- Branch comparisons
- Product comparisons

One important example is active accounts.

```DAX
Active Accounts =
DISTINCTCOUNT(Transactions[Account_ID])
```

This avoids counting the same account repeatedly when transaction data is viewed across multiple reporting periods.

Other measures include:

```DAX
Average Transaction Value =
DIVIDE(
    [Total Transaction Value],
    [Total Transactions]
)
```

The general rule I followed was:

> Put reusable business logic and heavy aggregation in SQL where appropriate, and use DAX for calculations that need to respond dynamically to Power BI filters.

---

# 10. Dashboard Findings → Business Impact → Action

The dashboards are not presented as a collection of charts. Each page follows the same business-analysis flow:

```text
Dashboard
   ↓
What does the data show?
   ↓
What does it mean for the business?
   ↓
What could be impacted?
   ↓
What should management / the relevant team do?
```

This is the main idea behind the dashboard design: **a KPI is useful only when it leads to a business question or decision.**

---

## 10.1 Bank Performance Overview

<img width="1920" height="1080" alt="Screenshot (138)" src="https://github.com/user-attachments/assets/16976dfe-d2e2-42f3-9385-818a8ce7aadb" />

### Business purpose

Give senior management a single-page health check of the bank covering deposits, lending exposure, customers, accounts and transaction activity.

### Key metrics

| Metric | Current dashboard value | Why it matters |
|---|---:|---|
| Total Customers | 5,000 | Size of customer base |
| Total Accounts | 7,500 | Account penetration |
| Total Transactions | 50,000 | Operational activity |
| Total Deposits | ₹6,608.56M | Deposit base / funding |
| Loan Exposure | ₹8,437.57M* | Lending exposure |
| Loan Customers | 1,656 | Customers with loan exposure |
| Transaction Trend | Monthly | Shows activity stability and peaks |

\*The current screenshot shows ₹8,437.57M as complete loan exposure. The SQL/reporting definition should be reconciled with the earlier approved-loan portfolio metric before publishing the project as a final case study.

### What the dashboard tells us

- The bank has a **5,000-customer base and 7,500 accounts**, giving management a clear view of overall scale.
- Deposit balances are a major source of funding.
- Transaction activity remains relatively stable across the displayed period.
- Home and Car loans are among the larger contributors to loan exposure.
- The dashboard provides an executive starting point for investigating the balance between deposits, lending and transaction activity.

### Business impact

**Financial impact:** Helps management understand where the bank's capital and funding are concentrated.

**Growth impact:** A large existing customer base creates opportunities for additional lending and product penetration.

**Operational impact:** Monthly transaction trends provide a baseline for capacity and liquidity monitoring.

### Recommended business actions

1. Compare **deposit growth against approved lending exposure** before expanding the loan portfolio.
2. Investigate Home and Car loan concentration rather than increasing lending uniformly across products.
3. Monitor months where withdrawals materially exceed deposits.
4. Use the customer base to identify cross-selling and lending opportunities.
5. Add liquidity stress testing in a future version.

### Decision this dashboard supports

> **Should the bank focus next on lending growth, liquidity protection, or customer/product expansion?**

The answer should be based on the supporting pages rather than this executive page alone.

The underlying project analysis similarly identified a deposit-heavy position and recommended evaluating additional credit deployment subject to risk appetite and regulatory constraints. fileciteturn27file0L44-L49

---

## 10.2 Customer Analytics Dashboard

<img width="1920" height="1080" alt="Screenshot (139)" src="https://github.com/user-attachments/assets/8e007240-f274-4352-8093-e94204f2f2c4" />


### Business purpose

Help relationship managers understand **who the customers are, how active they are, and where customer value is concentrated**.

### Key metrics

| Metric | Current dashboard value | Why it matters |
|---|---:|---|
| Total Customers | 5,000 | Customer base |
| Active Customers | 3,907 | Current engagement |
| Inactive Customers | 1,093 | Re-engagement opportunity |
| Average Customer Balance | ₹8,34,163.65 | Financial value |
| Average Customer Income | ₹16,12,036.10 | Customer capacity |
| Total Transactions | 50,000 | Engagement |
| Customer Transaction Value | ₹13,264.26M | Money movement |

### Customer segmentation

The project uses customer value/activity logic to separate customers into meaningful groups.

```text
                 CUSTOMER VALUE
                       ↑
                       │
        High Value     │     High Value
        Low Activity   │     High Activity
                       │
───────────────────────┼────────────────────→ Activity
                       │
        Low Value      │     Low Value
        Low Activity   │     High Activity
                       │
```

The analysis identifies a substantial low-value/low-activity population while a smaller premium segment contributes significant value. The source analysis reports 39.22% of customers as Premium and recommends targeted retention/upsell rather than treating the entire customer base the same way. fileciteturn27file0L51-L56

### What the dashboard tells us

- **3,907 customers are active**, while **1,093 are inactive**.
- Customer value is not evenly distributed.
- Some cities contribute more customers/value than others.
- High-value customers can be identified for relationship-management attention.
- Low-activity customers represent a potential re-engagement pool.

### Business impact

**Revenue impact:** Higher-value customers can generate more revenue through additional products and services.

**Retention impact:** Identifying valuable but less-active customers creates an opportunity for proactive retention.

**Marketing impact:** Campaigns can be segmented instead of sending the same offer to all customers.

### Recommended business actions

| Segment | Action |
|---|---|
| High Value + High Activity | Retain, relationship management, premium services |
| High Value + Low Activity | Re-engagement and retention campaign |
| Low Value + High Activity | Cross-sell / upsell |
| Low Value + Low Activity | Low-cost digital engagement |

### Decision this dashboard supports

> **Which customers should receive attention first, and what type of action should they receive?**

Future improvement: add a churn model to identify customers likely to become inactive.

---

## 10.3 Loan Risk Dashboard

<img width="1920" height="1080" alt="Screenshot (140)" src="https://github.com/user-attachments/assets/3f254b6b-21a3-440d-b77a-074d4a2e5661" />


### Business purpose

Give credit teams a view of portfolio risk and identify borrowers that deserve additional review.

### Key metrics

| Metric | Current dashboard value | Why it matters |
|---|---:|---|
| Total Loan Records | 2,000 | Portfolio/application scale |
| Approved Loans | 665 | Approved lending |
| High Risk Loans | 274 | Credit monitoring |
| Average LTI | 2.80 | Borrower leverage |
| Total Loan Exposure | ₹8,437.57M* | Portfolio exposure |

### Risk logic

```text
LTI = Loan Amount / Annual Income

< 2       → Low Risk
2 – <5    → Medium Risk
5 – <10   → High Risk
≥ 10      → Critical Risk
```

The project uses LTI-based risk tiering in the analytical SQL layer. fileciteturn26file0L28-L37

### What the dashboard tells us

- The dashboard identifies **274 high-risk loans**.
- The average LTI is approximately **2.80**.
- Risk is not uniform across loan products.
- The detailed loan table allows analysts to move from portfolio-level risk to individual borrower review.

### Business impact

**Credit-risk impact:** High-LTI borrowers require more scrutiny because loan exposure is high relative to reported income.

**Loss-prevention impact:** Early identification gives credit teams an opportunity to review exposure before problems materialize.

**Portfolio impact:** Comparing risk by loan type helps prevent concentration in products with unfavorable risk characteristics.

### Recommended business actions

1. Create a review queue for loans with **LTI ≥ 5**.
2. Investigate income stability and existing customer exposure before approval/renewal.
3. Compare high-risk concentration by loan product.
4. Avoid using LTI as the only underwriting variable; combine it with credit score, income stability and existing exposure.
5. Add default-probability modelling as a future ML layer.

### Decision this dashboard supports

> **Which loans require additional credit review, and where is lending risk concentrated?**

---

## 10.4 Branch Performance Dashboard

<img width="1920" height="1080" alt="Screenshot (141)" src="https://github.com/user-attachments/assets/0059b535-73bb-4e79-b173-372a35c6fa63" />


### Business purpose

Compare branches using multiple operational and financial measures instead of judging branches by customer count alone.

### Key metrics

| Metric | Current dashboard value | Why it matters |
|---|---:|---|
| Active Branches | 10 | Operational footprint |
| Branch Customers | 3,908 | Customer coverage |
| Branch Deposits | ₹6,256.23M | Branch funding contribution |
| Loan Exposure | ₹8,437.57M | Lending contribution |
| Branch Transactions | 50,000 | Operational activity |

### What the dashboard tells us

The dashboard compares branches across:

- customer count
- deposits
- transactions
- loan exposure

This matters because a branch can be strong on one metric and weak on another.

For example:

```text
High Deposits + High Customers
        → Strong branch franchise

High Customers + Low Deposits
        → Acquisition / conversion opportunity

Low Customers + High Deposits
        → Valuable but concentrated customer base

High Transactions + Low Deposits
        → High activity but lower financial contribution
```

The project uses horizontal ranking charts to compare branch deposits, loan exposure and customer base. fileciteturn27file6L332-L336

### Business impact

**Resource allocation:** Helps operations teams compare branches before allocating staff and budgets.

**Growth impact:** High-customer but lower-value branches may need product-conversion strategies.

**Operational impact:** Transaction activity can help identify branches with heavier workloads.

### Recommended business actions

1. Rank branches using a balanced score rather than one KPI.
2. Investigate the top-performing branches and identify practices that can be replicated.
3. Review branches with high customer counts but relatively lower deposits.
4. Align staffing with transaction workload.
5. Investigate inactive branch records rather than deleting them from the operational database.

### Decision this dashboard supports

> **Where should the bank allocate people, marketing budget and branch-level targets?**

---

## 10.5 Product Analysis Dashboard

<img width="1920" height="1080" alt="Screenshot (142)" src="https://github.com/user-attachments/assets/ed83c283-2f91-4f99-82a3-4c54e6c229ac" />


### Business purpose

Understand which account and loan products customers use and where the bank's financial exposure is concentrated.

### Key metrics

| Metric | Current dashboard value | Why it matters |
|---|---:|---|
| Loan Products | 4 | Lending portfolio variety |
| Account Products | 2 | Account product variety |
| Total Loan Exposure | ₹8,437.57M* | Lending concentration |
| Total Deposits | ₹6,608.56M | Deposit contribution |
| Approved Loans | 665 | Lending adoption |

### What the dashboard tells us

- Savings and Current accounts are almost evenly split by account count.
- Home loans represent a major portion of lending exposure in the current analysis.
- Product adoption and financial contribution are not the same thing.
- A product with many customers is not automatically the product contributing the most money.

The source analysis specifically recommends monitoring product adoption and diversifying exposure where Home Loans dominate the portfolio. fileciteturn25file8L510-L515

### Business impact

**Revenue impact:** Product teams can prioritize products with strong customer adoption and financial contribution.

**Risk impact:** Concentration in one loan category can increase portfolio dependency on that product.

**Cross-sell impact:** Account and customer data can be used to identify customers who may be suitable for additional products.

### Recommended business actions

1. Investigate why Home Loans contribute the largest exposure.
2. Compare product profitability, not just loan amount.
3. Identify customers holding only one product for cross-selling.
4. Monitor product-level LTI and risk.
5. Build a Next Best Product model in a future phase.

### Decision this dashboard supports

> **Which products should the bank promote, improve, diversify or cross-sell?**

---

## 10.6 Transaction Activity Dashboard

<img width="1920" height="1080" alt="Screenshot (143)" src="https://github.com/user-attachments/assets/a9b3fc41-2751-4fa2-a637-fc5d09f34b2d" />


### Business purpose

Monitor transaction volume, transaction value and account activity over time.

### Key metrics

| Metric | Current dashboard value | Why it matters |
|---|---:|---|
| Active Accounts | 7,495 | Accounts currently transacting |
| Total Transactions | 50,000 | Transaction volume |
| Total Transaction Amount | ₹13,264.26M | Money movement |
| Average Transaction Value | ₹2,65,285.27 | Transaction size |

### What the dashboard tells us

- The bank processes **50,000 transactions** in the dataset.
- Total transaction value is approximately **₹13.26B**.
- Average transaction value is approximately **₹2.65L**.
- Deposit and withdrawal transaction counts are close to a 50/50 split.
- Monthly activity provides a useful operational baseline.

The project documentation explicitly separates transaction activity into volume, value, active-account and monthly-trend metrics. fileciteturn27file6L344-L354

### Business impact

**Liquidity impact:** Persistent withdrawal pressure could require closer liquidity monitoring.

**Operational impact:** Transaction peaks can help plan infrastructure and operational capacity.

**Risk impact:** Unusual transaction spikes can become inputs for future fraud/anomaly detection.

### Recommended business actions

1. Monitor monthly deposit vs withdrawal patterns.
2. Set alerts for unusual transaction spikes.
3. Use transaction frequency to identify highly engaged customers.
4. Use transaction behaviour as one signal for future credit-card/product targeting.
5. Add anomaly/fraud detection to the next version.

### Decision this dashboard supports

> **Is transaction activity normal, growing, concentrated in particular periods, or showing behaviour that needs investigation?**

---

## 10.7 How the Six Dashboards Work Together

The real value is not in looking at six dashboards separately.

They form a decision chain:

```text
BANK PERFORMANCE
"How is the bank doing?"
          ↓
CUSTOMER ANALYTICS
"Who creates the value?"
          ↓
LOAN RISK
"Where is the credit risk?"
          ↓
BRANCH PERFORMANCE
"Where is the performance coming from?"
          ↓
PRODUCT ANALYSIS
"What products drive adoption/exposure?"
          ↓
TRANSACTION ACTIVITY
"How are customers actually using the bank?"
```

This creates a much stronger business story than:

```text
SQL → charts → screenshots
```

The intended flow is:

```text
SQL
 ↓
Metric
 ↓
Finding
 ↓
Business Impact
 ↓
Action
 ↓
Decision
```

That is the standard I would use for every dashboard in this project.

# 11. Data Quality Decisions

A useful part of this project was deciding what **not** to delete.

During validation, Branch IDs **108 and 109** were found to have no account activity.

Instead of removing them:

```text
Branch 108 → retained as inactive
Branch 109 → retained as inactive
```

This keeps the operational database structurally complete while allowing analytical reporting to distinguish active branches from inactive records.

Another validation identified approximately **1,093 customers without active accounts**, which is why the Customer Analytics dashboard separates active and inactive customers.

---

# 12. Primary Branch Logic

A customer can have accounts associated with more than one branch.

If the same customer is counted fully under every branch, branch-level customer value can be duplicated.

For branch attribution, the project uses a deterministic rule:

> Assign the customer to the branch associated with the customer's earliest account opening.

This is an **analytical attribution rule**. It does not change the underlying customer-account relationships.

---

# 13. Stored Procedures

The project also uses stored procedures for operational lookups.

Example:

```sql
CREATE PROCEDURE sp_Get_Customer_Transaction_Summary (
    IN cust_id_input INT
)
BEGIN

    SELECT
        c.Customer_ID,
        c.Name,
        COUNT(t.Transaction_ID) AS Total_Transactions,
        COALESCE(SUM(t.Amount), 0) AS Total_Transaction_Value,
        COALESCE(AVG(t.Amount), 0) AS Average_Transaction_Value
    FROM customers c
    LEFT JOIN accounts a
        ON c.Customer_ID = a.Customer_ID
    LEFT JOIN transactions t
        ON a.Account_ID = t.Account_ID
    WHERE c.Customer_ID = cust_id_input
    GROUP BY c.Customer_ID, c.Name;

END;
```

The procedure provides a reusable customer-level transaction summary instead of requiring an operational user to understand the underlying joins.

---

# 14. Problems I Ran Into

This is probably the most important section for an interviewer because it shows how the project was actually built.

### Problem 1 — Join multiplication

**Issue:** Joining customers, accounts, transactions and loans directly could inflate balances and loan amounts.

**Solution:** Aggregate each one-to-many source independently before joining.

---

### Problem 2 — Branch attribution

**Issue:** A customer may have accounts in multiple branches.

**Solution:** Define a deterministic primary-branch rule for branch-level customer attribution.

---

### Problem 3 — Loan application vs loan exposure

**Issue:** Pending and rejected applications should not automatically become active lending exposure.

**Solution:** Keep origination analysis and approved portfolio analysis as separate analytical views.

---

### Problem 4 — Distinct counts over time

**Issue:** Summing monthly active-account counts can count the same account multiple times.

**Solution:** Use a dedicated KPI calculation with `DISTINCTCOUNT`.

---

### Problem 5 — Running totals

**Issue:** Multiple transactions can occur on the same date.

**Solution:** Use a deterministic ordering such as:

```sql
ORDER BY Transaction_Date, Transaction_ID
```

when calculating a running total.

---

# 15. Project Structure

```text
PowerBI/
  Banking_Analytics_End_to_End Project.pbix
  Dashboards/                 # Dashboard screenshots
SQL/
  00_business_questions.sql
  01_customer_analytics/      # Q01-Q04
  02_transaction_analytics/  # Q05-Q08
  03_loan_risk_analytics/     # Q09-Q12
  04_branch_analytics/        # Q13-Q16
  05_account_analytics/       # Q17-Q20
database/
  banking_analytics_db.sql    # MySQL schema and synthetic data dump
  data_dictionary.json
  README.md
dataset/
  accounts.csv
  branches.csv
  customers.csv
  loans.csv
  transactions.csv
documentation/
  Banking_Analytics_Queries_and_Use_Cases_Summary.docx
  Workflow.docx
python/
  generate_banking_dataset (1).ipynb
  load_*.py
```

---

# 16. How to Run the Project

### Requirements

- Python 3.11 or newer
- MySQL 8.0 and the MySQL command-line client
- Power BI Desktop and the MySQL connector to open and refresh the `.pbix` file

### Set up Python

From the repository root in PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

The requirements cover the dataset notebook (Faker, Pandas and NumPy), the MySQL CSV loaders, and an IPython kernel for VS Code notebooks.

### Set up MySQL

The supplied `database/banking_analytics_db.sql` dump contains both table definitions and synthetic records. It is UTF-16 encoded and includes statements that drop and recreate tables. Import it only into a **new, dedicated project database**; do not run it against an existing database with data you need.

```powershell
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS banking_analytics_db;"
python -c "from pathlib import Path; p=Path('database/banking_analytics_db.sql'); p.with_name('banking_analytics_db.utf8.sql').write_text(p.read_text(encoding='utf-16'), encoding='utf-8')"
cmd /c 'mysql -u root -p banking_analytics_db < database\banking_analytics_db.utf8.sql'
Remove-Item database\banking_analytics_db.utf8.sql
```

Configure loader connections in the current PowerShell session. Enter the password at the secure prompt; do not put it in a source file or command history:

```powershell
$env:BANKING_DB_HOST = "localhost"
$env:BANKING_DB_USER = "root"
$env:BANKING_DB_NAME = "banking_analytics_db"
$securePassword = Read-Host "MySQL password" -AsSecureString
$env:BANKING_DB_PASSWORD = [System.Net.NetworkCredential]::new("", $securePassword).Password
```

The `python/load_*.py` scripts read the CSVs from the repository's `dataset/` folder. They write to MySQL; `load_transactions.py` also truncates its staging table. The bundled SQL dump already contains the synthetic data, so **do not run the loaders after importing that dump** or the rows may be duplicated. Only run loaders against a separate, appropriately prepared empty database. Clear the session password when finished:

```powershell
Remove-Item Env:BANKING_DB_PASSWORD
```

### Run the analysis

- Run the MySQL 8-compatible queries in `SQL/` against the imported database. The 20 individual analyses are grouped by customer, transaction, loan risk, branch and account topics.
- Open `PowerBI/Banking_Analytics_End_to_End Project.pbix` in Power BI Desktop, configure its MySQL connection, and refresh the model.
- The five CSV files in `dataset/` contain synthetic sample data. Never substitute real customer records or production banking exports in a public repository.

---

# 17. What I Learned

The biggest lesson from this project was that **building a dashboard is much easier than building a trustworthy dashboard**.

The difficult parts were:

- understanding table grain
- checking cardinality
- preventing duplicated metrics
- deciding business definitions
- separating operational data from analytical data
- validating SQL against source tables
- deciding what should happen in SQL vs DAX
- designing dashboards around actual business questions

The project therefore became less about "Power BI visuals" and more about the complete path from data to decision.

---

# 18. Future Improvements

If this were moved closer to a production banking analytics environment, I would add:

- automated data-quality checks
- incremental data refresh
- fraud/anomaly detection
- customer churn prediction
- loan default prediction
- customer lifetime value modeling
- branch profitability
- liquidity stress testing
- automated alerts for unusual transaction behaviour
- Power BI Service deployment and scheduled refresh

---

# 19. Tools Used

| Area | Tools |
|---|---|
| Database | MySQL |
| SQL | MySQL SQL |
| BI | Power BI |
| Calculations | DAX |
| Data generation | Python, Faker |
| Data format | CSV |
| Modeling | Normalized RDBMS + Star Schema |
| Analysis | SQL Views, CTEs, Window Functions |
| Operational logic | Stored Procedures |

---

# 20. Final Takeaway

This project was built to show the complete analytics workflow:

```text
Raw Data
   ↓
Database Design
   ↓
Data Validation
   ↓
SQL Analysis
   ↓
Business Rules
   ↓
Analytical Views
   ↓
Power BI Model
   ↓
DAX
   ↓
Dashboards
   ↓
Business Findings
```

The dashboards are the visible part of the project.

The more important part is the work underneath them: defining the grain of the data, preventing incorrect aggregations, creating reusable SQL logic, validating the numbers, and then presenting the results in a way that a business user can actually use.

---

## Author

**Vasanth Kumar**

B.Tech — Computer Science & Systems Engineering

Interested in:

- Data Analytics
- SQL
- Power BI
- Business Intelligence
- Machine Learning
- AI/ML
- AI Assistants

---

### Notes before publishing

- The screenshots in this README are the actual dashboard screenshots supplied with the project.
- Replace the four diagram placeholders with the final architecture, ERD, database-schema and Power BI star-schema images.
- Keep the SQL scripts in the repository so recruiters can inspect the actual implementation.
- The numerical findings above are based on the values currently visible in the supplied Power BI screenshots. Before presenting this as a production-style case study, reconcile the loan-exposure definition across SQL and Power BI so the same metric is not described with two different totals.
