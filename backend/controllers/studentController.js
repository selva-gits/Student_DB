const pool = require('../config/db');

// Get all students with pagination
exports.getAllStudents = async (req, res) => {
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    try {
        const result = await pool.query(
            `SELECT s.student_id, u.full_name, u.email, s.enrollment_no, s.current_semester, s.batch_year, s.cgpa
             FROM students s
             JOIN users u ON s.student_id = u.user_id
             ORDER BY u.full_name
             LIMIT $1 OFFSET $2`,
            [limit, offset]
        );

        res.json({ students: result.rows, page: parseInt(page), limit: parseInt(limit) });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};

// Get student by ID
exports.getStudentById = async (req, res) => {
    const { id } = req.params;

    try {
        const result = await pool.query(
            `SELECT s.student_id, u.full_name, u.email, s.enrollment_no, s.current_semester, s.batch_year, s.cgpa, d.dept_name
             FROM students s
             JOIN users u ON s.student_id = u.user_id
             LEFT JOIN departments d ON u.dept_id = d.dept_id
             WHERE s.student_id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Student not found' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};

// Get student analytics (screen time, read mode)
exports.getStudentAnalytics = async (req, res) => {
    const { id } = req.params;

    try {
        // Screen time stats
        const screenTimeResult = await pool.query(
            `SELECT 
                ROUND(AVG(total_active_seconds) / 3600.0, 2) AS avg_daily_hours,
                SUM(total_active_seconds) / 3600.0 AS total_hours
             FROM screen_time_daily
             WHERE student_id = $1`,
            [id]
        );

        // Read mode stats
        const readModeResult = await pool.query(
            `SELECT 
                COUNT(*) AS total_sessions,
                ROUND(SUM(duration_seconds) / 3600.0, 2) AS total_read_hours
             FROM read_mode_sessions
             WHERE student_id = $1`,
            [id]
        );

        res.json({
            screen_time: screenTimeResult.rows[0],
            read_mode: readModeResult.rows[0]
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};
