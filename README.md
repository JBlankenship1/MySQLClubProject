## MySQLClubProject

# Special Note

Because pushing files with password and login info for the rose DB is unsafe, we initially created a .env file (with a .gitignore) that prevented sensitive info from being pushing. Alas, roseDB does not allow the pip install to support this, so the Interface.py file needs to be seperately changed in order to run. This should not be done with the github file for security.

# Requirements
    1. Our Python code requires Python Version 3.1 or above
    2. Python code also requires mysql.connector: pip install mysql-connector-python


# How to run code

1. Login to RoseDB or any db with credentials
2. Copy Interface.py and Database.sql to the server or your local working directory
3. Edit mysql.connector.connect() and update live connection information (as .env package cant get downloaded). Code should be edited as follows:

    mysql.connector.connect(
    host="mysql.cs.uky.edu",
    user="your_linkblue_id",
    password="your_password",
    database="your_linkblue_id"
)

4. Login to your DB: using mysql -h mysql.cs.uky.edu -u <your_linkblue_id> -p
5. Access DB: USE <your_linkblue_id>
6. Run database initialization: source Database.sql
7. Exit database: exit
8. Run file: python3 Interface.py
9. The menu will display numbered options to add, view, update, and delete records. Enter the number corresponding to your choice

# Notes on where code we did not write came from:

• The base Interface.py code came from lecture class.

• Rollback code (as input checking each input for each choice was much too tedious and 
removes the need for the error checking in the DB) came from https://www.geeksforgeeks.org/python/commit-rollback-operation-in-python/. This code explained how to use rollbacks with a try: and except: method.

• Fetchall code (as I wanted a way to show modified tables after code was ran without hardcoding each possiblility) came from https://www.geeksforgeeks.org/dbms/querying-data-from-a-database-using-fetchone-and-fetchall/. This code explained and implemented how to use a fetchall method.

• Match case code was also used as I forgot the syntax as it differs from C's switch statement: https://www.freecodecamp.org/news/python-switch-statement-switch-case-example/. This code just gave a simple image showing the syntax for regular vs default case.

OpenAI. (2026). ChatGPT (April 27 version) [Large language model]. https://chat.openai.com/
Used to generate sample data for this assignment 

