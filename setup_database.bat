@echo off
setlocal
REM Database Setup Script for Student ERP System
REM This script creates the database, schema, and seeds data

echo ========================================
echo Student ERP - Database Setup
echo ========================================
echo.

REM Note: Update the path to psql.exe if PostgreSQL is installed in a different location
REM Common paths:
REM   C:\Program Files\PostgreSQL\14\bin\psql.exe
REM   C:\Program Files\PostgreSQL\15\bin\psql.exe
REM   C:\Program Files\PostgreSQL\16\bin\psql.exe

set "PSQL_PATH=psql"
set "PGPASSWORD=1234"

where psql >nul 2>&1
if errorlevel 1 (
    for %%I in (
        "C:\Program Files\PostgreSQL\16\bin\psql.exe"
        "C:\Program Files\PostgreSQL\15\bin\psql.exe"
        "C:\Program Files\PostgreSQL\14\bin\psql.exe"
    ) do (
        if exist %%~I (
            set "PSQL_PATH=%%~I"
            goto :psql_ready
        )
    )
    echo ERROR: Unable to locate psql.exe. Please update PSQL_PATH manually.
    pause
    exit /b 1
)
:psql_ready
echo Using psql at "%PSQL_PATH%"
echo.

echo Step 1: Creating database 'student_erp'...
"%PSQL_PATH%" -U postgres -c "DROP DATABASE IF EXISTS student_erp;"
"%PSQL_PATH%" -U postgres -c "CREATE DATABASE student_erp;"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create database. Please check:
    echo   1. PostgreSQL is running
    echo   2. Password is correct (currently set to: 1234)
    echo   3. psql is in your PATH or update PSQL_PATH variable
    pause
    exit /b 1
)

echo Database created successfully!
echo.

echo Step 2: Running schema.sql...
"%PSQL_PATH%" -U postgres -d student_erp -f database/schema.sql

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run schema.sql
    pause
    exit /b 1
)

echo Schema created successfully!
echo.

echo Step 3: Running seeds.sql (this may take a moment)...
"%PSQL_PATH%" -U postgres -d student_erp -f database/seeds.sql

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to run seeds.sql
    pause
    exit /b 1
)

echo Data seeded successfully!
echo.

echo ========================================
echo Database setup complete!
echo ========================================
echo.
echo You can now:
echo   1. Start the backend: cd backend && npm start
echo   2. Start the frontend: cd frontend && npm run dev
echo.
pause
