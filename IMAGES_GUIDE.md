# GivingBridge Images Guide

**How to add real images to your GivingBridge platform**

---

## 📂 Directory Structure

Create this folder structure in your frontend:

```
frontend/
├── web/
│   ├── assets/
│   │   └── images/
│   │       ├── hero/
│   │       │   └── hero-hands.jpg (800x600px, <500KB)
│   │       ├── donations/
│   │       │   ├── food.jpg (400x300px, <200KB)
│   │       │   ├── clothes.jpg (400x300px, <200KB)
│   │       │   ├── books.jpg (400x300px, <200KB)
│   │       │   └── electronics.jpg (400x300px, <200KB)
│   │       └── placeholder.png (fallback image)
│   └── index.html
```

---

## 🖼️ Step-by-Step: Adding Hero Image

### Step 1: Get a High-Quality Image

**Recommended Free Sources:**

1. **Unsplash** - https://unsplash.com/s/photos/helping-hands
2. **Pexels** - https://www.pexels.com/search/charity/
3. **Pixabay** - https://pixabay.com/images/search/donation/

**Search Keywords:**

- "helping hands"
- "charity donation"
- "community helping"
- "giving food"
- "volunteer"

### Step 2: Download & Optimize

1. **Download** the image
2. **Resize** to 800x600px (or 1600x1200px for retina)
3. **Compress** using:
   - TinyPNG: https://tinypng.com/
   - Squoosh: https://squoosh.app/
   - ImageOptim (Mac)
4. **Target size:** < 500KB

### Step 3: Add to Project

```bash
# Create directories
cd frontend/web
mkdir -p assets/images/hero

# Copy your image
copy path/to/your/image.jpg assets/images/hero/hero-hands.jpg
```

### Step 4: Update Code

Open `frontend/lib/screens/landing_screen.dart` and find the `_buildHeroIllustration` method (around line 443).

**Replace the gradient placeholder with:**

```dart
Widget _buildHeroIllustration(bool isDark) {
  return Container(
    height: 500,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Real image from assets
          Image.asset(
            'assets/images/hero/hero-hands.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to gradient if image not found
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade600,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 200,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              );
            },
          ),

          // Dark overlay for better text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Step 5: Update pubspec.yaml

Add assets declaration in `frontend/pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/hero/
    - assets/images/donations/
```

### Step 6: Rebuild

```bash
cd frontend
flutter build web --release
```

---

## 🌐 Alternative: Using Online Images

If you don't want to include images in your build, use URLs:

```dart
// Using Unsplash API
Image.network(
  'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800&h=600&fit=crop',
  fit: BoxFit.cover,
)

// Using Pexels
Image.network(
  'https://images.pexels.com/photos/6646917/pexels-photo-6646917.jpeg?auto=compress&w=800&h=600',
  fit: BoxFit.cover,
)
```

**Benefits:**

- No build size increase
- Easy to change
- CDN delivery

**Drawbacks:**

- Requires internet
- External dependency
- May load slower

---

## 📸 Recommended Images for GivingBridge

### Hero Section

**Theme:** Community helping, hands giving/receiving
**Examples:**

- Hands passing items
- People volunteering
- Community gathering
- Food donation
- Warm, inspiring scene

**Suggested Unsplash URLs:**

```
https://unsplash.com/photos/hands-holding-heart-xxxxx
https://unsplash.com/photos/food-donation-xxxxx
https://unsplash.com/photos/volunteer-work-xxxxx
```

### Featured Donations

**Food Category:**

- Packaged food items
- Fresh produce
- Grocery bags
- Rice/grains

**Clothes Category:**

- Folded clothes
- Clean garments
- Winter coats
- Children's clothing

**Books Category:**

- Stack of textbooks
- Library books
- Educational materials

**Electronics Category:**

- Laptop
- Tablet
- Phone
- Computer equipment

---

## 🎨 Quick Implementation (No External Images)

If you want to keep using the current gradient design but make it better:

**Option 1: Add subtle pattern**

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade50, Colors.green.shade50],
    ),
  ),
  child: CustomPaint(
    painter: DotPatternPainter(),
    child: Center(
      child: Icon(Icons.volunteer_activism, size: 200),
    ),
  ),
)
```

**Option 2: Use illustrations from unDraw**
Visit: https://undraw.co/illustrations
Download SVG → Convert to PNG → Add to assets

---

## ✅ Quick Checklist

Before deploying with real images:

- [ ] Images optimized (< 500KB each)
- [ ] Correct dimensions
- [ ] Added to assets folder
- [ ] Updated pubspec.yaml
- [ ] Tested on desktop
- [ ] Tested on mobile
- [ ] Dark mode compatible
- [ ] Fallback images work
- [ ] Attribution added (if required)
- [ ] Build successful

---

## 🚀 Deploy Updated Images

```bash
# Build frontend
cd frontend
flutter build web --release

# Update Docker container
cd ..
docker-compose up -d --build frontend

# Verify
# Open: http://localhost:8080
```

---

## 📝 Image Attribution (If Using Free Stock)

If using images that require attribution, add to footer:

```dart
Text('Photos from Unsplash.com',
  style: TextStyle(fontSize: 10, color: Colors.grey))
```

---

## 💡 Pro Tips

1. **Use WebP format** for smaller file sizes
2. **Lazy load** images for better performance
3. **Provide multiple resolutions** for responsive design
4. **Cache images** to improve loading speed
5. **Test on slow connections**

---

## 🆘 Troubleshooting

**Image not showing?**

- Check file path is correct
- Ensure pubspec.yaml includes assets
- Run `flutter pub get`
- Clear build cache: `flutter clean`

**Image too large?**

- Compress with TinyPNG
- Reduce dimensions
- Convert to WebP

**Slow loading?**

- Optimize images
- Use lazy loading
- Consider CDN
- Enable caching

---

**Next Steps:**

1. Choose your hero image
2. Download & optimize
3. Add to project
4. Rebuild & deploy
5. Enjoy your professional-looking platform! 🎉
