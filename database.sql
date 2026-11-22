IF DB_ID('BloodDonationSystem') IS NULL
BEGIN
    CREATE DATABASE BloodDonationSystem;
END
GO

USE BloodDonationSystem;
GO

-- Drop existing tables in reverse FK order for clean re-runs
IF OBJECT_ID('dbo.BLOOD_COMPONENTS', 'U') IS NOT NULL DROP TABLE dbo.BLOOD_COMPONENTS;
IF OBJECT_ID('dbo.BLOOD_BAGS', 'U') IS NOT NULL DROP TABLE dbo.BLOOD_BAGS;
IF OBJECT_ID('dbo.SCREENING', 'U') IS NOT NULL DROP TABLE dbo.SCREENING;
IF OBJECT_ID('dbo.BLOOD_REQUESTS', 'U') IS NOT NULL DROP TABLE dbo.BLOOD_REQUESTS;
IF OBJECT_ID('dbo.SYSTEM_USERS', 'U') IS NOT NULL DROP TABLE dbo.SYSTEM_USERS;
IF OBJECT_ID('dbo.MEDICAL_STAFF', 'U') IS NOT NULL DROP TABLE dbo.MEDICAL_STAFF;
IF OBJECT_ID('dbo.DONOR', 'U') IS NOT NULL DROP TABLE dbo.DONOR;
GO

-- 1. DONOR TABLE
CREATE TABLE DONOR (
    DonorID INT IDENTITY(1,1) PRIMARY KEY,
    Donation_Form VARCHAR(30) NOT NULL UNIQUE,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Middle_Name VARCHAR(50) NULL,
    Birth_Date DATE NOT NULL,
    Age INT NOT NULL,
    Civil_Status VARCHAR(20) NOT NULL,
    Sex VARCHAR(10) NOT NULL,
    Weight_KG DECIMAL(5,2) NOT NULL,
    Blood_Type VARCHAR(5) NOT NULL,
    Donor_Status VARCHAR(20) NOT NULL DEFAULT 'Eligible',
    Last_Donation_Date DATE NULL
);

-- 2. MEDICAL_STAFF TABLE
CREATE TABLE MEDICAL_STAFF (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL
);

-- 3. SCREENING TABLE
CREATE TABLE SCREENING (
    ScreeningID INT IDENTITY(1,1) PRIMARY KEY,
    DonorID INT NOT NULL FOREIGN KEY REFERENCES DONOR(DonorID),
    StaffID INT NOT NULL FOREIGN KEY REFERENCES MEDICAL_STAFF(StaffID),
    Screening_Date DATETIME NOT NULL DEFAULT GETDATE(),
    Systolic_BP INT NOT NULL,
    Diastolic_BP INT NOT NULL,
    Pulse_Rate INT NOT NULL,
    Has_Recent_Tattoos BIT NOT NULL DEFAULT 0,
    Screening_Result VARCHAR(20) NOT NULL,
    Interview_Sheet VARCHAR(255) NULL,
    Medical_History VARCHAR(255) NULL
);

-- 4. BLOOD_BAGS TABLE
CREATE TABLE BLOOD_BAGS (
    Bag_Serial_Number VARCHAR(30) PRIMARY KEY,
    DonorID INT NOT NULL FOREIGN KEY REFERENCES DONOR(DonorID),
    Collection_Date DATE NOT NULL,
    TTI_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    Bag_Status VARCHAR(20) NOT NULL DEFAULT 'Quarantined'
);

-- 5. BLOOD_REQUESTS TABLE
CREATE TABLE BLOOD_REQUESTS (
    RequestID INT IDENTITY(1,1) PRIMARY KEY,
    Patient_Name VARCHAR(100) NOT NULL,
    Hospital_Name VARCHAR(120) NOT NULL,
    Required_Blood_Type VARCHAR(5) NOT NULL,
    Quantity_Requested INT NOT NULL,
    Is_Blood_Samaritan BIT NOT NULL DEFAULT 0,
    Processing_Fee DECIMAL(10,2) NOT NULL DEFAULT 1800.00,
    Request_Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
);

