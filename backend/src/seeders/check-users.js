const User = require('../models/User');
const { sequelize } = require('../config/db');

async function checkUsers() {
  try {
    await sequelize.sync();
    const users = await User.findAll({ attributes: ['id', 'name', 'email', 'role'] });
    console.log('Users in database:');
    users.forEach(u => console.log(`- ${u.email} (${u.role})`));
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

checkUsers();
