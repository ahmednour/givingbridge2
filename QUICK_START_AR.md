# 🚀 دليل البدء السريع - GivingBridge

## للمستخدمين الجدد

### ✅ الخطوة 1: التأكد من المتطلبات

تأكد أن عندك:
- ✅ Docker Desktop مثبت وشغال
- ✅ Git مثبت (لتحميل المشروع)

### ✅ الخطوة 2: تحميل المشروع

```bash
# افتح Terminal أو PowerShell
git clone https://github.com/your-org/givingbridge.git
cd givingbridge
```

### ✅ الخطوة 3: تشغيل المشروع

```bash
docker-compose up -d
```

انتظر حوالي 2-3 دقائق للمرة الأولى (Docker بيحمل الصور ويبني المشروع)

### ✅ الخطوة 4: افتح المشروع

افتح المتصفح وروح على:
```
http://localhost:8080
```

### ✅ الخطوة 5: جرب تسجيل الدخول

استخدم أحد الحسابات التجريبية:

**متبرع:**
- Email: `demo@example.com`
- Password: `Demo1234`

**مستفيد:**
- Email: `receiver@example.com`
- Password: `Receive1234`

**مسؤول:**
- Email: `admin@givingbridge.com`
- Password: `Admin1234`

---

## 🎉 مبروك! المشروع شغال

الآن تقدر:
- ✅ تتصفح التبرعات
- ✅ تضيف تبرعات جديدة (كمتبرع)
- ✅ تطلب تبرعات (كمستفيد)
- ✅ تدير المستخدمين (كمسؤول)

---

## 🛑 إيقاف المشروع

```bash
docker-compose down
```

---

## 🔧 مشاكل شائعة

### المشروع مش بيفتح؟

1. **تأكد أن Docker شغال:**
   ```bash
   docker ps
   ```

2. **شوف حالة الخدمات:**
   ```bash
   docker-compose ps
   ```

3. **شوف السجلات:**
   ```bash
   docker-compose logs -f
   ```

### Port 3000 أو 8080 مستخدم؟

```bash
# أوقف المشروع
docker-compose down

# شوف إيه اللي مستخدم الـ Port
netstat -ano | findstr :3000
netstat -ano | findstr :8080

# أقفل البرنامج اللي مستخدم الـ Port أو غير الـ Port في docker-compose.yml
```

### مشكلة في Database؟

```bash
# امسح كل حاجة وابدأ من جديد
docker-compose down -v
docker-compose up -d
```

---

## 📱 عايز تفتح المشروع من موبايلك؟

شوف الدليل المفصل: [frontend/NETWORK_SETUP.md](frontend/NETWORK_SETUP.md)

**الخطوات السريعة:**

1. اعرف IP جهازك:
   ```bash
   ipconfig
   ```

2. غير الإعدادات:
   ```bash
   .\scripts\set-network-ip.ps1 192.168.1.100
   ```

3. أعد بناء Frontend:
   ```bash
   docker-compose build frontend
   docker-compose up -d frontend
   ```

4. افتح Firewall (Run as Admin):
   ```bash
   .\scripts\setup-firewall.ps1 add
   ```

5. افتح من الموبايل:
   ```
   http://192.168.1.100:8080
   ```

---

## 📚 مستندات إضافية

- 📖 [README الكامل](README.md)
- 📖 [دليل إعداد الشبكة](frontend/NETWORK_SETUP.md)
- 📖 [توثيق Scripts](scripts/README.md)
- 📖 [توثيق API](backend/API_DOCUMENTATION.md)

---

## 💡 نصائح

- 🔄 لو عملت تغييرات في الكود، استخدم `docker-compose restart [service]`
- 📝 السجلات مفيدة جداً: `docker-compose logs -f`
- 🧹 لو حصلت مشاكل غريبة، جرب: `docker-compose down -v && docker-compose up -d`
- 💾 البيانات محفوظة في Docker volumes، مش هتضيع لو أوقفت المشروع

---

## 🆘 محتاج مساعدة؟

1. شوف قسم [Troubleshooting](README.md#troubleshooting) في README
2. افتح [Issue على GitHub](https://github.com/your-org/givingbridge/issues)
3. اسأل في [Discussions](https://github.com/your-org/givingbridge/discussions)

---

**بالتوفيق! 🎉**
