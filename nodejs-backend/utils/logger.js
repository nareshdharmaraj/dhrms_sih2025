const fs = require('fs');
const path = require('path');

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '..', 'logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

const logger = {
  info: (message, meta = {}) => {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] INFO: ${message} ${JSON.stringify(meta)}\n`;
    
    console.log(`ℹ️  ${message}`);
    
    if (process.env.NODE_ENV !== 'test') {
      fs.appendFileSync(path.join(logsDir, 'app.log'), logMessage);
    }
  },

  error: (message, meta = {}) => {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ERROR: ${message} ${JSON.stringify(meta)}\n`;
    
    console.error(`❌ ${message}`);
    
    if (process.env.NODE_ENV !== 'test') {
      fs.appendFileSync(path.join(logsDir, 'error.log'), logMessage);
      fs.appendFileSync(path.join(logsDir, 'app.log'), logMessage);
    }
  },

  warn: (message, meta = {}) => {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] WARN: ${message} ${JSON.stringify(meta)}\n`;
    
    console.warn(`⚠️  ${message}`);
    
    if (process.env.NODE_ENV !== 'test') {
      fs.appendFileSync(path.join(logsDir, 'app.log'), logMessage);
    }
  },

  debug: (message, meta = {}) => {
    if (process.env.NODE_ENV === 'development') {
      const timestamp = new Date().toISOString();
      const logMessage = `[${timestamp}] DEBUG: ${message} ${JSON.stringify(meta)}\n`;
      
      console.log(`🐛 ${message}`);
      
      fs.appendFileSync(path.join(logsDir, 'debug.log'), logMessage);
    }
  }
};

module.exports = logger;
