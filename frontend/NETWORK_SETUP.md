# إعداد الشبكة | Network Setup

## الإعداد الافتراضي (Default Setup)

المشروع مضبوط افتراضياً للعمل على **localhost** فقط. هذا يعني:
- ✅ يعمل على نفس الجهاز الذي يشغل Docker
- ✅ مناسب للتطوير المحلي
- ✅ لا يحتاج إعدادات إضافية

## الوصول من أجهزة أخرى (Network Access)

إذا كنت تريد الوصول للمشروع من:
- 📱 موبايلك على نفس الشبكة
- 💻 جهاز كمبيوتر آخر
- 🌐 أي جهاز على نفس الـ WiFi

### الخطوات:

#### 1. اعرف IP جهازك

**Windows:**
```bash
ipconfig
```
ابحث عن `IPv4 Address` تحت الشبكة النشطة (عادة `192.168.x.x`)

**Linux/Mac:**
```bash
ifconfig
# أو
ip addr show
```

#### 2. عدّل ملف الإعدادات

افتح `frontend/web/config.js` وغيّر:

```javascript
// من:
window.ENV_CONFIG = {
  API_BASE_URL: "http://localhost:3000/api",
  SOCKET_URL: "http://localhost:3000",
  ENVIRONMENT: "development",
};

// إلى:
window.ENV_CONFIG = {
  API_BASE_URL: "http://192.168.1.100:3000/api",  // ضع IP جهازك هنا
  SOCKET_URL: "http://192.168.1.100:3000",
  ENVIRONMENT: "development",
};
```

#### 3. أعد بناء Frontend

```bash
docker-compose build frontend
docker-compose up -d frontend
```

#### 4. افتح Firewall (Windows فقط)

افتح **PowerShell كـ Administrator** وشغّل:

```powershell
netsh advfirewall firewall add rule name="GivingBridge Backend" dir=in action=allow protocol=TCP localport=3000
netsh advfirewall firewall add rule name="GivingBridge Frontend" dir=in action=allow protocol=TCP localport=8080
```

**أو استخدم Windows Firewall GUI:**
1. افتح Windows Defender Firewall
2. Advanced settings → Inbound Rules
3. New Rule → Port → TCP → 3000
4. Allow the connection
5. كرر للـ Port 8080

#### 5. افتح من الجهاز الآخر

من أي جهاز على نفس الشبكة، افتح المتصفح:
```
http://192.168.1.100:8080
```
(استبدل بـ IP جهازك)

## ⚠️ تحذيرات مهمة

### قبل مشاركة الكود:
- ❌ **لا تنسى** إرجاع `localhost` في `config.js`
- ❌ **لا تشارك** ملفات تحتوي على IP الخاص بك
- ✅ **تأكد** أن الكود يعمل على `localhost` قبل الـ commit

### للأمان:
- 🔒 لا تفتح الـ Firewall إلا إذا كنت على شبكة موثوقة
- 🔒 أغلق القواعد بعد الانتهاء من الاختبار:
  ```powershell
  netsh advfirewall firewall delete rule name="GivingBridge Backend"
  netsh advfirewall firewall delete rule name="GivingBridge Frontend"
  ```

## استكشاف الأخطاء (Troubleshooting)

### "Network error: Failed to fetch"
- ✅ تأكد أن الـ IP صحيح
- ✅ تأكد أن Firewall مفتوح
- ✅ تأكد أن الجهازين على نفس الشبكة
- ✅ جرب ping من الجهاز الآخر: `ping 192.168.1.100`

### "Connection refused"
- ✅ تأكد أن Docker containers شغالة: `docker-compose ps`
- ✅ تأكد أن Backend شغال: `curl http://localhost:3000/health`

### لا يمكن الوصول من الموبايل
- ✅ تأكد أن الموبايل على نفس WiFi
- ✅ تأكد أن الـ IP في `config.js` صحيح
- ✅ جرب إعادة تشغيل Frontend: `docker-compose restart frontend`

## العودة للإعداد الافتراضي

```bash
# 1. عدّل config.js وأرجع localhost
# 2. أعد البناء
docker-compose build frontend
docker-compose up -d frontend

# 3. (اختياري) أغلق Firewall
netsh advfirewall firewall delete rule name="GivingBridge Backend"
netsh advfirewall firewall delete rule name="GivingBridge Frontend"
```
