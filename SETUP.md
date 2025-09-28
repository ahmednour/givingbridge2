# Giving Bridge - Setup Guide

## Project Overview

Giving Bridge is a modern donation platform built with Flutter (frontend) and Node.js (backend) that connects donors and receivers in a seamless, user-friendly interface.

## 🚀 Features Implemented

### ✅ Modern UI/UX Design System

- **Color Palette**: Modern blue primary with green accents
- **Typography**: Inter font family with proper hierarchy
- **Components**: Reusable buttons, cards, inputs, navigation
- **Theme Support**: Light/Dark mode with smooth transitions
- **Responsive Design**: Mobile-first with desktop enhancements

### ✅ Authentication System

- Modern login/register screens with animations
- Role-based authentication (Donor, Receiver, Admin)
- Form validation and error handling
- Social login placeholders (Google, Facebook)

### ✅ User Dashboards

- **Donor Dashboard**: Create, manage, and track donations
- **Receiver Dashboard**: Browse donations with filters and request items
- **Admin Panel**: Comprehensive management with analytics
- Real-time stats and activity tracking

### ✅ Core Features

- Donation creation and management
- Request system with status tracking
- Category-based filtering
- User profile management
- Notification system
- Responsive navigation (bottom nav mobile, sidebar desktop)

## 🛠 Backend Connection

The frontend is configured to connect to your backend at `http://localhost:3000/api`. Update the `baseUrl` in `frontend/lib/services/api_service.dart` if needed.

### API Endpoints Integrated:

- `POST /api/auth/login` - User authentication
- `POST /api/auth/register` - User registration
- `GET /api/requests` - Fetch donations
- `POST /api/requests` - Create donation
- `PUT /api/requests/:id` - Update donation
- `DELETE /api/requests/:id` - Delete donation
- `GET /api/users` - Admin: Get all users
- `GET /api/stats` - Admin: Get platform statistics

## 📱 Getting Started

### Prerequisites

- Flutter SDK (>=2.17.0)
- Node.js and npm
- Your existing backend server

### Frontend Setup

1. Navigate to the frontend directory:

   ```bash
   cd frontend
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d chrome  # For web
   flutter run             # For mobile (with device/emulator connected)
   ```

### Backend Setup

1. Navigate to the backend directory:

   ```bash
   cd backend
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   npm start
   ```

## 🎨 Design System Usage

### Colors

```dart
// Primary colors
AppTheme.primaryColor      // Modern blue (#2563EB)
AppTheme.secondaryColor    // Green accent (#10B981)
AppTheme.successColor      // Success green
AppTheme.errorColor        // Error red

// Text colors (auto-adapts to theme)
AppTheme.lightTextPrimary / AppTheme.darkTextPrimary
AppTheme.lightTextSecondary / AppTheme.darkTextSecondary
```

### Components

```dart
// Buttons
PrimaryButton(text: 'Submit', onPressed: () {})
SecondaryButton(text: 'Cancel')
OutlineButton(text: 'Learn More')

// Cards
CustomCard(child: YourWidget())
DonationCard(title: 'Item', description: 'Description')
StatCard(title: 'Users', value: '150', icon: Icons.people)

// Inputs
CustomInput(label: 'Name', controller: controller)
EmailInput(controller: emailController)
PasswordInput(controller: passwordController)
```

## 🔧 Customization

### Theme Customization

Edit `frontend/lib/core/theme/app_theme.dart` to customize:

- Colors
- Typography
- Spacing
- Border radius
- Shadows

### Adding New Screens

1. Create in `frontend/lib/screens/`
2. Add route in `frontend/lib/main.dart`
3. Update navigation in `frontend/lib/screens/home_screen.dart`

## 📊 Project Structure

```
frontend/
├── lib/
│   ├── core/theme/          # Design system & themes
│   ├── widgets/             # Reusable UI components
│   ├── screens/             # App screens
│   ├── providers/           # State management
│   ├── services/            # API service
│   └── main.dart           # App entry point
├── pubspec.yaml            # Dependencies
└── assets/                 # Images & icons

backend/
├── src/
│   ├── controllers/        # Route handlers
│   ├── models/            # Data models
│   ├── routes/            # API routes
│   └── config/            # Configuration
├── package.json           # Dependencies
└── server.js             # Server entry point
```

## 🌟 Next Steps

1. **Test the complete flow**: Register → Login → Create/Browse donations
2. **Add real images**: Upload donation images to cloud storage
3. **Implement push notifications**: Add Firebase/OneSignal
4. **Add payment integration**: Stripe/PayPal for donation fees
5. **Enhance search**: Add advanced filtering and search
6. **Add messaging**: Direct communication between users
7. **Mobile optimization**: Test on various screen sizes

## 💡 Tips

- The app automatically adapts to light/dark mode based on system settings
- All API calls include error handling and loading states
- The design system ensures consistency across all screens
- Forms include proper validation and user feedback
- Navigation is responsive (bottom nav on mobile, sidebar on desktop)

## 🚀 Deployment

### Frontend (Web)

```bash
flutter build web
# Deploy the build/web folder to your hosting service
```

### Frontend (Mobile)

```bash
flutter build apk        # Android
flutter build ios        # iOS (requires Mac)
```

Your Giving Bridge platform is now ready! The modern UI/UX design, combined with the robust backend integration, provides a solid foundation for your graduation project.
