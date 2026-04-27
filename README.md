## MySQLClubProject

# Special Note

Because pushing files with password and login info for the rose DB is unsafe, we initially created a .env file (with a .gitignore) that prevented sensitive info from being pushing. Alas, roseDB does not allow the pip install to support this, so the Interface.py file needs to be seperately changed in order to run. This should not be done with the github file for security.

# Requirements
Our Python code requires Python Version 3.1 or above

# How to run code


1. Login to RoseDB or any db with credentials
2. Move or export Interface.py and Database.sql into DB
3. Edit mysql.connector.connect() and update live connection information (as .env package cant get downloaded)
4. Login to your DB: using mysql -h mysql.cs.uky.edu -u linkblue -p
5. Access DBL USE linkblue
6. Run database initialization: source Database.sql
7. Exit database: exit
8. Run file: python3 Interface.py
9. Edit view and delete database with displayed options


# Directions

In this project, you will work in groups of four members to design and implement a database
application. The purpose of the project is to apply the fundamental database design principles, use
MySQL to create and manipulate a database, and develop a Python application to interact with the
database.

The application will help a middle school manage its after-school club activities by maintaining the
following information:

• Clubs and their scheduled meetings (date, time, description, classroom), field-trip events (date, time, description), annual budgets, and expenses

• Faculty members and the clubs they advise

• Students and their club memberships

Assumptions
You may assume the following:

• Each club has a unique club name (e.g., Band, Orchestra, Speech, MathCounts, Choir, etc.)

• A club’s budget may vary from year to year

• Each club schedules multiple meetings and events each year

• A club has exactly one advisor each year, but the advisor may change from year to year

• A faculty member may advise multiple clubs

• A student may join multiple clubs, and their club memberships may change across different years

# Notes on where code we did not write came from:

• The base Interface.py code came from lecture class.

• Rollback code (as input checking each input for each choice was much too tedious and 
removes the need for the error checking in the DB) came from https://www.geeksforgeeks.org/python/commit-rollback-operation-in-python/. This code explained how to use rollbacks with a try: and except: method.

• Fetchall code (as I wanted a way to show modified tables after code was ran without hardcoding each possiblility) came from https://www.geeksforgeeks.org/dbms/querying-data-from-a-database-using-fetchone-and-fetchall/. This code explained and implemented how to use a fetchall method.

• Match case code was also used as I forgot the syntax as it differs from C's switch statement: https://www.freecodecamp.org/news/python-switch-statement-switch-case-example/. This code just gave a simple image showing the syntax for regular vs default case.

OpenAI. (2026). ChatGPT (April 27 version) [Large language model]. https://chat.openai.com/
Used to generate sample data for this assignment 

