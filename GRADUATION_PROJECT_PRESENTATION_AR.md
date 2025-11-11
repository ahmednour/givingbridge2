# شرح مشروع التخرج - منصة GivingBridge للتبرعات

## 📋 نظرة عامة على المشروع

**اسم المشروع:** GivingBridge - منصة التبرعات الشاملة  
**الهدف:** ربط المتبرعين بالمستفيدين من خلال منصة إلكترونية آمنة وسهلة الاستخدام  
**التقنيات المستخدمة:** 
- Backend: Node.js + Express.js
- Frontend: Flutter Web
- Database: MySQL 8.0
- Real-time Communication: Socket.IO

---

## 🎯 أهداف المشروع

### الأهداف الرئيسية:
1. **تسهيل عملية التبرع**: توفير منصة سهلة للمتبرعين لعرض تبرعاتهم
2. **ربط المحتاجين**: مساعدة المستفيدين في الوصول للتبرعات المناسبة
3. **الشفافية والأمان**: نظام موافقة إداري لضمان جودة التبرعات
4. **التواصل المباشر**: نظام مراسلة فورية بين المتبرعين والمستفيدين

### المشاكل التي يحلها المشروع:
- صعوبة التواصل بين المتبرعين والمحتاجين
- عدم وجود منصة موثوقة للتبرعات العينية
- غياب الشفافية في عمليات التبرع
- صعوبة متابعة حالة التبرعات

---

## 👥 أنواع المستخدمين (User Roles)

### 1. المتبرع (Donor)
**الصلاحيات:**
- إنشاء تبرعات جديدة (تخضع لموافقة المشرف)
- عرض تبرعاته وحالة الموافقة عليها
- استقبال طلبات من المستفيدين
- الموافقة أو رفض الطلبات
- التواصل مع المستفيدين عبر الرسائل

**حالات التبرع:**
- ⏳ Pending: في انتظار موافقة المشرف
- ✅ Approved: تمت الموافقة ومرئي للجميع
- ❌ Rejected: مرفوض مع ذكر السبب

### 2. المستفيد (Receiver)
**الصلاحيات:**
- تصفح التبرعات المعتمدة
- طلب التبرعات المناسبة
- متابعة حالة الطلبات
- التواصل مع المتبرعين
- إلغاء الطلبات قبل الموافقة عليها

### 3. المشرف (Admin)
**الصلاحيات:**
- مراجعة التبرعات المعلقة
- الموافقة على التبرعات أو رفضها
- إدارة المستخدمين
- عرض الإحصائيات والتقارير
- مراقبة النظام بالكامل


---

## 🗄️ قاعدة البيانات (Database Schema)

### نظرة عامة على الجداول:
المشروع يستخدم **MySQL 8.0** مع **4 جداول رئيسية** مترابطة

### 1. جدول المستخدمين (users)

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'donor', 'receiver') DEFAULT 'donor',
    phone VARCHAR(20),
    location VARCHAR(255),
    avatarUrl VARCHAR(500),
    isEmailVerified BOOLEAN DEFAULT FALSE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**الحقول المهمة:**
- `id`: المعرف الفريد للمستخدم
- `email`: البريد الإلكتروني (فريد لكل مستخدم)
- `password`: كلمة المرور المشفرة (bcrypt)
- `role`: دور المستخدم (متبرع/مستفيد/مشرف)
- `location`: الموقع الجغرافي للمستخدم

**الفهارس (Indexes):**
- فهرس فريد على `email` لضمان عدم التكرار
- فهرس على `role` لتسريع الاستعلامات

### 2. جدول التبرعات (donations)

```sql
CREATE TABLE donations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category ENUM('food', 'clothes', 'books', 'electronics', 'other'),
    condition ENUM('new', 'like-new', 'good', 'fair'),
    location VARCHAR(255) NOT NULL,
    imageUrl VARCHAR(500),
    donorId INT NOT NULL,
    donorName VARCHAR(255) NOT NULL,
    isAvailable BOOLEAN DEFAULT TRUE,
    status ENUM('available', 'pending', 'completed', 'cancelled'),
    approvalStatus ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    approvedBy INT,
    approvedAt TIMESTAMP,
    rejectionReason TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donorId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approvedBy) REFERENCES users(id)
);
```

**الحقول المهمة:**
- `donorId`: ربط مع جدول المستخدمين (المتبرع)
- `category`: تصنيف التبرع (طعام، ملابس، كتب، إلكترونيات، أخرى)
- `condition`: حالة التبرع (جديد، شبه جديد، جيد، مقبول)
- `approvalStatus`: حالة الموافقة (معلق، معتمد، مرفوض)
- `approvedBy`: المشرف الذي وافق على التبرع
- `rejectionReason`: سبب الرفض (إن وجد)

**العلاقات:**
- علاقة Many-to-One مع `users` (المتبرع)
- علاقة Many-to-One مع `users` (المشرف الموافق)
- علاقة One-to-Many مع `requests`


### 3. جدول الطلبات (requests)

```sql
CREATE TABLE requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    donationId INT NOT NULL,
    donorId INT NOT NULL,
    donorName VARCHAR(255),
    receiverId INT NOT NULL,
    receiverName VARCHAR(255) NOT NULL,
    receiverEmail VARCHAR(255) NOT NULL,
    receiverPhone VARCHAR(20),
    message TEXT,
    status ENUM('pending', 'approved', 'declined', 'completed', 'cancelled'),
    respondedAt TIMESTAMP,
    attachmentUrl VARCHAR(500),
    attachmentName VARCHAR(255),
    attachmentSize INT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donationId) REFERENCES donations(id) ON DELETE CASCADE,
    FOREIGN KEY (donorId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiverId) REFERENCES users(id) ON DELETE CASCADE
);
```

**الحقول المهمة:**
- `donationId`: التبرع المطلوب
- `donorId`: المتبرع صاحب التبرع
- `receiverId`: المستفيد الذي قدم الطلب
- `status`: حالة الطلب (معلق، موافق عليه، مرفوض، مكتمل، ملغي)
- `message`: رسالة من المستفيد للمتبرع
- `attachmentUrl`: مرفق صورة (اختياري)

**العلاقات:**
- علاقة Many-to-One مع `donations`
- علاقة Many-to-One مع `users` (المتبرع)
- علاقة Many-to-One مع `users` (المستفيد)

### 4. جدول الرسائل (messages)

