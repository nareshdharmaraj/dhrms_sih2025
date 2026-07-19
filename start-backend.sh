#!/bin/bash

# MyHealth DHRMS Backend Startup Script

echo "🏥 Starting MyHealth DHRMS Backend..."
echo "📍 Current Directory: $(pwd)"

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven first."
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 17 or higher."
    exit 1
fi

echo "✅ Java Version: $(java -version 2>&1 | head -n 1)"
echo "✅ Maven Version: $(mvn -version 2>&1 | head -n 1)"

# Navigate to backend directory
cd backend

echo "📦 Installing dependencies..."
mvn clean install -DskipTests

echo "🚀 Starting Spring Boot application..."
mvn spring-boot:run

echo "🎉 Backend started successfully!"
echo "📊 API Base URL: http://localhost:8080/api"
echo "🔍 Health Check: http://localhost:8080/api/test/health"
echo "🗄️  Database Test: http://localhost:8080/api/test/db-connection"
