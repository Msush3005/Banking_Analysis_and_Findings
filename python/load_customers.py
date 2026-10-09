# ============================================================
# BANKING ANALYTICS PROJECT
# LOAD CUSTOMERS INTO MYSQL
# ============================================================
#
# PURPOSE:
# Load customer CSV data into the MySQL customers table.
#
# SOURCE:
# ../01_dataset/customers.csv
#
# DESTINATION:
# banking_analytics_db.customers
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

df = pd.read_csv(Path(__file__).resolve().parents[1] / "dataset" / "customers.csv")

print("Customers CSV loaded.")
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
INSERT INTO customers
(
    Customer_ID,
    Name,
    Age,
    Gender,
    City,
    Occupation,
    Annual_Income,
    Credit_Score
)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
"""

records = list(
    df[
        [
            "Customer_ID",
            "Name",
            "Age",
            "Gender",
            "City",
            "Occupation",
            "Annual_Income",
            "Credit_Score"
        ]
    ].itertuples(index=False, name=None)
)

cursor.executemany(query, records)

connection.commit()

print("Customers inserted:", cursor.rowcount)


# ============================================================
# CLOSE CONNECTION
# ============================================================

cursor.close()
connection.close()

print("MySQL connection closed.")