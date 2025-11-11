const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { sequelize } = require('../config/db');

async function updateDemoPasswords() {
  try {
    await sequelize.sync();

    console.log('🔄 Updating demo user passwords...');

    // Update demo donor password
    const donor = await User.findOne({ where: { email: 'demo@example.com' } });
    if (donor) {
      const donorHash = await bcrypt.hash('Demo1234', 12);
      await donor.update({ password: donorHash });
      console.log('✅ Updated demo donor password: demo@example.com / Demo1234');
    }

    // Update demo admin password
    const admin = await User.findOne({ where: { email: 'admin@givingbridge.com' } });
    if (admin) {
      const adminHash = await bcrypt.hash('Admin1234', 12);
      await admin.update({ password: adminHash });
      console.log('✅ Updated demo admin password: admin@givingbridge.com / Admin1234');
    }

    // Update demo receiver password
    const receiver = await User.findOne({ where: { email: 'receiver@example.com' } });
    if (receiver) {
      const receiverHash = await bcrypt.hash('Receive1234', 12);
      await receiver.update({ password: receiverHash });
      console.log('✅ Updated demo receiver password: receiver@example.com / Receive1234');
    }

    console.log('🎉 Demo passwords updated successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error updating demo passwords:', error);
    process.exit(1);
  }
}

updateDemoPasswords();