-- 6. BLOOD_COMPONENTS TABLE
CREATE TABLE BLOOD_COMPONENTS (
    ComponentID INT IDENTITY(1,1) PRIMARY KEY,
    Bag_Serial_Number VARCHAR(30) NOT NULL FOREIGN KEY REFERENCES BLOOD_BAGS(Bag_Serial_Number),
    Component_Type VARCHAR(50) NOT NULL,
    Storage_Location VARCHAR(50) NOT NULL,
    Expiration_Date DATE NOT NULL,
    Availability_Status VARCHAR(20) NOT NULL DEFAULT 'Available',
    RequestID INT NULL FOREIGN KEY REFERENCES BLOOD_REQUESTS(RequestID)
);

-- 7. SYSTEM_USERS TABLE (Staff Login Accounts)
CREATE TABLE SYSTEM_USERS (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL FOREIGN KEY REFERENCES MEDICAL_STAFF(StaffID),
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password_Hash VARCHAR(100) NOT NULL
);
GO

-- =========================================================================
-- POPULATION OF ALL 6 CORE TABLES (180 TOTAL ROWS) + STAFF LOGIN ACCOUNTS
-- =========================================================================

-- 1. INSERT 30 ROWS INTO DONOR
INSERT INTO DONOR (Donation_Form, First_Name, Last_Name, Middle_Name, Birth_Date, Age, Civil_Status, Sex, Weight_KG, Blood_Type, Donor_Status, Last_Donation_Date) VALUES
('DF-2026-001', 'Juan', 'Dela Cruz', 'Santos', '1995-03-14', 31, 'Single', 'Male', 68.50, 'O+', 'Eligible', '2026-06-10'),
('DF-2026-002', 'Maria', 'Reyes', 'Bautista', '1998-07-22', 28, 'Single', 'Female', 55.00, 'A+', 'Eligible', '2026-07-15'),
('DF-2026-003', 'Jose', 'Garcia', 'Mendoza', '1989-11-05', 36, 'Married', 'Male', 75.20, 'B+', 'Eligible', '2026-05-20'),
('DF-2026-004', 'Ana', 'Torres', 'Villanueva', '2000-01-30', 26, 'Single', 'Female', 52.40, 'O-', 'Eligible', '2026-08-01'),
('DF-2026-005', 'Mark', 'Ramos', 'Aquino', '1992-09-18', 34, 'Married', 'Male', 80.00, 'AB+', 'Eligible', '2026-04-12'),
('DF-2026-006', 'Cathy', 'Fernandez', 'Cruz', '1996-12-11', 29, 'Single', 'Female', 58.10, 'A-', 'Eligible', '2026-07-25'),
('DF-2026-007', 'Paul', 'Castro', 'Morales', '1985-04-03', 41, 'Married', 'Male', 72.30, 'O+', 'Eligible', '2026-06-18'),
('DF-2026-008', 'Grace', 'Rivera', 'Perez', '1999-06-27', 27, 'Single', 'Female', 54.00, 'B-', 'Eligible', '2026-08-10'),
('DF-2026-009', 'Ryan', 'Gomez', 'Diaz', '1991-08-14', 35, 'Married', 'Male', 78.60, 'O+', 'Eligible', '2026-05-05'),
('DF-2026-010', 'Jenny', 'Navarro', 'Ocampo', '1997-02-19', 29, 'Single', 'Female', 56.80, 'A+', 'Eligible', '2026-07-30'),
('DF-2026-011', 'Carlo', 'Salazar', 'Rojas', '1994-10-09', 32, 'Single', 'Male', 69.00, 'B+', 'Eligible', '2026-06-22'),
('DF-2026-012', 'Bea', 'Molina', 'Alvarez', '2001-05-16', 25, 'Single', 'Female', 51.50, 'O+', 'Eligible', '2026-08-14'),
('DF-2026-013', 'Kevin', 'Delgado', 'Vargas', '1990-12-25', 35, 'Married', 'Male', 82.10, 'AB-', 'Eligible', '2026-03-30'),
('DF-2026-014', 'Trisha', 'Jimenez', 'Herrera', '1993-04-28', 33, 'Married', 'Female', 60.20, 'A+', 'Eligible', '2026-07-02'),
('DF-2026-015', 'Bryan', 'Romero', 'Medina', '1988-08-08', 38, 'Married', 'Male', 76.40, 'O-', 'Eligible', '2026-06-05'),
('DF-2026-016', 'Katrina', 'Aguilar', 'Serrano', '1996-01-12', 30, 'Single', 'Female', 57.90, 'B+', 'Eligible', '2026-08-19'),
('DF-2026-017', 'Dennis', 'Ortega', 'Silva', '1987-07-07', 39, 'Married', 'Male', 74.00, 'O+', 'Eligible', '2026-05-14'),
('DF-2026-018', 'Camille', 'Gutierrez', 'Pascual', '2002-09-23', 24, 'Single', 'Female', 53.30, 'A+', 'Eligible', '2026-08-25'),
('DF-2026-019', 'Francis', 'Marquez', 'Leon', '1995-11-30', 30, 'Single', 'Male', 71.20, 'B+', 'Eligible', '2026-06-28'),
('DF-2026-020', 'Bianca', 'Chavez', 'Miranda', '1998-03-04', 28, 'Single', 'Female', 55.60, 'O+', 'Eligible', '2026-07-11'),
('DF-2026-021', 'Angelo', 'Santiago', 'Valdez', '1991-06-15', 35, 'Married', 'Male', 79.50, 'A-', 'Eligible', '2026-05-29'),
('DF-2026-022', 'Nicole', 'Padilla', 'Cortez', '1999-10-21', 27, 'Single', 'Female', 52.80, 'AB+', 'Eligible', '2026-08-03'),
('DF-2026-023', 'Patrick', 'Espinoza', 'Nunez', '1986-02-10', 40, 'Married', 'Male', 81.00, 'O+', 'Eligible', '2026-04-20'),
('DF-2026-024', 'Denise', 'Velasco', 'Maldonado', '1994-08-17', 32, 'Married', 'Female', 59.40, 'B-', 'Eligible', '2026-07-18'),
('DF-2026-025', 'Vincent', 'Rios', 'Campos', '1997-12-02', 28, 'Single', 'Male', 67.80, 'O+', 'Eligible', '2026-08-08'),
('DF-2026-026', 'Erika', 'Solis', 'Fuentes', '2000-04-19', 26, 'Single', 'Female', 54.70, 'A+', 'Deferred', NULL),
('DF-2026-027', 'Gerald', 'Pena', 'Cabrera', '1984-09-09', 42, 'Married', 'Male', 85.20, 'B+', 'Deferred', '2025-11-12'),
('DF-2026-028', 'Clarissa', 'Bautista', 'Domingo', '1993-05-25', 33, 'Married', 'Female', 48.00, 'O-', 'Deferred', NULL),
('DF-2026-029', 'Rafael', 'Contreras', 'Estrada', '1990-01-06', 36, 'Single', 'Male', 73.10, 'O+', 'Deferred', '2026-01-15'),
('DF-2026-030', 'Monique', 'Figueroa', 'Luna', '1996-07-14', 30, 'Single', 'Female', 56.00, 'A+', 'Deferred', NULL);
GO

