# Quick Start Guide

## Prerequisites Check
- ✅ PostgreSQL installed and running on port 5432
- ✅ Password: 1234
- ✅ Node.js installed

## Setup Steps

### Option 1: Automated Setup (Windows)

1. **Run the database setup script:**
   ```cmd
   setup_database.bat
   ```
   This will:
   - Create the `student_erp` database
   - Run the schema
   - Seed ~5000+ records

2. **Start the backend:**
   ```cmd
   cd backend
   npm start
   ```

3. **Start the frontend (in a new terminal):**
   ```cmd
   cd frontend
   npm run dev
   ```

4. **Access the application:**
   - Open browser: `http://localhost:5173`
   - Login with: `student1@univ.edu` / `pass123`

### Option 2: Manual Setup

If `psql` is not in your PATH, you need to use the full path to PostgreSQL binaries.

**Find your PostgreSQL installation:**
- Common location: `C:\Program Files\PostgreSQL\<version>\bin\`

**Run commands manually:**

```cmd
# Set password environment variable
set PGPASSWORD=1234

# Create database
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE student_erp;"

# Run schema
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d student_erp -f database/schema.sql

# Seed data
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d student_erp -f database/seeds.sql
```

Then start backend and frontend as shown above.

## Troubleshooting

### Issue: "psql is not recognized"
**Solution**: Add PostgreSQL bin folder to your PATH, or use the full path to psql.exe

### Issue: "password authentication failed"
**Solution**: Update password in:
- `backend/.env` (DB_PASSWORD=1234)
- `setup_database.bat` (set PGPASSWORD=1234)

### Issue: Backend cannot connect to database
**Solution**: 
1. Verify PostgreSQL is running (check Services or pgAdmin)
2. Check `backend/.env` has correct credentials
3. Ensure database `student_erp` exists

## Testing the System

1. **Login**: Use `student1@univ.edu` / `pass123`
2. **View Dashboard**: See analytics charts
3. **Enter Read Mode**: Click "Enter Read Mode" button
4. **Check Analytics**: View screen time and read time stats

## Database Verification

To verify data was seeded correctly:

```sql
-- Connect to database
psql -U postgres -d student_erp

-- Check record counts
SELECT 'Students' as table_name, COUNT(*) FROM students
UNION ALL
SELECT 'Courses', COUNT(*) FROM courses
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM enrollments
UNION ALL
SELECT 'Assignments', COUNT(*) FROM assignments;
```

Expected results:
- Students: 2000
- Courses: 20
- Enrollments: 6000 (3 per student)
- Assignments: 40 (2 per course offering)
