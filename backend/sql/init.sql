-- ================================================
-- GivingBridge Database Initialization Script
-- Version: 1.0.2 (Updated Password Requirements)
-- Created by: Ahmed Hussein Nour
-- Description: Schema + Sample Data for Testing
-- 
-- Demo User Credentials:
-- - Admin: admin@givingbridge.com / Admin1234
-- - Donor: demo@example.com / Demo1234
-- - Receiver: receiver@example.com / Receive1234
-- - Arabic Donor: ahmed.donor@example.com / Demo1234
-- - Arabic Receiver: fatimah.receiver@example.com / Receive1234
-- - Charities: najran.charity@example.com, alwafa.charity@example.com / Charity1234
--
-- Password Requirements: 8+ characters, at least 1 uppercase letter
-- ================================================

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'donor', 'receiver') DEFAULT 'donor',
    phone VARCHAR(20),
    location VARCHAR(255),
    avatarUrl VARCHAR(500),
    fcmToken VARCHAR(500),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create donations table
CREATE TABLE IF NOT EXISTS donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    `condition` VARCHAR(50) NOT NULL,
    location VARCHAR(255) NOT NULL,
    imageUrl VARCHAR(500),
    donorId INT NOT NULL,
    donorName VARCHAR(255) NOT NULL,
    isAvailable BOOLEAN DEFAULT TRUE,
    status ENUM('available', 'pending', 'completed', 'cancelled') DEFAULT 'available',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donorId) REFERENCES users(id) ON DELETE CASCADE
);

-- Create requests table
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donationId INT NOT NULL,
    donorId INT NOT NULL,
    donorName VARCHAR(255),
    receiverId INT NOT NULL,
    receiverName VARCHAR(255) NOT NULL,
    receiverEmail VARCHAR(255) NOT NULL,
    receiverPhone VARCHAR(20),
    message TEXT,
    status ENUM('pending', 'approved', 'declined', 'completed', 'cancelled') DEFAULT 'pending',
    respondedAt TIMESTAMP NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donationId) REFERENCES donations(id) ON DELETE CASCADE,
    FOREIGN KEY (donorId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiverId) REFERENCES users(id) ON DELETE CASCADE
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    senderId INT NOT NULL,
    receiverId INT NOT NULL,
    donationId INT,
    requestId INT,
    content TEXT NOT NULL,
    messageType ENUM('text', 'image', 'file') DEFAULT 'text',
    isRead BOOLEAN DEFAULT FALSE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (senderId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiverId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (donationId) REFERENCES donations(id) ON DELETE SET NULL,
    FOREIGN KEY (requestId) REFERENCES requests(id) ON DELETE SET NULL
);

-- ================================================
-- Sample Data Section
-- ================================================

-- إدراج مستخدم المدير الافتراضي (كلمة المرور: Admin1234)
INSERT IGNORE INTO users (name, email, password, role) VALUES 
('المشرف العام', 'admin@givingbridge.com', '$2a$12$UFHbTU8jM4PF17KczDt8Yu1OzUn.LirtfWsGZQTI4rsN1GSqensqi', 'admin');

-- إدراج مستخدم متبرع تجريبي (كلمة المرور: Demo1234)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('Demo Donor', 'demo@example.com', '$2a$12$yAbUH55D4URG0BFM8ZDpy.QxrVstYO1MAGCxnTd9dNAB9bEdI7gRO', 'donor', '+1234567890', 'New York, NY');

-- إدراج مستخدم مستفيد تجريبي (كلمة المرور: Receive1234)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('Demo Receiver', 'receiver@example.com', '$2a$12$s32sOrjNTAOcO195J8yJZu0.mj0mxNdC6JIATs7ef0qZx9SHxQ5S.', 'receiver', '+1234567892', 'Los Angeles, CA');

-- إدراج مستخدم متبرع فردي (كلمة المرور: Demo1234)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('المتبرع أحمد', 'ahmed.donor@example.com', '$2a$12$yAbUH55D4URG0BFM8ZDpy.QxrVstYO1MAGCxnTd9dNAB9bEdI7gRO', 'donor', '+966505111111', 'نجران، المملكة العربية السعودية');

