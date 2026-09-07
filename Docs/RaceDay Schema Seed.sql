-- =============================================
-- RaceDay Database - Schema and Seed Data
-- Author: [Your Name]
-- Date:  September 2026
-- Description: Full database creation script for Part 1
-- =============================================

USE master;
GO

-- Drop database if it exists (for clean testing)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDay')
BEGIN
    ALTER DATABASE RaceDay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDay;
END
GO

-- Create the database
CREATE DATABASE RaceDay;
GO

USE RaceDay;
GO

-- =============================================
-- Drop tables in correct order (FK dependencies)
-- =============================================
IF OBJECT_ID('Results', 'U') IS NOT NULL DROP TABLE Results;
IF OBJECT_ID('Enrolments', 'U') IS NOT NULL DROP TABLE Enrolments;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Events', 'U') IS NOT NULL DROP TABLE Events;
IF OBJECT_ID('Locations', 'U') IS NOT NULL DROP TABLE Locations;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- =============================================
-- 1. Users Table
-- =============================================
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);
GO

-- =============================================
-- 2. Locations Table
-- =============================================
CREATE TABLE Locations (
    LocationId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Province NVARCHAR(50) NOT NULL,
    Latitude DECIMAL(9,6) NULL,
    Longitude DECIMAL(9,6) NULL
);
GO

-- =============================================
-- 3. Events Table
-- =============================================
CREATE TABLE Events (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    LocationId INT NOT NULL,
    OrganiserId INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Open' CHECK (Status IN ('Open', 'Closed')),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);
GO

-- =============================================
-- 4. Categories Table
-- =============================================
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200) NULL,
    Distance DECIMAL(5,2) NOT NULL,
    Fee DECIMAL(8,2) NOT NULL,
    MaxParticipants INT NULL
);
GO

-- =============================================
-- 5. Enrolments Table
-- =============================================
CREATE TABLE Enrolments (
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME2 DEFAULT GETUTCDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Confirmed' CHECK (Status IN ('Confirmed', 'Cancelled'))
);
GO

-- =============================================
-- 6. Results Table
-- =============================================
CREATE TABLE Results (
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL UNIQUE,  -- UK ensures 1-to-1 relationship
    FinishTime TIME NULL,
    [Position] INT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'DNS' CHECK (Status IN ('Finished', 'DNF', 'DNS'))
);
GO

-- =============================================
-- Add Foreign Key Constraints
-- =============================================

-- Events → Locations
ALTER TABLE Events
ADD CONSTRAINT FK_Events_Location
FOREIGN KEY (LocationId) REFERENCES Locations(LocationId);

-- Events → Users (Organiser)
ALTER TABLE Events
ADD CONSTRAINT FK_Events_Organiser
FOREIGN KEY (OrganiserId) REFERENCES Users(UserId);

-- Categories → Events
ALTER TABLE Categories
ADD CONSTRAINT FK_Categories_Event
FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE;

-- Enrolments → Users (Participant)
ALTER TABLE Enrolments
ADD CONSTRAINT FK_Enrolments_Participant
FOREIGN KEY (ParticipantId) REFERENCES Users(UserId);

-- Enrolments → Events
ALTER TABLE Enrolments
ADD CONSTRAINT FK_Enrolments_Event
FOREIGN KEY (EventId) REFERENCES Events(EventId);

-- Enrolments → Categories
ALTER TABLE Enrolments
ADD CONSTRAINT FK_Enrolments_Category
FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);

-- Results → Enrolments
ALTER TABLE Results
ADD CONSTRAINT FK_Results_Enrolment
FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE;

-- =============================================
-- Unique Constraints (Prevent duplicates)
-- =============================================

-- Prevent duplicate enrolments (same participant in same category/event)
ALTER TABLE Enrolments
ADD CONSTRAINT UQ_Enrolment UNIQUE (ParticipantId, EventId, CategoryId);

-- Prevent duplicate category names per event
ALTER TABLE Categories
ADD CONSTRAINT UQ_EventCategory UNIQUE (EventId, Name);

GO

-- =============================================
-- Seed Data
-- =============================================

-- Insert Users (2 Organisers, 2 Participants)
INSERT INTO Users (FullName, Email, PasswordHash, Role)
VALUES
    ('Thandi Mokoena', 'thandi@race.org', 'hashed_pw_1', 'Organiser'),
    ('Sipho Ndlovu', 'sipho@race.org', 'hashed_pw_2', 'Organiser'),
    ('Lerato Molefe', 'lerato@runner.com', 'hashed_pw_3', 'Participant'),
    ('Ethan Williams', 'ethan@cyclist.com', 'hashed_pw_4', 'Participant');
