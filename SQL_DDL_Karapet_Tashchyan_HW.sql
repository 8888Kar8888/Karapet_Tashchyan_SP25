--DROP DATABASE IF EXISTS EliteHire;
CREATE DATABASE EliteHire;

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS EliteHireSchema;

-- Drop existing tables if any
DROP TABLE IF EXISTS EliteHireSchema.Employees CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.JobOpenings CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.Applicants CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.JobApplicants CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.JobSkills CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.Interviews CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.Placements CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.JobOpeningSkills CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.ApplicantSkills CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.Services CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.JobPreferences CASCADE;
DROP TABLE IF EXISTS EliteHireSchema.ApplicantPreferences CASCADE;

CREATE TABLE EliteHireSchema.Employees
(
	Employee_ID SERIAL primary key,
	Name Varchar(255) not null,
	Surname Varchar(255) not null,
	Type Varchar(10) not null,
	Email Varchar(255) not null unique,
	CONSTRAINT CHK_Type CHECK(Type in('Employer','Recruiter'))	
);


CREATE TABLE EliteHireSchema.JobOpenings
(
	Job_ID SERIAL primary key,
	Employer_ID  Int,
	Job_name Varchar(255) not null,
	Num_of_applicants Int default 0,
	Opening_date Date not null default CURRENT_DATE,
	Closing_date Date,
	Status Varchar(10),
	Expected_experience Float,
	CONSTRAINT FK_employer foreign key (Employer_ID) references EliteHireSchema.Employees(Employee_ID),
	CONSTRAINT CHK_OpeningDate CHECK (Opening_Date > '2000-01-01'),
	CONSTRAINT CHK_ExpectedExperience CHECK (Expected_experience is null or Expected_experience>=0),
	CONSTRAINT CHK_Status CHECK(Status in ('Open','Closed'))
);


CREATE TABLE EliteHireSchema.Applicants
(
	Applicant_ID SERIAL primary key,
	Name Varchar(100) not null,
	Surname Varchar(100) not null,
	Gender Char(1) not null,
	Email Varchar(255),
	Opening_date Date not null default CURRENT_DATE,
	Experience Float not null default 0,
	CONSTRAINT CHK_Gender CHECK(Gender in ('M','F')),
	CONSTRAINT CHK_Experience CHECK(Experience >=0)
);


CREATE TABLE EliteHireSchema.JobApplicants
(
	Applicant_ID Int,
	Job_ID Int,
	Application_date Date not null default CURRENT_DATE,
	Status Varchar(10) not null default 'Pending',
	primary key(Applicant_ID,Job_ID),
	CONSTRAINT CHK_Status CHECK(Status in ('Pending','Accepted','Rejected','Hired')),
	CONSTRAINT CHK_ApplicationDate CHECK(Application_date>'2000-01-01'),
	CONSTRAINT FK_Applicant foreign key(Applicant_ID) references EliteHireSchema.Applicants(Applicant_ID),
	CONSTRAINT FK_Job foreign key(Job_ID)references EliteHireSchema.JobOpenings(Job_ID)
);


 
CREATE TABLE EliteHireSchema.JobSkills
(
	Job_Skills_ID SERIAL primary key,
	Skill_name Varchar(255) not null
);


CREATE TABLE EliteHireSchema.Interviews
(
	Interview_ID SERIAL primary key,
	Job_ID Int,
	Applicant_ID Int,
	Recruiter_ID Int,
	Stage Varchar(10) default 'HR',
	Feedback Text,
	Scheduled_Date Date not null,
	Time Time not null,
	CONSTRAINT FK_JobID foreign key(Job_ID) references EliteHireSchema.JobOpenings(Job_ID),
	CONSTRAINT FK_ApplicantID foreign key(Applicant_ID) references EliteHireSchema.Applicants(Applicant_ID),
	CONSTRAINT FK_RecruiterID foreign key(Recruiter_ID) references  EliteHireSchema.Employees(Employee_ID),
	CONSTRAINT CHK_Stage CHECK(Stage in ('HR','Technical','Final')),
	CONSTRAINT CHK_ScheduledDate CHECK(Scheduled_Date>'2000-01-01')
);


