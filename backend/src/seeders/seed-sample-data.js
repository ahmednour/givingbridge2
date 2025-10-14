const User = require('../models/User');
const Donation = require('../models/Donation');
const Request = require('../models/Request');
const Message = require('../models/Message');
const { sequelize } = require('../config/db');

async function seedSampleData() {
  try {
    await sequelize.sync();

    console.log('🌱 Seeding sample donations, requests, and messages...');

    // Get the demo users
    const donor = await User.findOne({ where: { email: 'demo@example.com' } });
    const receiver = await User.findOne({ where: { email: 'receiver@example.com' } });
    const admin = await User.findOne({ where: { email: 'admin@givingbridge.com' } });

    if (!donor || !receiver || !admin) {
      console.error('❌ Demo users not found. Please run seed-demo-users.js first');
      process.exit(1);
    }

    // Check if messages already exist
    const existingMessages = await Message.count();
    if (existingMessages > 0) {
      console.log('✅ Sample messages already exist, skipping seed');
      process.exit(0);
    }

    // Create sample donations
    const donation1 = await Donation.create({
      title: 'Winter Clothes Collection',
      description: 'Gently used winter jackets, sweaters, and warm clothing for all ages. All items are clean and in good condition.',
      category: 'clothes',
      condition: 'good',
      location: 'New York, NY',
      donorId: donor.id,
      donorName: donor.name,
      imageUrl: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500',
      isAvailable: true,
      status: 'available'
    });
    console.log('✅ Created donation: Winter Clothes Collection');

    const donation2 = await Donation.create({
      title: 'Books for Students',
      description: 'Collection of textbooks, novels, and educational materials. Perfect for students and book lovers.',
      category: 'books',
      condition: 'like-new',
      location: 'New York, NY',
      donorId: donor.id,
      donorName: donor.name,
      imageUrl: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500',
      isAvailable: true,
      status: 'available'
    });
    console.log('✅ Created donation: Books for Students');

    const donation3 = await Donation.create({
      title: 'Fresh Groceries',
      description: 'Non-perishable food items including canned goods, pasta, rice, and snacks.',
      category: 'food',
      condition: 'new',
      location: 'New York, NY',
      donorId: donor.id,
      donorName: donor.name,
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500',
      isAvailable: true,
      status: 'available'
    });
    console.log('✅ Created donation: Fresh Groceries');

    const donation4 = await Donation.create({
      title: 'Laptop and Electronics',
      description: 'Working laptop, tablet, and accessories. Great for students or remote work.',
      category: 'electronics',
      condition: 'good',
      location: 'San Francisco, CA',
      donorId: admin.id,
      donorName: admin.name,
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500',
      isAvailable: true,
      status: 'available'
    });
    console.log('✅ Created donation: Laptop and Electronics');

    // Create sample requests
    const request1 = await Request.create({
      donationId: donation1.id,
      donorId: donor.id,
      donorName: donor.name,
      receiverId: receiver.id,
      receiverName: receiver.name,
      receiverEmail: receiver.email,
      receiverPhone: receiver.phone,
      message: 'Hi! I would really appreciate these winter clothes for my family. We recently moved to the area and could use the warm clothing.',
      status: 'pending'
    });
    console.log('✅ Created request for Winter Clothes Collection');

    const request2 = await Request.create({
      donationId: donation2.id,
      donorId: donor.id,
      donorName: donor.name,
      receiverId: receiver.id,
      receiverName: receiver.name,
      receiverEmail: receiver.email,
      receiverPhone: receiver.phone,
      message: 'Hello! I am a student and would love to have these books for my studies. Thank you for your generosity!',
      status: 'approved',
      respondedAt: new Date()
    });
    console.log('✅ Created request for Books for Students');

    // Create sample messages
    await Message.create({
      senderId: receiver.id,
      senderName: receiver.name,
      receiverId: donor.id,
      receiverName: donor.name,
      donationId: donation1.id,
      requestId: request1.id,
      content: 'Hi! I saw your winter clothes donation. Is it still available?'
    });

    await Message.create({
      senderId: donor.id,
      senderName: donor.name,
      receiverId: receiver.id,
      receiverName: receiver.name,
      donationId: donation1.id,
      requestId: request1.id,
      content: 'Yes, it is! When would you like to pick it up?'
    });

    await Message.create({
      senderId: receiver.id,
      senderName: receiver.name,
      receiverId: donor.id,
      receiverName: donor.name,
      donationId: donation1.id,
      requestId: request1.id,
      content: 'Great! Would tomorrow afternoon work for you?',
      isRead: false
    });

    await Message.create({
      senderId: donor.id,
      senderName: donor.name,
      receiverId: receiver.id,
      receiverName: receiver.name,
      donationId: donation2.id,
      requestId: request2.id,
      content: 'The books are ready for pickup. Let me know when you can come by.'
    });

    await Message.create({
      senderId: receiver.id,
      senderName: receiver.name,
      receiverId: donor.id,
      receiverName: donor.name,
      donationId: donation2.id,
      requestId: request2.id,
      content: 'Thank you so much! I can pick them up this weekend.',
      isRead: false
    });

    console.log('✅ Created 5 sample messages');

    console.log('🎉 Sample data seeded successfully!');
    console.log('\nSummary:');
    console.log('- 4 donations created');
    console.log('- 2 requests created');
    console.log('- 5 messages created');
    console.log('\nYou can now test the messaging and profile screens!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding sample data:', error);
    process.exit(1);
  }
}

seedSampleData();
