-- =============================================
-- STUDENT ERP SYSTEM - POSTGRESQL SCHEMA
-- =============================================
-- Designed for 3NF Normalization standards.
-- Includes: Users, Academics, Assignments, Analytics.

-- Enable UUID extension for secure IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. USER MANAGEMENT & ROLES
-- =============================================

-- TABLE: Roles
-- Purpose: Define access levels (Admin, Faculty, Student)
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- TABLE: Departments
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    dept_code VARCHAR(10) NOT NULL UNIQUE
);

-- TABLE: Users
-- Supertype entity for all system users
-- CANDIDATE KEY: email
-- PRIMARY KEY: user_id
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL, -- Email is a Candidate Key
    password_hash VARCHAR(255) NOT NULL,
    role_id INT REFERENCES roles(role_id),
    dept_id INT REFERENCES departments(dept_id), -- Faculty/Students belong to dept
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- TABLE: Students
-- Subtype entity for specific student attributes
-- PK is strictly also an FK to users(user_id) (1:1 relationship)
CREATE TABLE students (
    student_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    enrollment_no VARCHAR(20) UNIQUE NOT NULL, -- Candidate Key
    current_semester INT CHECK (current_semester BETWEEN 1 AND 8),
    batch_year INT NOT NULL,
    cgpa NUMERIC(4,2) DEFAULT 0.0 CHECK (cgpa BETWEEN 0 AND 10)
);

-- TABLE: Faculty
-- Subtype entity for faculty
CREATE TABLE faculty (
    faculty_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    designation VARCHAR(50) NOT NULL, -- e.g., Professor, Assistant Prof
    specialization VARCHAR(100)
);

-- =============================================
-- 2. ACADEMIC STRUCTURE (Courses & Semesters)
-- =============================================

CREATE TABLE semesters (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(50) NOT NULL, -- e.g., 'Fall 2025'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    CHECK (end_date > start_date)
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INT CHECK (credits > 0),
    dept_id INT REFERENCES departments(dept_id)
);

-- TABLE: Course_Offerings (The section/class instance)
-- Composite Unique Constraint ensures a course isn't offered twice by same faculty in same sem (Business Rule choice)
CREATE TABLE course_offerings (
    offering_id SERIAL PRIMARY KEY,
    course_id INT REFERENCES courses(course_id),
    semester_id INT REFERENCES semesters(semester_id),
    faculty_id UUID REFERENCES faculty(faculty_id),
    UNIQUE (course_id, semester_id, faculty_id) -- Composite Candidate Key
);

-- TABLE: Enrollments
-- Link Student <-> Course Offering
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id UUID REFERENCES students(student_id),
    offering_id INT REFERENCES course_offerings(offering_id),
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    final_grade VARCHAR(2), -- A, B, C, F
    UNIQUE (student_id, offering_id) -- Prevent double enrollment
);

-- =============================================
-- 3. ASSIGNMENTS & EVALUATION
-- =============================================

CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    offering_id INT REFERENCES course_offerings(offering_id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date TIMESTAMP NOT NULL,
    max_marks INT CHECK (max_marks > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE submissions (
    submission_id SERIAL PRIMARY KEY,
    assignment_id INT REFERENCES assignments(assignment_id),
    student_id UUID REFERENCES students(student_id),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_url TEXT,
    marks_obtained NUMERIC(5,2) CHECK (marks_obtained >= 0),
    feedback TEXT,
    is_late BOOLEAN DEFAULT FALSE,
    UNIQUE (assignment_id, student_id) -- One submission per assignment per student
);

-- Constraint Logic: marks_obtained should not exceed assignment.max_marks
-- This requires a TRIGGER in Postgres (implemented in queries.sql or separate trigger section)

CREATE TABLE exams (
    exam_id SERIAL PRIMARY KEY,
    offering_id INT REFERENCES course_offerings(offering_id),
    exam_name VARCHAR(100) NOT NULL, -- Mid-Term, End-Term
    date DATE NOT NULL,
    max_marks INT NOT NULL
);

CREATE TABLE exam_results (
    result_id SERIAL PRIMARY KEY,
    exam_id INT REFERENCES exams(exam_id),
    student_id UUID REFERENCES students(student_id),
    marks_obtained NUMERIC(5,2) CHECK (marks_obtained >= 0),
    UNIQUE (exam_id, student_id)
);

-- =============================================
-- 4. ANALYTICS & TRACKING
-- =============================================

-- TABLE: Attendance
CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    offering_id INT REFERENCES course_offerings(offering_id),
    student_id UUID REFERENCES students(student_id),
    date DATE NOT NULL,
    status VARCHAR(10) CHECK (status IN ('Present', 'Absent', 'Late', 'Excused')),
    UNIQUE (offering_id, student_id, date)
);

-- TABLE: Screen Time Tracking
-- Tracks daily usage per student
CREATE TABLE screen_time_daily (
    log_id SERIAL PRIMARY KEY,
    student_id UUID REFERENCES students(student_id),
    date DATE DEFAULT CURRENT_DATE,
    total_active_seconds INT DEFAULT 0,
    app_open_count INT DEFAULT 0,
    last_active TIMESTAMP,
    UNIQUE (student_id, date)
);

-- TABLE: Read Mode Activity
-- Specific tracking for reading course material
CREATE TABLE read_mode_sessions (
    session_id SERIAL PRIMARY KEY,
    student_id UUID REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    duration_seconds INT GENERATED ALWAYS AS (EXTRACT(EPOCH FROM (end_time - start_time))) STORED,
    CONSTRAINT valid_duration CHECK (end_time > start_time)
);

-- TABLE: Login Sessions
CREATE TABLE login_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- =============================================
-- EXPLANATION OF KEYS
-- =============================================
-- PRIMARY KEYS (PK): Uniquely identify records (e.g., user_id, course_id).
-- FOREIGN KEYS (FK): Maintain referential integrity (e.g., students.user_id references users.user_id).
-- CANDIDATE KEYS: Minimal set of attributes that can uniquely identify a tuple (e.g., users.email, students.enrollment_no).
-- COMPOSITE KEYS: A key formed by multiple columns (e.g., UNIQUE(course_id, semester_id, faculty_id) in course_offerings could be a key).
-- SUPER KEYS: Any set of attributes that uniquely identifies a row (Candidate Key + any other attribute).

