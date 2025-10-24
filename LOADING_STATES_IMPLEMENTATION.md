# 🔄 Loading States Implementation Guide

## Overview

Comprehensive loading state system for the GivingBridge Flutter app with standardized components, shimmer effects, and async builders.

---

## 📦 Components Created

### 1. **GBLoadingIndicator** (`gb_loading_indicator.dart`)

Standardized loading indicator with multiple variants:

```dart
// Centered loading with message
GBLoadingIndicator(message: 'Loading donations...')

// Small inline spinner
GBLoadingIndicator.inline(message: 'Sending...')

// Full screen overlay
GBLoadingIndicator.overlay(message: 'Processing...')

// Linear progress bar
GBLoadingIndicator.linear(message: 'Uploading images...')

// Card-style loading
GBLoadingIndicator.card(message: 'Saving changes...')
```

**Features:**

- ✅ 5 different loading types
- ✅ Customizable colors and sizes
- ✅ Optional loading messages
- ✅ Theme-aware styling
- ✅ Semantic labels for accessibility

---

### 2. **GBShimmer** (`gb_loading_indicator.dart`)

Animated shimmer effect for skeleton screens:

```dart
GBShimmer(
  child: Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

**Features:**

- ✅ Smooth gradient animation
- ✅ Customizable base and highlight colors
- ✅ Enable/disable toggle
- ✅ Theme-aware colors

---

### 3. **GBSkeletonCard** (`gb_loading_indicator.dart`)

Pre-built skeleton loading cards:

```dart
// Simple skeleton card
GBSkeletonCard(height: 100, width: double.infinity)

