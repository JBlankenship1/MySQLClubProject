/*
Drop tables if they already exist
*/

--Then drop tables
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Meetings;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Are_in;
DROP TABLE IF EXISTS Clubs;
DROP TABLE IF EXISTS Faculty;
DROP TABLE IF EXISTS Students;


/*
Create tables
*/

--First create student table, no foreign keys
CREATE TABLE Students (
studentID char(6) primary key,
studentName varchar(20)
);

--Second create teacher table, no foreign keys
CREATE TABLE Faculty(
facultyID char(6) primary key,
facultyName varchar(20)
);

--Third create clubs table, which needs teachers as foreign keys
CREATE TABLE Clubs(
clubName VARCHAR (20),
clubYear INT CHECK (clubYear > 1900 AND clubYear < 2100),
budget DECIMAL (10,2),
facultyID CHAR (6),
PRIMARY KEY (clubName,clubYear),
CONSTRAINT faculty_clubs foreign key (facultyID) references Faculty(facultyID) on delete CASCADE
);

--Fourth create Are_in table
CREATE TABLE Are_in(
studentID char(6),
clubName varchar (20),
clubYear INT,
PRIMARY KEY (studentID, clubName, clubYear),
constraint clubs_arein foreign key (clubName, clubYear) references Clubs(clubName, clubYear) ON DELETE CASCADE,
constraint students_arein foreign key (studentID) REFERENCES Students(studentID)
);

--Fifth Expenses
CREATE TABLE Expenses(
expenseID CHAR(10) PRIMARY KEY,
expenseDATE DATE,
amount DECIMAL (10,2),
expenseDescription VARCHAR (30),
clubName VARCHAR (20),
clubYear INT,
CONSTRAINT Exp_Club FOREIGN KEY (clubName, clubYear) REFERENCES Clubs(clubName, clubYear)
);

--Sixth Meetings
CREATE TABLE Meetings(
meetingDate DATE,
classroom VARCHAR (20),
meetingStartTime TIME,
meetingEndTime TIME,
meetingDescription VARCHAR (30),
clubName VARCHAR (20),
clubYear INT,
PRIMARY KEY (meetingDATE,clubName, clubYear),
CONSTRAINT meet_club FOREIGN KEY (clubName, clubYear) references Clubs (clubName, clubYear)
);

--Seventh Events
CREATE TABLE Events (
    eventDate DATE,
    eventStartTime TIME,
    eventEndTime TIME,
    eventDescription VARCHAR(30),
    clubName VARCHAR (20),
    clubYear INT,
    PRIMARY KEY (eventDate,clubName,clubYear),
    CONSTRAINT event_club FOREIGN KEY (clubName, clubYear) REFERENCES Clubs (clubName,clubYear)
);