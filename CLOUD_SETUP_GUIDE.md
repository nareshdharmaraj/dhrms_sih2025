# 🌐 Environment-Based Configuration Guide

## Modern Configuration Management

Instead of hardcoding URLs, we now use environment variables for better configuration management.

### 🚀 Quick Start Commands

**Local Development (Physical Device):**
```bash
flutter run --dart-define=PHYSICAL_DEVICE_IP=172.2.4.104
```

**Render Cloud Development:**
```bash
flutter run --dart-define=USE_CLOUD_SERVER=true --dart-define=CLOUD_API_URL=https://dhrms-sih2025.onrender.com/api
```

**Production Build:**
```bash
flutter build apk --release --dart-define=USE_CLOUD_SERVER=true --dart-define=CLOUD_API_URL=https://dhrms-sih2025.onrender.com/api
```

## 🔧 Available Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `API_BASE_URL` | Direct API URL override | `https://api.myapp.com/v1` |
| `USE_CLOUD_SERVER` | Enable cloud mode | `true` or `false` |
| `CLOUD_API_URL` | Cloud deployment URL | `https://myapp.onrender.com/api` |
| `PHYSICAL_DEVICE_IP` | Local development IP | `192.168.1.100` |
| `SERVER_PORT` | Backend server port | `3000` |

## 🎯 Configuration Examples

### For Your Physical Device Testing:
```bash
# Replace with your computer's actual IP
flutter run --dart-define=PHYSICAL_DEVICE_IP=172.2.4.104 --dart-define=SERVER_PORT=3000
```

### For Render Cloud Testing:
```bash
# Your actual Render service URL is already configured
flutter run --dart-define=USE_CLOUD_SERVER=true --dart-define=CLOUD_API_URL=https://dhrms-sih2025.onrender.com/api
```

### For Production Deployment:
```bash
flutter build apk --release \
  --dart-define=USE_CLOUD_SERVER=true \
  --dart-define=CLOUD_API_URL=https://dhrms-sih2025.onrender.com/api
```

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