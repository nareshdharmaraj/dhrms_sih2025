@echo off
echo 🔧 Installing Apache Maven for MyHealth DHRMS Backend

echo 📦 Downloading Maven...
powershell -Command "& {Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip' -OutFile 'maven.zip'}"

echo 📁 Creating Maven directory...
if not exist "C:\maven" mkdir "C:\maven"

echo 📦 Extracting Maven...
powershell -Command "& {Expand-Archive -Path 'maven.zip' -DestinationPath 'C:\maven' -Force}"

echo 🔧 Setting up environment...
setx PATH "%PATH%;C:\maven\apache-maven-3.9.5\bin" /M

echo ✅ Maven installation completed!
echo 🔄 Please restart PowerShell and run: mvn -version

echo 🚀 After Maven is verified, run: .\start-backend.bat

pause
