# 🔄 Component Migration Plan

## 📊 Migration Overview

### **Old Components to Remove**

1. ❌ `app_button.dart` → ✅ `gb_button.dart`
2. ❌ `custom_button.dart` → ✅ `gb_button.dart`
3. ❌ `app_input.dart` → ✅ `gb_text_field.dart`
4. ❌ `custom_input.dart` → ✅ `gb_text_field.dart`
5. ❌ `app_card.dart` → ✅ `gb_card.dart`
6. ❌ `custom_card.dart` → ✅ `gb_card.dart`
7. ❌ `empty_state.dart` → ✅ `gb_empty_state.dart`
8. ❌ `custom_navigation.dart` → ✅ `gb_navigation.dart`
9. ❌ `app_components.dart` → ✅ Individual GB\* components

### **Files Using Old Components** (25+ occurrences)

#### **Screens with AppButton/CustomButton**:

- `login_screen.dart`
- `register_screen.dart`
- `browse_donations_screen.dart`
- `chat_screen_enhanced.dart`
- `create_donation_screen_enhanced.dart`
- `dashboard_screen.dart`
- `donor_dashboard_enhanced.dart`
- `incoming_requests_screen.dart`
- `landing_screen.dart` (uses CustomButton)
- `my_donations_screen.dart`
- `my_requests_screen.dart`
- `receiver_dashboard_enhanced.dart`

#### **Screens with AppInput**:

- `login_screen.dart`
- `register_screen.dart`
- `create_donation_screen_enhanced.dart`
- `chat_screen_enhanced.dart`

---

## 🔄 Migration Mapping

### **Button Migration**

| Old                                                 | New                                                               | Changes                     |
| --------------------------------------------------- | ----------------------------------------------------------------- | --------------------------- |
| `AppButton(text: 'Submit', ...)`                    | `GBButton(text: 'Submit', variant: GBButtonVariant.primary, ...)` | Add variant parameter       |
| `AppButton(type: AppButtonType.primary, ...)`       | `GBPrimaryButton(...)`                                            | Use convenience constructor |
| `AppButton(type: AppButtonType.secondary, ...)`     | `GBSecondaryButton(...)`                                          | Use convenience constructor |
| `AppButton(size: ButtonSize.large, ...)`            | `GBButton(size: GBButtonSize.large, ...)`                         | Update enum name            |
| `CustomButton(variant: ButtonVariant.primary, ...)` | `GBPrimaryButton(...)`                                            | Direct replacement          |
| `PrimaryButton(...)`                                | `GBPrimaryButton(...)`                                            | Direct replacement          |
| `OutlineButton(...)`                                | `GBOutlineButton(...)`                                            | Direct replacement          |

### **Input Migration**

| Old                                    | New                                       | Changes                        |
| -------------------------------------- | ----------------------------------------- | ------------------------------ |
| `AppInput(label: '...', ...)`          | `GBTextField(label: '...', ...)`          | Direct replacement             |
| `AppInput(obscureText: true, ...)`     | `GBTextField(obscureText: true, ...)`     | Auto password toggle included! |
| `AppInput(prefixIcon: Icon(...), ...)` | `GBTextField(prefixIcon: Icon(...), ...)` | Direct replacement             |

### **Card Migration**

| Old               | New           | Changes            |
| ----------------- | ------------- | ------------------ |
| `CustomCard(...)` | `GBCard(...)` | Direct replacement |
| `AppCard(...)`    | `GBCard(...)` | Direct replacement |

### **Empty State Migration**

| Old                                      | New                          | Changes     |
| ---------------------------------------- | ---------------------------- | ----------- |
| Custom empty state containers            | `GBEmptyState.noDonations()` | Use presets |
| CircularProgressIndicator during loading | `GBSkeletonCard()`           | Better UX   |

---

## 📝 Migration Steps

### **Step 1: Update Login Screen** ✅

- Replace `AppInput` → `GBTextField`
- Replace `AppButton` → `GBButton`
- Add password visibility toggle
- Improve error states

### **Step 2: Update Register Screen** ✅

- Replace `AppInput` → `GBTextField`
- Replace `AppButton` → `GBButton`
- Add password strength meter

### **Step 3: Update Landing Screen** ✅

- Replace `CustomButton` → `GBButton`
- Update imports

### **Step 4: Update Dashboard Screens** ✅

- Replace `AppButton` → `GBButton`
- Replace empty states → `GBEmptyState`
- Add skeleton loaders

### **Step 5: Update Browse/List Screens** ✅

- Replace `AppButton` → `GBButton`
- Add `GBFilterChips`
- Add `GBSearchBar`

### **Step 6: Update Create/Edit Screens** ✅

- Replace `AppInput` → `GBTextField`
- Replace `AppButton` → `GBButton`
- Add `GBImageUpload`

### **Step 7: Remove Old Component Files** ✅

- Delete `app_button.dart`
- Delete `custom_button.dart`
- Delete `app_input.dart`
- Delete `custom_input.dart`
- Delete `app_card.dart`
- Delete `custom_card.dart`
- Delete `empty_state.dart`
- Delete `custom_navigation.dart`
- Delete `app_components.dart`

---

## 🎯 Import Changes

### **Old Imports**

```dart
import '../widgets/app_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_card.dart';
```

### **New Imports**

```dart
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_text_field.dart';
import '../widgets/common/gb_card.dart';
import '../widgets/common/gb_empty_state.dart';
import '../../core/theme/design_system.dart'; // For design tokens
```

---

## ⚠️ Breaking Changes & Fixes

### **1. Button Enum Changes**

```dart
// OLD
ButtonSize.small → GBButtonSize.small
ButtonVariant.primary → GBButtonVariant.primary
AppButtonType.primary → Use GBPrimaryButton()

// NEW
size: GBButtonSize.medium
variant: GBButtonVariant.primary
// OR use convenience constructors
GBPrimaryButton(...)
```

### **2. Full Width Buttons**

```dart
// OLD
width: double.infinity

// NEW
fullWidth: true
```

### **3. Loading States**

```dart
// OLD
isLoading: _isLoading

// NEW (same)
isLoading: _isLoading
```

### **4. Password Fields**

```dart
// OLD
AppInput(
  obscureText: true,
  // Manual toggle needed
)

// NEW
GBTextField(
  obscureText: true, // Auto toggle included!
)
```

---

## ✅ Testing Checklist

After migration, test:

- [ ] All buttons render correctly
- [ ] All buttons respond to clicks
- [ ] Loading states work
- [ ] Text fields validate correctly
- [ ] Password visibility toggle works
- [ ] Forms submit properly
- [ ] Empty states display
- [ ] Skeleton loaders appear during loading
- [ ] No console errors
- [ ] Mobile responsive
- [ ] Accessibility (keyboard navigation)

---

## 📊 Expected Benefits

### **Before Migration**

- ❌ Inconsistent button styles
- ❌ No password visibility toggle
- ❌ Basic empty states
- ❌ Only CircularProgressIndicator
- ❌ Touch targets < 48px
- ❌ No animations

### **After Migration**

- ✅ Consistent GB\* components
- ✅ Auto password toggle
- ✅ Engaging empty states
- ✅ Skeleton loaders
- ✅ Accessible touch targets (≥44px)
- ✅ Smooth animations
- ✅ Better UX overall

---

**Status**: Ready to execute migration
**Estimated Time**: 2-4 hours
**Risk Level**: Low (backward compatible, incremental)
