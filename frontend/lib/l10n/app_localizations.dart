import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Giving Bridge'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myDonations.
  ///
  /// In en, this message translates to:
  /// **'My Donations'**
  String get myDonations;

  /// No description provided for @browseDonations.
  ///
  /// In en, this message translates to:
  /// **'Browse Donations'**
  String get browseDonations;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @incomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get incomingRequests;

  /// No description provided for @browseRequests.
  ///
  /// In en, this message translates to:
  /// **'Browse Requests'**
  String get browseRequests;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createDonation.
  ///
  /// In en, this message translates to:
  /// **'Create Donation'**
  String get createDonation;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @clothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get clothes;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @toys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get toys;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @donor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get donor;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get donations;

  /// No description provided for @donationCreated.
  ///
  /// In en, this message translates to:
  /// **'Donation created successfully'**
  String get donationCreated;

  /// No description provided for @donationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Donation updated successfully'**
  String get donationUpdated;

  /// No description provided for @editDonation.
  ///
  /// In en, this message translates to:
  /// **'Edit Donation'**
  String get editDonation;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @donationDetails.
  ///
  /// In en, this message translates to:
  /// **'Donation Details'**
  String get donationDetails;

  /// No description provided for @basicInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Provide basic information about your donation'**
  String get basicInfoDescription;

  /// No description provided for @donationTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation Title'**
  String get donationTitle;

  /// No description provided for @donationTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a descriptive title for your donation'**
  String get donationTitleHint;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @titleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters long'**
  String get titleTooShort;

  /// No description provided for @donationDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get donationDescription;

  /// No description provided for @donationDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your donation in detail'**
  String get donationDescriptionHint;

  /// No description provided for @descriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters long'**
  String get descriptionTooShort;

  /// No description provided for @donationLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get donationLocation;

  /// No description provided for @donationLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the location where the donation is available'**
  String get donationLocationHint;

  /// No description provided for @locationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Location must be at least 2 characters long'**
  String get locationTooShort;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of items'**
  String get quantityHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity (minimum 1)'**
  String get invalidQuantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional information (optional)'**
  String get notesHint;

  /// No description provided for @categoryAndCondition.
  ///
  /// In en, this message translates to:
  /// **'Category & Condition'**
  String get categoryAndCondition;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the appropriate category and condition for your donation'**
  String get categoryDescription;

  /// No description provided for @donationCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get donationCategory;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @connectingHearts.
  ///
  /// In en, this message translates to:
  /// **'Connecting hearts, changing lives'**
  String get connectingHearts;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @donationImages.
  ///
  /// In en, this message translates to:
  /// **'Donation Images'**
  String get donationImages;

  /// No description provided for @imagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add photos to showcase your donation'**
  String get imagesDescription;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @selectedImages.
  ///
  /// In en, this message translates to:
  /// **'Selected Images'**
  String get selectedImages;

  /// No description provided for @reviewDonation.
  ///
  /// In en, this message translates to:
  /// **'Review Donation'**
  String get reviewDonation;

  /// No description provided for @reviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your donation details before submitting'**
  String get reviewDescription;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'images'**
  String get images;

  /// No description provided for @updateDonation.
  ///
  /// In en, this message translates to:
  /// **'Update Donation'**
  String get updateDonation;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @messageSettings.
  ///
  /// In en, this message translates to:
  /// **'Message Settings'**
  String get messageSettings;

  /// No description provided for @archivedConversations.
  ///
  /// In en, this message translates to:
  /// **'Archived Conversations'**
  String get archivedConversations;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search Messages'**
  String get searchMessages;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @loadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No Messages'**
  String get noMessages;

  /// No description provided for @noMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation to connect with others'**
  String get noMessagesDescription;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start Conversation'**
  String get startConversation;

  /// No description provided for @aboutDonation.
  ///
  /// In en, this message translates to:
  /// **'About Donation'**
  String get aboutDonation;

  /// No description provided for @aboutRequest.
  ///
  /// In en, this message translates to:
  /// **'About Request'**
  String get aboutRequest;

  /// No description provided for @newConversationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'New Conversation - Coming Soon'**
  String get newConversationComingSoon;

  /// No description provided for @messageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Message Settings - Coming Soon'**
  String get messageSettingsComingSoon;

  /// No description provided for @archivedConversationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Archived Conversations - Coming Soon'**
  String get archivedConversationsComingSoon;

  /// No description provided for @blockedUsersComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users - Coming Soon'**
  String get blockedUsersComingSoon;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @donationManagement.
  ///
  /// In en, this message translates to:
  /// **'Donation Management'**
  String get donationManagement;

  /// No description provided for @requestManagement.
  ///
  /// In en, this message translates to:
  /// **'Request Management'**
  String get requestManagement;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalDonations.
  ///
  /// In en, this message translates to:
  /// **'Total Donations'**
  String get totalDonations;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get totalRequests;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Shows the number of pending offline operations
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pending operations} =1{1 pending operation} other{{count} pending operations}}'**
  String pendingOperations(int count);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @connectHeartsShareHope.
  ///
  /// In en, this message translates to:
  /// **'Connect Hearts,\nShare Hope'**
  String get connectHeartsShareHope;

  /// No description provided for @landingHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Giving Bridge connects generous donors with those in need, creating a community where kindness flows freely and every donation makes a real difference.'**
  String get landingHeroDescription;

  /// No description provided for @startDonating.
  ///
  /// In en, this message translates to:
  /// **'Start Donating'**
  String get startDonating;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @beautifulIllustrationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Illustration\nComing Soon'**
  String get beautifulIllustrationComingSoon;

  /// No description provided for @whyChooseGivingBridge.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Giving Bridge?'**
  String get whyChooseGivingBridge;

  /// No description provided for @platformDescription.
  ///
  /// In en, this message translates to:
  /// **'Our platform makes giving and receiving simple, safe, and meaningful.'**
  String get platformDescription;

  /// No description provided for @easyDonations.
  ///
  /// In en, this message translates to:
  /// **'Easy Donations'**
  String get easyDonations;

  /// No description provided for @easyDonationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Simple and secure way to donate items to those who need them most.'**
  String get easyDonationsDesc;

  /// No description provided for @smartMatching.
  ///
  /// In en, this message translates to:
  /// **'Smart Matching'**
  String get smartMatching;

  /// No description provided for @smartMatchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Our platform intelligently connects donors with receivers based on location and needs.'**
  String get smartMatchingDesc;

  /// No description provided for @verifiedUsers.
  ///
  /// In en, this message translates to:
  /// **'Verified Users'**
  String get verifiedUsers;

  /// No description provided for @verifiedUsersDesc.
  ///
  /// In en, this message translates to:
  /// **'All users are verified to ensure safe and trustworthy transactions.'**
  String get verifiedUsersDesc;

  /// No description provided for @impactTracking.
  ///
  /// In en, this message translates to:
  /// **'Impact Tracking'**
  String get impactTracking;

  /// No description provided for @impactTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your donations and see the real impact you\'re making in your community.'**
  String get impactTrackingDesc;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @stepSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get stepSignUp;

  /// No description provided for @stepSignUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your account as a donor or receiver in just a few clicks.'**
  String get stepSignUpDesc;

  /// No description provided for @stepBrowseOrPost.
  ///
  /// In en, this message translates to:
  /// **'Browse or Post'**
  String get stepBrowseOrPost;

  /// No description provided for @stepBrowseOrPostDesc.
  ///
  /// In en, this message translates to:
  /// **'Donors post items, receivers browse available donations.'**
  String get stepBrowseOrPostDesc;

  /// No description provided for @stepConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get stepConnect;

  /// No description provided for @stepConnectDesc.
  ///
  /// In en, this message translates to:
  /// **'Get matched with verified users in your community.'**
  String get stepConnectDesc;

  /// No description provided for @stepShareReceive.
  ///
  /// In en, this message translates to:
  /// **'Share & Receive'**
  String get stepShareReceive;

  /// No description provided for @stepShareReceiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete the donation and make a positive impact together.'**
  String get stepShareReceiveDesc;

  /// No description provided for @ourImpactInNumbers.
  ///
  /// In en, this message translates to:
  /// **'Our Impact in Numbers'**
  String get ourImpactInNumbers;

  /// No description provided for @itemsDonated.
  ///
  /// In en, this message translates to:
  /// **'Items Donated'**
  String get itemsDonated;

  /// No description provided for @happyRecipients.
  ///
  /// In en, this message translates to:
  /// **'Happy Recipients'**
  String get happyRecipients;

  /// No description provided for @citiesCovered.
  ///
  /// In en, this message translates to:
  /// **'Cities Covered'**
  String get citiesCovered;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @readyToMakeADifference.
  ///
  /// In en, this message translates to:
  /// **'Ready to Make a Difference?'**
  String get readyToMakeADifference;

  /// No description provided for @joinThousands.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of people who are already making their communities better, one donation at a time.'**
  String get joinThousands;

  /// No description provided for @browseDonationsAction.
  ///
  /// In en, this message translates to:
  /// **'Browse Donations'**
  String get browseDonationsAction;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Giving Bridge. All rights reserved.'**
  String get copyright;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for communities worldwide'**
  String get madeWithLove;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @pleaseCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get pleaseCheckConnection;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectRole;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome to Giving Bridge, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @avatarUploadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Avatar upload coming soon!'**
  String get avatarUploadComingSoon;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @notificationSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notification settings coming soon!'**
  String get notificationSettingsComingSoon;

  /// No description provided for @languageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Language settings coming soon!'**
  String get languageSettingsComingSoon;

  /// No description provided for @helpSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support coming soon!'**
  String get helpSupportComingSoon;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @thankYouDifference.
  ///
  /// In en, this message translates to:
  /// **'Thank you for making a difference'**
  String get thankYouDifference;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @impactScore.
  ///
  /// In en, this message translates to:
  /// **'Impact Score'**
  String get impactScore;

  /// No description provided for @recentDonations.
  ///
  /// In en, this message translates to:
  /// **'Recent Donations'**
  String get recentDonations;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @shareItemsNeed.
  ///
  /// In en, this message translates to:
  /// **'Share items with those in need'**
  String get shareItemsNeed;

  /// No description provided for @seeWhatPeopleNeed.
  ///
  /// In en, this message translates to:
  /// **'See what people need'**
  String get seeWhatPeopleNeed;

  /// No description provided for @viewImpact.
  ///
  /// In en, this message translates to:
  /// **'View Impact'**
  String get viewImpact;

  /// No description provided for @seeContributionStats.
  ///
  /// In en, this message translates to:
  /// **'See your contribution stats'**
  String get seeContributionStats;

  /// No description provided for @newButton.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newButton;

  /// No description provided for @noDonationsYet.
  ///
  /// In en, this message translates to:
  /// **'No donations yet'**
  String get noDonationsYet;

  /// No description provided for @startMakingDifference.
  ///
  /// In en, this message translates to:
  /// **'Start making a difference by creating your first donation'**
  String get startMakingDifference;

  /// No description provided for @createFirstDonation.
  ///
  /// In en, this message translates to:
  /// **'Create First Donation'**
  String get createFirstDonation;

  /// No description provided for @deleteDonation.
  ///
  /// In en, this message translates to:
  /// **'Delete Donation'**
  String get deleteDonation;

  /// No description provided for @deleteDonationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this donation?'**
  String get deleteDonationConfirm;

  /// No description provided for @donationDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Donation deleted successfully!'**
  String get donationDeletedSuccess;

  /// No description provided for @discoverItems.
  ///
  /// In en, this message translates to:
  /// **'Discover items that can help you'**
  String get discoverItems;

  /// No description provided for @availableItems.
  ///
  /// In en, this message translates to:
  /// **'Available Items'**
  String get availableItems;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get requestSentSuccess;

  /// No description provided for @requestDonation.
  ///
  /// In en, this message translates to:
  /// **'Request Donation'**
  String get requestDonation;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// Welcome message for admin
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeAdmin(String name);

  /// No description provided for @manageOversee.
  ///
  /// In en, this message translates to:
  /// **'Manage and oversee the GivingBridge platform'**
  String get manageOversee;

  /// No description provided for @platformStatistics.
  ///
  /// In en, this message translates to:
  /// **'Platform Statistics'**
  String get platformStatistics;

  /// No description provided for @activeItems.
  ///
  /// In en, this message translates to:
  /// **'Active Items'**
  String get activeItems;

  /// No description provided for @donationCategories.
  ///
  /// In en, this message translates to:
  /// **'Donation Categories'**
  String get donationCategories;

  /// No description provided for @requestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatus;

  /// No description provided for @noDonations.
  ///
  /// In en, this message translates to:
  /// **'No donations yet'**
  String get noDonations;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequests;

  /// No description provided for @featuredDonations.
  ///
  /// In en, this message translates to:
  /// **'Featured Donations'**
  String get featuredDonations;

  /// No description provided for @featuredDonationsDesc.
  ///
  /// In en, this message translates to:
  /// **'See what people are sharing in our community'**
  String get featuredDonationsDesc;

  /// No description provided for @viewAllDonations.
  ///
  /// In en, this message translates to:
  /// **'View All Donations'**
  String get viewAllDonations;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// Donated by someone
  ///
  /// In en, this message translates to:
  /// **'Donated by {name}'**
  String donatedBy(String name);

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our community to make a difference'**
  String get joinCommunity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
