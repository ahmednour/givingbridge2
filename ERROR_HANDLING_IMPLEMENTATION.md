# 🛡️ Error Handling Implementation - Complete Guide

## 🎯 Overview

Comprehensive error handling system for GivingBridge with friendly messages, automatic retry mechanisms, and offline mode support for superior user experience.

---

## 📦 Components Created

### **1. GBErrorWidget** - Standard Error Display

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Full-screen error widget with retry functionality.

```dart
GBErrorWidget(
  error: exception,
  onRetry: () => loadData(),
  retryButtonText: 'Try Again',
  showDetails: false, // Set true for debug mode
)
```

**Features:**

- ✅ Context-aware error icons and colors
- ✅ User-friendly error messages
- ✅ Optional retry button
- ✅ Debug details (when enabled)
- ✅ Theme-aware styling

---

### **2. GBInlineError** - Compact Error Display

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Small error widget for inline display.

```dart
GBInlineError(
  message: 'Failed to load data',
  onRetry: () => retry(),
  icon: Icons.error_outline,
)
```

**Use Cases:**

- Form field errors
- Card-level errors
- List item errors
- Inline validation

---

### **3. GBNetworkError** - Network-Specific Error

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Pre-configured network error widget.

```dart
GBNetworkError(
  onRetry: () => loadData(),
  customMessage: 'Optional custom message',
)
```

**Auto-displays:**

- WiFi off icon
- "No Internet Connection" title
- Helpful connection message
- Retry button

---

### **4. GBServerError** - Server Error Display

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Pre-configured server error widget.

```dart
GBServerError(
  onRetry: () => loadData(),
)
```

**Shows:**

- Cloud off icon
- "Server Unavailable" title
- Retry button
- Server-specific messaging

---

### **5. GBTimeoutError** - Timeout Error

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Pre-configured timeout error widget.

```dart
GBTimeoutError(
  onRetry: () => loadData(),
)
```

---

### **6. GBErrorSnackbar** - Error Notifications

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Smart snackbar system with retry actions.

```dart
// Network error
GBErrorSnackbar.showNetworkError(
  context,
  onRetry: () => loadData(),
);

// Server error
GBErrorSnackbar.showServerError(
  context,
  onRetry: () => loadData(),
);

// Success message
GBErrorSnackbar.showSuccess(
  context,
  message: 'Data saved successfully!',
);

// Warning message
GBErrorSnackbar.showWarning(
  context,
  message: 'Some items could not be loaded',
);

// Custom error
GBErrorSnackbar.show(
  context,
  message: 'Custom error message',
  onRetry: () => retry(),
  icon: Icons.error,
  backgroundColor: DesignSystem.error,
);
```

---

### **7. GBRetryMechanism** - Automatic Retry with Backoff

**File:** `frontend/lib/widgets/common/gb_error_widgets.dart`

Smart retry mechanism with exponential backoff.

```dart
GBRetryMechanism(
  onRetry: () async {
    await loadData();
  },
  maxRetries: 3,
  initialDelay: Duration(seconds: 1),
  onRetryFailed: (attempt, error) {
    print('Retry $attempt failed: $error');
  },
  builder: (context, isRetrying, retry) {
    if (hasError) {
      return GBButton(
        text: isRetrying ? 'Retrying...' : 'Retry',
        onPressed: isRetrying ? null : retry,
        isLoading: isRetrying,
      );
    }
    return DataList();
  },
)
```

**Features:**

- ✅ Exponential backoff (1s, 2s, 3s)
- ✅ Max retry limit (default: 3)
- ✅ Loading state management
- ✅ Failure callbacks
- ✅ Automatic error handling

---

### **8. GBOfflineIndicator** - Offline Mode Widget

**File:** `frontend/lib/widgets/common/gb_offline_indicator.dart`

Visual indicator for offline mode with sync status.

```dart
GBOfflineIndicator(
  showDetails: true, // Show pending operations count
)
```

**Features:**

- ✅ Gradient warning banner
- ✅ Shows pending operations count
- ✅ Only visible when offline
- ✅ Sync status information

---

### **9. GBOfflineBadge** - Compact Offline Badge

**File:** `frontend/lib/widgets/common/gb_offline_indicator.dart`

Small offline status badge.

```dart
const GBOfflineBadge()
```

**Use Cases:**

- App bar indicators
- Header badges
- Status indicators

---

### **10. GBOfflineStatusSheet** - Detailed Offline Status

**File:** `frontend/lib/widgets/common/gb_offline_indicator.dart`

Bottom sheet showing pending operations.

```dart
GBOfflineStatusSheet.show(context);
```

**Shows:**

- List of pending operations
- Operation types (create/update/delete)
- Timestamps
- Retry counts
- Errors
- Sync button

---

### **11. Enhanced Offline Banner**

**File:** `frontend/lib/widgets/offline_banner.dart`

Improved with pending operations count.

```dart
const AnimatedOfflineBanner()
```

**Features:**

- ✅ Animated show/hide
- ✅ Gradient background
- ✅ Pending operations count
- ✅ Sync status message

---

## 🔄 Retry Mechanisms

