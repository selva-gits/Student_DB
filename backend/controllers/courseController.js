const pool = require('../config/db');

// Get all courses
exports.getAllCourses = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT c.course_id, c.course_code, c.course_name, c.credits, d.dept_name
             FROM courses c
             LEFT JOIN departments d ON c.dept_id = d.dept_id
             ORDER BY c.course_code`
        );

        res.json({ courses: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};

// Get course offerings for current semester
exports.getCourseOfferings = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT co.offering_id, c.course_code, c.course_name, c.credits, 
                    u.full_name AS faculty_name, s.semester_name
             FROM course_offerings co
             JOIN courses c ON co.course_id = c.course_id
             JOIN semesters s ON co.semester_id = s.semester_id
             JOIN faculty f ON co.faculty_id = f.faculty_id
             JOIN users u ON f.faculty_id = u.user_id
             WHERE s.is_active = TRUE
             ORDER BY c.course_code`
        );

        res.json({ offerings: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};

// Get assignments for a course offering
exports.getAssignments = async (req, res) => {
    const { offering_id } = req.params;

    try {
        const result = await pool.query(
            `SELECT assignment_id, title, description, due_date, max_marks, created_at
             FROM assignments
             WHERE offering_id = $1
             ORDER BY due_date DESC`,
            [offering_id]
        );

        res.json({ assignments: result.rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};

// Submit assignment
exports.submitAssignment = async (req, res) => {
    const { assignment_id, student_id, file_url } = req.body;

    try {
        // Check if assignment exists and get due date
        const assignmentResult = await pool.query(
            'SELECT due_date FROM assignments WHERE assignment_id = $1',
            [assignment_id]
        );

        if (assignmentResult.rows.length === 0) {
            return res.status(404).json({ error: 'Assignment not found' });
        }

        const dueDate = new Date(assignmentResult.rows[0].due_date);
        const now = new Date();
        const isLate = now > dueDate;

        // Insert submission
        const result = await pool.query(
            `INSERT INTO submissions (assignment_id, student_id, file_url, is_late)
             VALUES ($1, $2, $3, $4)
             RETURNING submission_id, submitted_at, is_late`,
            [assignment_id, student_id, file_url, isLate]
        );

        res.status(201).json({
            message: 'Assignment submitted successfully',
            submission: result.rows[0]
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};
