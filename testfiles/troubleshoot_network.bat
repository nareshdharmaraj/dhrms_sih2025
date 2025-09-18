@echo off
echo ================================================
echo DHRMS Backend Connectivity Troubleshooting
echo ================================================
echo.

echo 1. Checking if backend server is running...
netstat -an | findstr :3000
if %errorLevel% == 0 (
    echo ✓ Backend server is running on port 3000
) else (
    echo ✗ Backend server is NOT running!
    echo Please start the backend server with: npm start
)
echo.

echo 2. Getting current IP addresses...
echo Your computer's IP addresses:
ipconfig | findstr "IPv4 Address"
echo.

echo 3. Testing backend health endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://172.2.4.104:3000/health' -Method GET -TimeoutSec 10; Write-Host '✓ Backend health check successful:' $response.StatusCode } catch { Write-Host '✗ Backend health check failed:' $_.Exception.Message }"
echo.

echo 4. Checking Windows Firewall rules for port 3000...
netsh advfirewall firewall show rule name="DHRMS Node.js Backend" dir=in
if %errorLevel__ == 0 (
    echo ✓ Firewall rule exists
) else (
    echo ✗ Firewall rule NOT found!
    echo Please run setup_firewall.bat as Administrator
)
echo.

echo 5. Network connectivity recommendations:
echo - Ensure your phone and computer are on the same WiFi network
echo - Disable AP Isolation in your router settings
echo - Try accessing http://172.2.4.104:3000/health from your phone's browser
echo - If using enterprise/corporate WiFi, contact your network administrator
echo.

echo ================================================
echo QUICK FIXES:
echo 1. Run setup_firewall.bat as Administrator
echo 2. Restart your backend server: npm start
echo 3. Test from phone browser: http://172.2.4.104:3000/health
echo 4. In Flutter app, use Debug Connection screen (bug icon)
echo ================================================
echo.

pause