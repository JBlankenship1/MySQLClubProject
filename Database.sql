/*
Drop tables if they already exist
*/

-- Then drop tables
DROP TABLE IF EXISTS ClubEvents;
DROP TABLE IF EXISTS Meetings;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Are_in;
DROP TABLE IF EXISTS Clubs;
DROP TABLE IF EXISTS Faculty;
DROP TABLE IF EXISTS Students;

-- Drop procedures if exists
DROP PROCEDURE IF EXISTS budgetAllClubs;
DROP PROCEDURE IF EXISTS remainingBudgetClub;
DROP PROCEDURE IF EXISTS allClubFaculty;
DROP PROCEDURE IF EXISTS allClubStudents;
DROP PROCEDURE IF EXISTS allClubsFromStudent;
DROP PROCEDURE IF EXISTS StudentScheduleOnDate;
/*
Create tables
*/

-- First create student table, no foreign keys
CREATE TABLE Students (
studentID char(6) primary key,
studentName varchar(20) NOT NULL
);

-- Second create teacher table, no foreign keys
CREATE TABLE Faculty(
facultyID char(6) primary key,
facultyName varchar(30) NOT NULL
);

-- Third create clubs table, which needs teachers as foreign keys
CREATE TABLE Clubs(
clubName VARCHAR (30),
clubYear INT CHECK (clubYear > 1900 AND clubYear < 2100),
budget DECIMAL (10,2) NOT NULL,
facultyID CHAR (6) NOT NULL,
PRIMARY KEY (clubName,clubYear),
CONSTRAINT faculty_clubs foreign key (facultyID) references Faculty(facultyID) on UPDATE CASCADE
);

-- Fourth create Are_in table
CREATE TABLE Are_in(
studentID char(6),
clubName varchar (30),
clubYear INT,
PRIMARY KEY (studentID, clubName, clubYear),
constraint clubs_arein foreign key (clubName, clubYear) references Clubs(clubName, clubYear) ON UPDATE CASCADE,
constraint students_arein foreign key (studentID) REFERENCES Students(studentID) ON UPDATE CASCADE
);

-- Fifth Expenses
CREATE TABLE Expenses(
expenseID CHAR(10) PRIMARY KEY,
expenseDATE DATE NOT NULL,
amount DECIMAL (10,2) NOT NULL,
expenseDescription VARCHAR (30) NOT NULL,
clubName VARCHAR (30) NOT NULL,
clubYear INT NOT NULL,
CONSTRAINT Exp_Club FOREIGN KEY (clubName, clubYear) REFERENCES Clubs(clubName, clubYear) ON UPDATE CASCADE
);

-- Sixth Meetings
CREATE TABLE Meetings(
meetingDate DATE,
classroom VARCHAR (20) NOT NULL,
meetingStartTime TIME NOT NULL,
meetingEndTime TIME NOT NULL,
meetingDescription VARCHAR (30) NOT NULL,
clubName VARCHAR (30),
clubYear INT,
PRIMARY KEY (meetingDATE,clubName, clubYear),
CONSTRAINT meet_club FOREIGN KEY (clubName, clubYear) references Clubs (clubName, clubYear) ON UPDATE CASCADE
);

-- Seventh Events
CREATE TABLE ClubEvents (
    eventDate DATE,
    eventStartTime TIME NOT NULL,
    eventEndTime TIME NOT NULL,
    eventDescription VARCHAR(30) NOT NULL,
    clubName VARCHAR (30),
    clubYear INT,
    PRIMARY KEY (eventDate,clubName,clubYear),
    CONSTRAINT event_club FOREIGN KEY (clubName, clubYear) REFERENCES Clubs (clubName,clubYear) ON UPDATE CASCADE
);
 
 -- prevent double booking meetings in same classroom

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

DELIMITER //

