/**
 * Script to list all users and their roles
 * Usage: node scripts/list-users.js
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

async function listUsers() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected\n');

    // Get all users
    const [users] = await sequelize.query(
      'SELECT id, name, email, role, createdAt FROM users ORDER BY createdAt DESC'
    );

    if (users.length === 0) {
      console.log('No users found in database');
      await sequelize.close();
      process.exit(0);
    }

    console.log(`Found ${users.length} user(s):\n`);
    console.table(users);

    // Show role summary
    const [roleCounts] = await sequelize.query(
      'SELECT role, COUNT(*) as count FROM users GROUP BY role'
    );

    console.log('\nRole Summary:');
    console.table(roleCounts);

    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
    process.exit(1);
  }
}

listUsers();
