// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SafeWayHome';

  @override
  String get startSession => 'Start Session';

  @override
  String get endSession => 'End Session';

  @override
  String get imSafe => 'I\'m OK';

  @override
  String get checkInPrompt => 'Are you still safe?';

  @override
  String countdownWarning(int seconds) {
    return 'Tap to confirm you\'re OK (${seconds}s)';
  }

  @override
  String get holdToStaySafe => 'Hold to stay safe';

  @override
  String get releaseDetected => 'Release detected';

  @override
  String get fakeCallIncoming => 'Incoming call...';

  @override
  String get fakeCallAnswer => 'Answer';

  @override
  String get fakeCallDecline => 'Decline';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Phone Number';

  @override
  String get contactRelationship => 'Relationship';

  @override
  String get preferredChannel => 'Preferred Channel';

  @override
  String get sms => 'SMS';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get telegram => 'Telegram';

  @override
  String get phoneCall => 'Phone Call';

  @override
  String get phoneCallDescription => 'Call your contact directly';

  @override
  String get settings => 'Settings';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get language => 'Language';

  @override
  String get escalationChain => 'Escalation Chain';

  @override
  String get reminderTemplates => 'Reminder Templates';

  @override
  String get modes => 'Modes';

  @override
  String get walkMode => 'Walk Mode';

  @override
  String get dateMode => 'Date Mode';

  @override
  String get customMode => 'Custom Mode';

  @override
  String get createMode => 'Create Mode';

  @override
  String get editMode => 'Edit Mode';

  @override
  String get checkInMechanism => 'Check-in Method';

  @override
  String get holdButton => 'Hold Button';

  @override
  String get disguisedReminder => 'Disguised Reminder';

  @override
  String get checkInInterval => 'Check-in Interval';

  @override
  String get missedTolerance => 'Missed Tolerance';

  @override
  String get fakeCallSettings => 'Fake Call Settings';

  @override
  String get callerName => 'Caller Name';

  @override
  String get callerPhoto => 'Caller Photo';

  @override
  String get voiceRecording => 'Voice Recording';

  @override
  String get ringDuration => 'Ring Duration';

  @override
  String get stepCountdownWarning => 'Countdown Warning';

  @override
  String get stepDisguisedReminder => 'Disguised Reminder';

  @override
  String get stepFakeCall => 'Fake Call';

  @override
  String get stepSmsContacts => 'SMS to Contacts';

  @override
  String get stepLoudAlarm => 'Loud Alarm';

  @override
  String get stepCallEmergency => 'Call Emergency Services';

  @override
  String get emergencyNumber => 'Emergency Number';

  @override
  String get onboardingWelcome => 'Welcome to SafeWayHome';

  @override
  String get onboardingDescription =>
      'Your personal safety companion. Add an emergency contact to get started.';

  @override
  String get onboardingSelectMode => 'Choose your default mode';

  @override
  String get onboardingSelectModeDescription =>
      'Walk Mode monitors while you walk home. Date Mode sends discreet check-ins during meetings or dates.';

  @override
  String get onboardingAddContact => 'Add an emergency contact';

  @override
  String get onboardingAddContactDescription =>
      'This person will be notified if you don\'t check in.';

  @override
  String get onboardingPermissions => 'Grant permissions';

  @override
  String get onboardingPermissionsDescription =>
      'SafeWayHome needs location, phone, and SMS access to keep you safe.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get permissionLocation => 'Location';

  @override
  String get permissionPhone => 'Phone';

  @override
  String get permissionSms => 'SMS';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionDenied => 'Denied';

  @override
  String get grantPermissions => 'Grant Permissions';

  @override
  String get permissionsNeeded => 'Permissions Needed';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String seconds(int count) {
    return '${count}s';
  }

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get sessionActive => 'Session Active';

  @override
  String sessionElapsed(String time) {
    return 'Elapsed: $time';
  }

  @override
  String smsMessage(String name, String locationUrl, String time) {
    return '$name may need help.\nLast known location: $locationUrl\nTime: $time';
  }

  @override
  String get noContactsYet => 'No emergency contacts yet';

  @override
  String get deleteContactConfirmTitle => 'Delete Contact';

  @override
  String deleteContactConfirmMessage(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidPhoneNumber => 'Enter a valid phone number';

  @override
  String get contactSaved => 'Contact saved';

  @override
  String get contactDeleted => 'Contact deleted';

  @override
  String get slideToAnswer => 'Slide to answer';

  @override
  String get fakeCallActive => 'Calling...';

  @override
  String get choosePhoto => 'Choose Photo';

  @override
  String get removePhoto => 'Remove';

  @override
  String get noFileSelected => 'None';

  @override
  String get templateCalendar => 'Calendar Event';

  @override
  String get templateDuolingo => 'Language Lesson';

  @override
  String get templateDelivery => 'Delivery Update';

  @override
  String get templateWeather => 'Weather Alert';

  @override
  String get templateFitness => 'Fitness Reminder';

  @override
  String get templateMessage => 'Message Preview';

  @override
  String get templateAppUpdate => 'App Update';

  @override
  String get templateBattery => 'Battery Warning';

  @override
  String get emergencyNumberSetup => 'Emergency Number';

  @override
  String get emergencyNumberDescription =>
      'This number will be called as a last resort if you don\'t respond';

  @override
  String get skipStep => 'Skip';

  @override
  String get skipStepWarning => 'We recommend completing this step';

  @override
  String get createCustomMode => 'Create Custom';

  @override
  String get templateSubtitle => 'Subtitle';

  @override
  String get templateImage => 'Custom Image';
}
