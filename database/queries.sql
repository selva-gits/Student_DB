-- =============================================
-- COMPLEX SQL QUERIES & ANALYTICS
-- =============================================

-- 1. CALCULATE SEMESTER GPA (Using Functions & Aggregates)
-- Logic: (Sum of (GradePoint * Credits)) / (Sum of Credits)
-- Mapping: A=10, B=8, C=6, D=4, F=0
SELECT 
    s.student_id,
    u.full_name,
    ROUND(SUM(
        CASE 
            WHEN e.final_grade = 'A' THEN 10
            WHEN e.final_grade = 'B' THEN 8
            WHEN e.final_grade = 'C' THEN 6
            WHEN e.final_grade = 'D' THEN 4
            ELSE 0 
        END * c.credits
    ) / NULLIF(SUM(c.credits), 0), 2) AS semester_gpa
FROM students s
JOIN users u ON s.student_id = u.user_id
JOIN enrollments e ON s.student_id = e.student_id
JOIN course_offerings co ON e.offering_id = co.offering_id
JOIN courses c ON co.course_id = c.course_id
WHERE e.final_grade IS NOT NULL
GROUP BY s.student_id, u.full_name
ORDER BY semester_gpa DESC
LIMIT 20;

-- 2. STUDENT RANKING PER COURSE (Window Functions)
-- Rank students based on marks obtained in assignments for a specific course
SELECT 
    c.course_name,
    u.full_name,
    SUM(sub.marks_obtained) as total_marks,
    RANK() OVER (PARTITION BY c.course_name ORDER BY SUM(sub.marks_obtained) DESC) as class_rank
FROM submissions sub
JOIN assignments a ON sub.assignment_id = a.assignment_id
JOIN course_offerings co ON a.offering_id = co.offering_id
JOIN courses c ON co.course_id = c.course_id
JOIN students s ON sub.student_id = s.student_id
JOIN users u ON s.student_id = u.user_id
GROUP BY c.course_name, u.full_name, s.student_id;

-- 3. DETECT LATE SUBMISSIONS & CALCULATE PENALTY (Date Arithmetic)
-- Finds submissions made after the due date
SELECT 
    u.full_name,
    c.course_name,
    a.title AS assignment_title,
    a.due_date,
    sub.submitted_at,
    EXTRACT(EPOCH FROM (sub.submitted_at - a.due_date))/3600 AS delay_hours,
    CASE 
        WHEN sub.submitted_at > a.due_date THEN 'LATE'
        ELSE 'ON TIME' 
    END AS status
FROM submissions sub
JOIN assignments a ON sub.assignment_id = a.assignment_id
JOIN course_offerings co ON a.offering_id = co.offering_id
JOIN courses c ON co.course_id = c.course_id
JOIN users u ON sub.student_id = u.user_id
WHERE sub.submitted_at > a.due_date;

-- 4. AVERAGE SCREEN TIME & ENGAGEMENT ANALYTICS (CTEs)
-- Identify "At-Risk" students (Low engagement < 1 hour/day avg)
WITH StudentEngagement AS (
    SELECT 
        student_id,
        AVG(total_active_seconds) / 3600.0 AS avg_daily_hours,
        COUNT(log_id) AS logged_days
    FROM screen_time_daily
    GROUP BY student_id
)
SELECT 
    u.full_name,
    u.email,
    ROUND(se.avg_daily_hours, 2) AS avg_hours,
    CASE 
        WHEN se.avg_daily_hours < 1 THEN 'AT RISK (Low Engagement)'
        WHEN se.avg_daily_hours > 5 THEN 'HIGH ENGAGEMENT'
        ELSE 'NORMAL'
    END AS engagement_status
FROM StudentEngagement se
JOIN users u ON se.student_id = u.user_id
ORDER BY se.avg_daily_hours ASC;

-- 5. READ MODE ANALYTICS PER COURSE
-- Total time spent reading materials per course
SELECT 
    c.course_name,
    COUNT(distinct rms.student_id) as active_readers,
    ROUND(SUM(rms.duration_seconds) / 3600.0, 2) AS total_read_hours
FROM read_mode_sessions rms
JOIN courses c ON rms.course_id = c.course_id
GROUP BY c.course_name
ORDER BY total_read_hours DESC;

-- 6. FACULTY COURSE LOAD (Complex Join)
-- Show which faculty is teaching which course and how many students are enrolled
SELECT 
    u.full_name AS faculty_name,
    c.course_name,
    s.semester_name,
    COUNT(e.enrollment_id) AS student_count
FROM faculty f
JOIN users u ON f.faculty_id = u.user_id
JOIN course_offerings co ON f.faculty_id = co.faculty_id
JOIN courses c ON co.course_id = c.course_id
JOIN semesters s ON co.semester_id = s.semester_id
LEFT JOIN enrollments e ON co.offering_id = e.offering_id
GROUP BY u.full_name, c.course_name, s.semester_name;