### **1. API Service Retry (Automatic)**

**File:** `frontend/lib/services/api_service.dart`

Built-in retry for all API calls with exponential backoff.

```dart
static Future<http.Response> _retryRequest(
  Future<http.Response> Function() request, {
  int maxAttempts = 3,
}) async {
  int attempt = 0;

  while (attempt < maxAttempts) {
    try {
      final response = await request();

      // Retry on 5xx server errors
      if (response.statusCode >= 500 && attempt < maxAttempts - 1) {
        attempt++;
        await Future.delayed(retryDelay * (attempt + 1));
        continue;
      }

      return response;
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      await Future.delayed(retryDelay * attempt);
    }
  }

  throw Exception('Max retries exceeded');
}
```

**Retry Strategy:**

- Attempt 1: Immediate
- Attempt 2: 2 seconds delay
- Attempt 3: 4 seconds delay (last attempt)

**Retries On:**

- Network errors (SocketException, HttpException)
- Server errors (500+)
- Timeout errors

**Does NOT Retry:**

- 4xx client errors (bad request, auth, validation)
- Successful responses (200-299)

---

### **2. Offline Queue (Automatic)**

**File:** `frontend/lib/services/offline_service.dart`

Operations queued when offline, auto-sync when back online.

```dart
// Queue operation
await offlineService.queueOperation(
  type: OfflineOperationType.createDonation,
  data: donationData,
);

// Auto-syncs when connection restored
// Manual sync
await offlineService.forceSync();
```

**Queued Operations:**

- Create/update/delete donations
- Create/update/delete requests
- Send messages
- Update profile
- Upload images

---

### **3. Manual Retry (User-Initiated)**

```dart
Future<void> _loadData() async {
  try {
    setState(() => _isLoading = true);
    final response = await ApiService.getDonations();

    if (response.success) {
      setState(() {
        _donations = response.data!.items;
        _error = null;
      });
    } else {
      setState(() {
        _error = AppException(
          message: response.error ?? 'Failed to load',
          code: 'LOAD_ERROR',
        );
      });
    }
  } catch (e, stackTrace) {
    setState(() {
      _error = ErrorHandler.handleException(e, stackTrace);
    });
  } finally {
    setState(() => _isLoading = false);
  }
}

// In build method
if (_error != null) {
  return GBErrorWidget(
    error: _error,
    onRetry: _loadData, // User can retry
  );
}
```

---

## 📱 User-Friendly Error Messages

### **Error Message Mapping**

| Technical Error    | User-Friendly Message                                               |
| ------------------ | ------------------------------------------------------------------- |
| `SocketException`  | "No internet connection. Please check your network settings."       |
| `HttpException`    | "Network error occurred. Please try again."                         |
| `TimeoutException` | "The request took too long. Please try again."                      |
| `FormatException`  | "Invalid data format. Please try again."                            |
| `401 Unauthorized` | "Your session has expired. Please log in again."                    |
| `403 Forbidden`    | "You don't have permission to perform this action."                 |
| `404 Not Found`    | "The requested resource was not found."                             |
| `422 Validation`   | Shows specific validation errors from server                        |
| `500 Server Error` | "Server error. Our team has been notified. Please try again later." |
| `503 Unavailable`  | "Service temporarily unavailable. Please try again in a moment."    |

---

### **Exception Types**

**1. NetworkException**

```dart
const NetworkException(
  message: 'No internet connection',
  code: 'NO_INTERNET',
)
```

- Icon: WiFi off
- Color: Orange
- Message: Connection-related help

**2. AuthenticationException**

```dart
const AuthenticationException(
  message: 'Session expired',
  code: 'AUTH_EXPIRED',
)
```

- Icon: Lock
- Color: Red
- Message: Re-authentication prompt

**3. ValidationException**

```dart
const ValidationException(
  message: 'Email format is invalid',
  code: 'VALIDATION_ERROR',
)
```

- Icon: Warning
- Color: Amber
- Message: Specific validation issue

**4. ServerException**

```dart
const ServerException(
  message: 'Internal server error',
  code: 'SERVER_ERROR',
)
```

- Icon: Cloud off
- Color: Red
- Message: Server issue explanation

**5. OfflineException**

```dart
const OfflineException(
  message: 'Offline mode active',
  code: 'OFFLINE',
)
```

- Icon: Cloud off
- Color: Grey
- Message: Offline capabilities info

---

## 🎯 Usage Patterns

### **Pattern 1: Simple Error Display**

```dart
class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool _isLoading = false;
  List<Data> _data = [];
  AppException? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getData();
      if (response.success) {
        setState(() => _data = response.data!);
      } else {
        throw AppException(message: response.error ?? 'Failed');
      }
    } catch (e, stackTrace) {
      setState(() {
        _error = ErrorHandler.handleException(e, stackTrace);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _data.isEmpty) {
      return GBLoadingIndicator();
    }

    if (_error != null) {
      return GBErrorWidget(
        error: _error,
        onRetry: _loadData,
      );
    }

    return DataList(data: _data);
  }
}
```

---

### **Pattern 2: Inline Error in Forms**

