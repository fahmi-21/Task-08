create database barwonheath
go

use barwonheath
go

CREATE SCHEMA TASK;
GO

CREATE TABLE TASK.Doctors
(
  Doctor_id INT NOT NULL,
  Name VARCHAR(100) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  Phone_Number VARCHAR(20) NOT NULL,
  Specialty VARCHAR(50) NOT NULL,
  Years_of_Experience INT NOT NULL CHECK (Years_of_Experience >=0 ),
  PRIMARY KEY (Doctor_id),
  UNIQUE (Email)
);

CREATE TABLE TASK.Patient
(
  UR_Number INT NOT NULL,
  Name VARCHAR(100) NOT NULL,
  CITY VARCHAR(100) NOT NULL,
  STREET VARCHAR(100) NOT NULL,
  STATE VARCHAR(100) NOT NULL,
  Age INT NOT NULL CHECK (AGE >= 0 ),
  Email VARCHAR(100),
  Phone_Number VARCHAR(20) NOT NULL,
  Medicare_Card_Number VARCHAR(20),
  Primary_Doctor_id INT NOT NULL,
  PRIMARY KEY (UR_Number),
  FOREIGN KEY (Primary_Doctor_id) REFERENCES TASK.Doctors(Doctor_id),
  UNIQUE (Email),
  UNIQUE (Medicare_Card_Number)
);

CREATE TABLE TASK.Pharmaceutical_Companies
(
  Company_id INT NOT NULL,
  Name VARCHAR(100) NOT NULL,
  STATE VARCHAR(100) NOT NULL,
  CITY VARCHAR(100) NOT NULL,
  STREET VARCHAR(100) NOT NULL,
  Phone VARCHAR(20) NOT NULL,
  PRIMARY KEY (Company_id)
);

CREATE TABLE TASK.Drug
(
  Drug_id INT NOT NULL,
  Trade_name VARCHAR(50) NOT NULL,
  Strength INT NOT NULL CHECK (Strength > 0 ),
  Company_id INT NOT NULL,
  PRIMARY KEY (Drug_id),
  FOREIGN KEY (Company_id) REFERENCES TASK.Pharmaceutical_Companies(Company_id) ON DELETE CASCADE
);

CREATE TABLE TASK.Prescription
(
  Prescription_id INT NOT NULL,
  Prescription_Date DATE NOT NULL,
  Quantity FLOAT NOT NULL CHECK ( Quantity > 0 ),
  Doctor_id INT NOT NULL,
  Drug_id INT NOT NULL,
  UR_Number INT NOT NULL,
  PRIMARY KEY (Prescription_id),
  FOREIGN KEY (Doctor_id) REFERENCES TASK.Doctors(Doctor_id),
  FOREIGN KEY (Drug_id) REFERENCES TASK.Drug(Drug_id),
  FOREIGN KEY (UR_Number) REFERENCES TASK.Patient(UR_Number)
);

--1. SELECT: Retrieve all columns from the Doctor table.
SELECT *
FROM TASK.DOCTORS;

--2. ORDER BY: List patients in the Patient table in ascending order of their
--ages.
SELECT *
FROM TASK.Patient
ORDER BY AGE;

--3. OFFSET FETCH: Retrieve the first 10 patients from the Patient table, starting
--from the 5th record.
SELECT *
FROM TASK.Patient
ORDER BY UR_Number
OFFSET 4 ROWS 
FETCH NEXT 10 ROWS ONLY;

--4. SELECT TOP: Retrieve the top 5 doctors from the Doctor table.
SELECT TOP 5 *
FROM TASK.Doctors
ORDER BY Doctor_id;

--5. SELECT DISTINCT: Get a list of unique address from the Patient table.
SELECT DISTINCT CITY + ', ' + STREET + ', ' + STATE AS Address
FROM TASK.Patient;

--6. WHERE: Retrieve patients from the Patient table who are aged 25.
SELECT *
FROM TASK.Patient
WHERE Age = 25;

--7. NULL: Retrieve patients from the Patient table whose email is not provided.
SELECT *
FROM TASK.Patient
WHERE Email IS NULL;

--8. AND: Retrieve doctors from the Doctor table who have experience greater
--than 5 years and specialize in Cardiology.
SELECT * 
FROM TASK.Doctors
WHERE Years_of_Experience >= 5 AND Specialty = 'Cardiology';