-- 2. INSERT 30 ROWS INTO MEDICAL_STAFF
INSERT INTO MEDICAL_STAFF (Name, Role) VALUES
('Dr. Roberto Santos', 'Physician'),
('Dr. Elena Cruz', 'Physician'),
('Dr. Miguel Reyes', 'Hematologist'),
('Nurse Sarah Lim', 'Phlebotomist'),
('Nurse Daniel Tan', 'Phlebotomist'),
('Nurse Angela Ong', 'Screening Nurse'),
('Nurse Joshua Chua', 'Screening Nurse'),
('MedTech Patricia Sy', 'Medical Technologist'),
('MedTech Christian Go', 'Medical Technologist'),
('MedTech Jasmine Uy', 'Medical Technologist'),
('Dr. Ricardo Mendoza', 'Physician'),
('Dr. Clarissa Villanueva', 'Physician'),
('Nurse Kevin Bautista', 'Phlebotomist'),
('Nurse Hannah Garcia', 'Phlebotomist'),
('Nurse Louie Torres', 'Screening Nurse'),
('Nurse Dianne Ramos', 'Screening Nurse'),
('MedTech Adrian Aquino', 'Medical Technologist'),
('MedTech Camille Castro', 'Medical Technologist'),
('MedTech Paolo Rivera', 'Medical Technologist'),
('Dr. Teresa Gomez', 'Hematologist'),
('Nurse Bianca Navarro', 'Phlebotomist'),
('Nurse Jerome Salazar', 'Phlebotomist'),
('Nurse Rachel Molina', 'Screening Nurse'),
('Nurse Andrei Delgado', 'Screening Nurse'),
('MedTech Sophia Jimenez', 'Medical Technologist'),
('MedTech Nathan Romero', 'Medical Technologist'),
('Dr. Victor Aguilar', 'Physician'),
('Nurse Alyssa Ortega', 'Phlebotomist'),
('Nurse Gabriel Gutierrez', 'Screening Nurse'),
('MedTech Chloe Marquez', 'Medical Technologist');
GO