```sql
CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    senderId INT NOT NULL,
    senderName VARCHAR(255) NOT NULL,
    receiverId INT NOT NULL,
    receiverName VARCHAR(255) NOT NULL,
    donationId INT,
    requestId INT,
    content TEXT NOT NULL,
    messageType ENUM('text', 'image', 'file') DEFAULT 'text',
    isRead BOOLEAN DEFAULT FALSE,
    attachmentUrl VARCHAR(500),
    attachmentName VARCHAR(255),
    attachmentType VARCHAR(50),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (senderId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiverId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (donationId) REFERENCES donations(id) ON DELETE SET NULL,
    FOREIGN KEY (requestId) REFERENCES requests(id) ON DELETE SET NULL
);
```

**الحقول المهمة:**
- `senderId`: المرسل
- `receiverId`: المستقبل
- `donationId`: التبرع المرتبط (اختياري)
- `requestId`: الطلب المرتبط (اختياري)
- `messageType`: نوع الرسالة (نص، صورة، ملف)
- `isRead`: هل تم قراءة الرسالة

**العلاقات:**
- علاقة Many-to-One مع `users` (المرسل)
- علاقة Many-to-One مع `users` (المستقبل)
- علاقة Many-to-One مع `donations` (اختياري)
- علاقة Many-to-One مع `requests` (اختياري)

---

## 🔗 العلاقات بين الجداول (Database Relationships)

### مخطط العلاقات (ERD):

```
┌─────────────┐
│   users     │
│  (id, name, │
│   email,    │
│   role)     │
└──────┬──────┘
       │
       ├──────────────────────────────────┐
       │                                  │
       │ 1:N (donor)                      │ 1:N (receiver)
       │                                  │
       ▼                                  ▼
┌─────────────┐                    ┌─────────────┐
│  donations  │ 1:N                │  requests   │
│  (id,       │◄───────────────────┤  (id,       │
│   donorId,  │                    │   donationId│
│   approval) │                    │   receiverId│
└──────┬──────┘                    └──────┬──────┘
       │                                  │
       │ 1:N                              │ 1:N
       │                                  │
       ▼                                  ▼
┌─────────────────────────────────────────┐
│              messages                   │
│  (id, senderId, receiverId,             │
│   donationId, requestId)                │
└─────────────────────────────────────────┘
```

### شرح العلاقات:

1. **User → Donations (1:N)**
   - كل مستخدم (متبرع) يمكنه إنشاء عدة تبرعات
   - كل تبرع ينتمي لمتبرع واحد فقط

2. **User → Requests (1:N) - كمستفيد**
   - كل مستخدم (مستفيد) يمكنه إنشاء عدة طلبات
   - كل طلب ينتمي لمستفيد واحد فقط

3. **User → Requests (1:N) - كمتبرع**
   - كل متبرع يستقبل عدة طلبات على تبرعاته
   - كل طلب يرتبط بمتبرع واحد

4. **Donation → Requests (1:N)**
   - كل تبرع يمكن أن يستقبل عدة طلبات
   - كل طلب يرتبط بتبرع واحد فقط

5. **User → Messages (1:N) - كمرسل**
   - كل مستخدم يمكنه إرسال عدة رسائل
   - كل رسالة لها مرسل واحد فقط

6. **User → Messages (1:N) - كمستقبل**
   - كل مستخدم يمكنه استقبال عدة رسائل
   - كل رسالة لها مستقبل واحد فقط

7. **Donation → Messages (1:N)**
   - كل تبرع يمكن أن يرتبط بعدة رسائل
   - كل رسالة يمكن أن ترتبط بتبرع واحد (اختياري)

8. **Request → Messages (1:N)**
   - كل طلب يمكن أن يرتبط بعدة رسائل
   - كل رسالة يمكن أن ترتبط بطلب واحد (اختياري)


---

## 🔧 Backend Architecture (Node.js + Express)

### البنية العامة:

```
backend/
├── src/
│   ├── config/          # إعدادات التطبيق والاتصال بقاعدة البيانات
│   ├── controllers/     # منطق الأعمال (Business Logic)
│   ├── models/          # نماذج قاعدة البيانات (Sequelize ORM)
│   ├── routes/          # مسارات API (Endpoints)
│   ├── middleware/      # الوسائط (Authentication, Validation, etc.)
│   ├── services/        # الخدمات (Email, Notifications, Search)
│   ├── utils/           # أدوات مساعدة
│   ├── migrations/      # ملفات الترحيل لقاعدة البيانات
│   └── server.js        # نقطة البداية للتطبيق
├── uploads/             # ملفات الصور المرفوعة
├── .env                 # متغيرات البيئة
└── package.json         # التبعيات والإعدادات
```

### التقنيات المستخدمة في Backend:

1. **Express.js**: إطار عمل لبناء API
2. **Sequelize ORM**: للتعامل مع قاعدة البيانات
3. **JWT (JSON Web Tokens)**: للمصادقة والتفويض
4. **Bcrypt**: لتشفير كلمات المرور
5. **Socket.IO**: للمراسلة الفورية
6. **Multer**: لرفع الملفات
7. **Express-Validator**: للتحقق من صحة البيانات
8. **Helmet**: لتأمين HTTP Headers
9. **CORS**: للسماح بالطلبات من مصادر مختلفة

### المكونات الرئيسية:

#### 1. Models (النماذج)

**User Model:**
```javascript
const User = sequelize.define('User', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  email: { type: DataTypes.STRING, unique: true, allowNull: false },
  password: { type: DataTypes.STRING, allowNull: false },
  role: { type: DataTypes.ENUM('donor', 'receiver', 'admin'), defaultValue: 'donor' },
  phone: { type: DataTypes.STRING },
  location: { type: DataTypes.STRING },
  avatarUrl: { type: DataTypes.STRING }
});
```

**Donation Model:**
```javascript
const Donation = sequelize.define('Donation', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  title: { type: DataTypes.STRING, allowNull: false },
  description: { type: DataTypes.TEXT, allowNull: false },
  category: { type: DataTypes.ENUM('food', 'clothes', 'books', 'electronics', 'other') },
  condition: { type: DataTypes.ENUM('new', 'like-new', 'good', 'fair') },
  location: { type: DataTypes.STRING, allowNull: false },
  donorId: { type: DataTypes.INTEGER, allowNull: false },
  approvalStatus: { type: DataTypes.ENUM('pending', 'approved', 'rejected'), defaultValue: 'pending' },
  approvedBy: { type: DataTypes.INTEGER },
  rejectionReason: { type: DataTypes.TEXT }
});
```