--9. IN: Retrieve doctors from the Doctor table whose speciality is either
--Dermatology or Oncology
SELECT *
FROM TASK.Doctors
where Specialty in ('Dermatology' , 'Oncology');

--10. BETWEEN: Retrieve patients from the Patient table whose ages are
--between 18 and 30.
select * 
FROM TASK.Patient
WHERE Age BETWEEN 18 AND 30;

--11. LIKE: Retrieve doctors from the Doctor table whose names start with Dr.
SELECT *
FROM TASK.Doctors
WHERE UPPER(Name) LIKE 'DR%';

--12. Column AND Table Aliases: Select the name and email of doctors, aliasing
--them as DoctorName and DoctorEmail.
SELECT D.Name , D.Email
FROM TASK.Doctors D;

--13. Joins: Retrieve all prescriptions with corresponding patient names.
SELECT PA.Name ,    
       P.Prescription_id,
       P.Prescription_Date,
       P.Quantity,
       P.Doctor_id,
       P.Drug_id,
       PA.Name AS PatientName
FROM TASK.Prescription AS P JOIN TASK.Patient AS PA
ON P.UR_Number = PA.UR_Number;


--14. GROUP BY: Retrieve the count of patients grouped by their cities.
SELECT CITY, COUNT(*) AS PatientCount
FROM TASK.Patient
GROUP BY CITY;

--15. HAVING: Retrieve cities with more than 3 patients.
SELECT City,COUNT(*) AS PatientCount
FROM TASK.Patient
GROUP BY City
HAVING COUNT(*) > 3;

--16. GROUPING SETS: Retrieve counts of patients grouped by cities and ages.
SELECT CITY , Age , COUNT(*) AS PatientCount
FROM TASK.Patient
GROUP BY GROUPING SETS ( 
                            ( CITY , AGE),
                            (CITY) ,
                            (Age), 
                            ()
                        );
--17. CUBE: Retrieve counts of patients considering all possible combinations of
--city and age.
select city , age ,count (*) as pcount
from task.Patient
group by cube ( city , age );


--18. ROLLUP: Retrieve counts of patients rolled up by city.
SELECT CITY , COUNT (*) AS PCOUNT
FROM TASK.Patient
GROUP BY ROLLUP (CITY);

SELECT CITY , COUNT (*) AS PCOUNT
FROM TASK.Patient
GROUP BY CITY WITH ROLLUP;

SELECT CITY , COUNT (*) AS PCOUNT
FROM TASK.Patient
GROUP BY CITY
UNION ALL
SELECT NULL AS CITY , COUNT (*) As PCOUNT
FROM  TASK.Patient;



--19. EXISTS: Retrieve patients who have at least one prescription.
SELECT *
FROM TASK.Patient PA
WHERE EXISTS (
    SELECT 1
    FROM TASK.Prescription P
    WHERE P.UR_Number = PA.UR_Number
);

--20. UNION: Retrieve a combined list of doctors and patients.
SELECT Name AS DNAME
FROM TASK.Doctors
UNION 
SELECT Name
FROM TASK.Patient;

--21. Common Table Expression (CTE): Retrieve patients along with their doctors
--using a CTE.
WITH PDCTE AS (
SELECT 
        P.Phone_Number,
        P.Name AS PatientName,
        P.Age,
        P.STATE,
        P.CITY ,
        P.STREET,
        P.Email , 
        P.Medicare_Card_Number,
        D.Name as DoctorName
FROM TASK.Patient P
JOIN TASK.Doctors D
ON P.Primary_Doctor_id = D.Doctor_id
)

select *
from PDCTE
order by PatientName;

--22. INSERT: Insert a new doctor into the Doctor table.
INSERT INTO TASK.Doctors
    (Doctor_id, Name, Email, Phone_Number, Specialty, Years_of_Experience)
VALUES
    (1, 'Dr. Ahmed Ali', 'ahmed.ali@example.com', '01012345678', 'Cardiology', 10);

--23. INSERT Multiple Rows: Insert multiple patients into the Patient table.
INSERT INTO TASK.Patient
    (UR_Number, Name, CITY, STREET, STATE, Age, Email, Phone_Number, Medicare_Card_Number, Primary_Doctor_id)
