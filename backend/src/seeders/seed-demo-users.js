const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { sequelize } = require('../config/db');

async function seedDemoUsers() {
  try {
    await sequelize.sync();

    // Check if users already exist
    const existingUsers = await User.count();
    if (existingUsers > 0) {
      console.log('✅ Demo users already exist, skipping seed');
      process.exit(0);
    }

    console.log('🌱 Seeding demo users...');

    // Create demo donor
    const donorHash = await bcrypt.hash('demo123', 12);
    await User.create({
      name: 'Demo Donor',
      email: 'demo@example.com',
      password: donorHash,
      role: 'donor',
      phone: '+1234567890',
      location: 'New York, NY'
    });
    console.log('✅ Created demo donor: demo@example.com / demo123');

    // Create demo admin
    const adminHash = await bcrypt.hash('admin123', 12);
    await User.create({
      name: 'Admin User',
      email: 'admin@givingbridge.com',
      password: adminHash,
      role: 'admin',
      phone: '+1234567891',
      location: 'San Francisco, CA'
    });
    console.log('✅ Created demo admin: admin@givingbridge.com / admin123');

    // Create demo receiver
    const receiverHash = await bcrypt.hash('receive123', 12);
    await User.create({
      name: 'Demo Receiver',
      email: 'receiver@example.com',
      password: receiverHash,
      role: 'receiver',
      phone: '+1234567892',
      location: 'Los Angeles, CA'
    });
    console.log('✅ Created demo receiver: receiver@example.com / receive123');

    console.log('🎉 Demo users seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding demo users:', error);
    process.exit(1);
  }
}

seedDemoUsers();
