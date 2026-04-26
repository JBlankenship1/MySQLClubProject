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
studentName varchar(20) NOT NULL
);

--Second create teacher table, no foreign keys
CREATE TABLE Faculty(
facultyID char(6) primary key,
facultyName varchar(20) NOT NULL
);

--Third create clubs table, which needs teachers as foreign keys
CREATE TABLE Clubs(
clubName VARCHAR (20),
clubYear INT CHECK (clubYear > 1900 AND clubYear < 2100),
budget DECIMAL (10,2) NOT NULL,
facultyID CHAR (6) NOT NULL,
PRIMARY KEY (clubName,clubYear),
CONSTRAINT faculty_clubs foreign key (facultyID) references Faculty(facultyID) on UPDATE CASCADE
);

--Fourth create Are_in table
CREATE TABLE Are_in(
studentID char(6),
clubName varchar (20),
clubYear INT,
PRIMARY KEY (studentID, clubName, clubYear),
constraint clubs_arein foreign key (clubName, clubYear) references Clubs(clubName, clubYear) ON UPDATE CASCADE,
constraint students_arein foreign key (studentID) REFERENCES Students(studentID) ON UPDATE CASCADE
);

--Fifth Expenses
CREATE TABLE Expenses(
expenseID CHAR(10) PRIMARY KEY,
expenseDATE DATE NOT NULL,
amount DECIMAL (10,2) NOT NULL,
expenseDescription VARCHAR (30) NOT NULL,
clubName VARCHAR (20) NOT NULL,
clubYear INT NOT NULL,
CONSTRAINT Exp_Club FOREIGN KEY (clubName, clubYear) REFERENCES Clubs(clubName, clubYear) ON UPDATE CASCADE
);

--Sixth Meetings
CREATE TABLE Meetings(
meetingDate DATE,
classroom VARCHAR (20) NOT NULL,
meetingStartTime TIME NOT NULL,
meetingEndTime TIME NOT NULL,
meetingDescription VARCHAR (30) NOT NULL,
clubName VARCHAR (20),
clubYear INT,
PRIMARY KEY (meetingDATE,clubName, clubYear),
CONSTRAINT meet_club FOREIGN KEY (clubName, clubYear) references Clubs (clubName, clubYear) ON UPDATE CASCADE
);

--Seventh Events
CREATE TABLE Events (
    eventDate DATE,
    eventStartTime TIME NOT NULL,
    eventEndTime TIME NOT NULL,
    eventDescription VARCHAR(30) NOT NULL,
    clubName VARCHAR (20),
    clubYear INT,
    PRIMARY KEY (eventDate,clubName,clubYear),
    CONSTRAINT event_club FOREIGN KEY (clubName, clubYear) REFERENCES Clubs (clubName,clubYear) ON UPDATE CASCADE
);
 
 --prevent double booking meetings in same classroom

DELIMITER //

CREATE TRIGGER check_classroom
BEFORE INSERT ON Meetings
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Meetings
        WHERE classroom = NEW.classroom
          AND meetingDate = NEW.meetingDate
          AND NOT (
              NEW.meetingEndTime <= meetingStartTime
              OR NEW.meetingStartTime >= meetingEndTime
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Classroom is booked during that time';
    END IF;
END//

DELIMITER ;