#### 2. Controllers (المتحكمات)

**AuthController:**
- `register()`: تسجيل مستخدم جديد
- `login()`: تسجيل الدخول
- `verifyToken()`: التحقق من صحة JWT Token
- `getProfile()`: الحصول على بيانات المستخدم

**DonationController:**
- `createDonation()`: إنشاء تبرع جديد (حالة pending)
- `getAllDonations()`: عرض التبرعات (المعتمدة فقط للمستخدمين العاديين)
- `getDonationById()`: عرض تفاصيل تبرع
- `updateDonation()`: تعديل تبرع
- `deleteDonation()`: حذف تبرع
- `approveDonation()`: موافقة المشرف على التبرع
- `rejectDonation()`: رفض المشرف للتبرع
- `getPendingDonations()`: عرض التبرعات المعلقة (للمشرف فقط)

**RequestController:**
- `createRequest()`: إنشاء طلب تبرع
- `getAllRequests()`: عرض الطلبات
- `updateRequestStatus()`: تحديث حالة الطلب (موافقة/رفض)
- `deleteRequest()`: حذف طلب

**MessageController:**
- `sendMessage()`: إرسال رسالة
- `getConversation()`: عرض المحادثة بين مستخدمين
- `markAsRead()`: تحديد الرسالة كمقروءة


#### 3. Routes (المسارات - API Endpoints)

### Authentication Routes (`/api/auth`)

| Method | Endpoint | الوصف | المصادقة |
|--------|----------|-------|----------|
| POST | `/api/auth/register` | تسجيل مستخدم جديد | لا |
| POST | `/api/auth/login` | تسجيل الدخول | لا |
| GET | `/api/auth/me` | الحصول على بيانات المستخدم الحالي | نعم |
| POST | `/api/auth/logout` | تسجيل الخروج | نعم |

### Donations Routes (`/api/donations`)

| Method | Endpoint | الوصف | المصادقة | الصلاحية |
|--------|----------|-------|----------|---------|
| GET | `/api/donations` | عرض جميع التبرعات | لا | الجميع |
| GET | `/api/donations/:id` | عرض تبرع محدد | لا | الجميع |
| POST | `/api/donations` | إنشاء تبرع جديد | نعم | Donor |
| PUT | `/api/donations/:id` | تعديل تبرع | نعم | Donor/Admin |
| DELETE | `/api/donations/:id` | حذف تبرع | نعم | Donor/Admin |
| GET | `/api/donations/user/my-donations` | تبرعاتي | نعم | Donor |
| GET | `/api/donations/admin/pending` | التبرعات المعلقة | نعم | Admin |
| PUT | `/api/donations/:id/approve` | الموافقة على تبرع | نعم | Admin |
| PUT | `/api/donations/:id/reject` | رفض تبرع | نعم | Admin |

### Requests Routes (`/api/requests`)

| Method | Endpoint | الوصف | المصادقة | الصلاحية |
|--------|----------|-------|----------|---------|
| GET | `/api/requests` | عرض جميع الطلبات | نعم | الجميع |
| GET | `/api/requests/:id` | عرض طلب محدد | نعم | Donor/Receiver/Admin |
| POST | `/api/requests` | إنشاء طلب جديد | نعم | Receiver |
| PUT | `/api/requests/:id/status` | تحديث حالة الطلب | نعم | Donor/Receiver |
| DELETE | `/api/requests/:id` | حذف طلب | نعم | Receiver/Admin |
| GET | `/api/requests/receiver/my-requests` | طلباتي | نعم | Receiver |
| GET | `/api/requests/donor/incoming-requests` | الطلبات الواردة | نعم | Donor |

### Messages Routes (`/api/messages`)

| Method | Endpoint | الوصف | المصادقة |
|--------|----------|-------|----------|
| GET | `/api/messages` | عرض جميع المحادثات | نعم |
| GET | `/api/messages/:userId` | عرض محادثة مع مستخدم | نعم |
| POST | `/api/messages` | إرسال رسالة | نعم |
| PUT | `/api/messages/:id/read` | تحديد رسالة كمقروءة | نعم |

### Admin Routes (`/api/admin`)

| Method | Endpoint | الوصف | المصادقة | الصلاحية |
|--------|----------|-------|----------|---------|
| GET | `/api/admin/users` | عرض جميع المستخدمين | نعم | Admin |
| GET | `/api/admin/stats` | إحصائيات النظام | نعم | Admin |
| PUT | `/api/admin/users/:id/role` | تغيير دور مستخدم | نعم | Admin |
| DELETE | `/api/admin/users/:id` | حذف مستخدم | نعم | Admin |

#### 4. Middleware (الوسائط)

**Authentication Middleware:**
```javascript
const authenticateToken = async (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Token required' });
  
  try {
    const user = await AuthController.verifyToken(token);
    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Invalid token' });
  }
};
```

**Admin Authorization Middleware:**
```javascript
const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
};
```

**Validation Middleware:**
- التحقق من صحة البيانات المدخلة
- التحقق من صيغة البريد الإلكتروني
- التحقق من قوة كلمة المرور
- تنظيف المدخلات من XSS

**Rate Limiting:**
- تحديد عدد الطلبات لكل IP
- حماية من هجمات DDoS
- حماية endpoints الحساسة

#### 5. Services (الخدمات)

**Email Service:**
- إرسال إشعارات البريد الإلكتروني
- إشعار الموافقة على التبرع
- إشعار رفض التبرع
- إشعار استلام طلب جديد

**Notification Service:**
- إدارة الإشعارات داخل التطبيق
- إرسال إشعارات فورية
- تتبع حالة الإشعارات

**Search Service:**
- البحث في التبرعات
- البحث في الطلبات
- فلترة النتائج حسب الفئة والموقع


---

## 🎨 Frontend Architecture (Flutter Web)

### البنية العامة:

```
frontend/lib/
├── core/
│   ├── config/          # إعدادات التطبيق
│   ├── constants/       # الثوابت
│   ├── routes/          # نظام التوجيه
│   ├── theme/           # الألوان والتصميم
│   └── utils/           # أدوات مساعدة
├── models/              # نماذج البيانات (Data Models)
├── providers/           # إدارة الحالة (State Management)
├── repositories/        # طبقة الوصول للبيانات
├── services/            # الخدمات (API, Socket, etc.)
├── screens/             # شاشات التطبيق
├── widgets/             # مكونات واجهة المستخدم القابلة لإعادة الاستخدام
├── l10n/                # الترجمة (العربية والإنجليزية)
└── main.dart            # نقطة البداية
```

