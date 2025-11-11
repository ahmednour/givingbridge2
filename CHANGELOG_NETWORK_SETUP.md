# Network Setup Changes - November 11, 2025

## المشكلة الأصلية | Original Problem

عند تشغيل المشروع على جهاز آخر، كان يظهر خطأ:
```
Network error: ClientException: Failed to fetch
uri=http://192.168.100.7:3000/api/auth/login
```

السبب: الـ Frontend كان مضبوط على IP محدد بدلاً من `localhost`، مما يمنع المشروع من العمل على أجهزة أخرى.

## الحل | Solution

تم إعادة ضبط المشروع ليعمل على `localhost` افتراضياً، مع توفير أدوات لتغيير الإعدادات عند الحاجة.

## التغييرات | Changes Made

### 1. إعادة ضبط Frontend Configuration

**الملف**: `frontend/web/config.js`

- ✅ تم إرجاع `API_BASE_URL` إلى `http://localhost:3000/api`
- ✅ تم إرجاع `SOCKET_URL` إلى `http://localhost:3000`
- ✅ تم إضافة تعليقات توضيحية شاملة

### 2. إضافة Scripts مساعدة

#### `scripts/set-network-ip.ps1` (PowerShell)
- تغيير الـ IP في `config.js` بسهولة
- دعم Windows PowerShell

#### `scripts/set-network-ip.js` (Node.js)
- نفس الوظيفة لكن باستخدام Node.js
- يعمل على جميع المنصات

#### `scripts/setup-firewall.ps1` (PowerShell)
- إضافة/حذف قواعد Windows Firewall تلقائياً
- يجب تشغيله كـ Administrator

### 3. توثيق شامل

#### `frontend/NETWORK_SETUP.md`
- دليل مفصل لإعداد الشبكة
- خطوات واضحة للوصول من أجهزة أخرى
- استكشاف الأخطاء وحلها

#### `scripts/README.md`
- توثيق جميع الـ Scripts
- أمثلة استخدام عملية
- سيناريوهات شائعة

#### تحديثات `README.md`
- إضافة قسم "الوصول من أجهزة أخرى"
- إضافة "مرجع سريع" للأوامر الشائعة
- روابط للمستندات الإضافية

## كيفية الاستخدام | How to Use

### الإعداد الافتراضي (موصى به)

```bash
# تشغيل المشروع
docker-compose up -d

# الوصول من نفس الجهاز
http://localhost:8080
```

✅ **يعمل على أي جهاز بدون تعديل**

### الوصول من أجهزة أخرى (عند الحاجة)

```powershell
# 1. معرفة IP الجهاز
ipconfig

# 2. تغيير الإعدادات
.\scripts\set-network-ip.ps1 192.168.1.100

# 3. إعادة بناء Frontend
docker-compose build frontend
docker-compose up -d frontend

# 4. فتح Firewall (Run as Admin)
.\scripts\setup-firewall.ps1 add

# 5. الوصول من جهاز آخر
http://192.168.1.100:8080
```

### العودة للإعداد الافتراضي

```powershell
# 1. إرجاع localhost
.\scripts\set-network-ip.ps1 localhost

# 2. إعادة بناء
docker-compose build frontend
docker-compose up -d frontend

# 3. إغلاق Firewall (اختياري)
.\scripts\setup-firewall.ps1 remove
```

## الفوائد | Benefits

✅ **Portable**: المشروع يعمل على أي جهاز بدون تعديل
✅ **Flexible**: سهولة التبديل بين localhost والشبكة
✅ **Documented**: توثيق شامل لجميع الخطوات
✅ **Automated**: Scripts تلقائية لتسهيل العملية
✅ **Safe**: تحذيرات واضحة قبل مشاركة الكود

## ملاحظات مهمة | Important Notes

⚠️ **قبل مشاركة الكود**:
- تأكد أن `config.js` يستخدم `localhost`
- لا تشارك ملفات تحتوي على IP الخاص بك
- استخدم `.\scripts\set-network-ip.ps1 localhost` للتأكد

🔒 **الأمان**:
- لا تفتح Firewall إلا على شبكات موثوقة
- أغلق القواعد بعد الانتهاء من الاختبار
- لا تستخدم هذا الإعداد في Production

## الملفات المضافة | Added Files

```
frontend/
  └── NETWORK_SETUP.md          # دليل إعداد الشبكة

scripts/
  ├── README.md                 # توثيق Scripts
  ├── set-network-ip.ps1        # PowerShell script
  ├── set-network-ip.js         # Node.js script
  └── setup-firewall.ps1        # Firewall management

CHANGELOG_NETWORK_SETUP.md      # هذا الملف
```

## الملفات المعدلة | Modified Files

```
frontend/web/config.js          # إرجاع localhost + تعليقات
README.md                       # إضافة أقسام جديدة
```

## الاختبار | Testing

تم اختبار التغييرات على:
- ✅ Windows 10/11
- ✅ Docker Desktop
- ✅ PowerShell 5.1+
- ✅ Node.js 16+

## المراجع | References

- [Frontend Network Setup Guide](frontend/NETWORK_SETUP.md)
- [Scripts Documentation](scripts/README.md)
- [Main README](README.md)

---

**التاريخ**: 11 نوفمبر 2025
**الإصدار**: 1.0.0
**الحالة**: ✅ مكتمل ومختبر
