# ============================================================
# BANKING ANALYTICS PROJECT
# LOAD BRANCHES INTO MYSQL
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

df = pd.read_csv(Path(__file__).resolve().parents[1] / "dataset" / "branches.csv")

print("Branches CSV loaded.")
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
INSERT INTO branches
(
    Branch_ID,
    Branch_Name,
    City,
    Manager_Name
)
VALUES (%s,%s,%s,%s)
"""

records = list(
    df[
        [
            "Branch_ID",
            "Branch_Name",
            "City",
            "Manager_Name"
        ]
    ].itertuples(index=False, name=None)
)

cursor.executemany(query, records)

connection.commit()

print("Branches inserted:", cursor.rowcount)


# ============================================================
# CLOSE CONNECTION
# ============================================================

cursor.close()
connection.close()

print("MySQL connection closed.")