### التقنيات المستخدمة في Frontend:

1. **Flutter 3.0+**: إطار عمل لبناء واجهات المستخدم
2. **Provider**: لإدارة الحالة (State Management)
3. **HTTP Package**: للاتصال بـ API
4. **Socket.IO Client**: للمراسلة الفورية
5. **Shared Preferences**: لحفظ البيانات محلياً
6. **Image Picker**: لاختيار الصور
7. **Intl**: للترجمة ودعم اللغات المتعددة

### المكونات الرئيسية:

#### 1. Models (النماذج)

**User Model:**
```dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? location;
  final String? avatarUrl;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.location,
    this.avatarUrl,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      location: json['location'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
```

**Donation Model:**
```dart
class Donation {
  final int id;
  final String title;
  final String description;
  final String category;
  final String condition;
  final String location;
  final String? imageUrl;
  final int donorId;
  final String donorName;
  final bool isAvailable;
  final String status;
  final String approvalStatus;
  final String? rejectionReason;
  final DateTime createdAt;
  
  Donation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.location,
    this.imageUrl,
    required this.donorId,
    required this.donorName,
    required this.isAvailable,
    required this.status,
    required this.approvalStatus,
    this.rejectionReason,
    required this.createdAt,
  });
  
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      condition: json['condition'],
      location: json['location'],
      imageUrl: json['imageUrl'],
      donorId: json['donorId'],
      donorName: json['donorName'],
      isAvailable: json['isAvailable'],
      status: json['status'],
      approvalStatus: json['approvalStatus'],
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

#### 2. Providers (إدارة الحالة)

**AuthProvider:**
```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.login(email, password);
      _user = User.fromJson(response['user']);
      _token = response['token'];
      await _saveToken(_token!);
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _user = null;
    _token = null;
    await _clearToken();
    notifyListeners();
  }
}
```

**DonationProvider:**
```dart
class DonationProvider extends ChangeNotifier {
  List<Donation> _donations = [];
  bool _isLoading = false;
  
  List<Donation> get donations => _donations;
  bool get isLoading => _isLoading;
  
