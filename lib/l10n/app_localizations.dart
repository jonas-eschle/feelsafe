import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SafeWayHome'**
  String get appTitle;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get endSession;

  /// No description provided for @imSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m OK'**
  String get imSafe;

  /// No description provided for @checkInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you still safe?'**
  String get checkInPrompt;

  /// No description provided for @countdownWarning.
  ///
  /// In en, this message translates to:
  /// **'Tap to confirm you\'re OK ({seconds}s)'**
  String countdownWarning(int seconds);

  /// No description provided for @holdToStaySafe.
  ///
  /// In en, this message translates to:
  /// **'Hold to stay safe'**
  String get holdToStaySafe;

  /// No description provided for @releaseDetected.
  ///
  /// In en, this message translates to:
  /// **'Release detected'**
  String get releaseDetected;

  /// No description provided for @fakeCallIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming call...'**
  String get fakeCallIncoming;

  /// No description provided for @fakeCallAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get fakeCallAnswer;

  /// No description provided for @fakeCallDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get fakeCallDecline;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get contactPhone;

  /// No description provided for @contactRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get contactRelationship;

  /// No description provided for @preferredChannel.
  ///
  /// In en, this message translates to:
  /// **'Preferred Channel'**
  String get preferredChannel;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @phoneCall.
  ///
  /// In en, this message translates to:
  /// **'Phone Call'**
  String get phoneCall;

  /// No description provided for @phoneCallDescription.
  ///
  /// In en, this message translates to:
  /// **'Call your contact directly'**
  String get phoneCallDescription;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @escalationChain.
  ///
  /// In en, this message translates to:
  /// **'Escalation Chain'**
  String get escalationChain;

  /// No description provided for @reminderTemplates.
  ///
  /// In en, this message translates to:
  /// **'Reminder Templates'**
  String get reminderTemplates;

  /// No description provided for @modes.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get modes;

  /// No description provided for @walkMode.
  ///
  /// In en, this message translates to:
  /// **'Walk Mode'**
  String get walkMode;

  /// No description provided for @dateMode.
  ///
  /// In en, this message translates to:
  /// **'Date Mode'**
  String get dateMode;

  /// No description provided for @customMode.
  ///
  /// In en, this message translates to:
  /// **'Custom Mode'**
  String get customMode;

  /// No description provided for @createMode.
  ///
  /// In en, this message translates to:
  /// **'Create Mode'**
  String get createMode;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit Mode'**
  String get editMode;

  /// No description provided for @checkInMechanism.
  ///
  /// In en, this message translates to:
  /// **'Check-in Method'**
  String get checkInMechanism;

  /// No description provided for @holdButton.
  ///
  /// In en, this message translates to:
  /// **'Hold Button'**
  String get holdButton;

  /// No description provided for @disguisedReminder.
  ///
  /// In en, this message translates to:
  /// **'Disguised Reminder'**
  String get disguisedReminder;

  /// No description provided for @checkInInterval.
  ///
  /// In en, this message translates to:
  /// **'Check-in Interval'**
  String get checkInInterval;

  /// No description provided for @missedTolerance.
  ///
  /// In en, this message translates to:
  /// **'Missed Tolerance'**
  String get missedTolerance;

  /// No description provided for @fakeCallSettings.
  ///
  /// In en, this message translates to:
  /// **'Fake Call Settings'**
  String get fakeCallSettings;

  /// No description provided for @callerName.
  ///
  /// In en, this message translates to:
  /// **'Caller Name'**
  String get callerName;

  /// No description provided for @callerPhoto.
  ///
  /// In en, this message translates to:
  /// **'Caller Photo'**
  String get callerPhoto;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Voice Recording'**
  String get voiceRecording;

  /// No description provided for @ringDuration.
  ///
  /// In en, this message translates to:
  /// **'Ring Duration'**
  String get ringDuration;

  /// No description provided for @stepCountdownWarning.
  ///
  /// In en, this message translates to:
  /// **'Countdown Warning'**
  String get stepCountdownWarning;

  /// No description provided for @stepDisguisedReminder.
  ///
  /// In en, this message translates to:
  /// **'Disguised Reminder'**
  String get stepDisguisedReminder;

  /// No description provided for @stepFakeCall.
  ///
  /// In en, this message translates to:
  /// **'Fake Call'**
  String get stepFakeCall;

  /// No description provided for @stepSmsContacts.
  ///
  /// In en, this message translates to:
  /// **'SMS to Contacts'**
  String get stepSmsContacts;

  /// No description provided for @stepLoudAlarm.
  ///
  /// In en, this message translates to:
  /// **'Loud Alarm'**
  String get stepLoudAlarm;

  /// No description provided for @stepCallEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call Emergency Services'**
  String get stepCallEmergency;

  /// No description provided for @emergencyNumber.
  ///
  /// In en, this message translates to:
  /// **'Emergency Number'**
  String get emergencyNumber;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SafeWayHome'**
  String get onboardingWelcome;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal safety companion. Add an emergency contact to get started.'**
  String get onboardingDescription;

  /// No description provided for @onboardingSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Choose your default mode'**
  String get onboardingSelectMode;

  /// No description provided for @onboardingSelectModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Walk Mode monitors while you walk home. Date Mode sends discreet check-ins during meetings or dates.'**
  String get onboardingSelectModeDescription;

  /// No description provided for @onboardingAddContact.
  ///
  /// In en, this message translates to:
  /// **'Add an emergency contact'**
  String get onboardingAddContact;

  /// No description provided for @onboardingAddContactDescription.
  ///
  /// In en, this message translates to:
  /// **'This person will be notified if you don\'t check in.'**
  String get onboardingAddContactDescription;

  /// No description provided for @onboardingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant permissions'**
  String get onboardingPermissions;

  /// No description provided for @onboardingPermissionsDescription.
  ///
  /// In en, this message translates to:
  /// **'SafeWayHome needs location, phone, and SMS access to keep you safe.'**
  String get onboardingPermissionsDescription;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @permissionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permissionLocation;

  /// No description provided for @permissionPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get permissionPhone;

  /// No description provided for @permissionSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get permissionSms;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionDenied;

  /// No description provided for @grantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantPermissions;

  /// No description provided for @permissionsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Permissions Needed'**
  String get permissionsNeeded;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String seconds(int count);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(int count);

  /// No description provided for @sessionActive.
  ///
  /// In en, this message translates to:
  /// **'Session Active'**
  String get sessionActive;

  /// No description provided for @sessionElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed: {time}'**
  String sessionElapsed(String time);

  /// No description provided for @smsMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} may need help.\nLast known location: {locationUrl}\nTime: {time}'**
  String smsMessage(String name, String locationUrl, String time);

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts yet'**
  String get noContactsYet;

  /// No description provided for @deleteContactConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContactConfirmTitle;

  /// No description provided for @deleteContactConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteContactConfirmMessage(String name);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @contactSaved.
  ///
  /// In en, this message translates to:
  /// **'Contact saved'**
  String get contactSaved;

  /// No description provided for @contactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted'**
  String get contactDeleted;

  /// No description provided for @slideToAnswer.
  ///
  /// In en, this message translates to:
  /// **'Slide to answer'**
  String get slideToAnswer;

  /// No description provided for @fakeCallActive.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get fakeCallActive;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get choosePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePhoto;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noFileSelected;

  /// No description provided for @templateCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar Event'**
  String get templateCalendar;

  /// No description provided for @templateDuolingo.
  ///
  /// In en, this message translates to:
  /// **'Language Lesson'**
  String get templateDuolingo;

  /// No description provided for @templateDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery Update'**
  String get templateDelivery;

  /// No description provided for @templateWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather Alert'**
  String get templateWeather;

  /// No description provided for @templateFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness Reminder'**
  String get templateFitness;

  /// No description provided for @templateMessage.
  ///
  /// In en, this message translates to:
  /// **'Message Preview'**
  String get templateMessage;

  /// No description provided for @templateAppUpdate.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get templateAppUpdate;

  /// No description provided for @templateBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery Warning'**
  String get templateBattery;

  /// No description provided for @emergencyNumberSetup.
  ///
  /// In en, this message translates to:
  /// **'Emergency Number'**
  String get emergencyNumberSetup;

  /// No description provided for @emergencyNumberDescription.
  ///
  /// In en, this message translates to:
  /// **'This number will be called as a last resort if you don\'t respond'**
  String get emergencyNumberDescription;

  /// No description provided for @skipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipStep;

  /// No description provided for @skipStepWarning.
  ///
  /// In en, this message translates to:
  /// **'We recommend completing this step'**
  String get skipStepWarning;

  /// No description provided for @createCustomMode.
  ///
  /// In en, this message translates to:
  /// **'Create Custom'**
  String get createCustomMode;

  /// No description provided for @templateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get templateSubtitle;

  /// No description provided for @templateImage.
  ///
  /// In en, this message translates to:
  /// **'Custom Image'**
  String get templateImage;
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
      <String>['de', 'en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
