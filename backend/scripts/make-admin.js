/**
 * Script to make a user an admin
 * Usage: node scripts/make-admin.js <email>
 * Example: node scripts/make-admin.js admin@example.com
 */

const { Sequelize } = require('sequelize');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

// Database configuration
const sequelize = new Sequelize(
  process.env.DB_NAME || 'givingbridge',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || '',
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    logging: false,
  }
);

async function makeAdmin(email) {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected');

    // Update user role to admin
    const [results] = await sequelize.query(
      'UPDATE users SET role = ? WHERE email = ?',
      {
        replacements: ['admin', email],
      }
    );

    if (results.affectedRows === 0) {
      console.log(`❌ No user found with email: ${email}`);
      console.log('\nAvailable users:');
      
      const [users] = await sequelize.query(
        'SELECT id, name, email, role FROM users ORDER BY createdAt DESC LIMIT 10'
      );
      
      console.table(users);
      process.exit(1);
    }

    console.log(`✅ User ${email} is now an admin!`);
    
    // Show updated user info
    const [user] = await sequelize.query(
      'SELECT id, name, email, role, createdAt FROM users WHERE email = ?',
      {
        replacements: [email],
      }
    );
    
    console.log('\nUpdated user info:');
    console.table(user);
    
    console.log('\n⚠️  IMPORTANT: User must logout and login again to get new permissions!');
    
    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
    process.exit(1);
  }
}

// Get email from command line arguments
const email = process.argv[2];

if (!email) {
  console.log('Usage: node scripts/make-admin.js <email>');
  console.log('Example: node scripts/make-admin.js admin@example.com');
  process.exit(1);
}

makeAdmin(email);
