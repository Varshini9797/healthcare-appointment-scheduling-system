create database hospital
use hospital

-- 1. Patients Table
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    address TEXT,
    created_at DATETIME
)
select*from Patients


-- 2. Doctors Table
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    available_status VARCHAR(10),
    created_at DATETIME
)

-- 3. AppointmentSlots Table
CREATE TABLE AppointmentSlots (
    slot_id INT PRIMARY KEY,
    doctor_id INT,
    slot_date DATE,
    start_time TIME,
    end_time TIME,
    is_booked VARCHAR(5),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
)

-- 4. Appointments Table
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    slot_id INT,
    appointment_date DATE,
    status VARCHAR(50),
    notes TEXT,
    created_at DATETIME,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (slot_id) REFERENCES AppointmentSlots(slot_id)
)

-- 5. MedicalHistories Table
CREATE TABLE MedicalHistories (
    history_id INT PRIMARY KEY,
    patient_id INT,
    diagnosis TEXT,
    treatment TEXT,
    medications TEXT,
    visit_date DATE,
    doctor_id INT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
)

-- 6. Departments Table
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100),
    dep_description TEXT
)

-- 7. DoctorSchedules Table
CREATE TABLE DoctorSchedules (
    schedule_id INT PRIMARY KEY,
    doctor_id INT,
    day_of_week VARCHAR(20),
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
)

-- 8. Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    password_hash VARCHAR(255),
    role VARCHAR(50),
    associated_doctor_id INT,
    FOREIGN KEY (associated_doctor_id) REFERENCES Doctors(doctor_id)
)


DELIMITER $$
CREATE PROCEDURE GetAppointmentsByPatient(IN pid INT)
BEGIN
    SELECT a.appointment_id, a.appointment_date, a.status, d.first_name AS doctor_name
    FROM Appointments a
    JOIN Doctors d ON a.doctor_id = d.doctor_id
    WHERE a.patient_id = pid;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetAvailableSlots(IN doc_id INT)
BEGIN
    SELECT slot_id, slot_date, start_time, end_time
    FROM AppointmentSlots
    WHERE doctor_id = doc_id AND is_booked = FALSE;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetMedicalHistory(IN pid INT)
BEGIN
    SELECT history_id, diagnosis, treatment, medications, visit_date
    FROM MedicalHistories
    WHERE patient_id = pid;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetDoctorSchedule(IN doc_id INT)
BEGIN
    SELECT day_of_week, start_time, end_time
    FROM DoctorSchedules
    WHERE doctor_id = doc_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetDoctorsByDepartment(IN dept_name VARCHAR(100))
BEGIN
    SELECT d.doctor_id, d.first_name, d.last_name, d.specialization
    FROM Doctors d
    JOIN Departments dept ON d.specialization = dept.name
    WHERE dept.name = dept_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetDailyAppointments(IN appt_date DATE)
BEGIN
    SELECT a.appointment_id, p.first_name AS patient_name, d.first_name AS doctor_name, a.status
    FROM Appointments a
    JOIN Patients p ON a.patient_id = p.patient_id
    JOIN Doctors d ON a.doctor_id = d.doctor_id
    WHERE a.appointment_date = appt_date;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetPatientCountByDoctor(IN doc_id INT)
BEGIN
    SELECT d.first_name, d.last_name, COUNT(a.patient_id) AS total_patients
    FROM Appointments a
    JOIN Doctors d ON a.doctor_id = d.doctor_id
    WHERE a.doctor_id = doc_id
    GROUP BY d.doctor_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetRecentVisits(IN pid INT)
BEGIN
    SELECT history_id, diagnosis, visit_date
    FROM MedicalHistories
    WHERE patient_id = pid
    ORDER BY visit_date DESC
    LIMIT 5;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE CheckDoctorAvailability(IN doc_id INT, IN dayname VARCHAR(20))
BEGIN
    SELECT *
    FROM DoctorSchedules
    WHERE doctor_id = doc_id AND day_of_week = dayname;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetAllPatients()
BEGIN
    SELECT patient_id, first_name, last_name, gender, phone_number, email
    FROM Patients;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetAllDoctors()
BEGIN
    SELECT doctor_id, first_name, last_name, specialization, phone_number, email
    FROM Doctors;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetNamesfromPatientstartingwithA()
BEGIN
     SELECT * FROM patients where first_name like "A%";
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetNamesfromPatientstartingwithJandZ()
BEGIN
     SELECT * FROM patients where first_name like "J%"and last_name like "%Z";
END$$
DELIMITER ;


CALL GetAppointmentsByPatient(1);
CALL GetAvailableSlots(1);
CALL GetMedicalHistory(5);
CALL GetDoctorSchedule(1);
CALL GetDoctorsByDepartment('Cardiology');
CALL GetDailyAppointments(CURDATE());
CALL GetPatientCountByDoctor(2);
CALL GetRecentVisits(5);
CALL CheckDoctorAvailability(1, 'Tuesday');
CALL GetAllPatients();
CALL GetAllDoctors();
CALL GetNamesfromPatientstartingwithJandZ();
CALL GetNamesfromPatientstartingwithA();