-- إدراج مستخدم مستفيد فردي (كلمة المرور: Receive1234)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('المستفيد فاطمة', 'fatimah.receiver@example.com', '$2a$12$s32sOrjNTAOcO195J8yJZu0.mj0mxNdC6JIATs7ef0qZx9SHxQ5S.', 'receiver', '+966506222222', 'أبها، المملكة العربية السعودية');

-- إدراج منظمات خيرية كمستفيدين مؤسسيين (كلمة المرور: Charity1234)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('جمعية البر بنجران', 'najran.charity@example.com', '$2a$12$L7qg.Ubw9e8O8L.OjOMHu.0lyDNQhDSB1.jmrFpnMalPV7kz1Ao36', 'receiver', '+966507333333', 'نجران، المملكة العربية السعودية'),
('جمعية الوفاء الخيرية', 'alwafa.charity@example.com', '$2a$12$L7qg.Ubw9e8O8L.OjOMHu.0lyDNQhDSB1.jmrFpnMalPV7kz1Ao36', 'receiver', '+966508444444', 'جدة، المملكة العربية السعودية');

-- إدراج تبرعات تجريبية
INSERT IGNORE INTO donations (title, description, category, `condition`, location, donorId, donorName) VALUES 
('كتب دراسية قديمة', 'مجموعة من الكتب الدراسية والقصص الأدبية بحالة ممتازة تصلح للطلاب.', 'كتب', 'جيدة', 'نجران، المملكة العربية السعودية', 2, 'المتبرع أحمد'),
('ملابس شتوية دافئة', 'مجموعة من المعاطف والكنزات الشتوية بحالة جديدة تقريبًا.', 'ملابس', 'ممتازة', 'نجران، المملكة العربية السعودية', 2, 'المتبرع أحمد'),
('أجهزة منزلية صغيرة', 'خلاط كهربائي ومحماصة خبز ومكواة بحالة جيدة.', 'أجهزة منزلية', 'جيدة', 'أبها، المملكة العربية السعودية', 2, 'المتبرع أحمد'),
('بطانيات وأغطية', 'عدد من البطانيات الجديدة لتوزيعها على الأسر المحتاجة في الشتاء.', 'مساعدات', 'ممتازة', 'نجران، المملكة العربية السعودية', 2, 'المتبرع أحمد');

-- إدراج طلبات تجريبية من الأفراد والمنظمات
INSERT IGNORE INTO requests (donationId, donorId, donorName, receiverId, receiverName, receiverEmail, receiverPhone, message, status) VALUES 
(1, 2, 'المتبرع أحمد', 3, 'المستفيد فاطمة', 'fatimah.receiver@example.com', '+966506222222', 'أحتاج هذه الكتب لدعم أطفالي في دراستهم، جزاكم الله خيرًا.', 'pending'),
(2, 2, 'المتبرع أحمد', 3, 'المستفيد فاطمة', 'fatimah.receiver@example.com', '+966506222222', 'هذه الملابس ستكون مفيدة جدًا لعائلتي مع اقتراب الشتاء.', 'pending'),
(4, 2, 'المتبرع أحمد', 4, 'جمعية البر بنجران', 'najran.charity@example.com', '+966507333333', 'نرغب في استلام هذه البطانيات لتوزيعها على الأسر المحتاجة في القرى المجاورة.', 'pending'),
(3, 2, 'المتبرع أحمد', 5, 'جمعية الوفاء الخيرية', 'alwafa.charity@example.com', '+966508444444', 'هذه الأجهزة مناسبة للأسر التي يتم تجهيز مساكنها ضمن مبادرة “بيت الخير”.', 'pending');

-- إدراج رسائل تجريبية بين المستخدمين
INSERT IGNORE INTO messages (senderId, receiverId, donationId, requestId, content, messageType) VALUES
(2, 3, 1, 1, 'مرحبًا أخت فاطمة، يمكننا ترتيب موعد لتسليم الكتب غدًا إن شاء الله.', 'text'),
(3, 2, 1, 1, 'شكرًا جزيلًا، الموعد مناسب جدًا، جزاكم الله خيرًا.', 'text'),
(2, 4, 4, 3, 'نحن جاهزون لتسليم البطانيات للجمعية الأسبوع القادم.', 'text'),
(4, 2, 4, 3, 'شكرًا لكم، سنرسل فريقنا للاستلام يوم الاثنين القادم بإذن الله.', 'text');

-- ================================================
-- End of Initialization Script
-- ================================================