VALUES
    (2, 'Sara Ahmed', 'Giza', 'Pyramids St', 'Giza', 32, 'sara.a@example.com', '01033334444', 'MC12346', 102),
    (3, 'Omar Hassan', 'Alexandria', 'Corniche St', 'Alexandria', 24, 'omar.h@example.com', '01055556666', 'MC12347', 103),
    (4, 'Laila Youssef', 'Cairo', 'Nasr City St', 'Cairo', 29, 'laila.y@example.com', '01077778888', 'MC12348', 101),
    (5, 'Hassan Ali', 'Giza', 'Dokki St', 'Giza', 35, 'hassan.a@example.com', '01099990000', 'MC12349', 102),
    (6, 'Mona Khaled', 'Cairo', 'Maadi St', 'Cairo', 27, 'mona.k@example.com', '01012121212', 'MC12350', 101),
    (7, 'Youssef Samir', 'Alexandria', 'Sidi Gaber St', 'Alexandria', 30, 'youssef.s@example.com', '01034343434', 'MC12351', 103),
    (8, 'Nada Omar', 'Giza', 'Mohandessin St', 'Giza', 26, 'nada.o@example.com', '01056565656', 'MC12352', 102),
    (9, 'Karim Tamer', 'Cairo', 'Heliopolis St', 'Cairo', 33, 'karim.t@example.com', '01078787878', 'MC12353', 101),
    (10, 'Salma Adel', 'Alexandria', 'Stanley St', 'Alexandria', 31, 'salma.a@example.com', '01090909090', 'MC12354', 103);


--24. UPDATE: Update the phone number of a doctor.
UPDATE TASK.Doctors
SET Phone_Number = '01211519206'
WHERE Doctor_id = 10;

--25. UPDATE JOIN: Update the city of patients who have a prescription from a
--specific doctor.
UPDATE TASK.Patient
SET CITY = 'CAIRO'
FROM TASK.Patient PA
JOIN TASK.Prescription P
ON PA.UR_Number = P.UR_Number
WHERE P.Doctor_id = 10;

--26. DELETE: Delete a patient from the Patient table.
DELETE FROM TASK.Patient
WHERE UR_Number = 2;

--27. Transaction: Insert a new doctor and a patient, ensuring both operations
--succeed or fail together.
BEGIN TRANSACTION;

BEGIN TRY
    -- 1️⃣ إدراج طبيب جديد
    INSERT INTO TASK.Doctors
        (Doctor_id, Name, Email, Phone_Number, Specialty, Years_of_Experience)
    VALUES
        (104, 'Dr. Fatma Ali', 'fatma.ali@example.com', '01012349876', 'Pediatrics', 8);

    INSERT INTO TASK.Patient
        (UR_Number, Name, CITY, STREET, STATE, Age, Email, Phone_Number, Medicare_Card_Number, Primary_Doctor_id)
    VALUES
        (211, 'Mariam Hassan', 'Cairo', 'Maadi St', 'Cairo', 25, 'mariam.h@example.com', '01011223344', 'MC12355', 104);

    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back due to an error: ' + ERROR_MESSAGE();
END CATCH;

--28. View: Create a view that combines patient and doctor information for easy
--access.
GO

CREATE VIEW TASK.VWPD
AS
SELECT 
    P.UR_Number,
    P.Name AS PatientName,
    P.Age,
    P.CITY,
    P.STREET,
    P.STATE,
    P.Phone_Number AS PatientPhone,
    P.Email AS PatientEmail,
    P.Medicare_Card_Number,
    D.Doctor_id,
    D.Name AS DoctorName,
    D.Specialty,
    D.Phone_Number AS DoctorPhone,
    D.Email AS DoctorEmail,
    D.Years_of_Experience
FROM TASK.Patient P
JOIN TASK.Doctors D
ON D.Doctor_id = P.Primary_Doctor_id;

GO

--29. Index: Create an index on the phone column of the Patient table to
--improve search performance.
CREATE NONCLUSTERED INDEX ID_P_PHONE
ON TASK.PATIENT (PHONE_NUMBER);

--30. Backup: Perform a backup of the entire database to ensure data safety.
BACKUP DATABASE TASK
TO DISK = 'C:\SQLBackups\TASK_FullBackup.bak'
WITH FORMAT,
     MEDIANAME = 'TASKBackup',
     NAME = 'Full Backup of TASK Database';