GO

-- Insert Locations
INSERT INTO Locations (Name, Address, City, Province, Latitude, Longitude)
VALUES
    ('King''s Park Stadium', '44 Margaret Mncadi Ave', 'Durban', 'KwaZulu-Natal', -29.8265, 31.0295),
    ('Cape Town Stadium', 'Fritz Sonnenberg Rd', 'Cape Town', 'Western Cape', -33.9035, 18.4111),
    ('Soweto Rugby Union', 'Chris Hani Rd', 'Soweto', 'Gauteng', -26.2485, 27.8580);
GO

-- Insert Events (3 events)
INSERT INTO Events (Title, Description, EventDate, StartTime, LocationId, OrganiserId, Status)
VALUES
    ('Comrades Marathon 2026', 'The Ultimate Human Race', '2026-06-10', '05:30:00', 1, 1, 'Open'),
    ('Cape Town Cycle Tour 2026', 'The world''s largest timed cycle race', '2026-03-08', '06:00:00', 2, 2, 'Open'),
    ('Soweto Marathon 2026', 'Running through the heart of Soweto', '2026-11-02', '05:45:00', 3, 1, 'Closed');
GO

-- Insert Categories (2 per event = 6 total)
INSERT INTO Categories (EventId, Name, Description, Distance, Fee, MaxParticipants)
VALUES
    -- Comrades (EventId = 1)
    (1, 'Ultra Marathon (90km)', 'The full Comrades distance', 90.0, 850.00, 20000),
    (1, 'Half Marathon (45km)', 'Half the Comrades', 45.0, 450.00, 15000),
    -- Cycle Tour (EventId = 2)
    (2, '109km Road Race', 'The classic distance', 109.0, 600.00, 35000),
    (2, '42km Fun Ride', 'Shorter route for leisure', 42.0, 300.00, 10000),
    -- Soweto Marathon (EventId = 3)
    (3, 'Full Marathon (42.2km)', 'The classic marathon', 42.2, 400.00, 25000),
    (3, '10km Road Race', 'Shorter distance', 10.0, 150.00, 8000);
GO

-- Insert Enrolments (3 enrolments)
INSERT INTO Enrolments (ParticipantId, EventId, CategoryId, Status)
VALUES
    (3, 1, 1, 'Confirmed'),  -- Lerato in Comrades Ultra
    (3, 2, 3, 'Confirmed'),  -- Lerato in Cycle Tour 109km
    (4, 3, 5, 'Confirmed');  -- Ethan in Soweto Full Marathon
GO

-- Insert Results (2 results, one enrolment still pending)
INSERT INTO Results (EnrolmentId, FinishTime, [Position], Status)
VALUES
    (1, '08:45:23', 125, 'Finished'),   -- Lerato's Comrades result
    (2, '04:12:34', 340, 'Finished');   -- Lerato's Cycle Tour result
GO

-- =============================================
-- Verification Queries (to confirm everything works)
-- =============================================

SELECT '✅ Users' AS TableName, COUNT(*) AS Count FROM Users
UNION ALL
SELECT '✅ Locations', COUNT(*) FROM Locations
UNION ALL
SELECT '✅ Events', COUNT(*) FROM Events
UNION ALL
SELECT '✅ Categories', COUNT(*) FROM Categories
UNION ALL
SELECT '✅ Enrolments', COUNT(*) FROM Enrolments
UNION ALL
SELECT '✅ Results', COUNT(*) FROM Results;
GO

-- Show sample data with joins
SELECT
    e.Title AS Event,
    l.Name AS Location,
    u.FullName AS Organiser,
    c.Name AS Category,
    COUNT(en.EnrolmentId) AS Enrolments
FROM Events e
JOIN Locations l ON e.LocationId = l.LocationId
JOIN Users u ON e.OrganiserId = u.UserId
JOIN Categories c ON e.EventId = c.EventId
LEFT JOIN Enrolments en ON c.CategoryId = en.CategoryId
GROUP BY e.Title, l.Name, u.FullName, c.Name
ORDER BY e.Title;
GO

PRINT '=============================================';
PRINT 'RaceDay database created and seeded successfully!';
PRINT '=============================================';
