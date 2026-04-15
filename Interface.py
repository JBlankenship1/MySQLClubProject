from dotenv import load_dotenv
import os
import mysql.connector

# Load variables from .env file
load_dotenv()

dbConnection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

# Create a mySQL cursor object to interact with the database
dbCursor = dbConnection.cursor()

# Read a table by issuing a select statement query to the database
dbCursor.execute("select cno, name from courses")

print("\nCourses(cno,name)")

for row in dbCursor:
    print(row)
    
print("\nNumber of rows: ", dbCursor.rowcount)

dbCursor.close()
dbConnection.close()