-- 3. INSERT 30 ROWS INTO SCREENING
INSERT INTO SCREENING (DonorID, StaffID, Screening_Date, Systolic_BP, Diastolic_BP, Pulse_Rate, Has_Recent_Tattoos, Screening_Result, Interview_Sheet, Medical_History) VALUES
(1, 1, '2026-10-01 08:30:00', 120, 80, 72, 0, 'Passed', 'Complete and verified', 'No known allergies or chronic illness'),
(2, 6, '2026-10-01 09:00:00', 110, 70, 76, 0, 'Passed', 'Complete and verified', 'Healthy, regular donor'),
(3, 2, '2026-10-02 08:45:00', 125, 82, 70, 0, 'Passed', 'Complete and verified', 'Controlled mild hypertension, cleared by MD'),
(4, 7, '2026-10-02 09:15:00', 115, 75, 78, 0, 'Passed', 'Complete and verified', 'No medical issues'),
(5, 11, '2026-10-03 10:00:00', 122, 80, 74, 0, 'Passed', 'Complete and verified', 'No medications taken'),
(6, 15, '2026-10-03 10:30:00', 118, 76, 80, 0, 'Passed', 'Complete and verified', 'Normal physical exam'),
(7, 12, '2026-10-04 08:20:00', 128, 84, 68, 0, 'Passed', 'Complete and verified', 'Cleared by physician'),
(8, 16, '2026-10-04 09:10:00', 112, 72, 75, 0, 'Passed', 'Complete and verified', 'Healthy'),
(9, 1, '2026-10-05 11:00:00', 120, 78, 71, 0, 'Passed', 'Complete and verified', 'No history of surgery'),
(10, 23, '2026-10-05 11:30:00', 116, 74, 79, 0, 'Passed', 'Complete and verified', 'No recent travel'),
(11, 2, '2026-10-06 08:50:00', 124, 80, 73, 0, 'Passed', 'Complete and verified', 'Healthy'),
(12, 24, '2026-10-06 09:40:00', 110, 70, 82, 0, 'Passed', 'Complete and verified', 'First-time cleared donor'),
(13, 27, '2026-10-07 10:15:00', 126, 82, 69, 0, 'Passed', 'Complete and verified', 'No chronic conditions'),
(14, 29, '2026-10-07 10:45:00', 118, 78, 74, 0, 'Passed', 'Complete and verified', 'Regular donor'),
(15, 11, '2026-10-08 08:30:00', 122, 80, 72, 0, 'Passed', 'Complete and verified', 'Cleared'),
(16, 6, '2026-10-08 09:20:00', 114, 74, 77, 0, 'Passed', 'Complete and verified', 'No medications'),
(17, 12, '2026-10-09 11:10:00', 120, 80, 70, 0, 'Passed', 'Complete and verified', 'Healthy'),
(18, 7, '2026-10-09 13:30:00', 112, 72, 81, 0, 'Passed', 'Complete and verified', 'Normal hemoglobin'),
(19, 1, '2026-10-10 14:00:00', 124, 82, 75, 0, 'Passed', 'Complete and verified', 'No medical issues'),
(20, 15, '2026-10-10 14:30:00', 116, 76, 76, 0, 'Passed', 'Complete and verified', 'Healthy'),
(21, 2, '2026-10-11 09:00:00', 128, 84, 72, 0, 'Passed', 'Complete and verified', 'Cleared'),
(22, 16, '2026-10-11 09:30:00', 110, 70, 78, 0, 'Passed', 'Complete and verified', 'No allergies'),
(23, 27, '2026-10-12 10:00:00', 126, 82, 68, 0, 'Passed', 'Complete and verified', 'Regular donor'),
(24, 23, '2026-10-12 10:30:00', 118, 76, 74, 0, 'Passed', 'Complete and verified', 'Healthy'),
(25, 11, '2026-10-13 11:00:00', 120, 80, 73, 0, 'Passed', 'Complete and verified', 'No known issues'),
(26, 24, '2026-10-14 08:30:00', 115, 75, 80, 1, 'Failed', 'Deferred due to tattoo', 'Got a tattoo 3 months ago'),
(27, 1, '2026-10-14 09:15:00', 155, 98, 88, 0, 'Failed', 'Deferred due to high BP', 'Elevated blood pressure during screening'),
(28, 29, '2026-10-15 10:00:00', 100, 65, 85, 0, 'Failed', 'Deferred due to underweight', 'Weight below 50kg requirement'),
(29, 2, '2026-10-15 11:00:00', 120, 80, 76, 0, 'Failed', 'Deferred due to medication', 'Currently taking antibiotics for tooth infection'),
(30, 6, '2026-10-16 13:00:00', 105, 68, 92, 0, 'Failed', 'Deferred due to low hemoglobin', 'Low hemoglobin count on pre-test');
GO

