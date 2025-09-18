# Environment Configuration Examples

## Local Development (Physical Device)
flutter run --dart-define=PHYSICAL_DEVICE_IP=172.2.4.104 --dart-define=SERVER_PORT=3000

## Cloud Development (Render)
flutter run --dart-define=USE_CLOUD_SERVER=true --dart-define=CLOUD_API_URL=https://your-app-name.onrender.com/api

## Production Build
flutter build apk --release --dart-define=USE_CLOUD_SERVER=true --dart-define=CLOUD_API_URL=https://your-production-api.com/api

## Custom API URL Override
flutter run --dart-define=API_BASE_URL=https://custom-api.example.com/v1

## Development with different IP
flutter run --dart-define=PHYSICAL_DEVICE_IP=192.168.1.100 --dart-define=SERVER_PORT=8080