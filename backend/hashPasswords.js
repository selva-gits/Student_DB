require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('./config/db');

async function hashPasswords() {
    try {
        console.log('Hashing passwords for all users...');

        // Hash the password 'pass123'
        const hashedPassword = await bcrypt.hash('pass123', 10);
        console.log('Hashed password:', hashedPassword);

        // Update all users with the hashed password
        const result = await pool.query(
            'UPDATE users SET password_hash = $1',
            [hashedPassword]
        );

        console.log(`Updated ${result.rowCount} users with hashed passwords`);
        console.log('All users can now login with password: pass123');

        process.exit(0);
    } catch (error) {
        console.error('Error hashing passwords:', error);
        process.exit(1);
    }
}

hashPasswords();
