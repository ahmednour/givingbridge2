# GivingBridge Scripts

مجموعة من الـ scripts المساعدة لإدارة المشروع.

## 🌐 Network Configuration Scripts

### set-network-ip.ps1 / set-network-ip.js

تغيير الـ IP في ملف `frontend/web/config.js` بسهولة.

**الاستخدام:**

```powershell
# PowerShell
.\scripts\set-network-ip.ps1 localhost
.\scripts\set-network-ip.ps1 192.168.1.100

# Node.js
node scripts/set-network-ip.js localhost
node scripts/set-network-ip.js 192.168.1.100
```

**متى تستخدمه:**
- عند الحاجة للوصول من أجهزة أخرى على الشبكة
- عند العودة للإعداد الافتراضي (localhost)

### setup-firewall.ps1

إدارة قواعد Windows Firewall للمشروع.

**الاستخدام:**

```powershell
# Run as Administrator

# إضافة القواعد
.\scripts\setup-firewall.ps1 add

# حذف القواعد
.\scripts\setup-firewall.ps1 remove
```

**ملاحظة:** يجب تشغيل PowerShell كـ Administrator.

## 📝 أمثلة الاستخدام

### السيناريو 1: إعداد المشروع للوصول من الموبايل

```powershell
# 1. اعرف IP جهازك
ipconfig
# مثال: 192.168.1.100

# 2. غيّر الـ IP في config.js
.\scripts\set-network-ip.ps1 192.168.1.100

# 3. أعد بناء Frontend
docker-compose build frontend
docker-compose up -d frontend

# 4. افتح Firewall (Run as Administrator)
.\scripts\setup-firewall.ps1 add

# 5. افتح من الموبايل
# http://192.168.1.100:8080
```

### السيناريو 2: العودة للإعداد الافتراضي

```powershell
# 1. أرجع localhost
.\scripts\set-network-ip.ps1 localhost

# 2. أعد بناء Frontend
docker-compose build frontend
docker-compose up -d frontend

# 3. (اختياري) أغلق Firewall
.\scripts\setup-firewall.ps1 remove
```

## 🔧 Backend Scripts

### list-users.js

عرض قائمة بجميع المستخدمين في قاعدة البيانات.

```bash
cd backend
node scripts/list-users.js
```

### make-admin.js

تحويل مستخدم إلى admin.

```bash
cd backend
node scripts/make-admin.js user@example.com
```

## 📚 مزيد من المعلومات

- **Network Setup Guide**: `frontend/NETWORK_SETUP.md`
- **Main README**: `README.md`
- **Backend Documentation**: `backend/API_DOCUMENTATION.md`
