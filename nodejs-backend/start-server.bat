@echo off
echo Starting DHRMS Node.js Backend Server...

cd /d "%~dp0"

echo Checking if dependencies are installed...
if not exist "node_modules" (
    echo Installing dependencies first...
    npm install
)

echo.
echo Starting development server...
npm run dev
