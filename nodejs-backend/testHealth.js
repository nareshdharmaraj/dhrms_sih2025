const http = require('http');

console.log('Testing health check endpoint...');

const options = {
  hostname: '127.0.0.1',
  port: 5000,
  path: '/health',
  method: 'GET'
};

const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('Status Code:', res.statusCode);
    console.log('Response:', data);
  });
});

req.on('error', (e) => {
  console.error('Error making request:', e);
});

req.end();
