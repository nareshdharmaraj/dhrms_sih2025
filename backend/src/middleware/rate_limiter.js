// Simple rate limiter middleware
const rateLimiter = (req, res, next) => {
  // For now, just pass through - in production you'd implement proper rate limiting
  next();
};

module.exports = {
  rateLimiter
};
