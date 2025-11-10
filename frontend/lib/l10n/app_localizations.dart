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
  /// **'Donation'**
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

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @messageHistory.
  ///
  /// In en, this message translates to:
  /// **'Message History'**
  String get messageHistory;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @playSoundForMessages.
  ///
  /// In en, this message translates to:
  /// **'Play sound for messages'**
  String get playSoundForMessages;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrateForMessages.
  ///
  /// In en, this message translates to:
  /// **'Vibrate for messages'**
  String get vibrateForMessages;

  /// No description provided for @readReceipts.
  ///
  /// In en, this message translates to:
  /// **'Read Receipts'**
  String get readReceipts;

  /// No description provided for @showReadReceipts.
  ///
  /// In en, this message translates to:
  /// **'Show when messages are read'**
  String get showReadReceipts;

  /// No description provided for @typingIndicators.
  ///
  /// In en, this message translates to:
  /// **'Typing Indicators'**
  String get typingIndicators;

  /// No description provided for @showTypingIndicators.
  ///
  /// In en, this message translates to:
  /// **'Show when others are typing'**
  String get showTypingIndicators;

  /// No description provided for @autoDeleteMessages.
  ///
  /// In en, this message translates to:
  /// **'Auto-delete Messages'**
  String get autoDeleteMessages;

  /// No description provided for @automaticallyDeleteOldMessages.
  ///
  /// In en, this message translates to:
  /// **'Automatically delete old messages'**
  String get automaticallyDeleteOldMessages;

  /// No description provided for @settingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Setting updated'**
  String get settingUpdated;

  /// No description provided for @noArchivedConversations.
  ///
  /// In en, this message translates to:
  /// **'No archived conversations'**
  String get noArchivedConversations;

  /// No description provided for @noArchivedConversationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your archived conversations will appear here'**
  String get noArchivedConversationsDescription;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

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
  /// **'Start donating to see your impact!'**
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
  /// **'Language settings coming soon'**
  String get languageSettingsComingSoon;

  /// No description provided for @helpSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support - Coming Soon'**
  String get helpSupportComingSoon;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language / اختر اللغة'**
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

  /// No description provided for @declineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline Request'**
  String get declineRequest;

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve Request'**
  String get approveRequest;

  /// No description provided for @approvalMessage.
  ///
  /// In en, this message translates to:
  /// **'Approval Message'**
  String get approvalMessage;

  /// No description provided for @provideDeclineReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for declining (optional)...'**
  String get provideDeclineReason;

  /// No description provided for @provideApprovalMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a message for the receiver (optional)...'**
  String get provideApprovalMessage;

  /// No description provided for @responseMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your message here...'**
  String get responseMessageHint;

  /// No description provided for @requestUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request updated successfully!'**
  String get requestUpdatedSuccess;

  /// No description provided for @failedToUpdateRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to update request'**
  String get failedToUpdateRequest;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @failedToLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests'**
  String get failedToLoadRequests;

  /// Request from someone
  ///
  /// In en, this message translates to:
  /// **'Request from'**
  String requestFrom(String name);

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @noRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any requests matching the selected filter.'**
  String get noRequestsDescription;

  /// No description provided for @respondedAt.
  ///
  /// In en, this message translates to:
  /// **'Responded'**
  String get respondedAt;

  /// No description provided for @requestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requestedAt;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// Number of unread notifications
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String unreadNotifications(int count);

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String minutesAgo(int minutes);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String hoursAgo(int hours);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @donationRequests.
  ///
  /// In en, this message translates to:
  /// **'Donation Requests'**
  String get donationRequests;

  /// No description provided for @notifyDonationRequests.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone requests your donations'**
  String get notifyDonationRequests;

  /// No description provided for @newDonations.
  ///
  /// In en, this message translates to:
  /// **'New Donations'**
  String get newDonations;

  /// No description provided for @notifyNewDonations.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new donations in your area'**
  String get notifyNewDonations;

  /// No description provided for @statusUpdates.
  ///
  /// In en, this message translates to:
  /// **'Status Updates'**
  String get statusUpdates;

  /// No description provided for @notifyStatusUpdates.
  ///
  /// In en, this message translates to:
  /// **'Get notified about donation status changes'**
  String get notifyStatusUpdates;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @notifyReminders.
  ///
  /// In en, this message translates to:
  /// **'Get reminded about pickup times and deadlines'**
  String get notifyReminders;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @receiveWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Receive a weekly summary of your activity'**
  String get receiveWeeklySummary;

  /// No description provided for @importantUpdates.
  ///
  /// In en, this message translates to:
  /// **'Important Updates'**
  String get importantUpdates;

  /// No description provided for @receiveImportantUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive important platform updates'**
  String get receiveImportantUpdates;

  /// No description provided for @marketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing Emails'**
  String get marketingEmails;

  /// No description provided for @receiveMarketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Receive tips and feature announcements'**
  String get receiveMarketingEmails;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsRead;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @clearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications? This action cannot be undone.'**
  String get clearAllConfirm;

  /// No description provided for @allNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// No description provided for @notificationsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Notifications refreshed'**
  String get notificationsRefreshed;

  /// No description provided for @newDonationRequest.
  ///
  /// In en, this message translates to:
  /// **'New donation request submitted'**
  String get newDonationRequest;

  /// No description provided for @donationApproved.
  ///
  /// In en, this message translates to:
  /// **'Donation approved!'**
  String get donationApproved;

  /// No description provided for @pickupReminder.
  ///
  /// In en, this message translates to:
  /// **'Pickup reminder'**
  String get pickupReminder;

  /// No description provided for @donationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Donation completed'**
  String get donationCompleted;

  /// No description provided for @newDonationAvailable.
  ///
  /// In en, this message translates to:
  /// **'New donation available'**
  String get newDonationAvailable;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get cancelRequestConfirm;

  /// No description provided for @yesCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancelRequest;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @haveReceivedDonation.
  ///
  /// In en, this message translates to:
  /// **'Have you received this donation?'**
  String get haveReceivedDonation;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled successfully'**
  String get requestCancelled;

  /// No description provided for @requestMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Request marked as completed'**
  String get requestMarkedCompleted;

  /// No description provided for @failedToCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel request'**
  String get failedToCancelRequest;

  /// No description provided for @failedToCompleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete request'**
  String get failedToCompleteRequest;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @noRouteDefined.
  ///
  /// In en, this message translates to:
  /// **'No route defined for'**
  String get noRouteDefined;

  /// No description provided for @securePlatform.
  ///
  /// In en, this message translates to:
  /// **'Secure Platform'**
  String get securePlatform;

  /// No description provided for @securePlatformDesc.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption and secure payment processing for your peace of mind.'**
  String get securePlatformDesc;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// No description provided for @support247Desc.
  ///
  /// In en, this message translates to:
  /// **'Our dedicated support team is always ready to help you make a difference.'**
  String get support247Desc;

  /// No description provided for @simpleSteps.
  ///
  /// In en, this message translates to:
  /// **'Simple steps to make a difference'**
  String get simpleSteps;

  /// No description provided for @whatCommunitySays.
  ///
  /// In en, this message translates to:
  /// **'What Our Community Says'**
  String get whatCommunitySays;

  /// No description provided for @realStories.
  ///
  /// In en, this message translates to:
  /// **'Real stories from donors and receivers who make a difference every day'**
  String get realStories;

  /// No description provided for @testimonial1Text.
  ///
  /// In en, this message translates to:
  /// **'After losing my business due to the pandemic, I found myself needing help. Within 2 days, a donor provided groceries for my family. Now that I\'m back on my feet, I donate regularly to pay it forward. This platform saved us.'**
  String get testimonial1Text;

  /// No description provided for @testimonial2Text.
  ///
  /// In en, this message translates to:
  /// **'I coordinate donations for my neighborhood. GivingBridge streamlined everything - from posting requests to tracking deliveries. We\'ve helped 23 families this year alone. The impact is real and measurable.'**
  String get testimonial2Text;

  /// No description provided for @testimonial3Text.
  ///
  /// In en, this message translates to:
  /// **'As a single mother working two jobs, affording school supplies was tough. Through GivingBridge, my kids got books, a laptop, and clothes. The donors were respectful and kind. This platform is a blessing.'**
  String get testimonial3Text;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhone;

  /// No description provided for @enterYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter your location'**
  String get enterYourLocation;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly'**
  String get pleaseFillRequiredFields;

  /// No description provided for @requestsForMyDonations.
  ///
  /// In en, this message translates to:
  /// **'Requests for my donations'**
  String get requestsForMyDonations;

  /// No description provided for @noIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests yet'**
  String get noIncomingRequests;

  /// No description provided for @whenReceiversRequest.
  ///
  /// In en, this message translates to:
  /// **'When receivers request your donations, they will appear here'**
  String get whenReceiversRequest;

  /// No description provided for @requestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested on'**
  String get requestedOn;

  /// No description provided for @myImpact.
  ///
  /// In en, this message translates to:
  /// **'My Impact'**
  String get myImpact;

  /// No description provided for @contributionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Contribution Statistics'**
  String get contributionStatistics;

  /// No description provided for @totalDonationsMade.
  ///
  /// In en, this message translates to:
  /// **'Total Donations Made'**
  String get totalDonationsMade;

  /// No description provided for @activeDonations.
  ///
  /// In en, this message translates to:
  /// **'Active Donations'**
  String get activeDonations;

  /// No description provided for @completedDonations.
  ///
  /// In en, this message translates to:
  /// **'Completed Donations'**
  String get completedDonations;

  /// No description provided for @peopleHelped.
  ///
  /// In en, this message translates to:
  /// **'People Helped'**
  String get peopleHelped;

  /// No description provided for @approvedRequests.
  ///
  /// In en, this message translates to:
  /// **'Approved Requests'**
  String get approvedRequests;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @impactOverTime.
  ///
  /// In en, this message translates to:
  /// **'Impact Over Time'**
  String get impactOverTime;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @contactRequester.
  ///
  /// In en, this message translates to:
  /// **'Contact Requester'**
  String get contactRequester;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved successfully'**
  String get requestApproved;

  /// No description provided for @requestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// No description provided for @communities.
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get communities;

  /// No description provided for @activeDonors.
  ///
  /// In en, this message translates to:
  /// **'Active Donors'**
  String get activeDonors;

  /// No description provided for @donationsToday.
  ///
  /// In en, this message translates to:
  /// **'donations today'**
  String get donationsToday;

  /// No description provided for @peopleHelpedCount.
  ///
  /// In en, this message translates to:
  /// **'people helped'**
  String get peopleHelpedCount;

  /// No description provided for @secure100.
  ///
  /// In en, this message translates to:
  /// **'Secure 100%'**
  String get secure100;

  /// No description provided for @popularBadge.
  ///
  /// In en, this message translates to:
  /// **'🔥 Popular'**
  String get popularBadge;

  /// No description provided for @trendingUp.
  ///
  /// In en, this message translates to:
  /// **'+18%'**
  String get trendingUp;

  /// No description provided for @newCommunities.
  ///
  /// In en, this message translates to:
  /// **'+3 new'**
  String get newCommunities;

  /// No description provided for @trendingUp24.
  ///
  /// In en, this message translates to:
  /// **'+24%'**
  String get trendingUp24;

  /// No description provided for @trustedBadge.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get trustedBadge;

  /// No description provided for @aiPoweredBadge.
  ///
  /// In en, this message translates to:
  /// **'✨ AI Powered'**
  String get aiPoweredBadge;

  /// No description provided for @verifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'✓ Verified'**
  String get verifiedBadge;

  /// No description provided for @realtimeBadge.
  ///
  /// In en, this message translates to:
  /// **'📊 Real-time'**
  String get realtimeBadge;

  /// No description provided for @secureBadge.
  ///
  /// In en, this message translates to:
  /// **'🔒 Secure'**
  String get secureBadge;

  /// No description provided for @supportBadge.
  ///
  /// In en, this message translates to:
  /// **'🆘 24/7 Support'**
  String get supportBadge;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'🆕 New'**
  String get newBadge;

  /// No description provided for @receiveDonationNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about donations'**
  String get receiveDonationNotifications;

  /// No description provided for @donationApprovals.
  ///
  /// In en, this message translates to:
  /// **'Donation Approvals'**
  String get donationApprovals;

  /// No description provided for @notifyOnApprovals.
  ///
  /// In en, this message translates to:
  /// **'Notify when your donation requests are approved'**
  String get notifyOnApprovals;

  /// No description provided for @notifyOnNewMessages.
  ///
  /// In en, this message translates to:
  /// **'Notify when you receive new messages'**
  String get notifyOnNewMessages;

  /// No description provided for @systemUpdates.
  ///
  /// In en, this message translates to:
  /// **'System Updates'**
  String get systemUpdates;

  /// No description provided for @notifyOnSystemUpdates.
  ///
  /// In en, this message translates to:
  /// **'Notify about app updates and maintenance'**
  String get notifyOnSystemUpdates;

  /// No description provided for @manageYourNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get manageYourNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @turnOnAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on all notifications'**
  String get turnOnAllNotifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @selectLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguagePrompt;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @failedToUpdateSetting.
  ///
  /// In en, this message translates to:
  /// **'Failed to update setting'**
  String get failedToUpdateSetting;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get manageAccount;

  /// No description provided for @chatWithUsers.
  ///
  /// In en, this message translates to:
  /// **'Chat with Users'**
  String get chatWithUsers;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage Alerts'**
  String get manageAlerts;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getAssistance.
  ///
  /// In en, this message translates to:
  /// **'Get Assistance'**
  String get getAssistance;

  /// No description provided for @searchDonations.
  ///
  /// In en, this message translates to:
  /// **'Search donations...'**
  String get searchDonations;

  /// No description provided for @overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor your platform performance and activity'**
  String get overviewSubtitle;

  /// No description provided for @usersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage registered users and their permissions'**
  String get usersSubtitle;

  /// No description provided for @requestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and manage donation requests'**
  String get requestsSubtitle;

  /// No description provided for @donationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage all donations'**
  String get donationsSubtitle;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View detailed analytics and reports'**
  String get analyticsSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure system settings and preferences'**
  String get settingsSubtitle;

  /// No description provided for @adminDashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the admin dashboard'**
  String get adminDashboardWelcome;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @newUserRegistered.
  ///
  /// In en, this message translates to:
  /// **'New user registered'**
  String get newUserRegistered;

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'hour ago'**
  String get hourAgo;

  /// No description provided for @recentUsers.
  ///
  /// In en, this message translates to:
  /// **'Recent Users'**
  String get recentUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No Users Found'**
  String get noUsersFound;

  /// No description provided for @noUsersFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No users found in the system'**
  String get noUsersFoundMessage;

  /// No description provided for @noDonationsFound.
  ///
  /// In en, this message translates to:
  /// **'No Donations'**
  String get noDonationsFound;

  /// No description provided for @noDonationsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No donations found in the system'**
  String get noDonationsFoundMessage;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @noPendingRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'All requests have been processed'**
  String get noPendingRequestsMessage;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @newUserRegisteredActivity.
  ///
  /// In en, this message translates to:
  /// **'New user registered'**
  String get newUserRegisteredActivity;

  /// No description provided for @newDonationPostedActivity.
  ///
  /// In en, this message translates to:
  /// **'New donation posted'**
  String get newDonationPostedActivity;

  /// No description provided for @newRequestSubmittedActivity.
  ///
  /// In en, this message translates to:
  /// **'New request submitted'**
  String get newRequestSubmittedActivity;

  /// No description provided for @joinedAs.
  ///
  /// In en, this message translates to:
  /// **'joined as'**
  String get joinedAs;

  /// No description provided for @donated.
  ///
  /// In en, this message translates to:
  /// **'donated'**
  String get donated;

  /// No description provided for @requestedHelp.
  ///
  /// In en, this message translates to:
  /// **'requested help'**
  String get requestedHelp;

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get unknownTime;

  /// No description provided for @justNowTime.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNowTime;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'weeks ago'**
  String get weeksAgo;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimed;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @platformInformation.
  ///
  /// In en, this message translates to:
  /// **'Platform Information'**
  String get platformInformation;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @platformName.
  ///
  /// In en, this message translates to:
  /// **'Platform Name'**
  String get platformName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get supportEmail;

  /// No description provided for @maxUploadSize.
  ///
  /// In en, this message translates to:
  /// **'Max Upload Size'**
  String get maxUploadSize;

  /// No description provided for @sessionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Session Timeout'**
  String get sessionTimeout;

  /// No description provided for @apiVersion.
  ///
  /// In en, this message translates to:
  /// **'API Version'**
  String get apiVersion;

  /// No description provided for @databaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Database Status'**
  String get databaseStatus;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @availableDonations.
  ///
  /// In en, this message translates to:
  /// **'Available Donations'**
  String get availableDonations;

  /// No description provided for @donors.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get donors;

  /// No description provided for @receivers.
  ///
  /// In en, this message translates to:
  /// **'Receivers'**
  String get receivers;

  /// No description provided for @totalUsersLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsersLabel;

  /// No description provided for @pendingRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequestsCount;

  /// No description provided for @pendingDonations.
  ///
  /// In en, this message translates to:
  /// **'Pending Donations'**
  String get pendingDonations;

  /// No description provided for @approveDonation.
  ///
  /// In en, this message translates to:
  /// **'Approve Donation'**
  String get approveDonation;

  /// No description provided for @rejectDonation.
  ///
  /// In en, this message translates to:
  /// **'Reject Donation'**
  String get rejectDonation;

  /// No description provided for @areYouSureApprove.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve \"{title}\"?'**
  String areYouSureApprove(String title);

  /// No description provided for @rejecting.
  ///
  /// In en, this message translates to:
  /// **'Rejecting: \"{title}\"'**
  String rejecting(String title);

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @provideRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason for rejection'**
  String get provideRejectionReason;

  /// No description provided for @pleaseProvideRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a rejection reason'**
  String get pleaseProvideRejectionReason;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @donationApprovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Donation approved successfully'**
  String get donationApprovedSuccessfully;

  /// No description provided for @failedToApproveDonation.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve donation'**
  String get failedToApproveDonation;

  /// No description provided for @donationRejectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Donation rejected successfully'**
  String get donationRejectedSuccessfully;

  /// No description provided for @failedToRejectDonation.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject donation'**
  String get failedToRejectDonation;

  /// No description provided for @failedToLoadPendingDonations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load pending donations'**
  String get failedToLoadPendingDonations;

  /// No description provided for @noPendingDonations.
  ///
  /// In en, this message translates to:
  /// **'No Pending Donations'**
  String get noPendingDonations;

  /// No description provided for @noPendingDonationsMessage.
  ///
  /// In en, this message translates to:
  /// **'All donations have been reviewed'**
  String get noPendingDonationsMessage;

  /// No description provided for @donorName.
  ///
  /// In en, this message translates to:
  /// **'Donor Name'**
  String get donorName;

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted On'**
  String get submittedOn;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @approvalStatus.
  ///
  /// In en, this message translates to:
  /// **'Approval Status'**
  String get approvalStatus;

  /// No description provided for @approvalStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get approvalStatusPending;

  /// No description provided for @approvalStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvalStatusApproved;

  /// No description provided for @approvalStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get approvalStatusRejected;

  /// No description provided for @approvalStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get approvalStatusUnknown;

  /// No description provided for @donationPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Your donation is pending review by an administrator'**
  String get donationPendingReview;

  /// No description provided for @donationApprovedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your donation has been approved by an administrator'**
  String get donationApprovedByAdmin;

  /// No description provided for @donationRejectedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your donation has been rejected by an administrator'**
  String get donationRejectedByAdmin;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Approval'**
  String get waitingForApproval;

  /// No description provided for @visibleAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Your donation will be visible to receivers once approved by an administrator'**
  String get visibleAfterApproval;

  /// No description provided for @donationCreatedPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Donation created successfully and is pending admin approval'**
  String get donationCreatedPendingApproval;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get statusUnavailable;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteConfirm;

  /// No description provided for @receiveEmailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive email updates about your activity'**
  String get receiveEmailUpdates;

  /// No description provided for @notifyOnNewRequests.
  ///
  /// In en, this message translates to:
  /// **'Notify when your donations are requested'**
  String get notifyOnNewRequests;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @housing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get housing;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @healthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthcare;

  /// No description provided for @childcare.
  ///
  /// In en, this message translates to:
  /// **'Childcare'**
  String get childcare;

  /// No description provided for @eldercare.
  ///
  /// In en, this message translates to:
  /// **'Eldercare'**
  String get eldercare;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @schoolSupplies.
  ///
  /// In en, this message translates to:
  /// **'School Supplies'**
  String get schoolSupplies;

  /// No description provided for @medicalSupplies.
  ///
  /// In en, this message translates to:
  /// **'Medical Supplies'**
  String get medicalSupplies;

  /// No description provided for @babyItems.
  ///
  /// In en, this message translates to:
  /// **'Baby Items'**
  String get babyItems;

  /// No description provided for @kitchenware.
  ///
  /// In en, this message translates to:
  /// **'Kitchenware'**
  String get kitchenware;

  /// No description provided for @bedding.
  ///
  /// In en, this message translates to:
  /// **'Bedding'**
  String get bedding;

  /// No description provided for @personalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get personalCare;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @hobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get hobbies;

  /// No description provided for @petSupplies.
  ///
  /// In en, this message translates to:
  /// **'Pet Supplies'**
  String get petSupplies;

  /// No description provided for @categoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get categoryMedical;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// No description provided for @categoryEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get categoryEmergency;

  /// No description provided for @categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// No description provided for @categoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get categoryBooks;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get categoryFurniture;

  /// No description provided for @categoryToys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get categoryToys;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @medicalDescription.
  ///
  /// In en, this message translates to:
  /// **'Medical supplies, medications, and health equipment'**
  String get medicalDescription;

  /// No description provided for @educationDescription.
  ///
  /// In en, this message translates to:
  /// **'School books, educational supplies, and study materials'**
  String get educationDescription;

  /// No description provided for @foodDescription.
  ///
  /// In en, this message translates to:
  /// **'Food, groceries, and ready meals'**
  String get foodDescription;

  /// No description provided for @housingDescription.
  ///
  /// In en, this message translates to:
  /// **'Home furniture and housing supplies'**
  String get housingDescription;

  /// No description provided for @emergencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Urgent aid and emergency supplies'**
  String get emergencyDescription;

  /// No description provided for @clothingDescription.
  ///
  /// In en, this message translates to:
  /// **'Clothes, shoes, and accessories'**
  String get clothingDescription;

  /// No description provided for @booksDescription.
  ///
  /// In en, this message translates to:
  /// **'Books, magazines, and reading materials'**
  String get booksDescription;

  /// No description provided for @electronicsDescription.
  ///
  /// In en, this message translates to:
  /// **'Electronic devices and technology'**
  String get electronicsDescription;

  /// No description provided for @furnitureDescription.
  ///
  /// In en, this message translates to:
  /// **'Home and office furniture'**
  String get furnitureDescription;

  /// No description provided for @toysDescription.
  ///
  /// In en, this message translates to:
  /// **'Toys and entertainment for children'**
  String get toysDescription;

  /// No description provided for @otherDescription.
  ///
  /// In en, this message translates to:
  /// **'Other miscellaneous items'**
  String get otherDescription;

  /// No description provided for @donationForMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical Donation'**
  String get donationForMedical;

  /// No description provided for @donationForEducation.
  ///
  /// In en, this message translates to:
  /// **'Educational Donation'**
  String get donationForEducation;

  /// No description provided for @donationForFood.
  ///
  /// In en, this message translates to:
  /// **'Food Donation'**
  String get donationForFood;

  /// No description provided for @donationForHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing Donation'**
  String get donationForHousing;

  /// No description provided for @donationForEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Donation'**
  String get donationForEmergency;

  /// No description provided for @urgentNeed.
  ///
  /// In en, this message translates to:
  /// **'Urgent Need'**
  String get urgentNeed;

  /// No description provided for @moderateNeed.
  ///
  /// In en, this message translates to:
  /// **'Moderate Need'**
  String get moderateNeed;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get lowPriority;

  /// No description provided for @criticalCondition.
  ///
  /// In en, this message translates to:
  /// **'Critical Condition'**
  String get criticalCondition;

  /// No description provided for @goodCondition.
  ///
  /// In en, this message translates to:
  /// **'Good Condition'**
  String get goodCondition;

  /// No description provided for @fairCondition.
  ///
  /// In en, this message translates to:
  /// **'Fair Condition'**
  String get fairCondition;

  /// No description provided for @excellentCondition.
  ///
  /// In en, this message translates to:
  /// **'Excellent Condition'**
  String get excellentCondition;

  /// No description provided for @newCondition.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCondition;

  /// No description provided for @usedCondition.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedCondition;

  /// No description provided for @refurbishedCondition.
  ///
  /// In en, this message translates to:
  /// **'Refurbished'**
  String get refurbishedCondition;

  /// No description provided for @donationTerminology.
  ///
  /// In en, this message translates to:
  /// **'Donation Terminology'**
  String get donationTerminology;

  /// No description provided for @charitableGiving.
  ///
  /// In en, this message translates to:
  /// **'Charitable Giving'**
  String get charitableGiving;

  /// No description provided for @socialResponsibility.
  ///
  /// In en, this message translates to:
  /// **'Social Responsibility'**
  String get socialResponsibility;

  /// No description provided for @communitySupport.
  ///
  /// In en, this message translates to:
  /// **'Community Support'**
  String get communitySupport;

  /// No description provided for @helpingOthers.
  ///
  /// In en, this message translates to:
  /// **'Helping Others'**
  String get helpingOthers;

  /// No description provided for @makingDifference.
  ///
  /// In en, this message translates to:
  /// **'Making a Difference'**
  String get makingDifference;

  /// No description provided for @spreadingKindness.
  ///
  /// In en, this message translates to:
  /// **'Spreading Kindness'**
  String get spreadingKindness;

  /// No description provided for @givingBack.
  ///
  /// In en, this message translates to:
  /// **'Giving Back'**
  String get givingBack;

  /// No description provided for @sharingIsCaring.
  ///
  /// In en, this message translates to:
  /// **'Sharing is Caring'**
  String get sharingIsCaring;

  /// No description provided for @togetherWeCanHelp.
  ///
  /// In en, this message translates to:
  /// **'Together We Can Help'**
  String get togetherWeCanHelp;

  /// No description provided for @everyDonationCounts.
  ///
  /// In en, this message translates to:
  /// **'Every Donation Counts'**
  String get everyDonationCounts;

  /// No description provided for @yourKindnessMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Kindness Matters'**
  String get yourKindnessMatters;

  /// No description provided for @buildingBetterCommunity.
  ///
  /// In en, this message translates to:
  /// **'Building a Better Community'**
  String get buildingBetterCommunity;

  /// No description provided for @connectingHeartsAndHands.
  ///
  /// In en, this message translates to:
  /// **'Connecting Hearts and Hands'**
  String get connectingHeartsAndHands;

  /// No description provided for @bridgingTheGap.
  ///
  /// In en, this message translates to:
  /// **'Bridging the Gap'**
  String get bridgingTheGap;

  /// No description provided for @unitedInGiving.
  ///
  /// In en, this message translates to:
  /// **'United in Giving'**
  String get unitedInGiving;

  /// No description provided for @compassionInAction.
  ///
  /// In en, this message translates to:
  /// **'Compassion in Action'**
  String get compassionInAction;

  /// No description provided for @hopeForAll.
  ///
  /// In en, this message translates to:
  /// **'Hope for All'**
  String get hopeForAll;

  /// No description provided for @lendingAHand.
  ///
  /// In en, this message translates to:
  /// **'Lending a Hand'**
  String get lendingAHand;

  /// No description provided for @caringCommunity.
  ///
  /// In en, this message translates to:
  /// **'Caring Community'**
  String get caringCommunity;

  /// No description provided for @generousHearts.
  ///
  /// In en, this message translates to:
  /// **'Generous Hearts'**
  String get generousHearts;

  /// No description provided for @kindnessRipples.
  ///
  /// In en, this message translates to:
  /// **'Kindness Ripples'**
  String get kindnessRipples;

  /// No description provided for @sharingHope.
  ///
  /// In en, this message translates to:
  /// **'Sharing Hope'**
  String get sharingHope;

  /// No description provided for @lightInDarkness.
  ///
  /// In en, this message translates to:
  /// **'Light in Darkness'**
  String get lightInDarkness;

  /// No description provided for @warmthInColdness.
  ///
  /// In en, this message translates to:
  /// **'Warmth in Coldness'**
  String get warmthInColdness;

  /// No description provided for @strengthInUnity.
  ///
  /// In en, this message translates to:
  /// **'Strength in Unity'**
  String get strengthInUnity;

  /// No description provided for @loveInAction.
  ///
  /// In en, this message translates to:
  /// **'Love in Action'**
  String get loveInAction;

  /// No description provided for @gracefulGiving.
  ///
  /// In en, this message translates to:
  /// **'Graceful Giving'**
  String get gracefulGiving;

  /// No description provided for @blessedToGive.
  ///
  /// In en, this message translates to:
  /// **'Blessed to Give'**
  String get blessedToGive;

  /// No description provided for @gratefulToReceive.
  ///
  /// In en, this message translates to:
  /// **'Grateful to Receive'**
  String get gratefulToReceive;

  /// No description provided for @humbleService.
  ///
  /// In en, this message translates to:
  /// **'Humble Service'**
  String get humbleService;

  /// No description provided for @dignifiedHelp.
  ///
  /// In en, this message translates to:
  /// **'Dignified Help'**
  String get dignifiedHelp;

  /// No description provided for @respectfulSupport.
  ///
  /// In en, this message translates to:
  /// **'Respectful Support'**
  String get respectfulSupport;

  /// No description provided for @culturalSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Cultural Sensitivity'**
  String get culturalSensitivity;

  /// No description provided for @islamicValues.
  ///
  /// In en, this message translates to:
  /// **'Islamic Values'**
  String get islamicValues;

  /// No description provided for @zakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get zakat;

  /// No description provided for @sadaqah.
  ///
  /// In en, this message translates to:
  /// **'Sadaqah'**
  String get sadaqah;

  /// No description provided for @khair.
  ///
  /// In en, this message translates to:
  /// **'Khair'**
  String get khair;

  /// No description provided for @barakah.
  ///
  /// In en, this message translates to:
  /// **'Barakah'**
  String get barakah;

  /// No description provided for @ajr.
  ///
  /// In en, this message translates to:
  /// **'Ajr'**
  String get ajr;

  /// No description provided for @hasanat.
  ///
  /// In en, this message translates to:
  /// **'Hasanat'**
  String get hasanat;

  /// No description provided for @birr.
  ///
  /// In en, this message translates to:
  /// **'Birr'**
  String get birr;

  /// No description provided for @ihsan.
  ///
  /// In en, this message translates to:
  /// **'Ihsan'**
  String get ihsan;

  /// No description provided for @takaful.
  ///
  /// In en, this message translates to:
  /// **'Takaful'**
  String get takaful;

  /// No description provided for @silaturrahim.
  ///
  /// In en, this message translates to:
  /// **'Silaturrahim'**
  String get silaturrahim;

  /// No description provided for @ukhuwah.
  ///
  /// In en, this message translates to:
  /// **'Ukhuwah'**
  String get ukhuwah;

  /// No description provided for @taawun.
  ///
  /// In en, this message translates to:
  /// **'Taawun'**
  String get taawun;

  /// No description provided for @rahma.
  ///
  /// In en, this message translates to:
  /// **'Rahma'**
  String get rahma;

  /// No description provided for @hikmah.
  ///
  /// In en, this message translates to:
  /// **'Hikmah'**
  String get hikmah;

  /// No description provided for @sabr.
  ///
  /// In en, this message translates to:
  /// **'Sabr'**
  String get sabr;

  /// No description provided for @shukr.
  ///
  /// In en, this message translates to:
  /// **'Shukr'**
  String get shukr;

  /// No description provided for @tawakkul.
  ///
  /// In en, this message translates to:
  /// **'Tawakkul'**
  String get tawakkul;

  /// No description provided for @ikhlas.
  ///
  /// In en, this message translates to:
  /// **'Ikhlas'**
  String get ikhlas;

  /// No description provided for @taqwa.
  ///
  /// In en, this message translates to:
  /// **'Taqwa'**
  String get taqwa;

  /// No description provided for @iman.
  ///
  /// In en, this message translates to:
  /// **'Iman'**
  String get iman;

  /// No description provided for @islam.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get islam;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field required'**
  String get fieldRequired;

  /// No description provided for @fieldTooShort.
  ///
  /// In en, this message translates to:
  /// **'Field too short'**
  String get fieldTooShort;

  /// No description provided for @fieldTooLong.
  ///
  /// In en, this message translates to:
  /// **'Field too long'**
  String get fieldTooLong;

  /// No description provided for @invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @pleaseEnterValidValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid value'**
  String get pleaseEnterValidValue;

  /// No description provided for @pleaseSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select option'**
  String get pleaseSelectOption;

  /// No description provided for @pleaseEnterText.
  ///
  /// In en, this message translates to:
  /// **'Please enter text'**
  String get pleaseEnterText;

  /// No description provided for @pleaseEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter number'**
  String get pleaseEnterNumber;

  /// No description provided for @numberTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Number too small'**
  String get numberTooSmall;

  /// No description provided for @numberTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Number too large'**
  String get numberTooLarge;

  /// No description provided for @mustBePositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be positive number'**
  String get mustBePositiveNumber;

  /// No description provided for @mustBeWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be whole number'**
  String get mustBeWholeNumber;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email is invalid'**
  String get emailInvalid;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email is too long'**
  String get emailTooLong;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists'**
  String get emailAlreadyExists;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get passwordTooWeak;

  /// No description provided for @passwordMustContainUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordMustContainUppercase;

  /// No description provided for @passwordMustContainLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a lowercase letter'**
  String get passwordMustContainLowercase;

  /// No description provided for @passwordMustContainNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number'**
  String get passwordMustContainNumber;

  /// No description provided for @passwordMustContainSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a special character'**
  String get passwordMustContainSpecialChar;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short (minimum 2 characters)'**
  String get nameTooShort;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long (maximum 50 characters)'**
  String get nameTooLong;

  /// No description provided for @nameInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Name contains invalid characters'**
  String get nameInvalidCharacters;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number is invalid'**
  String get phoneInvalid;

  /// No description provided for @phoneTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short'**
  String get phoneTooShort;

  /// No description provided for @phoneTooLong.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too long'**
  String get phoneTooLong;

  /// No description provided for @phoneAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Phone number already exists'**
  String get phoneAlreadyExists;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// No description provided for @locationTooLong.
  ///
  /// In en, this message translates to:
  /// **'Location is too long (maximum 100 characters)'**
  String get locationTooLong;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @titleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Title is too long (maximum 100 characters)'**
  String get titleTooLong;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @descriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description is too long (maximum 1000 characters)'**
  String get descriptionTooLong;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// No description provided for @categoryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid category'**
  String get categoryInvalid;

  /// No description provided for @conditionRequired.
  ///
  /// In en, this message translates to:
  /// **'Condition is required'**
  String get conditionRequired;

  /// No description provided for @conditionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid condition'**
  String get conditionInvalid;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @quantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity'**
  String get quantityInvalid;

  /// No description provided for @quantityTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Quantity is too small (minimum 1)'**
  String get quantityTooSmall;

  /// No description provided for @quantityTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Quantity is too large (maximum 1000)'**
  String get quantityTooLarge;

  /// No description provided for @imageRequired.
  ///
  /// In en, this message translates to:
  /// **'Image is required'**
  String get imageRequired;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image size is too large (maximum 5MB)'**
  String get imageTooLarge;

  /// No description provided for @imageFormatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid image format'**
  String get imageFormatInvalid;

  /// No description provided for @tooManyImages.
  ///
  /// In en, this message translates to:
  /// **'Too many images (maximum 5)'**
  String get tooManyImages;

  /// No description provided for @messageRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageRequired;

  /// No description provided for @messageTooShort.
  ///
  /// In en, this message translates to:
  /// **'Message is too short (minimum 5 characters)'**
  String get messageTooShort;

  /// No description provided for @messageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Message is too long (maximum 500 characters)'**
  String get messageTooLong;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date is required'**
  String get dateRequired;

  /// No description provided for @dateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get dateInvalid;

  /// No description provided for @dateTooEarly.
  ///
  /// In en, this message translates to:
  /// **'Date is too early'**
  String get dateTooEarly;

  /// No description provided for @dateTooLate.
  ///
  /// In en, this message translates to:
  /// **'Date is too late'**
  String get dateTooLate;

  /// No description provided for @timeRequired.
  ///
  /// In en, this message translates to:
  /// **'Time is required'**
  String get timeRequired;

  /// No description provided for @timeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get timeInvalid;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Timeout error'**
  String get timeoutError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get operationFailed;

  /// No description provided for @operationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get operationCancelled;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @alreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Already exists'**
  String get alreadyExists;

  /// No description provided for @conflictError.
  ///
  /// In en, this message translates to:
  /// **'Conflict error'**
  String get conflictError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

  /// No description provided for @processingError.
  ///
  /// In en, this message translates to:
  /// **'Processing error'**
  String get processingError;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error'**
  String get uploadError;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Download error'**
  String get downloadError;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save error'**
  String get saveError;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load error'**
  String get loadError;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete error'**
  String get deleteError;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error'**
  String get updateError;

  /// No description provided for @createError.
  ///
  /// In en, this message translates to:
  /// **'Create error'**
  String get createError;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error'**
  String get logoutError;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authenticationError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpired;

  /// No description provided for @accountLocked.
  ///
  /// In en, this message translates to:
  /// **'Account locked'**
  String get accountLocked;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account disabled'**
  String get accountDisabled;

  /// No description provided for @accountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Account not verified'**
  String get accountNotVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @phoneNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone not verified'**
  String get phoneNotVerified;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification required'**
  String get verificationRequired;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @verificationExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification expired'**
  String get verificationExpired;

  /// No description provided for @codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code required'**
  String get codeRequired;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Code invalid'**
  String get codeInvalid;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired'**
  String get codeExpired;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get tooManyAttempts;

  /// No description provided for @rateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Rate limit exceeded'**
  String get rateLimitExceeded;

  /// No description provided for @quotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Quota exceeded'**
  String get quotaExceeded;

  /// No description provided for @storageQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Storage quota exceeded'**
  String get storageQuotaExceeded;

  /// No description provided for @bandwidthExceeded.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth exceeded'**
  String get bandwidthExceeded;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get serviceUnavailable;

  /// No description provided for @maintenanceMode.
  ///
  /// In en, this message translates to:
  /// **'Maintenance mode'**
  String get maintenanceMode;

  /// No description provided for @featureDisabled.
  ///
  /// In en, this message translates to:
  /// **'Feature disabled'**
  String get featureDisabled;

  /// No description provided for @upgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'Upgrade required'**
  String get upgradeRequired;

  /// No description provided for @subscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Subscription required'**
  String get subscriptionRequired;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get subscriptionExpired;

  /// No description provided for @paymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Payment required'**
  String get paymentRequired;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @insufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds'**
  String get insufficientFunds;

  /// No description provided for @cardDeclined.
  ///
  /// In en, this message translates to:
  /// **'Card declined'**
  String get cardDeclined;

  /// No description provided for @cardExpired.
  ///
  /// In en, this message translates to:
  /// **'Card expired'**
  String get cardExpired;

  /// No description provided for @invalidCard.
  ///
  /// In en, this message translates to:
  /// **'Invalid card'**
  String get invalidCard;

  /// No description provided for @operationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Operation successful'**
  String get operationSuccessful;

  /// No description provided for @saveSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Save successful'**
  String get saveSuccessful;

  /// No description provided for @updateSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Update successful'**
  String get updateSuccessful;

  /// No description provided for @deleteSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Delete successful'**
  String get deleteSuccessful;

  /// No description provided for @createSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Create successful'**
  String get createSuccessful;

  /// No description provided for @uploadSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Upload successful'**
  String get uploadSuccessful;

  /// No description provided for @downloadSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Download successful'**
  String get downloadSuccessful;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @logoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Logout successful'**
  String get logoutSuccessful;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// No description provided for @verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification successful'**
  String get verificationSuccessful;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @settingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Settings updated'**
  String get settingsUpdated;

  /// No description provided for @preferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated'**
  String get preferencesUpdated;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Notification sent'**
  String get notificationSent;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get messageSent;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get failedToSendMessage;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// No description provided for @confirmationSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation sent'**
  String get confirmationSent;

  /// No description provided for @reminderSent.
  ///
  /// In en, this message translates to:
  /// **'Reminder sent'**
  String get reminderSent;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated'**
  String get reportGenerated;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupCreated;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported'**
  String get dataExported;

  /// No description provided for @dataImported.
  ///
  /// In en, this message translates to:
  /// **'Data imported'**
  String get dataImported;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncCompleted;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;

  /// No description provided for @processCompleted.
  ///
  /// In en, this message translates to:
  /// **'Process completed'**
  String get processCompleted;

  /// No description provided for @installationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Installation completed'**
  String get installationCompleted;

  /// No description provided for @configurationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Configuration completed'**
  String get configurationCompleted;

  /// No description provided for @setupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Setup completed'**
  String get setupCompleted;

  /// No description provided for @migrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Migration completed'**
  String get migrationCompleted;

  /// No description provided for @optimizationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Optimization completed'**
  String get optimizationCompleted;

  /// No description provided for @analysisCompleted.
  ///
  /// In en, this message translates to:
  /// **'Analysis completed'**
  String get analysisCompleted;

  /// No description provided for @scanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Scan completed'**
  String get scanCompleted;

  /// No description provided for @testCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test completed'**
  String get testCompleted;

  /// No description provided for @validationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Validation completed'**
  String get validationCompleted;

  /// No description provided for @processingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Processing completed'**
  String get processingCompleted;

  /// No description provided for @calculationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Calculation completed'**
  String get calculationCompleted;

  /// No description provided for @generationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Generation completed'**
  String get generationCompleted;

  /// No description provided for @conversionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Conversion completed'**
  String get conversionCompleted;

  /// No description provided for @compressionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Compression completed'**
  String get compressionCompleted;

  /// No description provided for @decompressionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Decompression completed'**
  String get decompressionCompleted;

  /// No description provided for @encryptionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Encryption completed'**
  String get encryptionCompleted;

  /// No description provided for @decryptionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Decryption completed'**
  String get decryptionCompleted;

  /// No description provided for @filterPresetSaved.
  ///
  /// In en, this message translates to:
  /// **'Filter preset saved'**
  String get filterPresetSaved;

  /// No description provided for @basicFilters.
  ///
  /// In en, this message translates to:
  /// **'Basic filters'**
  String get basicFilters;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @saveCurrentFilters.
  ///
  /// In en, this message translates to:
  /// **'Save current filters'**
  String get saveCurrentFilters;

  /// No description provided for @enterPresetName.
  ///
  /// In en, this message translates to:
  /// **'Enter preset name'**
  String get enterPresetName;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date created'**
  String get dateCreated;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @verifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get verifiedOnly;

  /// No description provided for @showOnlyVerifiedItems.
  ///
  /// In en, this message translates to:
  /// **'Show only verified items'**
  String get showOnlyVerifiedItems;

  /// No description provided for @urgentOnly.
  ///
  /// In en, this message translates to:
  /// **'Urgent only'**
  String get urgentOnly;

  /// No description provided for @showOnlyUrgentRequests.
  ///
  /// In en, this message translates to:
  /// **'Show only urgent requests'**
  String get showOnlyUrgentRequests;

  /// No description provided for @newYork.
  ///
  /// In en, this message translates to:
  /// **'New York'**
  String get newYork;

  /// No description provided for @losAngeles.
  ///
  /// In en, this message translates to:
  /// **'Los Angeles'**
  String get losAngeles;

  /// No description provided for @chicago.
  ///
  /// In en, this message translates to:
  /// **'Chicago'**
  String get chicago;

  /// No description provided for @houston.
  ///
  /// In en, this message translates to:
  /// **'Houston'**
  String get houston;

  /// No description provided for @phoenix.
  ///
  /// In en, this message translates to:
  /// **'Phoenix'**
  String get phoenix;

  /// No description provided for @philadelphia.
  ///
  /// In en, this message translates to:
  /// **'Philadelphia'**
  String get philadelphia;

  /// No description provided for @myDonationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'My Donations - Coming Soon'**
  String get myDonationsComingSoon;

  /// No description provided for @browseDonationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Browse Donations - Coming Soon'**
  String get browseDonationsComingSoon;

  /// No description provided for @myRequestsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'My Requests - Coming Soon'**
  String get myRequestsComingSoon;

  /// No description provided for @browseRequestsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Browse Requests - Coming Soon'**
  String get browseRequestsComingSoon;

  /// No description provided for @createDonationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Donation - Coming Soon'**
  String get createDonationComingSoon;

  /// No description provided for @createRequestComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Request - Coming Soon'**
  String get createRequestComingSoon;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile - Coming Soon'**
  String get profileComingSoon;

  /// No description provided for @messagesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Messages - Coming Soon'**
  String get messagesComingSoon;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications - Coming Soon'**
  String get notificationsComingSoon;

  /// No description provided for @analyticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Analytics - Coming Soon'**
  String get analyticsComingSoon;

  /// No description provided for @userManagementComingSoon.
  ///
  /// In en, this message translates to:
  /// **'User Management - Coming Soon'**
  String get userManagementComingSoon;

  /// No description provided for @reportsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reports - Coming Soon'**
  String get reportsComingSoon;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// No description provided for @noRouteDefinedForPath.
  ///
  /// In en, this message translates to:
  /// **'No route defined for this path'**
  String get noRouteDefinedForPath;

  /// No description provided for @errorLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard: {error}'**
  String errorLoadingDashboard(String error);

  /// No description provided for @noPermissionAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get noPermissionAccess;

  /// No description provided for @errorLoadingRequests.
  ///
  /// In en, this message translates to:
  /// **'Error loading requests: {error}'**
  String errorLoadingRequests(String error);

  /// No description provided for @errorUpdatingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error updating request: {error}'**
  String errorUpdatingRequest(String error);

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String errorLoadingUsers(String error);

  /// No description provided for @errorDeletingUser.
  ///
  /// In en, this message translates to:
  /// **'Error deleting user: {error}'**
  String errorDeletingUser(String error);

  /// No description provided for @requestUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request {status} successfully'**
  String requestUpdatedSuccessfully(String status);

  /// No description provided for @userDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccessfully;

  /// Success message when a user is blocked
  ///
  /// In en, this message translates to:
  /// **'{userName} has been blocked successfully'**
  String userBlockedSuccess(String userName);

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @requestNumber.
  ///
  /// In en, this message translates to:
  /// **'Request #{id}'**
  String requestNumber(String id);

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get switchToArabic;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// No description provided for @searchUserToChat.
  ///
  /// In en, this message translates to:
  /// **'Search for a user to start chatting'**
  String get searchUserToChat;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for users'**
  String get startTypingToSearch;

  /// No description provided for @conversationDetails.
  ///
  /// In en, this message translates to:
  /// **'Conversation Details'**
  String get conversationDetails;

  /// No description provided for @firstMessage.
  ///
  /// In en, this message translates to:
  /// **'First message'**
  String get firstMessage;

  /// No description provided for @archiveConversation.
  ///
  /// In en, this message translates to:
  /// **'Archive Conversation'**
  String get archiveConversation;

  /// No description provided for @messageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String messageCount(int count);

  /// No description provided for @searchByNameEmailLocation.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, or location...'**
  String get searchByNameEmailLocation;

  /// No description provided for @failedToSearchUsers.
  ///
  /// In en, this message translates to:
  /// **'Failed to search users'**
  String get failedToSearchUsers;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @fiveMiles.
  ///
  /// In en, this message translates to:
  /// **'5 miles'**
  String get fiveMiles;

  /// No description provided for @tenMiles.
  ///
  /// In en, this message translates to:
  /// **'10 miles'**
  String get tenMiles;

  /// No description provided for @twentyFiveMiles.
  ///
  /// In en, this message translates to:
  /// **'25 miles'**
  String get twentyFiveMiles;

  /// No description provided for @fiftyMiles.
  ///
  /// In en, this message translates to:
  /// **'50 miles'**
  String get fiftyMiles;

  /// No description provided for @anyDistance.
  ///
  /// In en, this message translates to:
  /// **'Any distance'**
  String get anyDistance;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// No description provided for @likeNew.
  ///
  /// In en, this message translates to:
  /// **'Like New'**
  String get likeNew;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @minAmount.
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get maxAmount;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @itemCondition.
  ///
  /// In en, this message translates to:
  /// **'Item Condition'**
  String get itemCondition;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @amountRange.
  ///
  /// In en, this message translates to:
  /// **'Amount Range'**
  String get amountRange;

  /// No description provided for @sortOptions.
  ///
  /// In en, this message translates to:
  /// **'Sort Options'**
  String get sortOptions;

  /// No description provided for @savedPresets.
  ///
  /// In en, this message translates to:
  /// **'Saved Presets'**
  String get savedPresets;

  /// No description provided for @noSavedPresets.
  ///
  /// In en, this message translates to:
  /// **'No saved presets'**
  String get noSavedPresets;

  /// No description provided for @applyPreset.
  ///
  /// In en, this message translates to:
  /// **'Apply preset'**
  String get applyPreset;

  /// No description provided for @deletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get deletePreset;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From: {date}'**
  String fromDate(String date);

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To: {date}'**
  String toDate(String date);

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeFilters(int count);

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (Optional)'**
  String get reasonOptional;

  /// No description provided for @whyBlockingUser.
  ///
  /// In en, this message translates to:
  /// **'Why are you blocking this user?'**
  String get whyBlockingUser;

  /// No description provided for @blockingUserWarning.
  ///
  /// In en, this message translates to:
  /// **'Blocking this user will prevent them from contacting you and viewing your donations.'**
  String get blockingUserWarning;

  /// No description provided for @failedToBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to block user'**
  String get failedToBlockUser;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete {itemName}?'**
  String deleteItem(String itemName);

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// No description provided for @areYouSureProceed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed?'**
  String get areYouSureProceed;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @startMakingDifferenceFirst.
  ///
  /// In en, this message translates to:
  /// **'Start making a difference by creating your first donation'**
  String get startMakingDifferenceFirst;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @browseAvailableDonations.
  ///
  /// In en, this message translates to:
  /// **'Browse available donations and request items you need'**
  String get browseAvailableDonations;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get tryAdjustingFilters;

  /// No description provided for @noUsersMatchCriteria.
  ///
  /// In en, this message translates to:
  /// **'No users match your search criteria'**
  String get noUsersMatchCriteria;

  /// No description provided for @noDonationsMatchCriteria.
  ///
  /// In en, this message translates to:
  /// **'No donations match your search criteria'**
  String get noDonationsMatchCriteria;

  /// No description provided for @noPermissionPage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get noPermissionPage;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status: '**
  String get filterByStatus;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @fromUser.
  ///
  /// In en, this message translates to:
  /// **'From: {name}'**
  String fromUser(String name);

  /// No description provided for @toUser.
  ///
  /// In en, this message translates to:
  /// **'To: {name}'**
  String toUser(String name);

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteUser(String name);

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by role: '**
  String get filterByRole;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @conversationUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Conversation unarchived'**
  String get conversationUnarchived;

  /// No description provided for @failedToChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Failed to change language'**
  String get failedToChangeLanguage;

  /// No description provided for @changingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Changing language...'**
  String get changingLanguage;

  /// No description provided for @conversationInfo.
  ///
  /// In en, this message translates to:
  /// **'Conversation Info'**
  String get conversationInfo;

  /// No description provided for @noFilters.
  ///
  /// In en, this message translates to:
  /// **'No filters'**
  String get noFilters;

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String categoriesCount(int count);

  /// No description provided for @statusesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} statuses'**
  String statusesCount(int count);

  /// No description provided for @approvedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Approved by Admin'**
  String get approvedByAdmin;

  /// No description provided for @rejectedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Admin'**
  String get rejectedByAdmin;

  /// No description provided for @allDonationsReviewed.
  ///
  /// In en, this message translates to:
  /// **'All donations have been reviewed'**
  String get allDonationsReviewed;

  /// No description provided for @messageSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get messageSentSuccessfully;

  /// No description provided for @requestsFilled.
  ///
  /// In en, this message translates to:
  /// **'Requests Filled'**
  String get requestsFilled;

  /// No description provided for @blockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserTitle;

  /// No description provided for @blockUserWarning.
  ///
  /// In en, this message translates to:
  /// **'Blocking this user will prevent them from contacting you and viewing your donations.'**
  String get blockUserWarning;

  /// No description provided for @blockUserReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (Optional)'**
  String get blockUserReasonLabel;

  /// No description provided for @blockUserReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you blocking this user?'**
  String get blockUserReasonHint;

  /// No description provided for @blockUserButton.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserButton;

  /// Shows pending operations count
  ///
  /// In en, this message translates to:
  /// **'{count} pending operation{plural} will sync when online'**
  String pendingOperationsText(int count, String plural);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language / اللغة'**
  String get languageLabel;

  /// Error message when user search fails
  ///
  /// In en, this message translates to:
  /// **'Failed to search users: {error}'**
  String failedToSearchUsersError(String error);

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @blockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsersTitle;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get noBlockedUsers;

  /// No description provided for @noBlockedUsersDescription.
  ///
  /// In en, this message translates to:
  /// **'Users you block will appear here'**
  String get noBlockedUsersDescription;

  /// No description provided for @donationsWithFilters.
  ///
  /// In en, this message translates to:
  /// **'Donations with Filters'**
  String get donationsWithFilters;

  /// No description provided for @noFiltersApplied.
  ///
  /// In en, this message translates to:
  /// **'No filters applied. Showing all donations.'**
  String get noFiltersApplied;

  /// No description provided for @yourImpact.
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// No description provided for @donationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} donations'**
  String donationsCount(int count);

  /// No description provided for @fullActivityLogComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Full activity log coming soon'**
  String get fullActivityLogComingSoon;

  /// No description provided for @goalTracking.
  ///
  /// In en, this message translates to:
  /// **'Goal Tracking'**
  String get goalTracking;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Goal'**
  String get monthlyGoal;

  /// No description provided for @archiveConversationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive conversation with {name}?'**
  String archiveConversationConfirm(String name);

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @conversationArchived.
  ///
  /// In en, this message translates to:
  /// **'Conversation archived'**
  String get conversationArchived;

  /// No description provided for @resetNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Notification Settings'**
  String get resetNotificationSettings;

  /// No description provided for @resetNotificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will reset all notification settings to their default values. Are you sure?'**
  String get resetNotificationConfirm;

  /// No description provided for @notificationSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Notification settings reset to defaults'**
  String get notificationSettingsReset;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications on your device'**
  String get pushNotificationsDesc;

  /// No description provided for @emailNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications via email'**
  String get emailNotificationsDesc;

  /// No description provided for @messageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Message Notifications'**
  String get messageNotifications;

  /// No description provided for @messageNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new messages'**
  String get messageNotificationsDesc;

  /// No description provided for @donationUpdates.
  ///
  /// In en, this message translates to:
  /// **'Donation Updates'**
  String get donationUpdates;

  /// No description provided for @donationUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive updates about your donations'**
  String get donationUpdatesDesc;

  /// No description provided for @pleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Please log in again'**
  String get pleaseLoginAgain;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle dark/light theme'**
  String get darkModeDesc;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage notification settings'**
  String get notificationsDesc;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageDesc;

  /// No description provided for @updateProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Picture'**
  String get updateProfilePicture;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadingAvatar.
  ///
  /// In en, this message translates to:
  /// **'Uploading avatar...'**
  String get uploadingAvatar;

  /// No description provided for @avatarUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Avatar uploaded successfully!'**
  String get avatarUploadedSuccess;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotification;

  /// No description provided for @deleteNotificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get deleteNotificationConfirm;

  /// No description provided for @syncCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully'**
  String get syncCompletedSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @forceSync.
  ///
  /// In en, this message translates to:
  /// **'Force Sync'**
  String get forceSync;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @givingBridge.
  ///
  /// In en, this message translates to:
  /// **'GivingBridge'**
  String get givingBridge;

  /// No description provided for @pleaseSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting'**
  String get pleaseSelectReason;

  /// No description provided for @pleaseProvideDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description'**
  String get pleaseProvideDescription;

  /// No description provided for @reportSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmittedSuccess;

  /// No description provided for @searchHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Search history cleared'**
  String get searchHistoryCleared;

  /// No description provided for @screenForRoute.
  ///
  /// In en, this message translates to:
  /// **'Screen for route: {route}'**
  String screenForRoute(String route);
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
