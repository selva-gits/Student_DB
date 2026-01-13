const express = require('express');
const router = express.Router();
const studentController = require('../controllers/studentController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

// GET /api/students (Protected - Faculty/Admin only)
router.get('/', verifyToken, requireRole(['Faculty', 'Admin']), studentController.getAllStudents);

// GET /api/students/:id (Protected)
router.get('/:id', verifyToken, studentController.getStudentById);

// GET /api/students/:id/analytics (Protected)
router.get('/:id/analytics', verifyToken, studentController.getStudentAnalytics);

module.exports = router;
