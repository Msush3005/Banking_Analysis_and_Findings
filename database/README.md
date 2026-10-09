# Banking Analytics Portfolio Dataset

Synthetic, business-oriented relational banking dataset derived from the supplied
Customers, Accounts, Transactions, Loans and Branches files.

## Tables
- customers.csv — 5,000 customers
- accounts.csv — 7,500 accounts
- transactions.csv — 50,000 transactions
- loans.csv — 2,000 loans/applications
- branches.csv — 10 branches

## Important
This is synthetic portfolio data. It is designed to support SQL, Power BI and
business-analysis exercises; it must not be presented as real bank customer data.

## Recommended analysis flow
Raw tables → data-quality checks → MySQL → analytical SQL views → Power BI.

## Important analytical caution
Loan risk fields such as Default_Flag, Delinquency_Days and Estimated_Monthly_EMI
are synthetic simulation fields. They are useful for portfolio analysis and SQL
practice, but they are not a real bank credit-risk model.
