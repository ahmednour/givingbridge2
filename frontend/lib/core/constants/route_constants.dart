/// Route constants for navigation
class RouteConstants {
  // Authentication Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main App Routes
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Donation Routes
  static const String browseDonations = '/donations';
  static const String createDonation = '/donations/create';
  static const String editDonation = '/donations/edit';
  static const String donationDetails = '/donations/details';
  static const String myDonations = '/donations/my';

  // Request Routes
  static const String myRequests = '/requests/my';
  static const String incomingRequests = '/requests/incoming';
  static const String requestDetails = '/requests/details';

  // Message Routes
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String conversations = '/conversations';

  // Admin Routes
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminDonations = '/admin/donations';
  static const String adminRequests = '/admin/requests';
  static const String adminAnalytics = '/admin/analytics';

  // Donor Routes
  static const String donorDashboard = '/donor';
  static const String donorDonations = '/donor/donations';
  static const String donorRequests = '/donor/requests';

  // Receiver Routes
  static const String receiverDashboard = '/receiver';
  static const String receiverRequests = '/receiver/requests';
  static const String receiverDonations = '/receiver/donations';

  // Utility Routes
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String terms = '/terms';

  // Error Routes
  static const String notFound = '/404';
  static const String error = '/error';
  static const String maintenance = '/maintenance';

  // Deep Link Routes
  static const String donationDeepLink = '/d';
  static const String requestDeepLink = '/r';
  static const String userDeepLink = '/u';

  // Route Groups
  static const List<String> authRoutes = [
    login,
    register,
    forgotPassword,
    resetPassword,
  ];

  static const List<String> adminRoutes = [
    adminDashboard,
    adminUsers,
    adminDonations,
    adminRequests,
    adminAnalytics,
  ];

  static const List<String> donorRoutes = [
    donorDashboard,
    donorDonations,
    donorRequests,
  ];

  static const List<String> receiverRoutes = [
    receiverDashboard,
    receiverRequests,
    receiverDonations,
  ];

  static const List<String> protectedRoutes = [
    dashboard,
    profile,
    settings,
    browseDonations,
    createDonation,
    myDonations,
    myRequests,
    incomingRequests,
    messages,
    chat,
    conversations,
    notifications,
    ...adminRoutes,
    ...donorRoutes,
    ...receiverRoutes,
  ];

  static const List<String> publicRoutes = [
    home,
    login,
    register,
    forgotPassword,
    resetPassword,
    help,
    about,
    contact,
    privacy,
    terms,
    notFound,
    error,
    maintenance,
  ];
}
