const jwt = require('jsonwebtoken');

// Verify JWT Token
exports.verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(403).json({ error: 'No token provided' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Attach user info to request
        next();
    } catch (err) {
        return res.status(401).json({ error: 'Invalid or expired token' });
    }
};

// Role-based Access Control
exports.requireRole = (allowedRoles) => {
    return async (req, res, next) => {
        const pool = require('../config/db');

        try {
            const roleResult = await pool.query(
                'SELECT r.role_name FROM users u JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = $1',
                [req.user.user_id]
            );

            if (roleResult.rows.length === 0) {
                return res.status(403).json({ error: 'User not found' });
            }

            const userRole = roleResult.rows[0].role_name;

            if (!allowedRoles.includes(userRole)) {
                return res.status(403).json({ error: 'Access denied' });
            }

            next();
        } catch (err) {
            console.error(err);
            res.status(500).json({ error: 'Server error' });
        }
    };
};
