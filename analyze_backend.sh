#!/bin/bash
echo "=== Backend Structure Analysis ==="
echo ""

echo "1. Backend directory contents:"
ls -la backend/
echo ""

echo "2. Package.json (if exists):"
if [ -f backend/package.json ]; then
    cat backend/package.json | head -20
else
    echo "No package.json found"
fi
echo ""

echo "3. Server file (checking common names):"
if [ -f backend/server.js ]; then
    echo "Found server.js"
    head -30 backend/server.js
elif [ -f backend/index.js ]; then
    echo "Found index.js"
    head -30 backend/index.js
elif [ -f backend/app.js ]; then
    echo "Found app.js"
    head -30 backend/app.js
else
    echo "No main server file found"
fi
echo ""

echo "4. Environment configuration:"
cat backend/.env
echo ""