-- 4. INSERT 30 ROWS INTO BLOOD_BAGS
INSERT INTO BLOOD_BAGS (Bag_Serial_Number, DonorID, Collection_Date, TTI_Status, Bag_Status) VALUES
('BAG-2026-1001', 1, '2026-10-01', 'Non-Reactive', 'Processed'),
('BAG-2026-1002', 2, '2026-10-01', 'Non-Reactive', 'Processed'),
('BAG-2026-1003', 3, '2026-10-02', 'Non-Reactive', 'Processed'),
('BAG-2026-1004', 4, '2026-10-02', 'Non-Reactive', 'Processed'),
('BAG-2026-1005', 5, '2026-10-03', 'Non-Reactive', 'Processed'),
('BAG-2026-1006', 6, '2026-10-03', 'Non-Reactive', 'Processed'),
('BAG-2026-1007', 7, '2026-10-04', 'Non-Reactive', 'Processed'),
('BAG-2026-1008', 8, '2026-10-04', 'Non-Reactive', 'Processed'),
('BAG-2026-1009', 9, '2026-10-05', 'Non-Reactive', 'Processed'),
('BAG-2026-1010', 10, '2026-10-05', 'Non-Reactive', 'Processed'),
('BAG-2026-1011', 11, '2026-10-06', 'Non-Reactive', 'Processed'),
('BAG-2026-1012', 12, '2026-10-06', 'Non-Reactive', 'Processed'),
('BAG-2026-1013', 13, '2026-10-07', 'Non-Reactive', 'Processed'),
('BAG-2026-1014', 14, '2026-10-07', 'Non-Reactive', 'Processed'),
('BAG-2026-1015', 15, '2026-10-08', 'Non-Reactive', 'Processed'),
('BAG-2026-1016', 16, '2026-10-08', 'Non-Reactive', 'Processed'),
('BAG-2026-1017', 17, '2026-10-09', 'Non-Reactive', 'Processed'),
('BAG-2026-1018', 18, '2026-10-09', 'Non-Reactive', 'Processed'),
('BAG-2026-1019', 19, '2026-10-10', 'Non-Reactive', 'Processed'),
('BAG-2026-1020', 20, '2026-10-10', 'Non-Reactive', 'Processed'),
('BAG-2026-1021', 21, '2026-10-11', 'Non-Reactive', 'Processed'),
('BAG-2026-1022', 22, '2026-10-11', 'Non-Reactive', 'Processed'),
('BAG-2026-1023', 23, '2026-10-12', 'Non-Reactive', 'Processed'),
('BAG-2026-1024', 24, '2026-10-12', 'Non-Reactive', 'Processed'),
('BAG-2026-1025', 25, '2026-10-13', 'Non-Reactive', 'Processed'),
('BAG-2026-1026', 1, '2026-11-01', 'Pending', 'Quarantined'),
('BAG-2026-1027', 2, '2026-11-02', 'Pending', 'Quarantined'),
('BAG-2026-1028', 3, '2026-11-03', 'Reactive', 'Discarded'),
('BAG-2026-1029', 4, '2026-11-04', 'Pending', 'Quarantined'),
('BAG-2026-1030', 5, '2026-11-05', 'Non-Reactive', 'Processed');
GO

