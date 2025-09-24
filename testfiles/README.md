# Test Files Organization

This document describes the organization of test and check files in the `testfiles/` directory.

## Directory Structure

```
testfiles/
├── backend/                          # Backend test and check files
│   ├── test-*.js                     # API and functionality tests
│   ├── check-*.js                    # Database and system checks
│   ├── comprehensive_*.js            # Comprehensive system tests
│   ├── direct_*test*.js              # Direct test implementations
│   ├── simple_*test*.js              # Simple test cases
│   ├── *.bat files                   # Test execution scripts
│   └── *.json files                  # Test result data
├── flutter/                          # Flutter test files
│   ├── rho_assignment_system_test.dart
│   └── widget_test.dart
└── root level files                  # Various test and check files
    ├── test_*.dart                   # Dart test files
    ├── test_*.html                   # HTML test interfaces
    ├── test_*.js                     # JavaScript test files
    ├── test_*.json                   # Test data files
    ├── TEST_*.md                     # Test documentation
    └── test_config_debug.dart        # Test configuration
```

## File Categories

### Backend Tests (`testfiles/backend/`)
- **API Tests**: Files testing API endpoints and responses
- **Database Checks**: Scripts verifying database state and data integrity
- **System Verification**: Comprehensive tests for complete workflows
- **Authentication Tests**: Login and authorization functionality tests
- **Assignment Tests**: RHO, SHO, and zone assignment verification

### Flutter Tests (`testfiles/flutter/`)
- **Widget Tests**: UI component testing
- **System Tests**: End-to-end Flutter application testing

### Root Level Tests
- **API Interface Tests**: HTML-based API testing interfaces
- **Configuration Tests**: Debug and configuration testing files
- **Standalone Tests**: Individual component and feature tests

## Usage Notes

### Debug Files NOT Moved
The following debug files remain in their original locations for active development:
- `backend/debug-*.js` files
- `*.log` files
- Development configuration files

### Excluded Files
- Production configuration files
- Active development scripts
- Critical system files
- Documentation files (unless specifically test-related)

## Running Tests

### Backend Tests
```bash
cd testfiles/backend
node test-[specific-test].js
```

### Flutter Tests
```bash
flutter test testfiles/flutter/
```

### Individual Tests
Navigate to the testfiles directory and run specific test files as needed.

## Maintenance

- Test files are organized by technology (backend, flutter)
- Check files are kept with their related test files
- Configuration and data files are grouped logically
- Documentation follows the same organizational pattern

This organization helps maintain a clean project structure while preserving all testing capabilities.