  Future<void> fetchDonations() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getDonations();
      _donations = (response['donations'] as List)
          .map((json) => Donation.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch donations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createDonation(Map<String, dynamic> data) async {
    try {
      await ApiService.createDonation(data);
      await fetchDonations();
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }
}
```


#### 3. Services (الخدمات)

**API Service:**
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }
  
  static Future<Map<String, dynamic>> getDonations() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/donations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch donations');
    }
  }
}
```

**Socket Service:**
```dart
class SocketService {
  static IO.Socket? _socket;
  
  static void connect(String token) {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
    });
    
    _socket?.connect();
    
    _socket?.on('connect', (_) {
      print('Connected to socket server');
    });
    
    _socket?.on('new_message', (data) {
      // Handle incoming message
      print('New message: $data');
    });
  }
  
  static void sendMessage(Map<String, dynamic> message) {
    _socket?.emit('send_message', message);
  }
  
  static void disconnect() {
    _socket?.disconnect();
  }
}
```

#### 4. Screens (الشاشات)

**الشاشات الرئيسية:**

1. **Landing Screen**: الصفحة الرئيسية للزوار
2. **Login Screen**: شاشة تسجيل الدخول
3. **Register Screen**: شاشة التسجيل
4. **Dashboard Screen**: لوحة التحكم الرئيسية (تختلف حسب الدور)
5. **Browse Donations Screen**: تصفح التبرعات
6. **Create Donation Screen**: إنشاء تبرع جديد
7. **My Donations Screen**: تبرعاتي
8. **Incoming Requests Screen**: الطلبات الواردة (للمتبرع)
9. **My Requests Screen**: طلباتي (للمستفيد)
10. **Messages Screen**: الرسائل
11. **Chat Screen**: شاشة المحادثة
12. **Profile Screen**: الملف الشخصي
13. **Admin Dashboard**: لوحة تحكم المشرف
14. **Admin Pending Donations**: التبرعات المعلقة (للمشرف)
15. **Admin Users Screen**: إدارة المستخدمين

**مثال على شاشة Dashboard:**
```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // عرض لوحة تحكم مختلفة حسب دور المستخدم
    if (user?.role == 'admin') {
      return AdminDashboard();
    } else if (user?.role == 'donor') {
      return DonorDashboard();
    } else if (user?.role == 'receiver') {
      return ReceiverDashboard();
    }
    
    return LandingScreen();
  }
}
```

#### 5. Widgets (المكونات القابلة لإعادة الاستخدام)

**DonationCard Widget:**
```dart
class DonationCard extends StatelessWidget {
  final Donation donation;
  final VoidCallback? onTap;
  
  const DonationCard({
    required this.donation,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // صورة التبرع
            if (donation.imageUrl != null)
              Image.network(donation.imageUrl!),
            
            // معلومات التبرع
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donation.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(donation.description),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Text(donation.location),
                    ],
                  ),
                  // حالة الموافقة
                  if (donation.approvalStatus == 'pending')
                    Chip(label: Text('⏳ Pending Approval')),
                  if (donation.approvalStatus == 'approved')
                    Chip(label: Text('✅ Approved')),
                  if (donation.approvalStatus == 'rejected')
                    Chip(label: Text('❌ Rejected')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 6. Localization (الترجمة)

**دعم اللغتين العربية والإنجليزية:**

```dart
// app_en.arb (English)
{
  "appTitle": "Giving Bridge",
  "login": "Login",
  "register": "Register",
  "donations": "Donations",
  "myDonations": "My Donations",
  "createDonation": "Create Donation",
  "pendingApproval": "Pending Approval",
  "approved": "Approved",
  "rejected": "Rejected"
}

// app_ar.arb (Arabic)
{
  "appTitle": "جسر العطاء",
  "login": "تسجيل الدخول",
  "register": "التسجيل",
  "donations": "التبرعات",
  "myDonations": "تبرعاتي",
  "createDonation": "إنشاء تبرع",
  "pendingApproval": "في انتظار الموافقة",
  "approved": "معتمد",
  "rejected": "مرفوض"
}
```

**استخدام الترجمة:**
```dart
Text(AppLocalizations.of(context)!.appTitle)
```


---

## 🔄 سير العمل (Workflow)

### 1. سير عمل التسجيل والدخول

```
المستخدم
   │
   ├─► يفتح التطبيق
   │
   ├─► يختار "تسجيل جديد"
   │
   ├─► يدخل البيانات (الاسم، البريد، كلمة المرور، الدور)
   │
   ├─► Frontend يرسل POST /api/auth/register
   │
   ├─► Backend يتحقق من البيانات
   │
   ├─► Backend يشفر كلمة المرور (bcrypt)
   │
   ├─► Backend يحفظ المستخدم في قاعدة البيانات
   │
   ├─► Backend يُنشئ JWT Token
   │
   ├─► Backend يرسل Token + بيانات المستخدم
   │
   ├─► Frontend يحفظ Token محلياً
   │
   └─► المستخدم يُوجه إلى Dashboard
```

### 2. سير عمل إنشاء تبرع (مع نظام الموافقة)

```
المتبرع
   │
   ├─► يضغط "إنشاء تبرع جديد"
   │
   ├─► يملأ النموذج (العنوان، الوصف، الفئة، الموقع، الصورة)
   │
   ├─► Frontend يرسل POST /api/donations مع Token
   │
   ├─► Backend يتحقق من Token والصلاحيات
   │
   ├─► Backend يحفظ الصورة في /uploads
   │
   ├─► Backend يُنشئ التبرع بحالة "pending"
   │
   ├─► Backend يحفظ التبرع في قاعدة البيانات
   │
   ├─► Backend يرسل إشعار للمشرفين
   │
   ├─► المتبرع يرى رسالة "تبرعك في انتظار الموافقة"
   │
   │   [المشرف يراجع التبرع]
   │
   ├─► المشرف يضغط "موافقة" أو "رفض"
   │
   ├─► Frontend يرسل PUT /api/donations/:id/approve أو reject
   │
   ├─► Backend يحدث approvalStatus إلى "approved" أو "rejected"
   │
   ├─► Backend يحفظ approvedBy و approvedAt
   │
   ├─► Backend يرسل إشعار بريد إلكتروني للمتبرع
   │
   ├─► إذا تمت الموافقة: التبرع يظهر للجميع
   │
   └─► إذا تم الرفض: المتبرع يرى سبب الرفض
```

### 3. سير عمل طلب تبرع

```
المستفيد
   │
   ├─► يتصفح التبرعات المعتمدة
   │
   ├─► يختار تبرع مناسب
   │
   ├─► يضغط "طلب هذا التبرع"
   │
   ├─► يكتب رسالة للمتبرع (اختياري)
   │
   ├─► يرفق صورة (اختياري)
   │
   ├─► Frontend يرسل POST /api/requests
   │
   ├─► Backend يتحقق من:
   │   ├─ المستخدم receiver
   │   ├─ التبرع متاح
   │   └─ لم يطلبه من قبل
   │
   ├─► Backend يُنشئ الطلب بحالة "pending"
   │
   ├─► Backend يرسل إشعار للمتبرع
   │
   │   [المتبرع يراجع الطلب]
   │
   ├─► المتبرع يضغط "موافقة" أو "رفض"
   │
   ├─► Frontend يرسل PUT /api/requests/:id/status
   │
   ├─► Backend يحدث status إلى "approved" أو "declined"
   │
   ├─► Backend يحدث حالة التبرع:
   │   ├─ إذا موافقة: isAvailable = false
   │   └─ إذا رفض: isAvailable = true
   │
   ├─► Backend يرسل إشعار للمستفيد
   │
   ├─► المستفيد والمتبرع يتواصلان عبر الرسائل
   │
   └─► بعد التسليم: يحدثان الحالة إلى "completed"
```

### 4. سير عمل المراسلة الفورية

```
المستخدم A
   │
   ├─► يفتح شاشة المحادثة مع المستخدم B
   │
   ├─► Frontend يتصل بـ Socket.IO Server
   │
   ├─► Socket.IO يُنشئ اتصال WebSocket
   │
   ├─► المستخدم A يكتب رسالة
   │
   ├─► Frontend يرسل emit('send_message', data)
   │
   ├─► Socket.IO Server يستقبل الرسالة
   │
   ├─► Backend يحفظ الرسالة في قاعدة البيانات
   │
   ├─► Socket.IO يرسل emit('new_message') للمستخدم B
   │
   ├─► Frontend للمستخدم B يستقبل الرسالة
   │
   ├─► الرسالة تظهر فوراً في شاشة المحادثة
   │
   └─► عند فتح المحادثة: تُحدث isRead = true
```

### 5. سير عمل لوحة تحكم المشرف

```
المشرف
   │
   ├─► يسجل الدخول بحساب admin
   │
   ├─► يُوجه إلى Admin Dashboard
   │
   ├─► يرى الإحصائيات:
   │   ├─ عدد المستخدمين
   │   ├─ عدد التبرعات (معلقة/معتمدة/مرفوضة)
   │   ├─ عدد الطلبات
   │   └─ نشاط النظام
   │
   ├─► يضغط "التبرعات المعلقة"
   │
   ├─► Frontend يرسل GET /api/donations/admin/pending
   │
   ├─► Backend يتحقق من صلاحية admin
   │
   ├─► Backend يرسل التبرعات بحالة "pending"
   │
   ├─► المشرف يراجع كل تبرع:
   │   ├─ يرى الصورة والوصف
   │   ├─ يرى بيانات المتبرع
   │   └─ يقرر الموافقة أو الرفض
   │
   ├─► إذا موافقة:
   │   ├─ PUT /api/donations/:id/approve
   │   ├─ approvalStatus = "approved"
   │   ├─ التبرع يظهر للجميع
   │   └─ إشعار للمتبرع
   │
   └─► إذا رفض:
       ├─ PUT /api/donations/:id/reject
       ├─ approvalStatus = "rejected"
       ├─ يكتب سبب الرفض
       ├─ التبرع لا يظهر للجميع
       └─ إشعار للمتبرع مع السبب
```


---

## 🔒 الأمان والحماية (Security Features)

### 1. المصادقة والتفويض (Authentication & Authorization)

**JWT (JSON Web Tokens):**
```javascript
// إنشاء Token عند تسجيل الدخول
const token = jwt.sign(
  { userId: user.id, email: user.email, role: user.role },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);
```

**التحقق من Token:**
```javascript
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Token required' });
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid token' });
    req.user = user;
    next();
  });
};
```

### 2. تشفير كلمات المرور (Password Hashing)

**استخدام Bcrypt:**
```javascript
// عند التسجيل
const hashedPassword = await bcrypt.hash(password, 12);

