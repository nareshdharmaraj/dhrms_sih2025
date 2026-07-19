// Minimal test server to debug connection issues
const express = require('express');
require('dotenv').config();

const app = express();

// Basic middleware
app.use(express.json());

console.log('Starting test server...');

// Test route
app.get('/health', (req, res) => {
  console.log('🏥 Health endpoint hit');
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Simple auth test route
app.post('/api/v1/auth/test', (req, res) => {
  console.log('🔑 Auth test endpoint hit:', req.body);
  res.json({ 
    status: 'success', 
    message: 'Auth test working',
    body: req.body 
  });
});

const PORT = 5000;

console.log(`Attempting to start server on port ${PORT}...`);

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Test server running on port ${PORT}`);
  console.log(`📡 Test health: http://localhost:${PORT}/health`);
  console.log(`🔑 Test auth: http://localhost:${PORT}/api/v1/auth/test`);
  console.log('Server is ready to accept connections');
});

server.on('error', (error) => {
  console.error('❌ Server error:', error);
});

server.on('listening', () => {
  console.log('✅ Server is listening on port', PORT);
});

console.log('Test server script loaded');
