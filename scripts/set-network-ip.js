#!/usr/bin/env node

/**
 * Script to update the API base URL in frontend/web/config.js
 * Usage:
 *   node scripts/set-network-ip.js localhost
 *   node scripts/set-network-ip.js 192.168.1.100
 */

const fs = require('fs');
const path = require('path');

const configPath = path.join(__dirname, '../frontend/web/config.js');

// Get IP from command line argument
const ip = process.argv[2];

if (!ip) {
  console.error('❌ Error: Please provide an IP address or "localhost"');
  console.log('\nUsage:');
  console.log('  node scripts/set-network-ip.js localhost');
  console.log('  node scripts/set-network-ip.js 192.168.1.100');
  process.exit(1);
}

// Validate IP format (basic validation)
const isLocalhost = ip === 'localhost' || ip === '127.0.0.1';
const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;

if (!isLocalhost && !ipRegex.test(ip)) {
  console.error('❌ Error: Invalid IP address format');
  console.log('Expected format: xxx.xxx.xxx.xxx or "localhost"');
  process.exit(1);
}

// Read current config
let config;
try {
  config = fs.readFileSync(configPath, 'utf8');
} catch (error) {
  console.error('❌ Error reading config file:', error.message);
  process.exit(1);
}

// Update the IP
const newConfig = config
  .replace(
    /API_BASE_URL: "http:\/\/[^:]+:3000\/api"/,
    `API_BASE_URL: "http://${ip}:3000/api"`
  )
  .replace(
    /SOCKET_URL: "http:\/\/[^:]+:3000"/,
    `SOCKET_URL: "http://${ip}:3000"`
  );

// Write updated config
try {
  fs.writeFileSync(configPath, newConfig, 'utf8');
  console.log('✅ Successfully updated config.js');
  console.log(`📝 API_BASE_URL: http://${ip}:3000/api`);
  console.log(`📝 SOCKET_URL: http://${ip}:3000`);
  console.log('\n📦 Next steps:');
  console.log('  1. Rebuild frontend: docker-compose build frontend');
  console.log('  2. Restart frontend: docker-compose up -d frontend');
  
  if (ip !== 'localhost' && ip !== '127.0.0.1') {
    console.log('\n🔥 Firewall setup (Windows - Run as Administrator):');
    console.log('  netsh advfirewall firewall add rule name="GivingBridge Backend" dir=in action=allow protocol=TCP localport=3000');
    console.log('  netsh advfirewall firewall add rule name="GivingBridge Frontend" dir=in action=allow protocol=TCP localport=8080');
  }
} catch (error) {
  console.error('❌ Error writing config file:', error.message);
  process.exit(1);
}
