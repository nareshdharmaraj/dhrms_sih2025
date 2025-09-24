@echo off
echo 🚀 Starting DHRMS Appointment Workflow Test Suite
echo ================================================

cd /d "%~dp0"

echo.
echo 📦 Step 1: Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo 🌱 Step 2: Seeding test data...
node seed_test_data.js
if %errorlevel% neq 0 (
    echo ❌ Failed to seed test data
    pause
    exit /b 1
)

echo.
echo 🚦 Step 3: Starting backend server...
start "DHRMS Backend Server" cmd /k "npm start"

echo.
echo ⏱️  Waiting for server to start (10 seconds)...
timeout /t 10 /nobreak

echo.
echo 🧪 Step 4: Running comprehensive tests...
node test_appointment_workflow.js

echo.
echo 📊 Test Results Summary:
echo ========================
if exist "appointment_workflow_test_results.json" (
    echo Test results saved to: appointment_workflow_test_results.json
    echo.
    echo ✅ Tests completed! Check the results above.
) else (
    echo ❌ No test results file found
)

echo.
echo 🔧 Manual Testing Instructions:
echo ==============================
echo 1. Backend server should be running on http://localhost:3000
echo 2. Use the Flutter app to test:
echo    - Patient appointment booking 
echo    - Doctor appointment management
echo 3. All data comes from MongoDB database (no mock data)
echo.

pause