// عند تسجيل الدخول
const isMatch = await bcrypt.compare(password, user.password);
```

### 3. التحقق من صحة البيانات (Input Validation)

**استخدام Express-Validator:**
```javascript
router.post('/register', [
  body('email').isEmail().withMessage('Invalid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('name').trim().notEmpty().withMessage('Name is required'),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  // معالجة التسجيل
});
```

### 4. حماية من XSS (Cross-Site Scripting)

**تنظيف المدخلات:**
```javascript
const sanitizeHtml = require('sanitize-html');

const sanitizeInput = (req, res, next) => {
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeHtml(req.body[key], {
          allowedTags: [],
          allowedAttributes: {}
        });
      }
    });
  }
  next();
};
```

### 5. CORS (Cross-Origin Resource Sharing)

**إعدادات CORS:**
```javascript
const cors = require('cors');

app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:8080',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### 6. Rate Limiting (تحديد معدل الطلبات)

**حماية من هجمات DDoS:**
```javascript
const rateLimit = require('express-rate-limit');

const generalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 دقيقة
  max: 100, // 100 طلب كحد أقصى
  message: 'Too many requests, please try again later'
});

app.use('/api/', generalRateLimit);
```

### 7. Helmet (تأمين HTTP Headers)

```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"]
    }
  }
}));
```

### 8. حماية قاعدة البيانات

**استخدام Sequelize ORM:**
- حماية من SQL Injection
- Parameterized Queries
- التحقق من أنواع البيانات

**مثال:**
```javascript
// آمن - يستخدم Parameterized Query
const user = await User.findOne({ where: { email: email } });

// غير آمن - عرضة لـ SQL Injection
// const user = await sequelize.query(`SELECT * FROM users WHERE email = '${email}'`);
```

### 9. التحكم في الصلاحيات (Role-Based Access Control)

**Middleware للتحقق من الصلاحيات:**
```javascript
const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
};

const requireDonor = (req, res, next) => {
  if (req.user.role !== 'donor') {
    return res.status(403).json({ message: 'Donor access required' });
  }
  next();
};

// استخدام
router.get('/admin/pending', authenticateToken, requireAdmin, getPendingDonations);
```

### 10. حماية رفع الملفات

**التحقق من نوع وحجم الملف:**
```javascript
const multer = require('multer');

const fileFilter = (req, file, cb) => {
  // السماح فقط بالصور
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only images are allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: fileFilter
});
```

---

## 📊 الإحصائيات والتقارير (Analytics & Reports)

### إحصائيات لوحة تحكم المشرف:

1. **إحصائيات المستخدمين:**
   - إجمالي عدد المستخدمين
   - عدد المتبرعين
   - عدد المستفيدين
   - المستخدمين الجدد (آخر 30 يوم)

2. **إحصائيات التبرعات:**
   - إجمالي التبرعات
   - التبرعات المعلقة (تحتاج موافقة)
   - التبرعات المعتمدة
   - التبرعات المرفوضة
   - التبرعات المكتملة
   - التبرعات حسب الفئة

3. **إحصائيات الطلبات:**
   - إجمالي الطلبات
   - الطلبات المعلقة
   - الطلبات الموافق عليها
   - الطلبات المرفوضة
   - الطلبات المكتملة
   - معدل الموافقة

4. **إحصائيات النشاط:**
   - عدد الرسائل المتبادلة
   - المستخدمين النشطين
   - التبرعات الجديدة (اليوم/الأسبوع/الشهر)

**مثال على API للإحصائيات:**
```javascript
router.get('/admin/stats', authenticateToken, requireAdmin, async (req, res) => {
  const stats = {
    users: {
      total: await User.count(),
      donors: await User.count({ where: { role: 'donor' } }),
      receivers: await User.count({ where: { role: 'receiver' } }),
      admins: await User.count({ where: { role: 'admin' } })
    },
    donations: {
      total: await Donation.count(),
      pending: await Donation.count({ where: { approvalStatus: 'pending' } }),
      approved: await Donation.count({ where: { approvalStatus: 'approved' } }),
      rejected: await Donation.count({ where: { approvalStatus: 'rejected' } }),
      completed: await Donation.count({ where: { status: 'completed' } })
    },
    requests: {
      total: await Request.count(),
      pending: await Request.count({ where: { status: 'pending' } }),
      approved: await Request.count({ where: { status: 'approved' } }),
      declined: await Request.count({ where: { status: 'declined' } }),
      completed: await Request.count({ where: { status: 'completed' } })
    }
  };
  
  res.json({ message: 'Statistics retrieved successfully', stats });
});
```


---

## 🚀 النشر والتشغيل (Deployment)

### استخدام Docker و Docker Compose

**ملف docker-compose.yml:**
```yaml
services:
  # قاعدة البيانات MySQL
  db:
    image: mysql:8.0
    container_name: givingbridge_db
    environment:
      MYSQL_ROOT_PASSWORD: secure_root_password_2024
      MYSQL_DATABASE: givingbridge
      MYSQL_USER: givingbridge_user
      MYSQL_PASSWORD: secure_prod_password_2024
    ports:
      - "3307:3306"
    volumes:
      - db_data:/var/lib/mysql
      - ./backend/sql/init.sql:/docker-entrypoint-initdb.d/init.sql

  # Backend API
  backend:
    build: ./backend
    container_name: givingbridge_backend
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: development
      DB_HOST: db
      DB_PORT: 3306
      DB_USER: givingbridge_user
      DB_PASSWORD: secure_prod_password_2024
      DB_NAME: givingbridge
      JWT_SECRET: your_jwt_secret_here
      FRONTEND_URL: http://localhost:8080
    depends_on:
      - db

  # Frontend Web
  frontend:
    build: ./frontend
    container_name: givingbridge_frontend
    ports:
      - "8080:80"
    depends_on:
      - backend
    environment:
      - BACKEND_API_URL=http://backend:3000/api

volumes:
  db_data:
```

### أوامر التشغيل:

