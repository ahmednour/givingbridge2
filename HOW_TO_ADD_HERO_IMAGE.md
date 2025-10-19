# 📸 How to Add Your Hero Image

**Quick Guide:** Follow these simple steps to add your own hero image to GivingBridge

---

## ✅ Step-by-Step Instructions

### Step 1: Get Your Image

**Option A: Download from Unsplash (Free)**

1. Visit https://unsplash.com/s/photos/helping-hands
2. Find an image you like
3. Click "Download free" (choose high resolution)
4. Save the image

**Option B: Use Your Own Photo**

- Make sure it's:
  - High quality (minimum 1200px width)
  - Theme-appropriate (helping hands, charity, community)
  - Free to use (if not yours)

---

### Step 2: Optimize the Image

**Recommended specs:**

- **Dimensions:** 1600x1200px (or similar 4:3 ratio)
- **File size:** < 500KB
- **Format:** JPEG or PNG
- **Name:** `hero-hands.jpg`

**Optimize online (free tools):**

- **TinyPNG:** https://tinypng.com/
- **Squoosh:** https://squoosh.app/
- **ImageOptim:** https://imageoptim.com/ (Mac)

---

### Step 3: Add to Your Project

**Create the folder structure:**

```
D:\project\git project\givingbridge\
└── frontend\
    └── web\
        └── assets\
            └── images\
                └── hero\
                    └── hero-hands.jpg  ← Your image goes here
```

**Windows Command:**

```powershell
cd "D:\project\git project\givingbridge\frontend\web"
mkdir -p assets\images\hero
```

**Then copy your image:**

```powershell
copy "C:\Downloads\your-image.jpg" "assets\images\hero\hero-hands.jpg"
```

---

### Step 4: Verify pubspec.yaml

The `frontend/pubspec.yaml` should already have:

```yaml
flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/hero/
    - assets/images/donations/
```

✅ This is already configured!

---

### Step 5: Build and Deploy

**Build the frontend:**

```powershell
cd "D:\project\git project\givingbridge\frontend"
flutter build web --release
```

**Deploy to Docker:**

```powershell
cd "D:\project\git project\givingbridge"
docker-compose up -d --build frontend
```

---

### Step 6: Verify

1. Open http://localhost:8080
2. Your hero image should appear!
3. If you see the fallback gradient, check the file path

---

## 🎨 Recommended Images

### Free Stock Photos

**Unsplash (Best option):**

- https://unsplash.com/photos/mAGZNECMcUg (Hands helping)
- https://unsplash.com/photos/2d4lAQAlbDA (Food donation)
- https://unsplash.com/photos/WNoLnJo7tS8 (Community)

**Pexels:**

- https://www.pexels.com/search/charity/

**Pixabay:**

- https://pixabay.com/images/search/donation/

---

## 🔧 Troubleshooting

### Image not showing?

**Check 1: File exists**

```powershell
dir "frontend\web\assets\images\hero\hero-hands.jpg"
```

**Check 2: pubspec.yaml is correct**

- Assets section under `flutter:` (not `dependencies:`)
- Indentation is correct (2 spaces)

**Check 3: Run flutter pub get**

```powershell
cd frontend
flutter pub get
flutter build web --release
```

**Check 4: Clear build cache**

```powershell
cd frontend
flutter clean
flutter build web --release
```

---

## 📊 File Structure

**Current setup:**

```
frontend/
├── lib/
│   └── screens/
│       └── landing_screen.dart  ← Uses: Image.asset('assets/images/hero/hero-hands.jpg')
├── web/
│   └── assets/
│       └── images/
│           └── hero/
│               └── hero-hands.jpg  ← Your image here
└── pubspec.yaml  ← Assets declared here
```

---

## ✨ Image Guidelines

### Good Hero Images:

- ✅ Show helping hands
- ✅ Have warm, inviting colors
- ✅ Are high resolution
- ✅ Work with text overlay
- ✅ Evoke emotion

### Avoid:

- ❌ Too busy/cluttered
- ❌ Too dark or too light
- ❌ Text embedded
- ❌ Low resolution
- ❌ Off-theme

---

## 🎯 Quick Test

**After adding your image, test:**

1. **Desktop view** (1920x1080)
2. **Tablet view** (768x1024)
3. **Mobile view** (375x667)
4. **Dark mode** (if applicable)
5. **Slow connection** (check loading)

---

## 💡 Pro Tips

1. **Use 4:3 aspect ratio** for best results
2. **Compress before adding** (< 500KB)
3. **Test on multiple devices**
4. **Keep original backup**
5. **Consider seasonal updates**

---

## 🆘 Still Not Working?

**Common issues:**

1. **Wrong path:** Ensure path is `assets/images/hero/hero-hands.jpg` (not `web/assets/...`)
2. **Wrong name:** Must be exactly `hero-hands.jpg`
3. **Not rebuilt:** Run `flutter build web --release`
4. **Cache issue:** Run `flutter clean` first
5. **pubspec error:** Check indentation and location

---

## 📸 Example: Download from Unsplash

**Step-by-step:**

```powershell
# 1. Download image from Unsplash
# Save as: C:\Downloads\unsplash-image.jpg

# 2. Navigate to project
cd "D:\project\git project\givingbridge\frontend\web"

# 3. Create folder (if not exists)
mkdir assets\images\hero -ErrorAction SilentlyContinue

# 4. Copy and rename
copy "C:\Downloads\unsplash-image.jpg" "assets\images\hero\hero-hands.jpg"

# 5. Build
cd ..\..
cd frontend
flutter build web --release

# 6. Deploy
cd ..
docker-compose up -d --build frontend

# 7. Open browser
start http://localhost:8080
```

---

## ✅ Success Checklist

- [ ] Image downloaded/prepared
- [ ] Image optimized (< 500KB)
- [ ] Folder created: `frontend/web/assets/images/hero/`
- [ ] Image copied: `hero-hands.jpg`
- [ ] pubspec.yaml has assets section
- [ ] Ran `flutter pub get`
- [ ] Ran `flutter build web --release`
- [ ] Ran `docker-compose up -d --build frontend`
- [ ] Verified at http://localhost:8080
- [ ] Image loads properly
- [ ] Text badges are readable

---

**That's it! Your hero image is now live! 🎉**

**Need help?** Check `HERO_IMAGE_INFO.md` for more details.
