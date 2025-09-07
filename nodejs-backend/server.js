const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const hospitalRoutes = require('./routes/hospitals');
const doctorRoutes = require('./routes/doctors');
const patientRoutes = require('./routes/patients');
const prescriptionRoutes = require('./routes/prescriptions');
const healthRoutes = require('./routes/health');
const dashboardRoutes = require('./routes/dashboard');
const emergencyRoutes = require('./routes/emergency');
const telemedicineRoutes = require('./routes/telemedicine');
const wearableRoutes = require('./routes/wearable');
const analyticsRoutes = require('./routes/analytics');

// Import middleware
const errorHandler = require('./middleware/errorHandler');
const logger = require('./utils/logger');

const app = express();

// Security middleware
app.use(helmet());
app.use(compression());

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW) * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_REQUESTS), // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// MongoDB connection
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    logger.info(`MongoDB Connected: ${conn.connection.host}`);
    console.log(`🍃 MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    logger.error('MongoDB connection failed:', error);
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

// Connect to database
connectDB();

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'DHRMS Backend API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: '1.0.0'
  });
});

// API Routes
const apiVersion = process.env.API_VERSION || 'v1';
app.use(`/api/${apiVersion}/auth`, authRoutes);
app.use(`/api/${apiVersion}/hospitals`, hospitalRoutes);
app.use(`/api/${apiVersion}/doctors`, doctorRoutes);
app.use(`/api/${apiVersion}/patients`, patientRoutes);
app.use(`/api/${apiVersion}/prescriptions`, prescriptionRoutes);
app.use(`/api/${apiVersion}/health`, healthRoutes);
app.use(`/api/${apiVersion}/dashboard`, dashboardRoutes);
app.use(`/api/${apiVersion}/emergency`, emergencyRoutes);
app.use(`/api/${apiVersion}/telemedicine`, telemedicineRoutes);
app.use(`/api/${apiVersion}/wearable`, wearableRoutes);
app.use(`/api/${apiVersion}/analytics`, analyticsRoutes);

// Default route
app.get('/', (req, res) => {
  res.json({
    message: '🏥 Digital Health Record Management System API',
    version: '1.0.0',
    documentation: `/api/${apiVersion}/docs`,
    health: '/health',
    endpoints: {
      auth: `/api/${apiVersion}/auth`,
      hospitals: `/api/${apiVersion}/hospitals`,
      doctors: `/api/${apiVersion}/doctors`,
      patients: `/api/${apiVersion}/patients`,
      prescriptions: `/api/${apiVersion}/prescriptions`,
      health: `/api/${apiVersion}/health`,
      dashboard: `/api/${apiVersion}/dashboard`,
      emergency: `/api/${apiVersion}/emergency`,
      telemedicine: `/api/${apiVersion}/telemedicine`,
      wearable: `/api/${apiVersion}/wearable`,
      analytics: `/api/${apiVersion}/analytics`
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found',
    requestedPath: req.originalUrl
  });
});

// Error handling middleware
app.use(errorHandler);

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('💤 Process terminated');
    mongoose.connection.close();
  });
});

const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, () => {
  console.log(`🚀 DHRMS Backend Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
  console.log(`🔗 API Base URL: http://localhost:${PORT}/api/${apiVersion}`);
  console.log(`❤️  Health Check: http://localhost:${PORT}/health`);
  logger.info(`Server started on port ${PORT}`);
});

module.exports = app;