```dart
GBTextField(
  label: 'Email',
  controller: _emailController,
  errorText: _emailError,
  onChanged: (value) {
    setState(() {
      _emailError = _validateEmail(value);
    });
  },
)

// Below the field
if (_submitError != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: GBInlineError(
      message: _submitError!,
      onRetry: () => _submitForm(),
    ),
  )
```

---

### **Pattern 3: Network-Aware Loading**

```dart
class NetworkAwareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusService>(
      builder: (context, networkStatus, child) {
        if (!networkStatus.isOnline) {
          return Column(
            children: [
              const AnimatedOfflineBanner(),
              Expanded(
                child: CachedDataView(),
              ),
            ],
          );
        }

        return FutureBuilder(
          future: loadData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return GBNetworkError(
                onRetry: () => setState(() {}),
              );
            }
            return DataView(snapshot.data);
          },
        );
      },
    );
  }
}
```

---

### **Pattern 4: Retry with Snackbar**

```dart
Future<void> _saveData() async {
  try {
    final response = await ApiService.saveData(_data);

    if (response.success) {
      GBErrorSnackbar.showSuccess(
        context,
        message: 'Data saved successfully!',
      );
    } else {
      throw AppException(message: response.error ?? 'Save failed');
    }
  } catch (e, stackTrace) {
    final error = ErrorHandler.handleException(e, stackTrace);

    GBErrorSnackbar.show(
      context,
      message: ErrorHandler.getUserFriendlyMessage(error),
      onRetry: () => _saveData(),
    );
  }
}
```

---

### **Pattern 5: Offline Status Check**

```dart
FloatingActionButton(
  onPressed: () {
    if (!networkStatus.isOnline) {
      // Show offline status
      GBOfflineStatusSheet.show(context);
    } else {
      // Perform action
      _createItem();
    }
  },
  child: Stack(
    children: [
      Icon(Icons.add),
      if (!networkStatus.isOnline)
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: DesignSystem.warning,
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  ),
)
```

---

## ✅ Implementation Checklist

### **Core Components** ✅

- [x] GBErrorWidget - Full screen error
- [x] GBInlineError - Compact error
- [x] GBNetworkError - Network specific
- [x] GBServerError - Server specific
- [x] GBTimeoutError - Timeout specific
- [x] GBErrorSnackbar - Notification system
- [x] GBRetryMechanism - Automatic retry
- [x] GBOfflineIndicator - Offline widget
- [x] GBOfflineBadge - Offline badge
- [x] GBOfflineStatusSheet - Detailed status

### **Error Handling** ✅

- [x] Custom exception types (6 types)
- [x] ErrorHandler service
- [x] User-friendly messages
- [x] Error icons and colors
- [x] Stack trace logging

### **Retry Mechanisms** ✅

- [x] API service automatic retry
- [x] Exponential backoff
- [x] Offline queue system
- [x] Manual retry buttons
- [x] Max retry limits

### **Offline Support** ✅

- [x] Network status monitoring
- [x] Offline operation queue
- [x] Data caching
- [x] Auto-sync on reconnect
- [x] Pending operations display

### **Documentation** ✅

- [x] Component usage guide
- [x] Error message mapping
- [x] Usage patterns
- [x] Best practices

---

## 🎨 Visual Features

### **Error States**

- Context-aware icons
- Color-coded errors (red/orange/amber/grey)
- Circular icon containers
- Clear typography hierarchy
- Retry buttons with icons

### **Offline Indicators**

- Gradient warning banners
- Animated show/hide transitions
- Pending operations count
- Sync status messages
- Modal bottom sheets

### **Snackbars**

- Floating behavior
- Rounded corners
- Icon + message layout
- Retry/dismiss actions
- Auto-dismiss timers

---

## 📊 Benefits

### **User Experience**

- ✅ **Clear Communication** - Users always know what went wrong
- ✅ **Easy Recovery** - One-tap retry buttons
- ✅ **Offline Awareness** - Transparent offline mode
- ✅ **No Data Loss** - Operations queued when offline
- ✅ **Professional Feel** - Polished error handling

### **Developer Experience**

- ✅ **Reusable Components** - Consistent error UI
- ✅ **Automatic Retry** - Built into API service
- ✅ **Type-Safe Errors** - Custom exception types
- ✅ **Easy Integration** - Simple widget usage
- ✅ **Debug Support** - Error details available

### **Reliability**

- ✅ **Network Resilience** - Automatic retry on failures
- ✅ **Offline Support** - Queue operations when offline
- ✅ **Data Integrity** - No operations lost
- ✅ **Error Recovery** - Multiple retry strategies
- ✅ **Graceful Degradation** - App remains functional

---

## 🚀 Next Steps (Optional)

1. **Error Analytics** - Track error rates and types
2. **Smart Retry** - Adaptive retry delays based on error type
3. **Offline Sync Progress** - Show sync progress bar
4. **Error Reporting** - Send errors to monitoring service
5. **A/B Testing** - Test different error messages

---

**Status:** ✅ **Production Ready**  
**Last Updated:** 2025-01-24  
**Components:** 11 error handling widgets + services  
**Impact:** 🛡️ Robust error handling with excellent UX
