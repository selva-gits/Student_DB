const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const bcrypt = require('bcryptjs');
const pool = require('../config/db');

// POST /api/auth/register
router.post('/register', authController.register);

// POST /api/auth/login
router.post('/login', authController.login);

// Temporary: Reset password endpoint (REMOVE AFTER TESTING)
router.post('/reset-password-temp', async (req, res) => {
    try {
        const newHash = await bcrypt.hash('pass123', 10);
        console.log('Generated hash:', newHash);
        await pool.query('UPDATE users SET password_hash = $1', [newHash]);
        res.json({ message: 'All passwords reset to pass123', hash: newHash });
    } catch (err) {
        console.error('Reset error:', err);
        res.status(500).json({ error: 'Failed to reset passwords' });
    }
});

module.exports = router;
