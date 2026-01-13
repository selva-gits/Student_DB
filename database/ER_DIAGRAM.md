# ER Diagram & Database Design Documentation

## Entity-Relationship Diagram (Textual Representation)

```
┌─────────────────┐
│     ROLES       │
├─────────────────┤
│ PK: role_id     │
│     role_name   │
└────────┬────────┘
         │
         │ 1:N
         │
┌────────▼────────────────────┐
│         USERS               │
├─────────────────────────────┤
│ PK: user_id (UUID)          │
│     full_name               │
│ CK: email (UNIQUE)          │
│     password_hash           │
│ FK: role_id → ROLES         │
│ FK: dept_id → DEPARTMENTS   │
└────┬──────────────┬─────────┘
     │              │
     │ 1:1          │ 1:1
     │              │
┌────▼────────┐  ┌─▼──────────┐
│  STUDENTS   │  │  FACULTY   │
├─────────────┤  ├────────────┤
│PK,FK:student│  │PK,FK:faculty│
│     _id     │  │    _id     │
│CK:enrollment│  │ designation│
│    _no      │  │specialization│
│current_sem  │  └─────┬──────┘
│ batch_year  │        │
│    cgpa     │        │
└─────┬───────┘        │
      │                │
      │                │ 1:N
      │         ┌──────▼──────────────┐
      │         │ COURSE_OFFERINGS    │
      │         ├─────────────────────┤
      │         │ PK: offering_id     │
      │         │ FK: course_id       │
      │         │ FK: semester_id     │
      │         │ FK: faculty_id      │
      │         │ UNIQUE(course,sem,  │
      │         │        faculty)     │
      │         └──────┬──────────────┘
      │                │
      │ N:M            │ 1:N
      │                │
┌─────▼────────────────▼──┐
│    ENROLLMENTS          │
├─────────────────────────┤
│ PK: enrollment_id       │
│ FK: student_id          │
│ FK: offering_id         │
│     final_grade         │
│ UNIQUE(student,offering)│
└─────────────────────────┘

┌─────────────────────────┐
│     ASSIGNMENTS         │
├─────────────────────────┤
│ PK: assignment_id       │
│ FK: offering_id         │
│     title, description  │
│     due_date, max_marks │
└────────┬────────────────┘
         │
         │ 1:N
         │
┌────────▼────────────────┐
│    SUBMISSIONS          │
├─────────────────────────┤
│ PK: submission_id       │
│ FK: assignment_id       │
│ FK: student_id          │
│     submitted_at        │
│     marks_obtained      │
│     is_late (BOOLEAN)   │
│ UNIQUE(assignment,      │
│        student)         │
└─────────────────────────┘

┌─────────────────────────┐
│  SCREEN_TIME_DAILY      │
├─────────────────────────┤
│ PK: log_id              │
│ FK: student_id          │
│     date                │
│     total_active_seconds│
│     app_open_count      │
│ UNIQUE(student, date)   │
└─────────────────────────┘

┌─────────────────────────┐
│  READ_MODE_SESSIONS     │
├─────────────────────────┤
│ PK: session_id          │
│ FK: student_id          │
│ FK: course_id           │
│     start_time          │
│     end_time            │
│     duration_seconds    │
│     (GENERATED COLUMN)  │
└─────────────────────────┘
```

## Key Definitions & Explanations

### 1. Primary Keys (PK)
- **Definition**: Uniquely identifies each record in a table
- **Examples**:
  - `users.user_id` (UUID)
  - `courses.course_id`
  - `assignments.assignment_id`

### 2. Foreign Keys (FK)
- **Definition**: Establishes relationships between tables, maintains referential integrity
- **Examples**:
  - `students.student_id` → `users.user_id` (1:1 relationship)
  - `enrollments.student_id` → `students.student_id`
  - `enrollments.offering_id` → `course_offerings.offering_id`

### 3. Candidate Keys (CK)
- **Definition**: Minimal set of attributes that can uniquely identify a tuple
- **Examples**:
  - `users.email` - Could serve as PK, but we chose `user_id` for consistency
  - `students.enrollment_no` - Unique identifier for students
  - `courses.course_code` - Unique course identifier

### 4. Composite Keys
- **Definition**: A key formed by combining multiple columns
- **Examples**:
  - `UNIQUE(course_id, semester_id, faculty_id)` in `course_offerings`
  - `UNIQUE(student_id, offering_id)` in `enrollments`
  - `UNIQUE(assignment_id, student_id)` in `submissions`

### 5. Super Keys
- **Definition**: Any set of attributes that uniquely identifies a row
- **Examples**:
  - `{user_id}` - Candidate Key (minimal)
  - `{user_id, email}` - Super Key (not minimal)
  - `{user_id, email, full_name}` - Super Key (not minimal)
  - `{email}` - Candidate Key
  - `{email, dept_id}` - Super Key

## Relationships

### One-to-One (1:1)
- `users` ↔ `students`: Each student is a user
- `users` ↔ `faculty`: Each faculty is a user

### One-to-Many (1:N)
- `roles` → `users`: One role has many users
- `departments` → `users`: One department has many users
- `course_offerings` → `assignments`: One offering has many assignments
- `assignments` → `submissions`: One assignment has many submissions

### Many-to-Many (M:N)
- `students` ↔ `course_offerings` (via `enrollments`)
  - Students can enroll in multiple courses
  - Courses can have multiple students

## Constraints Explained

### CHECK Constraints
```sql
CHECK (current_semester BETWEEN 1 AND 8)
CHECK (cgpa BETWEEN 0 AND 10)
CHECK (marks_obtained >= 0)
CHECK (end_date > start_date)
CHECK (status IN ('Present', 'Absent', 'Late', 'Excused'))
```

### UNIQUE Constraints
- Prevent duplicate data
- Examples: email, enrollment_no, course_code
- Composite unique: (student_id, offering_id) prevents double enrollment

### DEFAULT Values
```sql
DEFAULT uuid_generate_v4()  -- Auto-generate UUIDs
DEFAULT CURRENT_TIMESTAMP   -- Auto-timestamp
DEFAULT TRUE                -- Boolean defaults
```

## Normalization Analysis

### First Normal Form (1NF)
✅ All attributes contain atomic values
✅ No repeating groups

### Second Normal Form (2NF)
✅ In 1NF
✅ No partial dependencies (all non-key attributes depend on entire PK)

### Third Normal Form (3NF)
✅ In 2NF
✅ No transitive dependencies
- Example: `dept_name` is in `departments`, not duplicated in `users`
- `course_name` is in `courses`, not in `course_offerings`

## Business Rules Implemented

1. **Late Submission Detection**: Automatic `is_late` flag based on `submitted_at > due_date`
2. **Enrollment Uniqueness**: Student cannot enroll in same offering twice
3. **Submission Uniqueness**: One submission per assignment per student
4. **Grade Validation**: Marks cannot exceed max_marks (enforced in application logic)
5. **Active Semester**: Only one semester can be active at a time
6. **Role-Based Access**: Users have specific roles determining permissions

## Indexes (Recommended for Production)

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_students_enrollment ON students(enrollment_no);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_submissions_assignment ON submissions(assignment_id);
CREATE INDEX idx_screen_time_student_date ON screen_time_daily(student_id, date);
```

These indexes improve query performance for:
- Login lookups (email)
- Student searches (enrollment_no)
- Fetching student enrollments
- Assignment submissions
- Analytics queries
