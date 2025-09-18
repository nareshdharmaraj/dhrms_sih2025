# 🌐 Render Cloud Server Setup Guide

## Quick Setup for Render Deployment

To connect to your Render-deployed backend:

### Step 1: Update Debug Configuration

1. Open `lib/utils/debug_config.dart`
2. Settings are already configured for Render:

```dart
// Already set to true for cloud mode
static const bool useCloudServer = true;

// Update with your actual Render service URL
static const String cloudServerUrl = 'https://your-app-name.onrender.com/api';
```

### Step 2: Replace with Your Render URL

Replace `your-app-name` with your actual Render service name:

**Example:**
- If your Render service is named `myhealth-backend`
- Your URL would be: `https://myhealth-backend.onrender.com/api`

```dart
static const String cloudServerUrl = 'https://myhealth-backend.onrender.com/api';
```

### Step 3: Test Connection

1. Run the app: `flutter run`
2. Tap the debug icon (🐛) on the role selection screen
3. Check connection status and API responses
4. **Note**: First request may take 30-60 seconds if Render service was sleeping

## Render-Specific Configuration

### Backend Environment Variables on Render

Make sure your Render service has these environment variables:

```env
# MongoDB Connection (Required)
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/myhealth

# Server Configuration  
PORT=10000
NODE_ENV=production

# CORS Configuration (Important for mobile apps)
CORS_ORIGIN=*

# JWT Configuration
JWT_SECRET=your_secure_jwt_secret_for_production
JWT_EXPIRES_IN=24h

# Database name
DB_NAME=myhealth
```

### Important Render Notes

⚠️ **Free Tier Limitations:**
- Service sleeps after 15 minutes of inactivity
- Cold starts take 30-60 seconds to wake up
- Use debug screen to test and wake up the service

🚀 **Performance Tips:**
- First API call after sleep will be slow
- Subsequent calls will be fast
- Consider paid plan for production use
- Use health check endpoints to keep service warm

## Example Working Configuration

```dart
class DebugConfig {
  static const bool useCloudServer = true;
  static const String cloudServerUrl = 'https://myhealth-api-sih2025.onrender.com/api';
  
  // Local settings (ignored when using cloud)
  static const bool forcePhysicalDeviceMode = false;
  static const String physicalDeviceIP = '192.168.1.100';
  static const int serverPort = 3000;
}

## Troubleshooting

### Connection Issues
- Check if the cloud server is running
- Verify the URL format (should end with `/api`)
- Ensure CORS is configured to allow your app domain

### Authentication Issues
- Verify JWT_SECRET matches between environments
- Check user registration endpoints are working

### Database Issues
- Confirm MongoDB connection string is correct
- Verify database has proper collections and indexes

## Testing Checklist

- [ ] App connects to cloud backend
- [ ] User registration works
- [ ] User login works
- [ ] Patient dashboard loads data
- [ ] Emergency contacts sync properly
- [ ] All API endpoints respond correctly

## Switch Back to Local

To switch back to local development:

```dart
static const bool useCloudServer = false;
static const bool forcePhysicalDeviceMode = true;
```

## Need Help?

1. Check the debug connection screen in the app
2. Look at browser developer tools for network errors
3. Check cloud server logs for backend issues
4. Verify environment variables in cloud platform