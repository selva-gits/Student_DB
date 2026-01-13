# Student ERP System

A comprehensive **Enterprise Resource Planning (ERP)** system for educational institutions, built with **PostgreSQL**, **Node.js/Express**, and **React**.

## 🎯 Features

### Academic Management
- Student enrollment and profile management
- Course offerings and semester management
- Assignment submission with late detection
- Exam marks and grading system
- Attendance tracking

### Analytics & Tracking
- **Screen Time Tracking**: Monitor daily app usage
- **Read Mode**: Track time spent reading course materials
- Student engagement analytics
- Performance metrics and GPA calculation

### Role-Based Access
- **Students**: View marks, submit assignments, track progress
- **Faculty**: Grade assignments, view course analytics
- **Admin**: Full system access

## 📊 Database Design

### Entity-Relationship Overview

```
USERS (Supertype)
├── STUDENTS (Subtype)
├── FACULTY (Subtype)
└── ROLES

ACADEMIC STRUCTURE
├── DEPARTMENTS
├── COURSES
├── SEMESTERS
└── COURSE_OFFERINGS (Junction with Faculty assignment)

ENROLLMENT & EVALUATION
├── ENROLLMENTS (Student ↔ Course Offering)
├── ASSIGNMENTS
├── SUBMISSIONS
├── EXAMS
└── EXAM_RESULTS

ANALYTICS
├── ATTENDANCE
├── SCREEN_TIME_DAILY
├── READ_MODE_SESSIONS
└── LOGIN_SESSIONS
```

### Key Constraints Implemented

- **Primary Keys**: All tables have unique identifiers
- **Foreign Keys**: Referential integrity maintained
- **Candidate Keys**: `users.email`, `students.enrollment_no`
- **Composite Keys**: `(course_id, semester_id, faculty_id)` in course_offerings
- **Check Constraints**: Marks validation, date ranges, status enums
- **Unique Constraints**: Prevent duplicate enrollments, submissions

### Normalization

The schema follows **3NF (Third Normal Form)**:
- No partial dependencies
- No transitive dependencies
- Separate tables for distinct entities

## 🚀 Setup Instructions

### Prerequisites

- **PostgreSQL** 12+ (Running on port 5432)
- **Node.js** 16+
- **npm** or **yarn**

### 1. Database Setup

```bash
# Create database
psql -U postgres
CREATE DATABASE student_erp;
\q

# Run schema
psql -U postgres -d student_erp -f database/schema.sql

# Seed data (~5000+ records)
psql -U postgres -d student_erp -f database/seeds.sql
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Configure environment (update .env if needed)
# DB_PASSWORD should match your PostgreSQL password

# Start server
npm start
```

Server runs on `http://localhost:5000`

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend runs on `http://localhost:5173`

## 🔐 Demo Credentials

After seeding the database, you can login with:

- **Email**: `student1@univ.edu` (or any student2, student3, etc.)
- **Password**: `pass123`

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login

### Students (Protected)
- `GET /api/students` - Get all students (Faculty/Admin only)
- `GET /api/students/:id` - Get student details
- `GET /api/students/:id/analytics` - Get student analytics

### Courses (Protected)
- `GET /api/courses` - Get all courses
- `GET /api/courses/offerings` - Get current semester offerings
- `GET /api/courses/offerings/:id/assignments` - Get assignments
- `POST /api/courses/assignments/submit` - Submit assignment

## 🗂️ Project Structure

```
Minor_project_student/
├── database/
│   ├── schema.sql          # Database schema with constraints
│   ├── seeds.sql           # Data generation script
│   └── queries.sql         # Complex analytical queries
├── backend/
│   ├── controllers/        # Business logic
│   ├── routes/            # API routes
│   ├── middleware/        # Auth & validation
│   ├── server.js          # Express app
│   └── .env               # Environment config
└── frontend/
    ├── src/
    │   ├── components/    # Reusable components
    │   ├── pages/         # Login, Dashboard
    │   ├── services/      # API calls
    │   └── context/       # Auth context
    └── package.json
```

## 📈 Complex SQL Queries

The `database/queries.sql` file includes:

- **GPA Calculation** using CASE statements
- **Student Ranking** with Window Functions (RANK, DENSE_RANK)
- **Late Submission Detection** with date arithmetic
- **Engagement Analytics** using CTEs
- **Read Mode Statistics** with aggregations

## 🎓 DBMS Concepts Demonstrated

1. **Keys**: Primary, Foreign, Candidate, Composite, Super
2. **Constraints**: CHECK, UNIQUE, NOT NULL, DEFAULT
3. **Normalization**: 3NF schema design
4. **Joins**: INNER, LEFT, complex multi-table joins
5. **Aggregations**: SUM, AVG, COUNT with GROUP BY
6. **Window Functions**: RANK, ROW_NUMBER, PARTITION BY
7. **CTEs**: Common Table Expressions for readability
8. **Transactions**: ACID properties in submissions
9. **Indexing**: On foreign keys and frequently queried columns

## 🛠️ Technologies Used

- **Database**: PostgreSQL 14+
- **Backend**: Node.js, Express, pg (node-postgres), JWT, bcrypt
- **Frontend**: React 18, Vite, React Router, Recharts, Axios

## 📝 License

This project is for educational purposes.