-- 5. INSERT 30 ROWS INTO BLOOD_REQUESTS
INSERT INTO BLOOD_REQUESTS (Patient_Name, Hospital_Name, Required_Blood_Type, Quantity_Requested, Is_Blood_Samaritan, Processing_Fee, Request_Status) VALUES
('Mateo Morales', 'Camarines Norte Provincial Hospital', 'O+', 2, 0, 1800.00, 'Fulfilled'),
('Sofia Perez', 'Bicol Medical Center', 'A+', 1, 1, 0.00, 'Fulfilled'),
('Lucas Diaz', 'Leon D. Hernandez Memorial Hospital', 'B+', 3, 0, 1800.00, 'Fulfilled'),
('Isabella Ocampo', 'Camarines Norte Provincial Hospital', 'O-', 2, 0, 1800.00, 'Fulfilled'),
('Gabriel Rojas', 'Our Lady of Lourdes Hospital', 'AB+', 1, 1, 0.00, 'Fulfilled'),
('Mia Alvarez', 'Bicol Regional Hospital', 'A-', 2, 0, 1800.00, 'Fulfilled'),
('Liam Vargas', 'Camarines Norte Provincial Hospital', 'O+', 1, 0, 1800.00, 'Fulfilled'),
('Emma Herrera', 'St. Jude Hospital', 'B-', 1, 1, 0.00, 'Fulfilled'),
('Noah Medina', 'Bicol Medical Center', 'O+', 2, 0, 1800.00, 'Fulfilled'),
('Olivia Serrano', 'Daet Doctors Hospital', 'A+', 2, 0, 1800.00, 'Fulfilled'),
('Ethan Silva', 'Camarines Norte Provincial Hospital', 'B+', 1, 1, 0.00, 'Fulfilled'),
('Ava Pascual', 'Bicol Medical Center', 'O+', 3, 0, 1800.00, 'Fulfilled'),
('Mason Leon', 'Our Lady of Lourdes Hospital', 'AB-', 1, 0, 1800.00, 'Fulfilled'),
('Sophia Miranda', 'Daet Doctors Hospital', 'A+', 2, 1, 0.00, 'Fulfilled'),
('Logan Valdez', 'Bicol Regional Hospital', 'O-', 2, 0, 1800.00, 'Fulfilled'),
('Amelia Cortez', 'Camarines Norte Provincial Hospital', 'B+', 1, 0, 1800.00, 'Pending'),
('Jacob Nunez', 'Bicol Medical Center', 'O+', 2, 1, 0.00, 'Pending'),
('Harper Maldonado', 'Daet Doctors Hospital', 'A+', 1, 0, 1800.00, 'Pending'),
('Michael Campos', 'St. Jude Hospital', 'B+', 2, 0, 1800.00, 'Pending'),
('Evelyn Fuentes', 'Camarines Norte Provincial Hospital', 'O+', 1, 1, 0.00, 'Pending'),
('Daniel Cabrera', 'Bicol Medical Center', 'A-', 2, 0, 1800.00, 'Pending'),
('Abigail Domingo', 'Our Lady of Lourdes Hospital', 'AB+', 1, 0, 1800.00, 'Pending'),
('Henry Estrada', 'Bicol Regional Hospital', 'O+', 3, 1, 0.00, 'Pending'),
('Emily Luna', 'Daet Doctors Hospital', 'B-', 1, 0, 1800.00, 'Pending'),
('Sebastian Cruz', 'Camarines Norte Provincial Hospital', 'O+', 2, 0, 1800.00, 'Pending'),
('Elizabeth Reyes', 'Bicol Medical Center', 'A+', 1, 0, 1800.00, 'Cancelled'),
('Jack Garcia', 'Daet Doctors Hospital', 'O-', 2, 1, 0.00, 'Cancelled'),
('Scarlett Torres', 'St. Jude Hospital', 'B+', 1, 0, 1800.00, 'Cancelled'),
('Owen Ramos', 'Camarines Norte Provincial Hospital', 'O+', 2, 0, 1800.00, 'Pending'),
('Victoria Fernandez', 'Bicol Medical Center', 'A+', 1, 1, 0.00, 'Pending');
GO

