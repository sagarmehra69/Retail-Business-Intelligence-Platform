from sqlalchemy import create_engine
from sqlalchemy.engine import URL

connection_url = URL.create(
    "mysql+pymysql",
    username="root",
    password="Sagar@123",
    host="localhost",
    port=3306,
    database="retail_business_intelligence"
)

engine = create_engine(connection_url)

with engine.connect() as conn:
    print("✅ Connected to MySQL successfully!")
    