// Security Cleanup Script for DHRMS
// This script helps clean up exposed MongoDB credentials and updates environment files

const fs = require('fs');
const path = require('path');

console.log('🔒 DHRMS Security Cleanup Script');
console.log('=================================');

// Function to generate a secure MongoDB URI placeholder
function createSecureEnvTemplate() {
    const secureTemplate = `# MongoDB Configuration - SECURE
# Replace with your actual MongoDB URI from MongoDB Atlas
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority

# Server Configuration
PORT=3000
NODE_ENV=development

# API Configuration
API_BASE_URL=http://localhost:3000/api
CLOUD_API_URL=https://dhrms-sih2025.onrender.com/api
USE_CLOUD_SERVER=false

# Security - CHANGE THESE IN PRODUCTION
JWT_SECRET=your_secure_jwt_secret_here_change_in_production
WHO_JWT_SECRET=your_secure_who_jwt_secret_here_change_in_production

# Database Configuration
DB_NAME=myhealth

# CORS Configuration
CORS_ORIGIN=*

# JWT Configuration
JWT_EXPIRES_IN=24h
WHO_SESSION_TIMEOUT=24h
WHO_MAX_LOGIN_ATTEMPTS=5
WHO_LOCK_DURATION=30

# Rate Limiting
WHO_RATE_LIMIT_REQUESTS=100
WHO_RATE_LIMIT_WINDOW=900000

# Security Configuration
BCRYPT_ROUNDS=12
PASSWORD_MIN_LENGTH=8

# System Configuration
WHO_SYSTEM_NAME=WHO India Health Management System
WHO_CONTACT_EMAIL=support@who-india.org
WHO_SUPPORT_PHONE=+91-11-12345678

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
`;

    fs.writeFileSync('.env.template', secureTemplate);
    console.log('✅ Created secure .env.template file');
}

// Function to check for exposed credentials in files
function scanForExposedCredentials() {
    console.log('\n🔍 Scanning for exposed credentials...');
    
    const jsFiles = [
        'create_admin.js',
        'create_assistant.js', 
        'create_doctor.js',
        'check_db_data.js',
        'setup_test_data.js',
        'test_complete_system.js'
    ];
    
    let foundExposed = false;
    
    jsFiles.forEach(file => {
        if (fs.existsSync(file)) {
            const content = fs.readFileSync(file, 'utf8');
            if (content.includes('mongodb+srv://saravana:saravana100@')) {
                console.log(`❌ EXPOSED CREDENTIALS in ${file}`);
                foundExposed = true;
            } else {
                console.log(`✅ ${file} - credentials secured`);
            }
        }
    });
    
    return foundExposed;
}

// Function to update .gitignore to prevent future exposure
function updateGitignore() {
    const gitignorePath = '../.gitignore';
    let gitignoreContent = '';
    
    if (fs.existsSync(gitignorePath)) {
        gitignoreContent = fs.readFileSync(gitignorePath, 'utf8');
    }
    
    const envPatterns = [
        '# Environment files',
        '.env',
        '.env.local',
        '.env.production',
        '.env.development',
        '*.env',
        'backend/.env*',
        '!.env.example',
        '!.env.template'
    ];
    
    let needsUpdate = false;
    envPatterns.forEach(pattern => {
        if (!gitignoreContent.includes(pattern)) {
            gitignoreContent += '\n' + pattern;
            needsUpdate = true;
        }
    });
    
    if (needsUpdate) {
        fs.writeFileSync(gitignorePath, gitignoreContent);
        console.log('✅ Updated .gitignore to protect environment files');
    } else {
        console.log('✅ .gitignore already configured properly');
    }
}

// Main execution
try {
    // Create secure template
    createSecureEnvTemplate();
    
    // Scan for exposed credentials
    const hasExposed = scanForExposedCredentials();
    
    if (!hasExposed) {
        console.log('\n✅ All files have been secured!');
    }
    
    // Update gitignore
    updateGitignore();
    
    console.log('\n🛡️  SECURITY RECOMMENDATIONS:');
    console.log('1. Change your MongoDB password immediately');
    console.log('2. Update MONGODB_URI in your .env file with new credentials');
    console.log('3. Never commit .env files to version control');
    console.log('4. Use .env.template for sharing configuration structure');
    console.log('5. Set environment variables directly in Render.com dashboard');
    
    console.log('\n📋 NEXT STEPS:');
    console.log('1. Go to MongoDB Atlas and change your password');
    console.log('2. Update .env file with new connection string');
    console.log('3. Test connection: node -e "require(\'./src/config/database\')"');
    console.log('4. Commit the fixed files to git');
    
} catch (error) {
    console.error('❌ Error during security cleanup:', error.message);
}
