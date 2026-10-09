# ============================================================
# BANKING ANALYTICS PROJECT
# LOAD LOANS INTO MYSQL
# ============================================================

import os
from pathlib import Path

import pandas as pd
import mysql.connector


db_password = os.getenv("BANKING_DB_PASSWORD")
if not db_password:
    raise RuntimeError("Set BANKING_DB_PASSWORD before running this loader.")

db_host = os.getenv("BANKING_DB_HOST", "localhost")
db_user = os.getenv("BANKING_DB_USER", "root")
db_name = os.getenv("BANKING_DB_NAME", "banking_analytics_db")


# ============================================================
# LOAD CSV
# ============================================================

df = pd.read_csv(Path(__file__).resolve().parents[1] / "dataset" / "loans.csv")

print("Loans CSV loaded.")
print("Rows:", len(df))


# ============================================================
# CONNECT TO MYSQL
# ============================================================

connection = mysql.connector.connect(
    host=db_host,
    user=db_user,
    password=db_password,
    database=db_name
)

cursor = connection.cursor()

print("Connected to MySQL.")


# ============================================================
# INSERT DATA
# ============================================================

query = """
INSERT INTO loans
(
    Loan_ID,
    Customer_ID,
    Loan_Type,
    Loan_Amount,
    Interest_Rate,
    Loan_Status
)
VALUES (%s,%s,%s,%s,%s,%s)
"""

records = list(
    df[
        [
            "Loan_ID",
            "Customer_ID",
            "Loan_Type",
            "Loan_Amount",
            "Interest_Rate",
            "Loan_Status"
        ]
    ].itertuples(index=False, name=None)
)

cursor.executemany(query, records)

connection.commit()

print("Loans inserted:", cursor.rowcount)


# ============================================================
# CLOSE CONNECTION
# ============================================================

cursor.close()
connection.close()

print("MySQL connection closed.")