CREATE TABLE EliteHireSchema.Placements
(
	Placement_ID SERIAL primary key,
	Applicant_ID Int,
	Job_ID Int,
	Offer_status char(8) ,
	Start_date Date,
	Salary Int not null default 0, 
	CONSTRAINT FK_ApplicantID foreign key(Applicant_ID) references EliteHireSchema.Applicants(Applicant_ID),
	CONSTRAINT FK_Job_ID foreign key(Job_ID) references EliteHireSchema.JobOpenings(Job_ID),
	CONSTRAINT CHK_OfferStatus CHECK(Offer_status is null or Offer_status in ('Accepted','Rejected')),
	CONSTRAINT CHK_StartDate CHECK(Start_date is null or Start_date>'2000-01-01'),
	CONSTRAINT CHK_Salary CHECK(Salary >=0)
);


CREATE TABLE EliteHireSchema.JobOpeningSkills
(
	Job_ID Int,
	Job_Skills_ID Int,
	PRIMARY KEY (Job_ID,Job_Skills_ID),
	CONSTRAINT FK_JobId foreign key(Job_ID) references EliteHireSchema.JobOpenings(Job_ID),
	CONSTRAINT FK_JobSkillsId foreign key(Job_Skills_ID) references EliteHireSchema.JobSkills(Job_Skills_ID)
);


CREATE TABLE EliteHireSchema.ApplicantSkills
(
	Applicant_ID Int,
	Job_Skills_ID Int,
	PRIMARY KEY(Applicant_ID,Job_Skills_ID),
	CONSTRAINT FK_ApplicantId foreign key(Applicant_ID) references EliteHireSchema.Applicants(Applicant_ID),
	CONSTRAINT FK_JobSkillsId foreign key(Job_Skills_ID) references EliteHireSchema.JobSkills(Job_Skills_ID)
);

CREATE TABLE EliteHireSchema.Services
(
	Service_ID SERIAL primary key,
	Job_opening_ID Int NULL,
	Person_email Varchar(255) not null unique,
	Service_type Varchar(20),
	Start_date Date not null,
	End_date Date not null,
	Status Varchar(10),
	CONSTRAINT FK_JobOpeningId foreign key(Job_opening_ID) references EliteHireSchema.JobOpenings(Job_ID),
	CONSTRAINT CHK_ServiceType CHECK(Service_type in ('Resume Writing', 'Interview Coaching', 'Skills Development')),
	CONSTRAINT CHK_StartDate CHECK(Start_date>'2000-01-01'),
	CONSTRAINT CHK_Status CHECK(Status in ('Begined','Canceled','Completed'))
);

CREATE TABLE EliteHireSchema.JobPreferences
(
	Job_ID Int primary key,
	Expected_sallary Int,
	Location Varchar(255),
	Remote Boolean,
	CONSTRAINT FK_JobId foreign key(Job_ID) references EliteHireSchema.JobOpenings(Job_ID),
	CONSTRAINT CHK_ExpectedSallary CHECK(Expected_sallary is null or Expected_sallary>=0)
);

CREATE TABLE EliteHireSchema.ApplicantPreferences
(
	Preference_ID Int primary key,
	Applicant_ID Int,
	Job_ID  Int,
	Expected_salary Int,
	Location Varchar(255),
	Remote Boolean,
	CONSTRAINT FK_ApplicantId foreign key(Applicant_ID) references EliteHireSchema.Applicants(Applicant_ID),
	CONSTRAINT FK_JobId foreign key(Job_ID) references EliteHireSchema.JobOpenings(Job_ID),
	CONSTRAINT CHK_ExpectedSalary CHECK(Expected_salary is null or Expected_salary >=0)
);

ALTER TABLE EliteHireSchema.ApplicantPreferences
ALTER COLUMN Preference_ID
ADD GENERATED BY DEFAULT AS IDENTITY;

INSERT INTO EliteHireSchema.Employees(Name, Surname, Type, Email)
VALUES 
  ('Karapet','Tashchyan','Employer','tashchyankar@gmail.com'),
  ('Vazgen','Khachatryan','Recruiter','Vzgkhach@gmail.com')
ON CONFLICT (Email) DO NOTHING;


INSERT INTO elitehireschema.jobopenings(employer_id, job_name, Num_of_applicants, Status, expected_experience)
SELECT 1, 'Junior Java Developer', 2, 'Open', 1
WHERE NOT EXISTS (
    SELECT 1 FROM elitehireschema.jobopenings WHERE lower(job_name) = 'junior java developer' and employer_id = 1
);

INSERT INTO elitehireschema.jobopenings(employer_id, job_name, Num_of_applicants, Status, expected_experience)
SELECT 2, 'Database Developer', 0, 'Closed', 3
WHERE NOT EXISTS (
    SELECT 1 FROM elitehireschema.jobopenings WHERE lower(job_name) = 'database developer'
);

