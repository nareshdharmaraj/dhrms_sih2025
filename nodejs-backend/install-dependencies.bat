@echo off
echo Installing DHRMS Node.js Backend Dependencies...

cd /d "%~dp0"

echo Installing npm packages...
npm install

echo.
echo Dependencies installed successfully!
echo.
echo To start the development server, run:
echo npm run dev
echo.
echo To start the production server, run:
echo npm start
echo.
pause