```bash
# تشغيل جميع الخدمات
docker-compose up -d

# عرض السجلات
docker-compose logs -f

# إيقاف الخدمات
docker-compose down

# إعادة بناء الصور
docker-compose build --no-cache

# الوصول للتطبيق
# Frontend: http://localhost:8080
# Backend API: http://localhost:3000
# API Documentation: http://localhost:3000/api-docs
```

---

## 🧪 الاختبار (Testing)

### بيانات تجريبية (Demo Credentials):

```
المشرف (Admin):
Email: admin@givingbridge.com
Password: Admin1234

المتبرع (Donor):
Email: demo@example.com
Password: Demo1234

المستفيد (Receiver):
Email: receiver@example.com
Password: Receive1234
```

### سيناريوهات الاختبار:

#### 1. اختبار التسجيل والدخول:
- تسجيل مستخدم جديد كمتبرع
- تسجيل الدخول بالبيانات الصحيحة
- محاولة تسجيل الدخول ببيانات خاطئة
- تسجيل الخروج

#### 2. اختبار إنشاء تبرع:
- المتبرع يُنشئ تبرع جديد
- التحقق من حالة "pending"
- المشرف يراجع التبرع
- المشرف يوافق على التبرع
- التحقق من ظهور التبرع للجميع

#### 3. اختبار طلب تبرع:
- المستفيد يتصفح التبرعات المعتمدة
- المستفيد يطلب تبرع
- المتبرع يستقبل إشعار
- المتبرع يوافق على الطلب
- التحقق من تحديث حالة التبرع

#### 4. اختبار المراسلة:
- المتبرع والمستفيد يتبادلان الرسائل
- التحقق من الإشعارات الفورية
- تحديد الرسائل كمقروءة

#### 5. اختبار لوحة تحكم المشرف:
- عرض الإحصائيات
- عرض التبرعات المعلقة
- الموافقة/رفض التبرعات
- إدارة المستخدمين

---

## 📱 الميزات الإضافية

### 1. دعم اللغتين (Bilingual Support)
- واجهة كاملة بالعربية والإنجليزية
- دعم RTL (Right-to-Left) للعربية
- تبديل اللغة من الإعدادات

### 2. المراسلة الفورية (Real-time Messaging)
- استخدام Socket.IO
- إشعارات فورية للرسائل الجديدة
- حالة الاتصال (متصل/غير متصل)

### 3. رفع الصور
- رفع صور للتبرعات
- رفع مرفقات للطلبات
- التحقق من نوع وحجم الملف
- معاينة الصور قبل الرفع

### 4. البحث والفلترة
- البحث في التبرعات
- فلترة حسب الفئة
- فلترة حسب الموقع
- فلترة حسب الحالة

### 5. الإشعارات
- إشعارات البريد الإلكتروني
- إشعارات داخل التطبيق
- إشعارات الموافقة/الرفض
- إشعارات الطلبات الجديدة

---

## 🎯 التحديات والحلول

### التحديات التي واجهتنا:

1. **نظام الموافقة على التبرعات:**
   - **التحدي:** كيفية منع ظهور التبرعات غير المعتمدة للمستخدمين العاديين
   - **الحل:** إضافة حقل `approvalStatus` وفلترة النتائج حسب دور المستخدم

2. **المراسلة الفورية:**
   - **التحدي:** تحديث الرسائل في الوقت الفعلي
   - **الحل:** استخدام Socket.IO للاتصال ثنائي الاتجاه

3. **إدارة الحالة في Flutter:**
   - **التحدي:** مزامنة البيانات بين الشاشات المختلفة
   - **الحل:** استخدام Provider لإدارة الحالة المركزية

4. **الأمان:**
   - **التحدي:** حماية البيانات الحساسة
   - **الحل:** استخدام JWT، تشفير كلمات المرور، التحقق من الصلاحيات

5. **دعم اللغتين:**
   - **التحدي:** واجهة متعددة اللغات مع دعم RTL
   - **الحل:** استخدام Flutter Intl وتصميم مرن يدعم الاتجاهين

---

## 📈 التطويرات المستقبلية

### ميزات مقترحة للنسخ القادمة:

1. **نظام التقييمات:**
   - تقييم المتبرعين والمستفيدين
   - نظام النجوم والتعليقات
   - بناء السمعة

2. **الخرائط والموقع:**
   - عرض التبرعات على الخريطة
   - البحث حسب المسافة
   - تحديد الموقع الجغرافي

3. **تطبيق الموبايل:**
   - تطبيق Android و iOS
   - إشعارات Push
   - مشاركة الموقع

4. **التقارير المتقدمة:**
   - تقارير شهرية للمتبرعين
   - إحصائيات تفصيلية
   - تصدير البيانات

5. **التكامل مع وسائل الدفع:**
   - التبرعات المالية
   - الدفع الإلكتروني
   - إصدار الإيصالات

6. **نظام التحقق:**
   - التحقق من هوية المستخدمين
   - رفع المستندات
   - شارات التحقق

7. **المجموعات والحملات:**
   - إنشاء حملات تبرع جماعية
   - مجموعات خيرية
   - أهداف التبرع


---

## 💡 النقاط المهمة للعرض التقديمي

### 1. المقدمة (2-3 دقائق)
- **المشكلة:** صعوبة التواصل بين المتبرعين والمحتاجين
- **الحل:** منصة إلكترونية شاملة تربط الطرفين
- **الهدف:** تسهيل عملية التبرع وضمان الشفافية

### 2. التقنيات المستخدمة (3-4 دقائق)
- **Backend:** Node.js + Express.js + MySQL
- **Frontend:** Flutter Web
- **Real-time:** Socket.IO
- **Security:** JWT, Bcrypt, Input Validation
- **Deployment:** Docker + Docker Compose

### 3. قاعدة البيانات (5-7 دقائق)
- **4 جداول رئيسية:** Users, Donations, Requests, Messages
- **العلاقات:** شرح ERD والعلاقات بين الجداول
- **الفهارس:** لتحسين الأداء
- **Foreign Keys:** لضمان سلامة البيانات

### 4. الميزة الرئيسية: نظام الموافقة (5 دقائق)
- **لماذا؟** لضمان جودة التبرعات ومنع الاحتيال
- **كيف يعمل؟** 
  - المتبرع يُنشئ تبرع (pending)
  - المشرف يراجع ويوافق/يرفض
  - التبرع المعتمد فقط يظهر للجميع
- **الفوائد:** الشفافية، الجودة، الثقة

