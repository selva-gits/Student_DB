const express = require('express');
const router = express.Router();
const courseController = require('../controllers/courseController');
const { verifyToken } = require('../middleware/authMiddleware');

// GET /api/courses
router.get('/', verifyToken, courseController.getAllCourses);

// GET /api/courses/offerings
router.get('/offerings', verifyToken, courseController.getCourseOfferings);

// GET /api/courses/offerings/:offering_id/assignments
router.get('/offerings/:offering_id/assignments', verifyToken, courseController.getAssignments);

// POST /api/courses/assignments/submit
router.post('/assignments/submit', verifyToken, courseController.submitAssignment);

module.exports = router;
