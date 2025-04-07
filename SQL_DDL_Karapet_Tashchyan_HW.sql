--DROP DATABASE IF EXISTS EliteHire;

CREATE DATABASE EliteHire;

--DROP SCHEMA IF EXISTS EliteHireSchema CASCADE;

CREATE SCHEMA EliteHireSchema;

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

insert into EliteHireSchema.Employees(Name,Surname,type,Email)
values('Karapet','Tashchyan','Employer','tashchyankar@gmail.com'),
('Vazgen','Khachatryan','Recruiter','Vzgkhach@gmail.com');


insert into elitehireschema.jobopenings(employer_id,job_name,Num_of_applicants,Status,expected_experience)
values (1,'Junior Java Developer',2,'Open',1),
(2,'Database Developer',0,'Closed',3);

update elitehireschema.jobopenings
set status = 'Open' where job_id = 2;

update elitehireschema.jobopenings
set employer_id = 2 where job_id = 1;

update elitehireschema.jobopenings
set Num_of_applicants = 1 where job_id in (1,2);

update  elitehireschema.jobopenings 
set opening_date = '2024-07-06' where job_id in (1,2);

insert into elitehireschema.applicants(Name,Surname,Gender,Email,Opening_date,Experience)
values('Khachatur','Khachatryan','M','Khachkhachat@gmail.com','2024-06-06',3),
('Vzg','Vzgyan','M','vzvzg@gmail.com','2023-05-04',1);

insert into elitehireschema.JobApplicants(applicant_id,job_id,status)
values(1,2,'Accepted'),
(2,1,'Accepted');

update elitehireschema.JobApplicants 
set application_date = '2024-07-26' where applicant_id in (1,2);

insert into EliteHireSchema.JobSkills(Skill_name)
values('Java'),
('SQL'),
('C++'),
('Database Modeling'),
('OOP'),
('Data Structures'),
('Python'),
('Javascript');

insert into EliteHireSchema.Interviews(job_id,Applicant_ID,Recruiter_ID,Stage,Feedback,Scheduled_Date,Time)
values(1,2,2,'HR','Approved','2024-08-01','15:00'),
(2,1,2,'HR','Approved','2024-08-01','14:30');

insert into EliteHireSchema.services (Job_opening_id,Person_email,Service_type,Start_date,End_date,Status)
values(1,'vzvzg@gmail.com','Interview Coaching','2024-07-27','2024-07-28','Completed'),
(2,'Khachkhachat@gmail.com','Interview Coaching','2024-07-28','2024-07-29','Completed');

insert into elitehireschema.jobopeningskills(Job_ID,Job_Skills_ID)
values(1,1),
(1,5),
(1,6),
(2,2),
(2,4),
(2,7);

insert into elitehireschema.applicantskills (applicant_id,job_skills_id)
values(1,2),
(1,4),
(1,7),
(1,8),
(2,1),
(2,5),
(2,6),
(2,7);

insert into elitehireschema.jobpreferences(Job_ID,Expected_sallary,location,Remote)
values(1,200000,'Yerevan',False),
(2,250000,'Gyumri',False);

insert into elitehireschema.applicantpreferences(Applicant_ID,Job_ID,Expected_salary,location,Remote)
values(1,2,200000,'Gyumri',FALSE),
(2,1,200000,'Yerevan',FALSE);

insert into EliteHireSchema.Interviews(job_id,Applicant_ID,Recruiter_ID,Stage,Feedback,Scheduled_Date,Time)
values(1,2,2,'Technical','Approved','2024-08-03','16:00'),
(1,2,2,'Final','Accepted ready to hire','2024-08-06','15:30'),
(2,1,2,'Technical','Approved', '2024-08-04','14:00'),
(2,1,2,'Final','Accepted ready to hire','2024-08-05','14:30');


insert into elitehireschema.placements(Applicant_ID,Job_ID,Offer_status,Start_date,Salary)
values(1,2,'Accepted','2024-09-01',200000),
(2,1,'Accepted','2024-09-01',200000);



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













