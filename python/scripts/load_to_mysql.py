import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from pathlib import Path

# ==========================================================
# MySQL Configuration
# ==========================================================

USERNAME = "root"
PASSWORD = "Sagar@123"
HOST = "localhost"
PORT = 3306
DATABASE = "retail_business_intelligence"

connection_url = URL.create(
    "mysql+pymysql",
    username=USERNAME,
    password=PASSWORD,
    host=HOST,
    port=PORT,
    database=DATABASE,
)

engine = create_engine(connection_url)

# ==========================================================
# Project Directory
# ==========================================================

BASE_DIR = Path(r"D:\Retail-Business-Intelligence-Platform")

RAW = BASE_DIR / "data" / "raw"
PROCESSED = BASE_DIR / "data" / "processed"

# ==========================================================
# CSV Files
# ==========================================================

files = {
    "category_translation": RAW / "product_category_name_translation.csv",
    "customers": RAW / "olist_customers_dataset.csv",
    "sellers": RAW / "olist_sellers_dataset.csv",
    "products": PROCESSED / "products_clean.csv",
    "orders": RAW / "olist_orders_dataset.csv",
    "payments": RAW / "olist_order_payments_dataset.csv",
    "reviews": PROCESSED / "reviews_clean.csv",
    "order_items": RAW / "olist_order_items_dataset.csv",
    "geolocation": PROCESSED / "geolocation_clean.csv",
}

# ==========================================================
# Test Connection
# ==========================================================

print("=" * 60)
print("Testing MySQL Connection...")
print("=" * 60)

with engine.connect() as conn:
    print("✅ Connected Successfully!\n")

# ==========================================================
# Import Tables
# ==========================================================

for table, filepath in files.items():
    print("=" * 60)
    print(f"Loading Table : {table}")
    print("=" * 60)

    if not filepath.exists():
        print(f"❌ File not found : {filepath}")
        continue

    print("Reading CSV...")

    df = pd.read_csv(filepath)

    print(f"Rows    : {len(df):,}")
    print(f"Columns : {len(df.columns)}")

    try:
        with engine.begin() as conn:
            conn.execute(text(f"DELETE FROM {table}"))

        df.to_sql(
            table,
            con=engine,
            if_exists="append",
            index=False,
            chunksize=1000,
            method="multi",
        )

        with engine.connect() as conn:
            total = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()

        print(f"✅ Imported Successfully")
        print(f"Rows in MySQL : {total:,}\n")

    except Exception as e:
        print(f"❌ Error importing {table}")
        print(e)
        print()

print("=" * 60)
print("ALL TABLES IMPORTED")
print("=" * 60)
