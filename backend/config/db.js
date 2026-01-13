require('dotenv').config();
const { Pool } = require('pg');

// Database Connection Pool
const connectionOptions = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.DATABASE_USE_SSL !== 'false' ? { rejectUnauthorized: false } : false,
    }
  : {
      user: process.env.DB_USER || 'postgres',
      host: process.env.DB_HOST || 'localhost',
      database: process.env.DB_NAME || 'student_erp',
      password: process.env.DB_PASSWORD || '1234',
      port: Number(process.env.DB_PORT) || 5432,
    };

const pool = new Pool(connectionOptions);

pool.on('error', (err) => {
    console.error('Unexpected error on idle client', err);
    process.exit(-1);
});

module.exports = pool;
