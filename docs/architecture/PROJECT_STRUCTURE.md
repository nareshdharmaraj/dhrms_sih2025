# DHRMS Project Structure

This document outlines the complete project structure for the Digital Health Record Management System (DHRMS).

## 📁 Project Overview

```
myhealth/
├── frontend/              # Flutter frontend application
├── backend/               # Node.js backend API
├── database/              # MongoDB schemas and migrations
├── lib/                   # Main Flutter app entry point
├── android/               # Android-specific configurations
├── ios/                   # iOS-specific configurations
├── web/                   # Web-specific configurations
├── windows/               # Windows-specific configurations
├── linux/                 # Linux-specific configurations
├── macos/                 # macOS-specific configurations
└── test/                  # Test files
```

## 🎨 Frontend Structure (`frontend/`)

```
frontend/
├── lib/
│   ├── screens/           # UI screens/pages
│   │   ├── role_selection_screen.dart
│   │   ├── patient/       # Patient-specific screens
│   │   ├── hospital/      # Hospital staff screens
│   │   └── regional/      # Regional officer screens
│   ├── widgets/           # Reusable UI components
│   │   ├── role_card_widget.dart
│   │   ├── common/        # Common widgets
│   │   └── custom/        # Custom widgets
│   ├── models/            # Data models
│   │   ├── user_role_model.dart
│   │   ├── user_model.dart
│   │   └── health_record_model.dart
│   ├── services/          # API services and business logic
│   │   ├── auth_service.dart
│   │   ├── patient_service.dart
│   │   └── api_service.dart
│   └── utils/             # Utilities and constants
│       ├── app_constants.dart
│       ├── validators.dart
│       └── helpers.dart
```

## ⚡ Backend Structure (`backend/`)

```
backend/
├── src/
│   ├── controllers/       # Request handlers
│   │   ├── auth_controller.js
│   │   ├── patient_controller.js
│   │   ├── hospital_controller.js
│   │   └── regional_controller.js
│   ├── routes/            # API route definitions
│   │   ├── auth_routes.js
│   │   ├── patient_routes.js
│   │   ├── hospital_routes.js
│   │   └── regional_routes.js
│   ├── models/            # Database models
│   │   ├── user_model.js
│   │   ├── health_record_model.js
│   │   └── appointment_model.js
│   ├── middleware/        # Express middleware
│   │   ├── auth.js
│   │   ├── validation.js
│   │   ├── error_handler.js
│   │   └── rate_limiter.js
│   ├── services/          # Business logic services
│   │   ├── ai_service.js
│   │   ├── notification_service.js
│   │   └── encryption_service.js
│   └── server.js          # Express server setup
├── package.json           # Dependencies and scripts
└── .env.example           # Environment variables template
```

## 🗄️ Database Structure (`database/`)

```
database/
├── schemas/               # MongoDB schema definitions
│   ├── user_schema.js
│   ├── health_record_schema.js
│   ├── appointment_schema.js
│   ├── hospital_schema.js
│   └── notification_schema.js
├── migrations/            # Database migration scripts
│   ├── 001_initial_setup.js
│   ├── 002_add_indexes.js
│   └── 003_add_ai_fields.js
└── seeders/               # Test data seeders
    ├── users_seeder.js
    └── hospitals_seeder.js
```

## 🎯 Key Features Implementation

### 1. Role-Based Access Control
- **Patient**: Access personal health records, book appointments, view vitals
- **Hospital Staff**: 
  - **Doctor**: Create/view patient records, prescriptions, consultations
  - **Admin**: Manage hospital operations, staff, reports
  - **Assistant**: Support administrative tasks, patient check-ins
- **Regional Officer**: Monitor health trends, manage regional healthcare data

### 2. Universal Health Identity (UHI)
- Format: `[FirstName2chars][LastName2chars][Aadhaar4digits]`
- Example: `JODO1234` (John Doe with Aadhaar ending in 1234)

### 3. AI-Powered Features
- Disease prediction based on symptoms and health history
- Early warning system for outbreaks
- Risk scoring for patients
- Automated health recommendations

### 4. Real-time Features
- Proximity infection alerts
- Live health monitoring from wearables
- Emergency SOS functionality
- Instant notifications

### 5. Security & Privacy
- End-to-end encryption for sensitive data
- JWT-based authentication
- Role-based authorization
- Data anonymization for research

## 🚀 Getting Started

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

### Backend (Node.js)
```bash
cd backend
npm install
npm run dev
```

### Database (MongoDB)
```bash
# Start MongoDB locally or use MongoDB Atlas
mongod --dbpath ./data
```

## 📱 App Flow

1. **App Launch** → Role Selection Screen
2. **Role Selection** → Authentication (Login/Register)
3. **Authentication** → Role-specific Dashboard
4. **Dashboard** → Feature-specific screens

## 🎨 Design Principles

- **Mobile-first**: Optimized for smartphones with responsive design
- **Accessibility**: Support for screen readers and high contrast
- **Offline-first**: Local storage for critical health data
- **Material Design 3**: Modern, consistent UI components
- **Performance**: Efficient state management and caching

## 🔧 Development Guidelines

- Use meaningful file names that reflect their function
- Follow Dart/JavaScript naming conventions
- Implement proper error handling and validation
- Write unit tests for critical functionality
- Document API endpoints and data models
- Use version control with meaningful commit messages

## 📊 Monitoring & Analytics

- User engagement tracking
- Performance monitoring
- Error reporting and crash analytics
- Health data analytics (anonymized)
- API usage statistics

This structure provides a solid foundation for building a comprehensive healthcare management system that can scale with user needs and regulatory requirements.