// Skeleton list
GBSkeletonList(
  itemCount: 5,
  itemHeight: 120,
)
```

**Features:**

- ✅ Shimmer animation included
- ✅ Customizable dimensions
- ✅ Rounded corners
- ✅ List variant for multiple items

---

### 4. **GBAsyncBuilder** (`gb_async_builder.dart`)

Smart async builder that handles loading, error, and empty states:

```dart
GBAsyncBuilder<List<Donation>>(
  future: donationProvider.loadDonations(),
  builder: (context, data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => DonationCard(data[index]),
    );
  },
  loadingMessage: 'Loading donations...',
  emptyMessage: 'No donations available',
  onRetry: () => donationProvider.loadDonations(),
)
```

**Features:**

- ✅ Automatic loading state detection
- ✅ Error handling with retry button
- ✅ Empty state support
- ✅ Custom builders for all states
- ✅ Smart data emptiness detection

---

### 5. **GBLoadingOverlay** (`gb_async_builder.dart`)

Full-screen loading overlay for blocking operations:

```dart
GBLoadingOverlay(
  isLoading: _isSubmitting,
  message: 'Creating donation...',
  child: YourContent(),
)
```

**Features:**

- ✅ Blocks user interaction
- ✅ Semi-transparent background
- ✅ Centered loading indicator
- ✅ Optional message

---

## 🎯 Provider Loading States

All providers now have comprehensive loading states:

### **AuthProvider**

```dart
class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.loading;

  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get hasError => _state == AuthState.error;
}
```

**States:**

- `loading` - Initial auth check, login, register
- `authenticated` - User logged in
- `unauthenticated` - No user
- `error` - Auth failure

---

### **DonationProvider**

```dart
class DonationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingMyDonations = false;
  bool _isLoadingStats = false;

  bool get isLoading => _isLoading;
  bool get isLoadingMyDonations => _isLoadingMyDonations;
  bool get isLoadingStats => _isLoadingStats;
}
```

**Loading States:**

- `isLoading` - Loading all donations
- `isLoadingMyDonations` - Loading user's donations
- `isLoadingStats` - Loading statistics
- `hasMoreData` - Pagination state

---

### **RequestProvider**

```dart
class RequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingMyRequests = false;
  bool _isLoadingIncomingRequests = false;
  bool _isLoadingStats = false;
}
```

**Loading States:**

- `isLoading` - Loading all requests
- `isLoadingMyRequests` - Loading receiver's requests
- `isLoadingIncomingRequests` - Loading donor's requests
- `isLoadingStats` - Loading statistics

---

### **MessageProvider**

```dart
class MessageProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isLoadingConversations = false;
}
```

**Loading States:**

- `isLoading` - Sending messages
- `isLoadingMessages` - Loading chat messages
- `isLoadingConversations` - Loading conversation list

---

## 📝 Usage Examples

### **1. Simple Loading State**

```dart
Consumer<DonationProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading && provider.donations.isEmpty) {
      return GBLoadingIndicator(
        message: 'Loading donations...',
      );
    }

    if (provider.donations.isEmpty) {
      return GBEmptyState(
        message: 'No donations found',
      );
    }

    return ListView.builder(
      itemCount: provider.donations.length,
      itemBuilder: (context, index) {
        return DonationCard(provider.donations[index]);
      },
    );
  },
)
```

---

### **2. Skeleton Loading**

```dart
Consumer<DonationProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading && provider.donations.isEmpty) {
      return GBSkeletonList(
        itemCount: 5,
        itemHeight: 150,
      );
    }

    return DonationList(provider.donations);
  },
)
```

---

### **3. Pull-to-Refresh with Loading**

```dart
RefreshIndicator(
  onRefresh: () async {
    await provider.loadDonations(refresh: true);
  },
  child: Consumer<DonationProvider>(
    builder: (context, provider, child) {
      // Show skeleton on first load
      if (provider.isLoading && provider.donations.isEmpty) {
        return GBSkeletonList(itemCount: 5);
      }

      // Show list with loading indicator at bottom for pagination
      return ListView.builder(
        itemCount: provider.donations.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.donations.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GBLoadingIndicator.inline(
                message: 'Loading more...',
              ),
            );
          }
          return DonationCard(provider.donations[index]);
        },
      );
    },
  ),
)
```

---

### **4. Form Submission Loading**

```dart
class _CreateDonationScreenState extends State<CreateDonationScreen> {
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    final success = await donationProvider.createDonation(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      condition: _selectedCondition,
      location: _locationController.text,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GBLoadingOverlay(
      isLoading: _isSubmitting,
      message: 'Creating donation...',
      child: Scaffold(
        body: Form(
          child: Column(
            children: [
              // Form fields...
              GBButton(
                text: 'Create Donation',
                onPressed: _isSubmitting ? null : _submitForm,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### **5. Multiple Loading States**

```dart
class DonorDashboard extends StatefulWidget {
  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final donationProvider = Provider.of<DonationProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);

      donationProvider.loadMyDonations();
      donationProvider.loadStats();
      requestProvider.loadIncomingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            donationProvider.loadMyDonations(),
            donationProvider.loadStats(),
            requestProvider.loadIncomingRequests(),
          ]);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stats Section
              Consumer<DonationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingStats) {
                    return GBSkeletonCard(height: 200);
                  }
                  return StatsCard(stats: provider.stats);
                },
              ),

              // My Donations
              Consumer<DonationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingMyDonations) {
                    return GBSkeletonList(itemCount: 3);
                  }
                  return MyDonationsList(provider.myDonations);
                },
              ),

              // Incoming Requests
              Consumer<RequestProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingIncomingRequests) {
                    return GBSkeletonList(itemCount: 3);
                  }
                  return IncomingRequestsList(provider.incomingRequests);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🎨 Styling Guidelines

### **Colors**

- Primary loading color: `DesignSystem.primaryBlue`
- Skeleton base: `DesignSystem.neutral200` (light) / `DesignSystem.neutral800` (dark)
- Skeleton highlight: `DesignSystem.neutral100` (light) / `DesignSystem.neutral700` (dark)

### **Sizes**

- Default spinner: 40x40px
- Inline spinner: 20x20px
- Card spinner: 24x24px
- Stroke width: 2-4px

### **Messages**

- Keep loading messages short and action-oriented
- Examples: "Loading...", "Sending...", "Processing..."
- Avoid "Please wait" or overly formal language

---

## ✅ Best Practices

1. **Show skeleton on first load**

   - Use `GBSkeletonList` when data list is initially empty
   - Switch to inline loading for pagination

2. **Use appropriate loading type**

   - Centered: Full screen loads
   - Inline: Pagination, button actions
   - Overlay: Form submissions, critical operations
   - Linear: File uploads, progress tracking

3. **Provide retry options**

   - Always show retry button on errors
   - Include helpful error messages

4. **Handle empty states**

   - Show meaningful empty messages
   - Provide call-to-action when possible

5. **Optimize performance**

   - Use `RefreshIndicator` for pull-to-refresh
   - Implement pagination to avoid loading too much data
   - Cache data in providers

6. **Accessibility**
   - All loading indicators have semantic labels
   - Error messages are screen reader friendly
   - Empty states are descriptive

---

## 📊 Loading State Checklist

- [x] **Auth Provider** - Login, register, initialize states
- [x] **Donation Provider** - Load, create, update, delete states
- [x] **Request Provider** - Load my/incoming requests, update status
- [x] **Message Provider** - Load conversations, messages, send states
- [x] **Loading Components** - 5 variants + shimmer + skeleton
- [x] **Async Builder** - Smart loading/error/empty handling
- [x] **Loading Overlay** - Full-screen blocking loader
- [x] **Documentation** - Complete usage guide

---

## 🚀 Next Steps

1. **Implement in remaining screens:**

   - Admin dashboard
   - User management screens
   - Analytics screens
   - Settings screens

2. **Add progress tracking:**

   - File upload progress
   - Multi-step form progress
   - Batch operation progress

3. **Enhanced error states:**

   - Network error detection
   - Offline mode handling
   - Retry with exponential backoff

4. **Performance monitoring:**
   - Track loading times
   - Optimize slow queries
   - Add loading state analytics

---

## 📚 References

- **Components:** `lib/widgets/common/gb_loading_indicator.dart`
- **Async Builder:** `lib/widgets/common/gb_async_builder.dart`
- **Provider States:** `lib/providers/*_provider.dart`
- **Design System:** `lib/core/theme/design_system.dart`

---

**Last Updated:** 2025-01-24  
**Status:** ✅ Complete
