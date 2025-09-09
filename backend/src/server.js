const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./routes/auth_routes');
// const patientRoutes = require('./routes/patient_routes');  // Temporarily disabled
// const hospitalRoutes = require('./routes/hospital_routes');  // Temporarily disabled
// const regionalRoutes = require('./routes/regional_routes');  // Temporarily disabled
const userRoutes = require('./routes/user_routes');
const allRolesRoutes = require('./routes/all_roles_routes');
const dashboardRoutes = require('./routes/dashboardRoutes');

// Import middleware
const errorHandler = require('./middleware/error_handler');
const logger = require('./middleware/logger');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(logger); // Request logging

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'DHRMS Backend is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API Routes
app.use('/api/auth', authRoutes);
// app.use('/api/patients', patientRoutes);  // Temporarily disabled
// app.use('/api/hospital', hospitalRoutes);  // Temporarily disabled
// app.use('/api/regional', regionalRoutes);  // Temporarily disabled
app.use('/api/users', userRoutes);
app.use('/api/roles', allRolesRoutes);
app.use('/api', dashboardRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Error handling middleware
app.use(errorHandler);

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ Connected to MongoDB - Database: myhealth');
  
  // Start server
  app.listen(PORT, () => {
    console.log(`🚀 DHRMS Backend server running on port ${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/health`);
  });
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  mongoose.connection.close(() => {
    console.log('MongoDB connection closed.');
    process.exit(0);
  });
});

module.exports = app;