select * from elitehireschema.jobopenings
update elitehireschema.jobopenings
set status = 'Open' where lower(job_name)='database developer';

update elitehireschema.jobopenings
set employer_id = 2 where lower(job_name) = 'junior java developer';

update elitehireschema.jobopenings
set Num_of_applicants = 1 where lower(job_name) in ('junior java developer','database developer');

update  elitehireschema.jobopenings 
set opening_date = '2024-07-06'where lower(job_name) in ('junior java developer','database developer');

INSERT INTO elitehireschema.applicants(Name, Surname, Gender, Email, Opening_date, Experience)
SELECT 'Khachatur', 'Khachatryan', 'M', 'Khachkhachat@gmail.com', '2024-06-06', 3
WHERE NOT EXISTS (
    SELECT 1 FROM elitehireschema.applicants WHERE lower(Email) = 'khachkhachat@gmail.com'
);

INSERT INTO elitehireschema.applicants(Name, Surname, Gender, Email, Opening_date, Experience)
SELECT 'Vzg', 'Vzgyan', 'M', 'vzvzg@gmail.com', '2023-05-04', 1
WHERE NOT EXISTS (
    SELECT 1 FROM elitehireschema.applicants WHERE lower(Email) = 'vzvzg@gmail.com'
);



INSERT INTO elitehireschema.JobApplicants(applicant_id, job_id, status)
SELECT a.applicant_id, j.job_id, 'Accepted'
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON 1=1
WHERE lower(a.email) = 'khachkhachat@gmail.com'
  AND j.opening_date = '2024-07-06'
  AND lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.JobApplicants ja
    WHERE ja.applicant_id = a.applicant_id 
      AND ja.job_id = j.job_id
      AND lower(ja.status) = 'accepted'
);



INSERT INTO elitehireschema.JobApplicants(applicant_id, job_id, status)
SELECT a.applicant_id, j.job_id, 'Accepted'
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON 1=1
WHERE lower(a.email) = 'vzvzg@gmail.com'
  AND j.opening_date = '2024-07-06'
  AND lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1
    FROM elitehireschema.JobApplicants ja
    WHERE ja.applicant_id = a.applicant_id 
      AND ja.job_id = j.job_id
      AND lower(ja.status) = 'accepted'
);


UPDATE elitehireschema.JobApplicants ja
SET application_date = '2024-07-26'
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON 1=1
WHERE ja.applicant_id = a.applicant_id
  AND ja.job_id = j.job_id
  AND lower(a.email) IN ('khachkhachat@gmail.com', 'vzvzg@gmail.com');



INSERT INTO EliteHireSchema.JobSkills(Skill_name)
VALUES 
  ('Java'),
  ('SQL'),
  ('C++'),
  ('Database Modeling'),
  ('OOP'),
  ('Data Structures'),
  ('Python'),
  ('Javascript')
ON CONFLICT DO NOTHING;

INSERT INTO EliteHireSchema.Interviews(job_id, applicant_id, recruiter_id, stage, feedback, scheduled_date, time)
SELECT j.job_id, a.applicant_id, e.employee_id, 'HR', 'Approved', DATE '2024-08-01', TIME '15:00'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'vzvzg@gmail.com'
JOIN elitehireschema.employees e ON lower(e.email) = 'vzgkhach@gmail.com'
WHERE lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1
    FROM EliteHireSchema.Interviews i
    WHERE i.job_id = j.job_id
      AND i.applicant_id = a.applicant_id
      AND i.recruiter_id = e.employee_id
  );



INSERT INTO EliteHireSchema.Interviews(job_id, applicant_id, recruiter_id, stage, feedback, scheduled_date, time)
SELECT j.job_id, a.applicant_id, e.employee_id, 'HR', 'Approved', DATE '2024-08-01', TIME '14:30'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'khachkhachat@gmail.com'
JOIN elitehireschema.employees e ON lower(e.email) = 'vzgkhach@gmail.com'
WHERE lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1
    FROM EliteHireSchema.Interviews i
    WHERE i.job_id = j.job_id
      AND i.applicant_id = a.applicant_id
      AND i.recruiter_id = e.employee_id
  );




INSERT INTO EliteHireSchema.services (Job_opening_id, Person_email, Service_type, Start_date, End_date, Status)
SELECT j.job_id, a.email, 'Interview Coaching', DATE '2024-07-27', DATE '2024-07-28', 'Completed'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'vzvzg@gmail.com'
WHERE lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1
    FROM EliteHireSchema.Services s
    WHERE s.job_opening_id = j.job_id
      AND lower(s.person_email) = lower(a.email)
      AND lower(s.service_type) = 'interview coaching'
  );