### 5. أنواع المستخدمين (3-4 دقائق)
- **المتبرع:** إنشاء تبرعات، استقبال طلبات، الموافقة عليها
- **المستفيد:** تصفح التبرعات، طلب التبرعات، التواصل
- **المشرف:** مراجعة التبرعات، إدارة المستخدمين، الإحصائيات

### 6. سير العمل (5-7 دقائق)
- **عرض توضيحي حي (Demo):**
  - تسجيل دخول كمتبرع
  - إنشاء تبرع جديد
  - تسجيل دخول كمشرف
  - الموافقة على التبرع
  - تسجيل دخول كمستفيد
  - طلب التبرع
  - المراسلة بين المتبرع والمستفيد

### 7. الأمان (3-4 دقائق)
- **JWT:** للمصادقة والتفويض
- **Bcrypt:** لتشفير كلمات المرور
- **Input Validation:** للتحقق من صحة البيانات
- **CORS & Helmet:** لتأمين API
- **Role-Based Access:** التحكم في الصلاحيات

### 8. الميزات الإضافية (2-3 دقائق)
- دعم اللغتين (عربي/إنجليزي)
- المراسلة الفورية
- رفع الصور
- البحث والفلترة
- الإشعارات

### 9. التحديات والحلول (2-3 دقائق)
- نظام الموافقة
- المراسلة الفورية
- إدارة الحالة
- الأمان
- دعم اللغتين

### 10. الخاتمة (2 دقيقة)
- **الإنجازات:** منصة كاملة وعملية
- **التأثير:** تسهيل التبرع ومساعدة المحتاجين
- **المستقبل:** ميزات إضافية وتطوير مستمر

---

## 📊 إحصائيات المشروع

### حجم المشروع:
- **Backend:**
  - 15+ API Endpoints
  - 4 Models (Users, Donations, Requests, Messages)
  - 8 Controllers
  - 10+ Middleware
  - 34 Database Migrations

- **Frontend:**
  - 30+ Screens
  - 8 Providers (State Management)
  - 20+ Reusable Widgets
  - 4 Services (API, Socket, Cache, etc.)
  - دعم لغتين كاملتين

- **Database:**
  - 4 جداول رئيسية
  - 15+ علاقة (Foreign Keys)
  - 20+ فهرس (Indexes)

### الوقت المستغرق:
- التخطيط والتصميم: أسبوعان
- تطوير Backend: 3 أسابيع
- تطوير Frontend: 3 أسابيع
- الاختبار والتحسين: أسبوعان
- **الإجمالي:** حوالي 10 أسابيع

---

## 🎓 المهارات المكتسبة

### تقنية:
1. **Backend Development:**
   - Node.js & Express.js
   - RESTful API Design
   - Database Design & Optimization
   - Authentication & Authorization
   - Real-time Communication (Socket.IO)

2. **Frontend Development:**
   - Flutter Web Development
   - State Management (Provider)
   - Responsive Design
   - Internationalization (i18n)
   - API Integration

3. **Database:**
   - MySQL Database Design
   - Sequelize ORM
   - Database Migrations
   - Query Optimization
   - Data Relationships

4. **DevOps:**
   - Docker & Docker Compose
   - Environment Configuration
   - Deployment Strategies

5. **Security:**
   - JWT Authentication
   - Password Hashing
   - Input Validation
   - CORS & Security Headers
   - Role-Based Access Control

### غير تقنية:
1. **إدارة المشروع:**
   - تخطيط المشروع
   - تقسيم المهام
   - إدارة الوقت

2. **حل المشكلات:**
   - تحليل المشاكل
   - إيجاد الحلول
   - التعامل مع التحديات

3. **التوثيق:**
   - كتابة الوثائق الفنية
   - شرح الكود
   - إنشاء API Documentation

---

## 📚 المراجع والمصادر

### التوثيق الرسمي:
1. **Node.js:** https://nodejs.org/docs
2. **Express.js:** https://expressjs.com
3. **Flutter:** https://flutter.dev/docs
4. **MySQL:** https://dev.mysql.com/doc
5. **Socket.IO:** https://socket.io/docs
6. **Sequelize:** https://sequelize.org/docs

### الأدوات المستخدمة:
1. **VS Code:** محرر الأكواد
2. **Postman:** اختبار API
3. **MySQL Workbench:** إدارة قاعدة البيانات
4. **Docker Desktop:** تشغيل الحاويات
5. **Git & GitHub:** إدارة الإصدارات

### المكتبات الرئيسية:
**Backend:**
- express: ^4.18.2
- sequelize: ^6.35.0
- mysql2: ^3.6.0
- jsonwebtoken: ^9.0.2
- bcryptjs: ^2.4.3
- socket.io: ^4.8.1
- express-validator: ^7.0.1
- multer: ^1.4.5
- helmet: ^7.0.0
- cors: ^2.8.5

**Frontend:**
- flutter: SDK
- provider: ^6.0.2
- http: ^1.0.0
- socket_io_client: ^2.0.3
- shared_preferences: ^2.0.13
- image_picker: ^1.0.4
- intl: any

---

## 🎯 الخلاصة

### ما تم إنجازه:
✅ منصة تبرعات كاملة وعملية  
✅ نظام موافقة إداري للتبرعات  
✅ مراسلة فورية بين المستخدمين  
✅ واجهة مستخدم سهلة وجذابة  
✅ دعم لغتين (عربي/إنجليزي)  
✅ نظام أمان متكامل  
✅ قاعدة بيانات محسّنة  
✅ API موثق بالكامل  

### التأثير المتوقع:
- تسهيل عملية التبرع
- ربط المتبرعين بالمحتاجين
- زيادة الشفافية والثقة
- توفير الوقت والجهد
- مساعدة المجتمع

### الرسالة النهائية:
**GivingBridge** ليس مجرد مشروع تخرج، بل هو منصة حقيقية يمكن أن تُحدث فرقاً في المجتمع من خلال تسهيل عملية التبرع وربط القلوب الكريمة بالمحتاجين.

---

## 📞 معلومات الاتصال

**اسم المشروع:** GivingBridge - منصة التبرعات  
**GitHub:** https://github.com/your-username/givingbridge  
**Demo:** http://localhost:8080  
**API Docs:** http://localhost:3000/api-docs  

---

**شكراً لاهتمامكم! 🙏**

**نتمنى أن يكون هذا المشروع قد حقق الأهداف المرجوة وأن يساهم في خدمة المجتمع.**

