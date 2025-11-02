# 🌐 حل مشكلة Network Error - Failed to fetch

## ❌ المشكلة

```
Network error: ClientException: Failed to fetch,
uri=http://localhost:3000/api/auth/login
```

## 🔍 السبب

عند تشغيل Flutter على جهاز/محاكي، `localhost` يشير للجهاز نفسه وليس للكمبيوتر المضيف!

---

## ✅ الحل حسب نوع الجهاز

### 1️⃣ Android Emulator (المحاكي الأندرويد)

استخدم `10.0.2.2` بدلاً من `localhost`:

```dart
// في frontend/lib/core/config/api_config.dart
static String get baseUrl => 'http://10.0.2.2:3000/api';
```

**لماذا؟**
- `10.0.2.2` هو عنوان خاص يشير للكمبيوتر المضيف من داخل Android Emulator

---

### 2️⃣ iOS Simulator (محاكي iOS)

استخدم `localhost`:

```dart
static String get baseUrl => 'http://localhost:3000/api';
```

**لماذا؟**
- iOS Simulator يشارك نفس network مع الكمبيوتر المضيف

---

### 3️⃣ Physical Device (جهاز حقيقي)

استخدم IP الكمبيوتر على الشبكة المحلية:

```dart
static String get baseUrl => 'http://192.168.1.X:3000/api';
```

**كيف تعرف IP الكمبيوتر؟**

**Windows:**
```cmd
ipconfig
```
ابحث عن `IPv4 Address` تحت `Wireless LAN adapter Wi-Fi`

**Mac/Linux:**
```bash
ifconfig | grep "inet "
```

**مثال:**
```
IPv4 Address: 192.168.1.105
```

استخدم:
```dart
static String get baseUrl => 'http://192.168.1.105:3000/api';
```

---

### 4️⃣ Web (متصفح)

استخدم `localhost`:

```dart
static String get baseUrl => 'http://localhost:3000/api';
```

---

## 🎯 الحل الديناميكي (الأفضل)

استخدم Platform detection:

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Web
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://localhost:3000/api';
    } else {
      // Fallback
      return 'http://localhost:3000/api';
    }
  }
  
  // ... rest of the code
}
```

---

## 🔧 الإصلاح المطبق

تم تغيير `api_config.dart` لاستخدام `10.0.2.2` (Android Emulator):

```dart
static String get baseUrl {
  const String host = '10.0.2.2'; // Android Emulator
  return 'http://$host:3000/api';
}
```

---

## 🧪 الاختبار

### 1. أعد تشغيل التطبيق

```bash
# أوقف التطبيق الحالي (Ctrl+C)
# ثم شغله مرة أخرى
flutter run --debug
```

### 2. جرب تسجيل الدخول

```
Email: demo@example.com
Password: password123
```

### 3. النتيجة المتوقعة

✅ تسجيل دخول ناجح  
✅ الانتقال للـ Dashboard

---

## 🚨 إذا استمرت المشكلة

### تحقق من تشغيل الباك إند

```bash
docker ps
```

يجب أن ترى:
```
givingbridge_backend   Up   0.0.0.0:3000->3000/tcp
```

### تحقق من الاتصال

**من الكمبيوتر:**
```bash
curl http://localhost:3000/api/auth/login
```

**من Android Emulator:**
```bash
# في Android Studio Terminal
adb shell
curl http://10.0.2.2:3000/api/auth/login
```

---

## 📝 ملاحظات مهمة

### للجهاز الحقيقي:

1. **تأكد من نفس الشبكة:**
   - الكمبيوتر والجهاز يجب أن يكونا على نفس Wi-Fi

2. **تعطيل Firewall:**
   - قد يحتاج Windows Firewall للسماح بالاتصال على port 3000

3. **استخدام HTTPS:**
   - iOS يتطلب HTTPS للاتصال بالـ APIs (أو تعطيل ATS)

---

## 🎯 الحل السريع حسب حالتك

| الحالة | العنوان المطلوب |
|--------|-----------------|
| Android Emulator | `http://10.0.2.2:3000/api` |
| iOS Simulator | `http://localhost:3000/api` |
| Physical Device | `http://192.168.1.X:3000/api` |
| Web Browser | `http://localhost:3000/api` |
| Docker Container | `http://host.docker.internal:3000/api` |

---

## ✅ التحقق من النجاح

بعد الإصلاح، يجب أن ترى:

```
✅ Login successful
✅ Navigating to Dashboard
✅ User data loaded
```

---

**تاريخ الإصلاح:** 2 نوفمبر 2025  
**الحالة:** ✅ تم الإصلاح  
**الأولوية:** 🔴 عالية