INSERT INTO EliteHireSchema.services (Job_opening_id, Person_email, Service_type, Start_date, End_date, Status)
SELECT j.job_id, a.email, 'Interview Coaching', DATE '2024-07-28', DATE '2024-07-29', 'Completed'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'khachkhachat@gmail.com'
WHERE lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1
    FROM EliteHireSchema.Services s
    WHERE s.job_opening_id = j.job_id
      AND lower(s.person_email) = lower(a.email)
      AND lower(s.service_type) = 'interview coaching'
  );




INSERT INTO elitehireschema.jobopeningskills(Job_ID, Job_Skills_ID)
SELECT j.job_id, s.job_skills_id
FROM elitehireschema.jobopenings j
JOIN elitehireschema.jobskills s ON s.skill_name IN ('Java', 'OOP', 'Data Structures')
WHERE lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.jobopeningskills jos 
    WHERE jos.job_id = j.job_id 
      AND jos.job_skills_id = s.job_skills_id
  );

INSERT INTO elitehireschema.jobopeningskills(Job_ID, Job_Skills_ID)
SELECT j.job_id, s.job_skills_id
FROM elitehireschema.jobopenings j
JOIN elitehireschema.jobskills s ON s.skill_name IN ('SQL', 'Database Modeling', 'Python')
WHERE lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.jobopeningskills jos 
    WHERE jos.job_id = j.job_id 
      AND jos.job_skills_id = s.job_skills_id
  );

INSERT INTO elitehireschema.applicantskills(Applicant_ID, Job_Skills_ID)
SELECT a.applicant_id, s.job_skills_id
FROM elitehireschema.applicants a
JOIN elitehireschema.jobskills s ON s.skill_name IN ('SQL', 'Database Modeling', 'Python', 'Javascript')
WHERE lower(a.email) = 'khachkhachat@gmail.com'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.applicantskills ak
    WHERE ak.applicant_id = a.applicant_id AND ak.job_skills_id = s.job_skills_id
  );

INSERT INTO elitehireschema.applicantskills(Applicant_ID, Job_Skills_ID)
SELECT a.applicant_id, s.job_skills_id
FROM elitehireschema.applicants a
JOIN elitehireschema.jobskills s ON s.skill_name IN ('Java', 'OOP', 'Data Structures', 'Python')
WHERE lower(a.email) = 'vzvzg@gmail.com'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.applicantskills ak
    WHERE ak.applicant_id = a.applicant_id AND ak.job_skills_id = s.job_skills_id
  );


INSERT INTO elitehireschema.jobpreferences(Job_ID, Expected_sallary, location, Remote)
SELECT j.job_id, 200000, 'Yerevan', FALSE
FROM elitehireschema.jobopenings j
WHERE lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1 FROM elitehireschema.jobpreferences jp WHERE jp.job_id = j.job_id
  );

INSERT INTO elitehireschema.jobpreferences(Job_ID, Expected_sallary, location, Remote)
SELECT j.job_id, 250000, 'Gyumri', FALSE
FROM elitehireschema.jobopenings j
WHERE lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1 FROM elitehireschema.jobpreferences jp WHERE jp.job_id = j.job_id
  );



INSERT INTO elitehireschema.applicantpreferences(Applicant_ID, Job_ID, Expected_salary, location, Remote)
SELECT a.applicant_id, j.job_id, 200000, 'Gyumri', FALSE
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON lower(j.job_name) = 'database developer'
WHERE lower(a.email) = 'khachkhachat@gmail.com'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.applicantpreferences ap 
    WHERE ap.applicant_id = a.applicant_id AND ap.job_id = j.job_id
  );

INSERT INTO elitehireschema.applicantpreferences(Applicant_ID, Job_ID, Expected_salary, location, Remote)
SELECT a.applicant_id, j.job_id, 200000, 'Yerevan', FALSE
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON lower(j.job_name) = 'junior java developer'
WHERE lower(a.email) = 'vzvzg@gmail.com'
  AND NOT EXISTS (
    SELECT 1 
    FROM elitehireschema.applicantpreferences ap 
    WHERE ap.applicant_id = a.applicant_id AND ap.job_id = j.job_id
  );



