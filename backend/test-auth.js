/**
 * Quick script to test JWT token and admin access
 * Usage: node test-auth.js <your-jwt-token>
 */

const jwt = require('jsonwebtoken');
require('dotenv').config();

const token = process.argv[2];

if (!token) {
  console.log('Usage: node test-auth.js <your-jwt-token>');
  console.log('\nTo get your token:');
  console.log('1. Open browser console');
  console.log('2. Run: localStorage.getItem("auth_token")');
  console.log('3. Copy the token and run this script');
  process.exit(1);
}

console.log('Testing JWT Token...\n');
console.log('Token (first 50 chars):', token.substring(0, 50) + '...\n');

try {
  // Verify token
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  
  console.log('✅ Token is VALID!\n');
  console.log('Decoded payload:');
  console.log(JSON.stringify(decoded, null, 2));
  
  console.log('\n--- Authorization Check ---');
  console.log('User ID:', decoded.userId);
  console.log('Email:', decoded.email);
  console.log('Role:', decoded.role);
  
  if (decoded.role === 'admin') {
    console.log('\n✅ User HAS admin privileges');
    console.log('This token SHOULD work for approval endpoints');
  } else {
    console.log('\n❌ User DOES NOT have admin privileges');
    console.log(`Current role: ${decoded.role}`);
    console.log('This token will get 403 Forbidden on admin endpoints');
  }
  
} catch (error) {
  console.log('❌ Token is INVALID!\n');
  console.log('Error:', error.message);
  
  if (error.name === 'TokenExpiredError') {
    console.log('\n💡 Token has expired. Please login again.');
  } else if (error.name === 'JsonWebTokenError') {
    console.log('\n💡 Token is malformed or signed with wrong secret.');
  }
}
