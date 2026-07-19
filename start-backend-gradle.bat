@echo off

REM MyHealth DHRMS Backend Startup Script using Gradle

echo 🏥 Starting MyHealth DHRMS Backend with Gradle...
echo 📍 Current Directory: %cd%

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Java is not installed. Please install Java 17 or higher.
    pause
    exit /b 1
)

echo ✅ Java is installed.

REM Navigate to backend directory
cd backend

echo 📦 Setting up Gradle and dependencies...
echo 🔄 This may take a few minutes on first run...

REM Run Gradle build and start application
gradlew.bat bootRun

echo 🎉 Backend started successfully!
echo 📊 API Base URL: http://localhost:8080/api
echo 🔍 Health Check: http://localhost:8080/api/test/health
echo 🗄️  Database Test: http://localhost:8080/api/test/db-connection

pause
