# ============================================================
# BANKING ANALYTICS PROJECT
# TRANSACTION DATA ETL PIPELINE
# ============================================================
#
# PURPOSE:
# 1. Read transaction data from CSV.
# 2. Validate and clean the data using Pandas.
# 3. Connect to MySQL.
# 4. Load data into the staging_transactions table.
# 5. Verify that all records were inserted successfully.
#
# SOURCE:
# ../01_dataset/transactions.csv
#
# DATABASE:
# banking_analytics_db
#
# STAGING TABLE:
# staging_transactions
#
# EXPECTED RECORDS:
# 50,000
#
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
# STEP 1: LOAD TRANSACTION CSV
# ============================================================

df = pd.read_csv(Path(__file__).resolve().parents[1] / "dataset" / "transactions.csv")

print("CSV loaded successfully.")
print("Rows:", len(df))
print("Columns:", df.columns.tolist())


# ============================================================
# STEP 2: VALIDATE TRANSACTION IDs
# ============================================================

duplicate_ids = df["Transaction_ID"].duplicated().sum()

print("Duplicate Transaction IDs:", duplicate_ids)

if duplicate_ids > 0:
    raise ValueError(
        "Duplicate Transaction_ID values found."
    )


# ============================================================
# STEP 3: CLEAN / CONVERT DATA TYPES
# ============================================================

df["Transaction_ID"] = pd.to_numeric(
    df["Transaction_ID"],
    errors="raise"
).astype(int)

df["Account_ID"] = pd.to_numeric(
    df["Account_ID"],
    errors="raise"
).astype(int)

df["Transaction_Date"] = df[
    "Transaction_Date"
].astype(str)

df["Transaction_Type"] = df[
    "Transaction_Type"
].astype(str)

df["Amount"] = pd.to_numeric(
    df["Amount"],
    errors="raise"
)

df["Transaction_Channel"] = df[
    "Transaction_Channel"
].astype(str)

df["Transaction_Category"] = df[
    "Transaction_Category"
].astype(str)


# Transaction_Month contains values such as:
# 2024-04
# 2025-04
# 2026-03
#
# Therefore it is stored as text.

df["Transaction_Month"] = df[
    "Transaction_Month"
].astype(str)


df["Transaction_Year"] = pd.to_numeric(
    df["Transaction_Year"],
    errors="raise"
).astype(int)


# Transaction_Day contains:
# Monday, Tuesday, Wednesday, etc.
#
# Therefore it is stored as text.

df["Transaction_Day"] = df[
    "Transaction_Day"
].astype(str)


df["High_Value_Flag"] = pd.to_numeric(
    df["High_Value_Flag"],
    errors="raise"
).astype(int)


# ============================================================
# STEP 4: CHECK FOR NULL VALUES
# ============================================================

null_count = df.isnull().sum().sum()

print("Total NULL values:", null_count)

if null_count > 0:
    raise ValueError(
        "NULL values found in transaction data."
    )


# ============================================================
# STEP 5: CONNECT TO MYSQL
# ============================================================

connection = mysql.connector.connect(
    host=db_host,
    user=db_user,
    password=db_password,
    database=db_name
)

cursor = connection.cursor()

print("Connected to MySQL successfully.")


# ============================================================
# STEP 6: CLEAR STAGING TABLE
# ============================================================
#
# The staging table is used as a temporary ETL layer.
#
# Existing staging records are removed before loading
# the current dataset.
#
# ============================================================

cursor.execute(
    "TRUNCATE TABLE staging_transactions"
)

connection.commit()

print("Staging table cleared.")


# ============================================================
# STEP 7: INSERT QUERY
# ============================================================

insert_query = """
INSERT INTO staging_transactions
(
    Transaction_ID,
    Account_ID,
    Transaction_Date,
    Transaction_Type,
    Amount,
    Transaction_Channel,
    Transaction_Category,
    Transaction_Month,
    Transaction_Year,
    Transaction_Day,
    High_Value_Flag
)
VALUES
(
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s
)
"""


# ============================================================
# STEP 8: PREPARE RECORDS
# ============================================================

records = list(
    df[
        [
            "Transaction_ID",
            "Account_ID",
            "Transaction_Date",
            "Transaction_Type",
            "Amount",
            "Transaction_Channel",
            "Transaction_Category",
            "Transaction_Month",
            "Transaction_Year",
            "Transaction_Day",
            "High_Value_Flag"
        ]
    ].itertuples(
        index=False,
        name=None
    )
)

print("Records prepared:", len(records))


# ============================================================
# STEP 9: INSERT DATA
# ============================================================

try:

    cursor.executemany(
        insert_query,
        records
    )

    connection.commit()

    print("Transaction data inserted successfully.")
    print("Rows inserted:", len(records))

except Exception as error:

    connection.rollback()

    print("ERROR:")
    print(error)

    print("Transaction load rolled back.")

    cursor.close()
    connection.close()

    raise


# ============================================================
# STEP 10: VERIFY MYSQL ROW COUNT
# ============================================================

cursor.execute(
    "SELECT COUNT(*) FROM staging_transactions"
)

row_count = cursor.fetchone()[0]

print(
    "Rows currently in staging_transactions:",
    row_count
)


# ============================================================
# STEP 11: VERIFY SAMPLE DATA
# ============================================================

cursor.execute("""
    SELECT
        Transaction_ID,
        Account_ID,
        Transaction_Date,
        Transaction_Type,
        Amount,
        Transaction_Channel,
        Transaction_Category,
        Transaction_Month,
        Transaction_Year,
        Transaction_Day,
        High_Value_Flag
    FROM staging_transactions
    LIMIT 5
""")

sample_rows = cursor.fetchall()

print("\nSample rows from MySQL:")

for row in sample_rows:
    print(row)


# ============================================================
# STEP 12: CLOSE MYSQL CONNECTION
# ============================================================

cursor.close()
connection.close()

print("\nMySQL connection closed.")