from dotenv import load_dotenv
import os
import mysql.connector

# Load variables from safe .env file
load_dotenv()

# This does not work on Multilab servers because the .env file is not stored there.
# To run this program on a Multilab server, you can either:
# 1. Set environment variables in the terminal before running the program:  
# 2. Edit the exported Interface.py file to include your database credentials directly in
#  the mysql.connector.connect() function call 
dbConnection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

dbCursor = dbConnection.cursor(buffered=True)

while True:
    print("\nWelcome to the University of Kentucky Club Management System!")
    choice = input("Enter 'view' to view data, 'insert' to insert data, 'delete' to delete data, or 'exit' to exit: ").strip().lower()

    match choice:

        case 'view':
            print("\nPlease select a query to run:")
            print("0. All remaining budgets for all clubs in a year")
            print("1. Remaining budget for a club")
            print("2. All faculty advisors for clubs in a given year")
            print("3. All students in a club")
            print("4. All clubs a student is in")
            print("5. Schedule for a club")
            print("6. Schedule for a student on a specific date")
            print("7. Back to main menu")
            view_choice = input("Enter your choice (0-7): ")

            match view_choice:
                case '0':
                    year = input("Enter the year: ")
                    try:
                        dbCursor.callproc('budgetAllClubs', [year])
                        for result in dbCursor.stored_results():
                            for row in result.fetchall():
                                print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()
                case '1':
                    club = input("Enter the club name: ")
                    year = input("Enter the year: ")
                    try:
                        dbCursor.callproc('remainingBudgetClub', [club, year])
                        for result in dbCursor.stored_results():
                            for row in result.fetchall():
                                print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '2':
                    year = input("Enter the year: ")
                    try:
                        dbCursor.execute("""
                            SELECT Clubs.clubName, Clubs.clubYear, Faculty.facultyName, Clubs.facultyID
                            FROM Clubs, Faculty
                            WHERE Clubs.facultyID = Faculty.facultyID
                            AND Clubs.clubYear = %s
                        """, (year,))
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '3':
                    club = input("Enter the club name: ")
                    year = input("Enter the year: ")
                    try:
                        dbCursor.callproc('allClubStudents', [club, year])
                        for result in dbCursor.stored_results():
                            for row in result.fetchall():
                                print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '4':
                    student_id = input("Enter the student ID: ")
                    try:
                        dbCursor.callproc('allClubsFromStudent', [student_id])
                        for result in dbCursor.stored_results():
                            for row in result.fetchall():
                                print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '5':
                    club = input("Enter the club name: ")
                    year = input("Enter the year: ")
                    try:
                        dbCursor.callproc('ClubSchedule', [club, year])
                        for result in dbCursor.stored_results():
                            print(result.column_names)
                            for row in result.fetchall():
                                print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '6':
                    student_id = input("Enter the student ID: ")
                    date = input("Enter the date (YYYY-MM-DD): ")
                    try:
                        dbCursor.callproc('studentScheduleOnDate', [student_id, date])
                        for result in dbCursor.stored_results():
                            print(result.column_names)
                            for row in result.fetchall():
                                print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '7':
                    print("Returning to main menu...")

                case _:
                    print("Invalid choice. Please enter a number between 0 and 7.")

        case 'insert':
            print("\nWhat would you like to insert?")
            print("0. Add a student")
            print("1. Add a faculty member")
            print("2. Add a club (with budget and faculty advisor)")
            print("3. Add a student to a club")
            print("4. Add an expense")
            print("5. Add a meeting")
            print("6. Add an event")
            print("7. Back to main menu")
            insert_choice = input("Enter your choice (0-7): ")

            match insert_choice:
                case '0':
                    student_id = input("Enter the student ID (6 chars): ")
                    student_name = input("Enter the student name: ")
                    try:
                        dbCursor.execute("INSERT INTO Students (studentID, studentName) VALUES (%s, %s)", (student_id, student_name))
                        dbConnection.commit()
                        print("Student added successfully.")
                        dbCursor.execute("SELECT * FROM Students")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '1':
                    faculty_id = input("Enter the faculty ID (6 chars): ")
                    faculty_name = input("Enter the faculty name: ")
                    try:
                        dbCursor.execute("INSERT INTO Faculty (facultyID, facultyName) VALUES (%s, %s)", (faculty_id, faculty_name))
                        dbConnection.commit()
                        print("Faculty member added successfully.")
                        dbCursor.execute("SELECT * FROM Faculty")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '2':
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    budget = input("Enter the budget: ")
                    faculty_id = input("Enter the faculty ID to assign as advisor: ")
                    try:
                        dbCursor.execute("INSERT INTO Clubs (clubName, clubYear, budget, facultyID) VALUES (%s, %s, %s, %s)", (club_name, year, budget, faculty_id))
                        dbConnection.commit()
                        print("Club added successfully.")
                        dbCursor.execute("SELECT * FROM Clubs")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '3':
                    student_id = input("Enter the student ID: ")
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    try:
                        dbCursor.execute("INSERT INTO Are_in (studentID, clubName, clubYear) VALUES (%s, %s, %s)", (student_id, club_name, year))
                        dbConnection.commit()
                        print("Student added to club successfully.")
                        dbCursor.execute("SELECT * FROM Are_in")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '4':
                    expense_id = input("Enter the expense ID (10 chars): ")
                    date = input("Enter the expense date (YYYY-MM-DD): ")
                    amount = input("Enter the amount: ")
                    description = input("Enter the description: ")
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    try:
                        dbCursor.execute("INSERT INTO Expenses (expenseID, expenseDATE, amount, expenseDescription, clubName, clubYear) VALUES (%s, %s, %s, %s, %s, %s)", (expense_id, date, amount, description, club_name, year))
                        dbConnection.commit()
                        print("Expense added successfully.")
                        dbCursor.execute("SELECT * FROM Expenses")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '5':
                    date = input("Enter the meeting date (YYYY-MM-DD): ")
                    classroom = input("Enter the classroom: ")
                    start_time = input("Enter the start time (HH:MM:SS): ")
                    end_time = input("Enter the end time (HH:MM:SS): ")
                    description = input("Enter the meeting description: ")
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    try:
                        dbCursor.execute("INSERT INTO Meetings (meetingDate, classroom, meetingStartTime, meetingEndTime, meetingDescription, clubName, clubYear) VALUES (%s, %s, %s, %s, %s, %s, %s)", (date, classroom, start_time, end_time, description, club_name, year))
                        dbConnection.commit()
                        print("Meeting added successfully.")
                        dbCursor.execute("SELECT * FROM Meetings")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '6':
                    date = input("Enter the event date (YYYY-MM-DD): ")
                    start_time = input("Enter the start time (HH:MM:SS): ")
                    end_time = input("Enter the end time (HH:MM:SS): ")
                    description = input("Enter the event description: ")
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    try:
                        dbCursor.execute("INSERT INTO ClubEvents (eventDate, eventStartTime, eventEndTime, eventDescription, clubName, clubYear) VALUES (%s, %s, %s, %s, %s, %s)", (date, start_time, end_time, description, club_name, year))
                        dbConnection.commit()
                        print("Event added successfully.")
                        dbCursor.execute("SELECT * FROM ClubEvents")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '7':
                    print("Returning to main menu...")

                case _:
                    print("Invalid choice. Please enter a number between 0 and 7.")

        case 'delete':
            print("\nWhat would you like to delete?")
            print("0. Delete a meeting")
            print("1. Delete an event")
            print("2. Remove a student from a club")
            print("3. Back to main menu")
            delete_choice = input("Enter your choice (0-3): ")

            match delete_choice:
                case '0':
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    date = input("Enter the meeting date (YYYY-MM-DD): ")
                    try:
                        dbCursor.execute("DELETE FROM Meetings WHERE clubName = %s AND clubYear = %s AND meetingDate = %s", (club_name, year, date))
                        dbConnection.commit()
                        print("Meeting deleted successfully.")
                        dbCursor.execute("SELECT * FROM Meetings")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '1':
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    date = input("Enter the event date (YYYY-MM-DD): ")
                    try:
                        dbCursor.execute("DELETE FROM ClubEvents WHERE clubName = %s AND clubYear = %s AND eventDate = %s", (club_name, year, date))
                        dbConnection.commit()
                        print("Event deleted successfully.")
                        dbCursor.execute("SELECT * FROM ClubEvents")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '2':
                    student_id = input("Enter the student ID: ")
                    club_name = input("Enter the club name: ")
                    year = input("Enter the club year: ")
                    try:
                        dbCursor.execute("DELETE FROM Are_in WHERE studentID = %s AND clubName = %s AND clubYear = %s", (student_id, club_name, year))
                        dbConnection.commit()
                        print("Student removed from club successfully.")
                        dbCursor.execute("SELECT * FROM Are_in")
                        for row in dbCursor.fetchall():
                            print(row)
                    except Exception as error:
                        print(f"Error: {error}")
                        dbConnection.rollback()

                case '3':
                    print("Returning to main menu...")

                case _:
                    print("Invalid choice. Please enter a number between 0 and 3.")

        case 'exit':
            print("Exiting program.")
            break

        case _:
            print("Invalid choice. Please enter 'view', 'insert', 'delete', or 'exit'.")

dbCursor.close()
dbConnection.close()