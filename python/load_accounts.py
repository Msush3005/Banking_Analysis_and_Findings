# ============================================================
# BANKING ANALYTICS PROJECT
# LOAD ACCOUNTS INTO MYSQL
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

df = pd.read_csv(Path(__file__).resolve().parents[1] / "dataset" / "accounts.csv")

print("Accounts CSV loaded.")
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
INSERT INTO accounts
(
    Account_ID,
    Customer_ID,
    Branch_ID,
    Account_Type,
    Balance
)
VALUES (%s,%s,%s,%s,%s)
"""

records = list(
    df[
        [
            "Account_ID",
            "Customer_ID",
            "Branch_ID",
            "Account_Type",
            "Balance"
        ]
    ].itertuples(index=False, name=None)
)

cursor.executemany(query, records)

connection.commit()

print("Accounts inserted:", cursor.rowcount)


# ============================================================
# CLOSE CONNECTION
# ============================================================

cursor.close()
connection.close()

print("MySQL connection closed.")