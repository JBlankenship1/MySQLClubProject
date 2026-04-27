# 1. Edit a Python source code either on your own local computer or directly on a Multilab server
#        * If you write Python code on your own computer, use the following steps to copy it to a Multilab server
#           a) cd directoryWherePythonFileIsStored
#           b) For Macbook:
#                    scp ./filename yourLinkBlueID@lily.cs.uky.edu:~/destDirectory/ 
#              For Windows:
#                    scp .\filename yourLinkBlueID@lily.cs.uky.edu:~\destDirectory\
# 2. Run the Python program on a Multilab server by executing: python3 exampleSQLConnector.py

import mysql.connector

# Connect to the database
dbConnection = mysql.connector.connect(
        host = "mysql.cs.uky.edu",
        user = "yourLinkBlueID",
        password = "yourMySQLpassword",
        database = "yourLinkBlueID"
        )

# Create a MySQL cursor 
dbCursor = dbConnection.cursor()

# Read a table and use certain columns
dbCursor.execute("select cno, name from courses")

print("\nCourses(cno, name):")
# Loop through query results
for row in dbCursor:
    print(row)
print("\nNumber of rows:", dbCursor.rowcount)

sqlStatement = "insert into courses values (%s, %s, %s)"
values = ("CS800", "Seminar", 3)
dbCursor.execute(sqlStatement, values)

# IMPORTANT: save changes into the database
# Without commit, the change  
#        - will not be visiable to other sessions, and 
#        - will not persist after this program (session) ends
dbConnection.commit()   

# Read a table
dbCursor.execute("select * from courses")

print("\nCourses:")
for row in dbCursor:
    print(row[0], row[1], row[2])
print("\nNumber of rows:", dbCursor.rowcount)


dbCursor.close()
dbConnection.close()