CREATE TRIGGER check_club_event_conflict
BEFORE INSERT ON Meetings
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM ClubEvents
        WHERE clubName = NEW.clubName
          AND clubYear = NEW.clubYear
          AND eventDate = NEW.meetingDate
          AND NOT (
              NEW.meetingEndTime <= eventStartTime
              OR NEW.meetingStartTime >= eventEndTime
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Club has event during that time';
    END IF;
END//

DELIMITER ;




DELIMITER //
CREATE TRIGGER check_club_meeting_conflict
BEFORE INSERT ON ClubEvents
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Meetings
        WHERE clubName = NEW.clubName
          AND clubYear = NEW.clubYear
          AND meetingDate = NEW.eventDate
          AND NOT (
              NEW.eventEndTime <= meetingStartTime
              OR NEW.eventStartTime >= meetingEndTime
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Club has meeting during that time';
    END IF;
END//
DELIMITER ;



-- Reports the budget of all clubs in a given year (Requirement 1h)
-- Call using this statement: CALL budgetAllClubs(YEAR);
DELIMITER //
CREATE PROCEDURE budgetAllClubs(IN inputYear INT)
BEGIN
    SELECT clubName, clubYear, budget
    FROM Clubs
    WHERE clubYear = inputYear;
END //
DELIMITER ;


--Reports the total expenses and remaining budget of a given club in a given year (Requirement 1g)
-- Call using this statement: CALL remainingBudgetClub(CLUBNAME, YEAR);
DELIMITER //
CREATE PROCEDURE remainingBudgetClub(IN inputClub VARCHAR(30), IN inputYear INT)
BEGIN
    SELECT Clubs.clubName, Clubs.clubYear, Clubs.budget,
        Expenses.totalExpenses AS totalExpenses,
        Clubs.budget - Expenses.totalExpenses AS remainingBudget
    FROM Clubs
    LEFT JOIN (
        SELECT clubName, clubYear, SUM(amount) AS totalExpenses
        FROM Expenses
        GROUP BY clubName, clubYear
    ) Expenses
    ON Clubs.clubName = Expenses.clubName
    AND Clubs.clubYear = Expenses.clubYear
    WHERE Clubs.clubName = inputClub
      AND Clubs.clubYear = inputYear;
END //
DELIMITER ;


--Reports the faculty member of all clubs (Requirement 2b)
-- Call using this statement: CALL allClubFaculty();
DELIMITER //
CREATE PROCEDURE allClubFaculty()
BEGIN
    SELECT clubName, clubYear, facultyName, Clubs.facultyID
    FROM Clubs, Faculty
    WHERE Clubs.facultyID = Faculty.facultyID;
END //
DELIMITER ;



--Reports all students in a given club in a given year (Requirement 3b)
-- Call using this statement: CALL allClubStudents(CLUBNAME, YEAR);
DELIMITER //
CREATE PROCEDURE allClubStudents(IN inputClub VARCHAR(30), IN inputYear INT)
BEGIN
    SELECT Are_in.clubName, Are_in.clubYear, Students.studentID, Students.studentName
    FROM Students
    JOIN Are_in
        ON Students.studentID = Are_in.studentID
    WHERE Are_in.clubName = inputClub
      AND Are_in.clubYear = inputYear;
END //
DELIMITER ;


--Reports all clubs a student is in (Requirement 3c)
-- Call using this statement: CALL allClubsFromStudent(STUDENTID);
DELIMITER //
CREATE PROCEDURE allClubsFromStudent(IN inputStudentID CHAR(6))
BEGIN
    SELECT Students.studentName, Students.studentID, Are_in.clubName, Are_in.clubYear
    FROM Students
    JOIN Are_in
        ON Students.studentID = Are_in.studentID
    WHERE Are_in.studentID = inputStudentID;
END //
DELIMITER ;



--Reports the schedule of a given student on a given day (Requirement 3d)
-- Call using this statement: CALL studentScheduleOnDate(STUDENTID, DATE (yyyy-mm-dd) );
DELIMITER //
CREATE PROCEDURE studentScheduleOnDate(IN inputStudentID CHAR(6), IN inputDate DATE)
BEGIN
    -- Meetings result set
    SELECT
        'Meeting' AS activityType, Are_in.clubName, Are_in.clubYear,
        Meetings.meetingStartTime AS startTime,
        Meetings.meetingEndTime AS endTime,
        Meetings.classroom AS location,
        Meetings.meetingDescription AS description,
        Meetings.meetingDate AS activityDate
    FROM Are_in
    JOIN Meetings
        ON Are_in.clubName = Meetings.clubName
        AND Are_in.clubYear = Meetings.clubYear
    WHERE Are_in.studentID = inputStudentID
      AND Meetings.meetingDate = inputDate;
    -- Events result set
    SELECT
        'Event' AS activityType,
        Are_in.clubName,
        Are_in.clubYear,
        ClubEvents.eventStartTime AS startTime,
        ClubEvents.eventEndTime AS endTime,
        ClubEvents.eventDescription AS description,
        ClubEvents.eventDate AS activityDate
    FROM Are_in
    JOIN ClubEvents
        ON Are_in.clubName = ClubEvents.clubName
        AND Are_in.clubYear = ClubEvents.clubYear
    WHERE Are_in.studentID = inputStudentID
      AND ClubEvents.eventDate = inputDate;
END //
DELIMITER ;


INSERT INTO Students (studentName, studentID)
VALUES
('Holden Caulfield', 381472),
('Matilda Wormwood', 604915),
('Charlie Bucket', 157893),
('Ender Wiggin', 492306),
('Percy Jackson', 728154),
('Nancy Drew', 263941),
('Pip Pirrip', 915620),
('Scout Finch', 540287),
('Jo March', 176458),
('Anne Shirley', 834719);

INSERT INTO Faculty (facultyName, facultyID)
VALUES
('Miss Honey', 482731),
('Mr. Keating', 615294),
('Professor McGonagall', 903418),
('Miss Stacy', 274650),
('Mr. Ratburn', 758193);

INSERT INTO Clubs (clubName, clubYear, budget, facultyID)
VALUES
('Midnight Book Society', 2026, 500, 482731),
('Campus Trailblazers', 2026, 1200, 482731),
('Innovation Forge', 2026, 1800, 903418),
('Green Thumb Guild', 2026, 900, 274650);

INSERT INTO Are_in (studentID, clubName, clubYear)
VALUES
-- Holden Caulfield is in every club
(381472, 'Midnight Book Society', 2026),
(381472, 'Campus Trailblazers', 2026),
(381472, 'Innovation Forge', 2026),
(381472, 'Green Thumb Guild', 2026),
(604915, 'Midnight Book Society', 2026),
(157893, 'Midnight Book Society', 2026),
(492306, 'Campus Trailblazers', 2026),
(728154, 'Campus Trailblazers', 2026),
(263941, 'Innovation Forge', 2026),
(915620, 'Innovation Forge', 2026),
(540287, 'Green Thumb Guild', 2026),
(176458, 'Green Thumb Guild', 2026);

INSERT INTO Expenses
(expenseID, expenseDate, amount, expenseDescription, clubName, clubYear)
VALUES
('EXP0000001', '2026-02-10', 120, 'Book order', 'Midnight Book Society', 2026),
('EXP0000002', '2026-03-15', 80, 'Meeting snacks', 'Midnight Book Society', 2026),
('EXP0000003', '2026-04-20', 150, 'Author event', 'Midnight Book Society', 2026),
('EXP0000004', '2026-02-18', 300, 'Trail supplies', 'Campus Trailblazers', 2026),
('EXP0000005', '2026-05-05', 400, 'Bus rental', 'Campus Trailblazers', 2026),
('EXP0000006', '2026-09-12', 250, 'First aid kits', 'Campus Trailblazers', 2026),
('EXP0000007', '2026-01-25', 500, 'Robot parts', 'Innovation Forge', 2026),
('EXP0000008', '2026-04-08', 350, 'Workshop tools', 'Innovation Forge', 2026),
('EXP0000009', '2026-10-17', 600, 'Tech fair booth', 'Innovation Forge', 2026),
('EXP0000010', '2026-03-01', 200, 'Seeds and soil', 'Green Thumb Guild', 2026),
('EXP0000011', '2026-04-14', 250, 'Garden tools', 'Green Thumb Guild', 2026),
('EXP0000012', '2026-06-22', 300, 'Compost bins', 'Green Thumb Guild', 2026);

INSERT INTO Meetings
(meetingDate, classroom, meetingStartTime, meetingEndTime, meetingDescription, clubName, clubYear)
VALUES
('2026-02-12', 'Room 101', '09:00:00', '10:00:00', 'Book planning', 'Midnight Book Society', 2026),
('2026-02-12', 'Room 101', '10:30:00', '11:30:00', 'Trail signup', 'Campus Trailblazers', 2026),
('2026-03-05', 'Room 102', '13:00:00', '14:00:00', 'Robot demo', 'Innovation Forge', 2026),
('2026-03-10', 'Room 103', '15:00:00', '16:00:00', 'Spring planting', 'Green Thumb Guild', 2026),
('2026-04-08', 'Room 101', '14:00:00', '15:00:00', 'Author prep', 'Midnight Book Society', 2026),
('2026-04-15', 'Room 102', '09:30:00', '10:30:00', 'Hike routes', 'Campus Trailblazers', 2026),
('2026-05-06', 'Room 103', '11:00:00', '12:00:00', 'Tool training', 'Innovation Forge', 2026),
('2026-05-20', 'Room 101', '16:00:00', '17:00:00', 'Garden budget', 'Green Thumb Guild', 2026);

INSERT INTO ClubEvents
(eventDate, eventStartTime, eventEndTime, eventDescription, clubName, clubYear)
VALUES
('2026-02-20', '18:00:00', '20:00:00', 'Open mic night', 'Midnight Book Society', 2026),
('2026-03-14', '09:00:00', '12:00:00', 'Morning trail hike', 'Campus Trailblazers', 2026),
('2026-04-18', '13:00:00', '16:00:00', 'Mini maker fair', 'Innovation Forge', 2026),
('2026-05-09', '10:00:00', '13:00:00', 'Plant swap', 'Green Thumb Guild', 2026),

('2026-06-12', '17:00:00', '19:00:00', 'Poetry reading', 'Midnight Book Society', 2026),
('2026-07-11', '08:00:00', '11:00:00', 'River walk', 'Campus Trailblazers', 2026),
('2026-09-19', '14:00:00', '17:00:00', 'Robot challenge', 'Innovation Forge', 2026),
('2026-10-03', '09:00:00', '12:00:00', 'Fall garden day', 'Green Thumb Guild', 2026);
