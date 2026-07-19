# DHRMS Database Queries Documentation

This folder contains all database-related queries, schemas, and sample data for the Digital Health Records Management System (DHRMS).

## Structure

- `create-database.js` - Database creation and initial setup
- `schemas/` - MongoDB schema definitions
- `sample-data/` - Sample data for testing
- `migrations/` - Database migration scripts
- `indexes.js` - Database indexes for performance optimization

## Collections

1. **patients** - Patient records and health information
2. **doctors** - Doctor profiles and professional information
3. **hospitals** - Hospital information and facilities
4. **appointments** - Appointment scheduling and management
5. **medical_records** - Medical history and treatment records
6. **prescriptions** - Prescription details and medication history
7. **telemedicine_sessions** - Virtual consultation records
8. **wearable_data** - IoT device and wearable health data
9. **analytics** - Health analytics and reports

## Usage

Run the database setup:
```bash
node create-database.js
```

Load sample data:
```bash
node sample-data/load-sample-data.js
```

## Updates

This documentation is updated whenever database schema changes are made to ensure consistency across the application.