INSERT INTO EliteHireSchema.Interviews(job_id, applicant_id, recruiter_id, stage, feedback, scheduled_date, time)
SELECT j.job_id, a.applicant_id, e.employee_id, 'Technical', 'Approved', DATE '2024-08-03', TIME '16:00'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'vzvzg@gmail.com'
JOIN elitehireschema.employees e ON lower(e.email) = 'vzgkhach@gmail.com'
WHERE lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1 FROM EliteHireSchema.Interviews i
    WHERE i.job_id = j.job_id AND i.applicant_id = a.applicant_id AND i.recruiter_id = e.employee_id AND lower(i.stage) = 'technical'
  );

INSERT INTO EliteHireSchema.Interviews(job_id, applicant_id, recruiter_id, stage, feedback, scheduled_date, time)
SELECT j.job_id, a.applicant_id, e.employee_id, 'Final', 'Accepted ready to hire', DATE '2024-08-06', TIME '15:30'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'vzvzg@gmail.com'
JOIN elitehireschema.employees e ON lower(e.email) = 'vzgkhach@gmail.com'
WHERE lower(j.job_name) = 'junior java developer'
  AND NOT EXISTS (
    SELECT 1 FROM EliteHireSchema.Interviews i
    WHERE i.job_id = j.job_id AND i.applicant_id = a.applicant_id AND i.recruiter_id = e.employee_id AND lower(i.stage) = 'final'
  );


INSERT INTO EliteHireSchema.Interviews(job_id, applicant_id, recruiter_id, stage, feedback, scheduled_date, time)
SELECT j.job_id, a.applicant_id, e.employee_id, 'Technical', 'Approved', DATE '2024-08-04', TIME '14:00'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'khachkhachat@gmail.com'
JOIN elitehireschema.employees e ON lower(e.email) = 'vzgkhach@gmail.com'
WHERE lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1 FROM EliteHireSchema.Interviews i
    WHERE i.job_id = j.job_id AND i.applicant_id = a.applicant_id AND i.recruiter_id = e.employee_id AND lower(i.stage) = 'technical'
  );

INSERT INTO EliteHireSchema.Interviews(job_id, applicant_id, recruiter_id, stage, feedback, scheduled_date, time)
SELECT j.job_id, a.applicant_id, e.employee_id, 'Final', 'Accepted ready to hire', DATE '2024-08-05', TIME '14:30'
FROM elitehireschema.jobopenings j
JOIN elitehireschema.applicants a ON lower(a.email) = 'khachkhachat@gmail.com'
JOIN elitehireschema.employees e ON lower(e.email) = 'vzgkhach@gmail.com'
WHERE lower(j.job_name) = 'database developer'
  AND NOT EXISTS (
    SELECT 1 FROM EliteHireSchema.Interviews i
    WHERE i.job_id = j.job_id AND i.applicant_id = a.applicant_id AND i.recruiter_id = e.employee_id AND lower(i.stage) = 'final'
  );



INSERT INTO elitehireschema.placements(Applicant_ID, Job_ID, Offer_status, Start_date, Salary)
SELECT a.applicant_id, j.job_id, 'Accepted', DATE '2024-09-01', 200000
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON lower(j.job_name) = 'database developer'
WHERE lower(a.email) = 'khachkhachat@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM elitehireschema.placements
    WHERE applicant_id = a.applicant_id AND job_id = j.job_id
  );

INSERT INTO elitehireschema.placements(Applicant_ID, Job_ID, Offer_status, Start_date, Salary)
SELECT a.applicant_id, j.job_id, 'Accepted', DATE '2024-09-01', 200000
FROM elitehireschema.applicants a
JOIN elitehireschema.jobopenings j ON lower(j.job_name) = 'junior java developer'
WHERE lower(a.email) = 'vzvzg@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM elitehireschema.placements
    WHERE applicant_id = a.applicant_id AND job_id = j.job_id
  );



ALTER TABLE EliteHireSchema.Employees
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.JobOpenings
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.Applicants
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.JobApplicants
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.JobSkills
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.Interviews
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.Placements
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.JobOpeningSkills
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.ApplicantSkills
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.Services
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.JobPreferences
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;

ALTER TABLE EliteHireSchema.ApplicantPreferences
ADD COLUMN record_ts DATE NOT NULL DEFAULT CURRENT_DATE;


UPDATE EliteHireSchema.Employees
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.JobOpenings
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.Applicants
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.JobApplicants
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.JobSkills
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.Interviews
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.Placements
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.JobOpeningSkills
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.ApplicantSkills
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.Services
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.JobPreferences
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;

UPDATE EliteHireSchema.ApplicantPreferences
SET record_ts = CURRENT_DATE
WHERE record_ts IS NULL;


