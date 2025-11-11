const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { sequelize } = require('../config/db');

async function createDemoUsers() {
  try {
    await sequelize.sync();

    console.log('🌱 Creating demo users...');

    // Check and create demo donor
    let donor = await User.findOne({ where: { email: 'demo@example.com' } });
    if (!donor) {
      const donorHash = await bcrypt.hash('Demo1234', 12);
      donor = await User.create({
        name: 'Demo Donor',
        email: 'demo@example.com',
        password: donorHash,
        role: 'donor',
        phone: '+1234567890',
        location: 'New York, NY',
        isEmailVerified: true
      });
      console.log('✅ Created demo donor: demo@example.com / Demo1234');
    } else {
      console.log('ℹ️  Demo donor already exists');
    }

    // Check and create demo receiver
    let receiver = await User.findOne({ where: { email: 'receiver@example.com' } });
    if (!receiver) {
      const receiverHash = await bcrypt.hash('Receive1234', 12);
      receiver = await User.create({
        name: 'Demo Receiver',
        email: 'receiver@example.com',
        password: receiverHash,
        role: 'receiver',
        phone: '+1234567892',
        location: 'Los Angeles, CA',
        isEmailVerified: true
      });
      console.log('✅ Created demo receiver: receiver@example.com / Receive1234');
    } else {
      console.log('ℹ️  Demo receiver already exists');
    }

    console.log('🎉 Demo users ready!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating demo users:', error);
    process.exit(1);
  }
}

createDemoUsers();
