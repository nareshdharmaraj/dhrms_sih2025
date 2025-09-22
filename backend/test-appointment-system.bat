@echo off
echo 🧪 DHRMS Appointment System Test
echo ================================
echo.

cd /d "%~dp0"

echo 📦 Installing dependencies...
call npm install node-fetch >nul 2>&1

echo 🚀 Starting appointment system test...
echo.
echo 📋 This will test:
echo   ✅ Hospital listing
echo   ✅ Doctor listing for hospitals  
echo   ✅ Appointment creation
echo   ✅ Appointment status updates
echo   ✅ Appointment retrieval
echo.

node test-appointment-api.js

echo.
echo 🏁 Test complete! 
echo.
pause