-- 6. INSERT 30 ROWS INTO BLOOD_COMPONENTS
INSERT INTO BLOOD_COMPONENTS (Bag_Serial_Number, Component_Type, Storage_Location, Expiration_Date, Availability_Status, RequestID) VALUES
('BAG-2026-1001', 'Packed Red Blood Cells', 'Ref-A1', '2026-11-12', 'Issued', 1),
('BAG-2026-1002', 'Packed Red Blood Cells', 'Ref-A1', '2026-11-12', 'Issued', 2),
('BAG-2026-1003', 'Packed Red Blood Cells', 'Ref-A2', '2026-11-13', 'Issued', 3),
('BAG-2026-1004', 'Packed Red Blood Cells', 'Ref-A2', '2026-11-13', 'Issued', 4),
('BAG-2026-1005', 'Packed Red Blood Cells', 'Ref-A3', '2026-11-14', 'Issued', 5),
('BAG-2026-1006', 'Packed Red Blood Cells', 'Ref-A3', '2026-11-14', 'Issued', 6),
('BAG-2026-1007', 'Packed Red Blood Cells', 'Ref-B1', '2026-11-15', 'Issued', 7),
('BAG-2026-1008', 'Packed Red Blood Cells', 'Ref-B1', '2026-11-15', 'Issued', 8),
('BAG-2026-1009', 'Packed Red Blood Cells', 'Ref-B2', '2026-11-16', 'Issued', 9),
('BAG-2026-1010', 'Packed Red Blood Cells', 'Ref-B2', '2026-11-16', 'Issued', 10),
('BAG-2026-1011', 'Packed Red Blood Cells', 'Ref-B3', '2026-11-17', 'Issued', 11),
('BAG-2026-1012', 'Packed Red Blood Cells', 'Ref-B3', '2026-11-17', 'Issued', 12),
('BAG-2026-1013', 'Packed Red Blood Cells', 'Ref-C1', '2026-11-18', 'Issued', 13),
('BAG-2026-1014', 'Packed Red Blood Cells', 'Ref-C1', '2026-11-18', 'Issued', 14),
('BAG-2026-1015', 'Packed Red Blood Cells', 'Ref-C2', '2026-11-19', 'Issued', 15),
('BAG-2026-1016', 'Packed Red Blood Cells', 'Ref-C2', '2026-11-19', 'Available', NULL),
('BAG-2026-1017', 'Packed Red Blood Cells', 'Ref-C3', '2026-11-20', 'Available', NULL),
('BAG-2026-1018', 'Packed Red Blood Cells', 'Ref-C3', '2026-11-20', 'Available', NULL),
('BAG-2026-1019', 'Packed Red Blood Cells', 'Ref-D1', '2026-11-21', 'Available', NULL),
('BAG-2026-1020', 'Packed Red Blood Cells', 'Ref-D1', '2026-11-21', 'Available', NULL),
('BAG-2026-1021', 'Fresh Frozen Plasma', 'Freezer-F1', '2027-10-11', 'Available', NULL),
('BAG-2026-1022', 'Fresh Frozen Plasma', 'Freezer-F1', '2027-10-11', 'Available', NULL),
('BAG-2026-1023', 'Fresh Frozen Plasma', 'Freezer-F2', '2027-10-12', 'Available', NULL),
('BAG-2026-1024', 'Fresh Frozen Plasma', 'Freezer-F2', '2027-10-12', 'Available', NULL),
('BAG-2026-1025', 'Fresh Frozen Plasma', 'Freezer-F3', '2027-10-13', 'Available', NULL),
('BAG-2026-1001', 'Platelet Concentrate', 'Agitator-P1', '2026-10-06', 'Expired', NULL),
('BAG-2026-1002', 'Platelet Concentrate', 'Agitator-P1', '2026-10-06', 'Expired', NULL),
('BAG-2026-1026', 'Whole Blood', 'Quarantine-Q1', '2026-12-06', 'Quarantined', NULL),
('BAG-2026-1027', 'Whole Blood', 'Quarantine-Q1', '2026-12-07', 'Quarantined', NULL),
('BAG-2026-1030', 'Packed Red Blood Cells', 'Ref-D2', '2026-12-17', 'Available', NULL);
GO

-- 7. INSERT DEMO LOGIN ACCOUNTS INTO SYSTEM_USERS
INSERT INTO SYSTEM_USERS (StaffID, Username, Password_Hash) VALUES
(1, 'dr.santos', 'prc2026'),
(4, 'nurse.lim', 'prc2026'),
(8, 'medtech.sy', 'prc2026');
GO