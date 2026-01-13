-- =============================================
-- SEED DATA SCRIPT
-- Generates realistic dummy data for testing (~5000+ rows)
-- =============================================

-- Clean up existing data (Order matters due to FKs)
TRUNCATE TABLE read_mode_sessions, screen_time_daily, attendance, exam_results, submissions, assignments, enrollments, course_offerings, courses, semesters, faculty, students, users, departments, roles RESTART IDENTITY CASCADE;

-- 1. SEED ROLES
INSERT INTO roles (role_name) VALUES ('Admin'), ('Faculty'), ('Student');

-- 2. SEED DEPARTMENTS
INSERT INTO departments (dept_name, dept_code) VALUES 
('Computer Science', 'CS'),
('Electronics', 'EC'),
('Mechanical', 'ME'),
('Civil Engineering', 'CV'),
('Business Admin', 'MBA');

-- 3. SEED USERS (ADMIN)
INSERT INTO users (full_name, email, password_hash, role_id, dept_id)
VALUES ('System Admin', 'admin@erp.com', 'hashed_pass_123', 1, 1);

-- 4. SEED FACULTY (50 Users)
-- Using CTE to get Role ID
WITH role_data AS (SELECT role_id FROM roles WHERE role_name = 'Faculty')
INSERT INTO users (full_name, email, password_hash, role_id, dept_id)
SELECT 
    'Faculty Member ' || i, 
    'faculty' || i || '@univ.edu', 
    'pass123', 
    (SELECT role_id FROM role_data), 
    (i % 5) + 1 -- Assign random department (1-5)
FROM generate_series(1, 50) AS s(i);

-- Insert into Faculty table linking to Users
INSERT INTO faculty (faculty_id, designation, specialization)
SELECT 
    user_id, 
    CASE WHEN (random() > 0.5) THEN 'Professor' ELSE 'Assistant Professor' END,
    'Specialization ' || substring(email from 8 for 2)
FROM users 
WHERE email LIKE 'faculty%';

-- 5. SEED STUDENTS (2000 Users)
WITH role_data AS (SELECT role_id FROM roles WHERE role_name = 'Student')
INSERT INTO users (full_name, email, password_hash, role_id, dept_id)
SELECT 
    'Student ' || i, 
    'student' || i || '@univ.edu', 
    'pass123', 
    (SELECT role_id FROM role_data), 
    (i % 5) + 1
FROM generate_series(1, 2000) AS s(i);

-- Insert into Students table
INSERT INTO students (student_id, enrollment_no, current_semester, batch_year, cgpa)
SELECT 
    user_id, 
    'STU2024' || lpad(row_number() OVER (ORDER BY user_id)::text, 4, '0'),
    (floor(random() * 8) + 1)::int, -- Sem 1 to 8
    2024,
    (random() * 10)::numeric(4,2)
FROM users 
WHERE email LIKE 'student%';

-- 6. SEED COURSES (20 Courses)
INSERT INTO courses (course_code, course_name, credits, dept_id)
SELECT 
    'CS' || (100 + i), 
    'Course Name ' || i, 
    3 + (i % 2), 
    1 + (i % 5)
FROM generate_series(1, 20) AS s(i);

-- 7. SEED SEMESTERS
INSERT INTO semesters (semester_name, start_date, end_date, is_active)
VALUES ('Fall 2024', '2024-08-01', '2024-12-15', TRUE);

-- 8. SEED COURSE OFFERINGS
-- Offer all 20 courses in the current semester, assigned to random faculty
INSERT INTO course_offerings (course_id, semester_id, faculty_id)
SELECT 
    c.course_id, 
    1, -- Semester ID 1
    (SELECT faculty_id FROM faculty ORDER BY random() LIMIT 1)
FROM courses c;

-- 9. SEED ENROLLMENTS
-- Enroll each student in 3 random courses
INSERT INTO enrollments (student_id, offering_id)
SELECT 
    s.student_id, 
    co.offering_id
FROM students s
CROSS JOIN LATERAL (
    SELECT offering_id FROM course_offerings ORDER BY random() LIMIT 3
) co
ON CONFLICT DO NOTHING;

-- 10. SEED ASSIGNMENTS (2 per offering)
INSERT INTO assignments (offering_id, title, description, due_date, max_marks)
SELECT 
    co.offering_id,
    'Assignment ' || i || ' for Course ' || co.offering_id,
    'Description for assignment...',
    '2024-11-30 23:59:59',
    50
FROM course_offerings co
CROSS JOIN generate_series(1, 2) AS i;

-- 11. SEED SUBMISSIONS (Random submissions for 70% of enrollments)
-- This creates a realistic "Assignment Lifecycle"
INSERT INTO submissions (assignment_id, student_id, submitted_at, marks_obtained)
SELECT 
    a.assignment_id,
    e.student_id,
    a.due_date - (floor(random() * 5) || ' days')::interval, -- Submitted before due date
    (random() * a.max_marks)::numeric(5,2)
FROM assignments a
JOIN enrollments e ON e.offering_id = a.offering_id
WHERE random() < 0.7; -- 70% submission rate

-- 12. SEED SCREEN TIME LOGS (Analytics)
-- Generate 2 days of logs for each student
INSERT INTO screen_time_daily (student_id, date, total_active_seconds, app_open_count)
SELECT 
    s.student_id,
    cast('2024-11-01' as date) + i,
    (random() * 7200)::int, -- Up to 2 hours
    (random() * 10)::int
FROM students s
CROSS JOIN generate_series(0, 1) AS i;

-- 13. SEED READ MODE LOGS
WITH session_data AS (
    SELECT 
        e.student_id,
        co.course_id,
        now() - (random() * 100 || ' hours')::interval AS start_time
    FROM enrollments e
    JOIN course_offerings co ON e.offering_id = co.offering_id
    WHERE random() < 0.5
    LIMIT 3000
)
INSERT INTO read_mode_sessions (student_id, course_id, start_time, end_time)
SELECT 
    student_id,
    course_id,
    start_time,
    start_time + (random() * 60 + 10 || ' minutes')::interval AS end_time
FROM session_data;

