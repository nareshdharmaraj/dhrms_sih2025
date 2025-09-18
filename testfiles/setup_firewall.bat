@echo off
echo Setting up Windows Firewall for DHRMS Backend...
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges detected. Proceeding...
    echo.
) else (
    echo ERROR: This script must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

REM Add firewall rule for Node.js backend
echo Adding firewall rule for port 3000...
netsh advfirewall firewall add rule name="DHRMS Node.js Backend" dir=in action=allow protocol=TCP localport=3000

if %errorLevel% == 0 (
    echo SUCCESS: Firewall rule added successfully!
    echo.
    echo The following rule has been created:
    echo - Name: DHRMS Node.js Backend
    echo - Direction: Inbound
    echo - Action: Allow
    echo - Protocol: TCP
    echo - Port: 3000
    echo.
    echo Your backend server should now be accessible from mobile devices.
) else (
    echo ERROR: Failed to add firewall rule!
    echo Please check Windows Firewall settings manually.
)

echo.
echo Press any key to close...
pause >nul