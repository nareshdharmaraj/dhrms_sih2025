@echo off

REM MyHealth DHRMS Backend Startup Script for Windows

echo 🏥 Starting MyHealth DHRMS Backend...
echo 📍 Current Directory: %cd%

REM Check if Maven is installed
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Maven is not installed. Please install Maven first.
    pause
    exit /b 1
)

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Java is not installed. Please install Java 17 or higher.
    pause
    exit /b 1
)

echo ✅ Java and Maven are installed.

REM Navigate to backend directory
cd backend

echo 📦 Installing dependencies...
mvn clean install -DskipTests

echo 🚀 Starting Spring Boot application...
mvn spring-boot:run

echo 🎉 Backend started successfully!
echo 📊 API Base URL: http://localhost:8080/api
echo 🔍 Health Check: http://localhost:8080/api/test/health
echo 🗄️  Database Test: http://localhost:8080/api/test/db-connection

pause
