import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('pl'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// The application name shown in titles and launchers.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela'**
  String get appTitle;

  /// Generic save action.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic delete action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic edit action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic add action.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// Generic close action.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic confirm action.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Generic back action.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Generic done action.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Generic retry action.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// Generic no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// Toggle on label.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get commonEnabled;

  /// Toggle off label.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get commonDisabled;

  /// None / empty placeholder.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// Seconds unit.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get commonSeconds;

  /// Minutes unit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get commonMinutes;

  /// Cancel label used by dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of the home screen.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela'**
  String get homeTitle;

  /// Primary CTA on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get homeStartSession;

  /// Toggle that switches between a real and a simulated session.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get homeSimulate;

  /// Heading shown while a session is running.
  ///
  /// In en, this message translates to:
  /// **'Active session'**
  String get homeActiveSession;

  /// Resume CTA when a session is active.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeResumeSession;

  /// Empty state shown on home when no modes exist.
  ///
  /// In en, this message translates to:
  /// **'No modes yet. Tap Modes to add one.'**
  String get homeNoModes;

  /// Empty state shown on home when no contacts exist.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts yet. Tap Contacts to add one.'**
  String get homeNoContacts;

  /// Settings button on home.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeMenuSettings;

  /// Contacts button on home.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get homeMenuContacts;

  /// Modes button on home.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get homeMenuModes;

  /// History button on home.
  ///
  /// In en, this message translates to:
  /// **'Past sessions'**
  String get homeMenuHistory;

  /// Mode-picker label on home.
  ///
  /// In en, this message translates to:
  /// **'Select mode'**
  String get homeSelectMode;

  /// Title on onboarding welcome page.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Guardian Angela'**
  String get onboardingWelcomeTitle;

  /// Body on onboarding welcome page.
  ///
  /// In en, this message translates to:
  /// **'A companion that keeps you safe on the way home. Guardian Angela watches over you while you walk, run, or travel, and can alert your chosen contacts if you need help.'**
  String get onboardingWelcomeBody;

  /// Title on onboarding profile page.
  ///
  /// In en, this message translates to:
  /// **'Profile & first contact'**
  String get onboardingProfileTitle;

  /// Body on onboarding profile page.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about you so Guardian Angela can share helpful details if you need emergency help. Then add one trusted contact.'**
  String get onboardingProfileBody;

  /// Title on onboarding permissions page.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get onboardingPermissionsTitle;

  /// Body on onboarding permissions page.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela needs a few permissions to keep you safe. Grant them now or later from Settings.'**
  String get onboardingPermissionsBody;

  /// Next button on onboarding.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Skip button on onboarding.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Finish button on last onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// Title of the active-session screen.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// Label of the disarm CTA.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe'**
  String get sessionDisarm;

  /// Pause button on session screen.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get sessionPause;

  /// Resume button on session screen.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get sessionResume;

  /// Prompt on hold-button step.
  ///
  /// In en, this message translates to:
  /// **'Hold to stay safe'**
  String get sessionHoldPrompt;

  /// Accessibility label for the hold button.
  ///
  /// In en, this message translates to:
  /// **'Hold down. Lifting starts a grace period.'**
  String get sessionHoldSemantic;

  /// Step counter.
  ///
  /// In en, this message translates to:
  /// **'Step {index} of {total}'**
  String sessionStepLabel(Object index, Object total);

  /// Miss count badge.
  ///
  /// In en, this message translates to:
  /// **'Missed: {count}'**
  String sessionMissCount(Object count);

  /// Remaining seconds label.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left'**
  String sessionRemaining(Object seconds);

  /// Label shown when session is paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get sessionPausedBadge;

  /// Label shown when session finished.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionPhaseEnded;

  /// Banner for simulated sessions.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get sessionSimulationBanner;

  /// In-app button shown during a disguisedReminder step (Q6, Date Mode). Tapping resets the chain to step 0 without ending the session.
  ///
  /// In en, this message translates to:
  /// **'I\'m checked in'**
  String get sessionCheckIn;

  /// Title of the disarm-trigger confirmation dialog (GPS arrival / timer).
  ///
  /// In en, this message translates to:
  /// **'Disarm trigger fired'**
  String get sessionDisarmTriggerTitle;

  /// Body of the disarm-trigger confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'A disarm trigger fired. End the session?'**
  String get sessionDisarmTriggerBody;

  /// Confirm button on the disarm-trigger dialog.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get sessionDisarmTriggerConfirm;

  /// Cancel button on the disarm-trigger dialog.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sessionDisarmTriggerCancel;

  /// Title of the deceptive dialog shown after the wrong-PIN threshold is reached. 'Angela' is a deliberate safety keyword per spec 06 and MUST be kept in translations.
  ///
  /// In en, this message translates to:
  /// **'Old PIN from Angela'**
  String get wrongPinAngelaTitle;

  /// Body of the deceptive wrong-PIN dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed with this old PIN?'**
  String get wrongPinAngelaBody;

  /// Primary button on the deceptive wrong-PIN dialog.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get wrongPinAngelaConfirm;

  /// Secondary button on the deceptive wrong-PIN dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get wrongPinAngelaCancel;

  /// Heading on the countdown-warning step UI; the screen shows a large countdown timer before the next escalation fires.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get sessionStepCountdownTitle;

  /// Subtitle on the countdown-warning step UI.
  ///
  /// In en, this message translates to:
  /// **'The next escalation fires when the countdown ends. Swipe \'I\'m safe\' below to disarm.'**
  String get sessionStepCountdownBody;

  /// Fallback title shown on a disguisedReminder step when no template title is resolved.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get sessionStepDisguisedDefaultTitle;

  /// Fallback body shown on a disguisedReminder step when no template body is resolved.
  ///
  /// In en, this message translates to:
  /// **'Tap \'I\'m checked in\' to confirm you\'re safe.'**
  String get sessionStepDisguisedDefaultBody;

  /// Status text shown during an smsContact step while messages are being sent. Updates with delivery status when available.
  ///
  /// In en, this message translates to:
  /// **'Sending message to contacts…'**
  String get sessionStepSmsStatus;

  /// Per-message status label shown when the messaging service reports the message was delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get sessionStepSmsDelivered;

  /// Per-message status label shown when the messaging service reports the message was sent (but not yet acknowledged as delivered).
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sessionStepSmsSent;

  /// Per-message status label shown while a message is queued for delivery.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get sessionStepSmsQueued;

  /// Per-message status label shown when the messaging service reports a delivery failure.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get sessionStepSmsFailed;

  /// Status text shown during a phoneCallContact step while the contact is being called.
  ///
  /// In en, this message translates to:
  /// **'Calling emergency contact…'**
  String get sessionStepPhoneCallStatus;

  /// Button shown during a phoneCallContact step that cancels the in-flight call (disarms the session).
  ///
  /// In en, this message translates to:
  /// **'Cancel call'**
  String get sessionStepPhoneCallCancel;

  /// Title shown during a loudAlarm step. The alarm sound is playing; the user can disarm via the I'm safe slider.
  ///
  /// In en, this message translates to:
  /// **'Alarm playing'**
  String get sessionStepLoudAlarmTitle;

  /// Subtitle shown during a loudAlarm step.
  ///
  /// In en, this message translates to:
  /// **'The alarm is sounding to attract attention.'**
  String get sessionStepLoudAlarmBody;

  /// Photosensitive epilepsy warning shown when LoudAlarmConfig.flashScreen is true.
  ///
  /// In en, this message translates to:
  /// **'Photosensitive warning: screen is flashing.'**
  String get sessionStepLoudAlarmFlashWarning;

  /// Status text shown during a callEmergency step before / while the emergency number is dialed.
  ///
  /// In en, this message translates to:
  /// **'Calling emergency services…'**
  String get sessionStepCallEmergencyStatus;

  /// Display of the emergency number being dialed.
  ///
  /// In en, this message translates to:
  /// **'Number: {number}'**
  String sessionStepCallEmergencyNumber(Object number);

  /// Instruction text shown during a hardwareButton step with repeat-press pattern.
  ///
  /// In en, this message translates to:
  /// **'Press {button} {count} times within {windowMs}ms'**
  String sessionStepHardwareButtonRepeat(
    Object button,
    Object count,
    Object windowMs,
  );

  /// Instruction text shown during a hardwareButton step with long-press pattern.
  ///
  /// In en, this message translates to:
  /// **'Hold {button} for {seconds} seconds'**
  String sessionStepHardwareButtonLong(Object button, Object seconds);

  /// Lowercase noun for the volume-up hardware button used in step instructions.
  ///
  /// In en, this message translates to:
  /// **'volume up'**
  String get sessionStepHardwareButtonVolumeUp;

  /// Lowercase noun for the volume-down hardware button used in step instructions.
  ///
  /// In en, this message translates to:
  /// **'volume down'**
  String get sessionStepHardwareButtonVolumeDown;

  /// Lowercase noun for the power hardware button used in step instructions.
  ///
  /// In en, this message translates to:
  /// **'power'**
  String get sessionStepHardwareButtonPower;

  /// Title of the session-completed screen.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionCompletedTitle;

  /// Body on the session-completed screen.
  ///
  /// In en, this message translates to:
  /// **'You arrived safely. Guardian Angela is standing down.'**
  String get sessionCompletedBody;

  /// Return-home CTA after session.
  ///
  /// In en, this message translates to:
  /// **'Return home'**
  String get sessionCompletedReturnHome;

  /// Title of the simulation-summary screen.
  ///
  /// In en, this message translates to:
  /// **'Simulation summary'**
  String get simulationSummaryTitle;

  /// Shown when no steps fired.
  ///
  /// In en, this message translates to:
  /// **'No steps fired during this simulation.'**
  String get simulationSummaryEmpty;

  /// CTA returning to home after sim summary.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get simulationSummaryReturn;

  /// Title of the fake-call screen.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get fakeCallTitle;

  /// Answer-call button.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get fakeCallAnswer;

  /// Decline-call button.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get fakeCallDecline;

  /// Hang-up button.
  ///
  /// In en, this message translates to:
  /// **'Hang up'**
  String get fakeCallHangUp;

  /// Hint text inside the iOS-style slide-to-answer track.
  ///
  /// In en, this message translates to:
  /// **'slide to answer'**
  String get fakeCallSlideToAnswer;

  /// Fallback caller name when the configured callerName is empty.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get fakeCallUnknownCaller;

  /// Incoming-call header for the WhatsApp call style.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp voice call'**
  String get fakeCallIncomingWhatsapp;

  /// Incoming-call header for the Telegram call style.
  ///
  /// In en, this message translates to:
  /// **'Telegram voice call'**
  String get fakeCallIncomingTelegram;

  /// Incoming-call header for the Signal call style.
  ///
  /// In en, this message translates to:
  /// **'Signal voice call'**
  String get fakeCallIncomingSignal;

  /// Top-of-screen brand badge in the WhatsApp fake-call style.
  ///
  /// In en, this message translates to:
  /// **'WHATSAPP'**
  String get fakeCallBrandWhatsapp;

  /// Top-of-screen brand badge in the Telegram fake-call style.
  ///
  /// In en, this message translates to:
  /// **'TELEGRAM'**
  String get fakeCallBrandTelegram;

  /// Top-of-screen brand badge in the Signal fake-call style.
  ///
  /// In en, this message translates to:
  /// **'SIGNAL'**
  String get fakeCallBrandSignal;

  /// Title of the contacts list screen.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get contactsTitle;

  /// Empty state on contacts list.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet. Add one to receive your distress messages.'**
  String get contactsEmpty;

  /// Add-contact FAB.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get contactsAdd;

  /// Title when creating a contact.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get contactFormTitleCreate;

  /// Title when editing a contact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get contactFormTitleEdit;

  /// Name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactFieldName;

  /// Phone number field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get contactFieldPhone;

  /// Relationship field.
  ///
  /// In en, this message translates to:
  /// **'Relationship (optional)'**
  String get contactFieldRelationship;

  /// Per-contact language field.
  ///
  /// In en, this message translates to:
  /// **'SMS language (optional)'**
  String get contactFieldLanguage;

  /// Channels section header.
  ///
  /// In en, this message translates to:
  /// **'Messaging channels'**
  String get contactChannelsHeader;

  /// SMS channel label.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get contactChannelSms;

  /// WhatsApp channel label.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactChannelWhatsapp;

  /// Telegram channel label.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get contactChannelTelegram;

  /// Phone-call channel label.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get contactChannelPhone;

  /// Confirmation title on delete.
  ///
  /// In en, this message translates to:
  /// **'Delete contact?'**
  String get contactDeleteConfirm;

  /// Confirmation body on delete.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from your emergency list.'**
  String contactDeleteBody(Object name);

  /// Validation error for contact form.
  ///
  /// In en, this message translates to:
  /// **'Name and phone number are required.'**
  String get contactRequiredError;

  /// Title of the modes list.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get modesTitle;

  /// Empty state on modes.
  ///
  /// In en, this message translates to:
  /// **'No modes yet. Tap Add to create a mode.'**
  String get modesEmpty;

  /// Add-mode FAB.
  ///
  /// In en, this message translates to:
  /// **'Add mode'**
  String get modesAdd;

  /// Title when creating a mode.
  ///
  /// In en, this message translates to:
  /// **'New mode'**
  String get modeEditorTitleCreate;

  /// Title when editing a mode.
  ///
  /// In en, this message translates to:
  /// **'Edit mode'**
  String get modeEditorTitleEdit;

  /// Mode name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get modeFieldName;

  /// Check-in-type selector.
  ///
  /// In en, this message translates to:
  /// **'Check-in type'**
  String get modeFieldCheckInType;

  /// Distress-chain selector.
  ///
  /// In en, this message translates to:
  /// **'Distress chain'**
  String get modeFieldDistressChain;

  /// Default option in distress-chain selector.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get modeFieldDistressChainDefault;

  /// Header above the chain-step list.
  ///
  /// In en, this message translates to:
  /// **'Escalation chain'**
  String get modeChainHeader;

  /// Button to add a chain step.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get modeChainAddStep;

  /// Empty state on mode chain list.
  ///
  /// In en, this message translates to:
  /// **'No steps yet. Tap Add step.'**
  String get modeChainEmpty;

  /// Label for the mode-icon picker.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get modeFieldIcon;

  /// Title of the icon-picker bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get modeIconPickerTitle;

  /// Option in the icon picker that clears the icon selection.
  ///
  /// In en, this message translates to:
  /// **'No icon'**
  String get modeIconClear;

  /// Section header for distress-trigger list.
  ///
  /// In en, this message translates to:
  /// **'Distress triggers'**
  String get modeDistressHeader;

  /// Empty state for distress triggers.
  ///
  /// In en, this message translates to:
  /// **'No distress triggers configured.'**
  String get modeDistressEmpty;

  /// Button to add a distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Add distress trigger'**
  String get modeDistressAdd;

  /// Distress trigger type: hardware button.
  ///
  /// In en, this message translates to:
  /// **'Hardware button'**
  String get modeDistressTypeHardware;

  /// Hardware-button selector label.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get modeDistressButtonType;

  /// Hardware-button option: volume up.
  ///
  /// In en, this message translates to:
  /// **'Volume up'**
  String get modeDistressButtonVolumeUp;

  /// Hardware-button option: volume down.
  ///
  /// In en, this message translates to:
  /// **'Volume down'**
  String get modeDistressButtonVolumeDown;

  /// Hardware-button option: power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get modeDistressButtonPower;

  /// Distress hardware-pattern selector label.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get modeDistressPattern;

  /// Distress pattern: multiple presses.
  ///
  /// In en, this message translates to:
  /// **'Repeat press'**
  String get modeDistressPatternRepeat;

  /// Distress pattern: long press.
  ///
  /// In en, this message translates to:
  /// **'Long press'**
  String get modeDistressPatternLong;

  /// Distress repeat-press count field.
  ///
  /// In en, this message translates to:
  /// **'Press count'**
  String get modeDistressPressCount;

  /// Distress repeat-press window field, in ms.
  ///
  /// In en, this message translates to:
  /// **'Press window (ms)'**
  String get modeDistressPressWindow;

  /// Distress long-press duration field, in seconds.
  ///
  /// In en, this message translates to:
  /// **'Hold duration (seconds)'**
  String get modeDistressLongDuration;

  /// Compact summary of a repeat-press distress trigger.
  ///
  /// In en, this message translates to:
  /// **'{count} presses / {windowMs} ms'**
  String modeDistressSummaryRepeat(Object count, Object windowMs);

  /// Compact summary of a long-press distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Hold {seconds}s'**
  String modeDistressSummaryLong(Object seconds);

  /// Section header for the per-mode overrides panel.
  ///
  /// In en, this message translates to:
  /// **'Mode overrides'**
  String get modeOverridesHeader;

  /// Toggle that resets a mode override to its app-wide default.
  ///
  /// In en, this message translates to:
  /// **'Use app default'**
  String get modeOverridesUseDefault;

  /// Sub-label for the GPS-logging override row.
  ///
  /// In en, this message translates to:
  /// **'GPS logging'**
  String get modeOverridesGpsLabel;

  /// Sub-label for the stealth override row.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get modeOverridesStealthLabel;

  /// Sub-label for the event-defaults override row.
  ///
  /// In en, this message translates to:
  /// **'Event defaults'**
  String get modeOverridesEventDefaultsLabel;

  /// Sub-label for the local-templates override row.
  ///
  /// In en, this message translates to:
  /// **'Local reminder templates'**
  String get modeOverridesLocalTemplatesLabel;

  /// Per-mode GPS-logging toggle.
  ///
  /// In en, this message translates to:
  /// **'GPS logging enabled'**
  String get modeOverridesGpsEnabled;

  /// Per-mode GPS sampling interval label.
  ///
  /// In en, this message translates to:
  /// **'Sampling interval (seconds)'**
  String get modeOverridesGpsIntervalLabel;

  /// Per-mode GPS-in-SMS toggle.
  ///
  /// In en, this message translates to:
  /// **'Append location to SMS'**
  String get modeOverridesGpsIncludeInSms;

  /// Per-mode stealth toggle.
  ///
  /// In en, this message translates to:
  /// **'Stealth enabled'**
  String get modeOverridesStealthEnabled;

  /// Per-mode stealth fake-name field.
  ///
  /// In en, this message translates to:
  /// **'Fake app name'**
  String get modeOverridesStealthFakeName;

  /// Hint when event defaults are overridden.
  ///
  /// In en, this message translates to:
  /// **'Custom event defaults active for this mode.'**
  String get modeOverridesEventDefaultsHint;

  /// Mode-local template count summary.
  ///
  /// In en, this message translates to:
  /// **'{count} mode-local templates'**
  String modeOverridesLocalTemplatesCount(Object count);

  /// Unsaved-changes prompt title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get modeUnsavedTitle;

  /// Unsaved-changes prompt body.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them and leave the editor?'**
  String get modeUnsavedBody;

  /// Confirm-discard button label.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get modeUnsavedDiscard;

  /// Cancel-discard button label.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get modeUnsavedKeep;

  /// Tooltip / label for the duplicate-step action on a chain step tile.
  ///
  /// In en, this message translates to:
  /// **'Duplicate step'**
  String get stepDuplicate;

  /// Header for the collapsible timing panel on a step tile.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get stepTimingHeader;

  /// Compact summary shown on a collapsed timing panel.
  ///
  /// In en, this message translates to:
  /// **'wait {wait}s / duration {duration}s / grace {grace}s'**
  String stepTimingSummary(Object wait, Object duration, Object grace);

  /// Step-type picker filter: all categories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get stepCategoryAll;

  /// Step-type picker filter: outgoing-action steps (SMS, calls, alarm).
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get stepCategoryAction;

  /// Step-type picker filter: reminder / countdown steps.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get stepCategoryReminder;

  /// Step-type picker filter: hold-button / hardware check-in steps.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get stepCategoryDisarm;

  /// Section header for interval-based GPS tracking settings (DE-3).
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get modeTrackingHeader;

  /// Toggle: enable interval-based GPS recording.
  ///
  /// In en, this message translates to:
  /// **'Record GPS during session'**
  String get modeTrackingEnabled;

  /// Label above the tracking-interval slider.
  ///
  /// In en, this message translates to:
  /// **'Sampling interval'**
  String get modeTrackingIntervalLabel;

  /// Label above the tracking buffer-size slider.
  ///
  /// In en, this message translates to:
  /// **'Buffer size'**
  String get modeTrackingBufferSizeLabel;

  /// Current buffer capacity in points.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String modeTrackingBufferSizeValue(Object count);

  /// Inline warning shown beneath the tracking section.
  ///
  /// In en, this message translates to:
  /// **'Frequent GPS tracking increases battery drain.'**
  String get modeTrackingBatteryNote;

  /// Label for the per-step GPS logging tri-state selector (spec 11 §DE-2).
  ///
  /// In en, this message translates to:
  /// **'GPS logging'**
  String get stepConfigLogGpsLabel;

  /// Tri-state segment label: defer to the per-type/global default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get stepConfigLogGpsDefault;

  /// Tri-state segment label: force GPS logging on for this step.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get stepConfigLogGpsOn;

  /// Tri-state segment label: skip GPS logging for this step.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get stepConfigLogGpsOff;

  /// Muted hint under the GPS selector when set to Default and the resolved value is On.
  ///
  /// In en, this message translates to:
  /// **'Default (On)'**
  String get stepConfigLogGpsDefaultOn;

  /// Muted hint under the GPS selector when set to Default and the resolved value is Off.
  ///
  /// In en, this message translates to:
  /// **'Default (Off)'**
  String get stepConfigLogGpsDefaultOff;

  /// Header for the collapsible More settings tile in step config editors (spec 11 §DE-4).
  ///
  /// In en, this message translates to:
  /// **'More settings'**
  String get moreSettingsHeader;

  /// Header for the More settings tile when one or more rare-toggle fields differ from their defaults.
  ///
  /// In en, this message translates to:
  /// **'More settings ({count} customized)'**
  String moreSettingsHeaderCustomized(int count);

  /// Label for the step-type dropdown in the mode editor.
  ///
  /// In en, this message translates to:
  /// **'Step type'**
  String get stepTypePickerLabel;

  /// Label for holdButton step.
  ///
  /// In en, this message translates to:
  /// **'Hold button'**
  String get stepTypeHoldButton;

  /// Label for disguisedReminder step.
  ///
  /// In en, this message translates to:
  /// **'Disguised reminder'**
  String get stepTypeDisguisedReminder;

  /// Label for countdownWarning step.
  ///
  /// In en, this message translates to:
  /// **'Countdown warning'**
  String get stepTypeCountdownWarning;

  /// Label for fakeCall step.
  ///
  /// In en, this message translates to:
  /// **'Fake call'**
  String get stepTypeFakeCall;

  /// Label for smsContact step.
  ///
  /// In en, this message translates to:
  /// **'SMS contact'**
  String get stepTypeSmsContact;

  /// Label for phoneCallContact step.
  ///
  /// In en, this message translates to:
  /// **'Phone contact'**
  String get stepTypePhoneCallContact;

  /// Label for loudAlarm step.
  ///
  /// In en, this message translates to:
  /// **'Loud alarm'**
  String get stepTypeLoudAlarm;

  /// Label for callEmergency step.
  ///
  /// In en, this message translates to:
  /// **'Call emergency'**
  String get stepTypeCallEmergency;

  /// Label for hardwareButton step.
  ///
  /// In en, this message translates to:
  /// **'Hardware button'**
  String get stepTypeHardwareButton;

  /// Duration field.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get stepFieldDuration;

  /// Grace-period field.
  ///
  /// In en, this message translates to:
  /// **'Grace period (seconds)'**
  String get stepFieldGrace;

  /// Wait field.
  ///
  /// In en, this message translates to:
  /// **'Wait (seconds)'**
  String get stepFieldWait;

  /// Retry-count field.
  ///
  /// In en, this message translates to:
  /// **'Retries'**
  String get stepFieldRetryCount;

  /// Randomize field.
  ///
  /// In en, this message translates to:
  /// **'Timing jitter'**
  String get stepFieldRandomize;

  /// Label for the preview button on step config forms.
  ///
  /// In en, this message translates to:
  /// **'Preview in simulation'**
  String get stepPreview;

  /// Toast shown after preview in simulation.
  ///
  /// In en, this message translates to:
  /// **'Preview ran: {description}'**
  String stepPreviewFired(Object description);

  /// Fake-call caller name.
  ///
  /// In en, this message translates to:
  /// **'Caller name'**
  String get stepConfigFakeCallCaller;

  /// Fake-call decline toggle.
  ///
  /// In en, this message translates to:
  /// **'Decline counts as disarm'**
  String get stepConfigFakeCallDecline;

  /// Flash toggle.
  ///
  /// In en, this message translates to:
  /// **'Strobe screen'**
  String get stepConfigLoudAlarmFlash;

  /// Max-volume toggle.
  ///
  /// In en, this message translates to:
  /// **'Max volume'**
  String get stepConfigLoudAlarmVolume;

  /// Countdown vibrate toggle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get stepConfigCountdownVibrate;

  /// Countdown tone toggle.
  ///
  /// In en, this message translates to:
  /// **'Play tone'**
  String get stepConfigCountdownTone;

  /// Sms selection label.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get stepConfigSmsSelection;

  /// Sms all-contacts option.
  ///
  /// In en, this message translates to:
  /// **'All contacts'**
  String get stepConfigSmsAllContacts;

  /// Sms specific-contact option.
  ///
  /// In en, this message translates to:
  /// **'Specific contacts'**
  String get stepConfigSmsSpecific;

  /// Include-location toggle.
  ///
  /// In en, this message translates to:
  /// **'Include location'**
  String get stepConfigSmsIncludeLocation;

  /// Include-medical-info toggle.
  ///
  /// In en, this message translates to:
  /// **'Include medical info'**
  String get stepConfigSmsIncludeMedical;

  /// Hold release sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Release sensitivity (s)'**
  String get stepConfigHoldReleaseSensitivity;

  /// Reminder interval.
  ///
  /// In en, this message translates to:
  /// **'Reminder interval (seconds)'**
  String get stepConfigReminderInterval;

  /// Template picker label.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get stepConfigReminderTemplate;

  /// Hardware pattern label.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get stepConfigHardwarePattern;

  /// Hardware press count.
  ///
  /// In en, this message translates to:
  /// **'Press count'**
  String get stepConfigHardwarePressCount;

  /// Hardware button field.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get stepConfigHardwareButton;

  /// Volume up label.
  ///
  /// In en, this message translates to:
  /// **'Volume up'**
  String get stepConfigHardwareButtonVolumeUp;

  /// Volume down label.
  ///
  /// In en, this message translates to:
  /// **'Volume down'**
  String get stepConfigHardwareButtonVolumeDown;

  /// Power button label.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get stepConfigHardwareButtonPower;

  /// Repeat press label.
  ///
  /// In en, this message translates to:
  /// **'Repeat press'**
  String get stepConfigHardwarePatternRepeat;

  /// Long press label.
  ///
  /// In en, this message translates to:
  /// **'Long press'**
  String get stepConfigHardwarePatternLong;

  /// Emergency-number override label.
  ///
  /// In en, this message translates to:
  /// **'Emergency number override'**
  String get stepConfigEmergencyNumber;

  /// Confirm-before-calling toggle.
  ///
  /// In en, this message translates to:
  /// **'Confirm before calling'**
  String get stepConfigEmergencyConfirm;

  /// Pre-call SMS toggle.
  ///
  /// In en, this message translates to:
  /// **'Send pre-call SMS'**
  String get stepConfigPhonePreSms;

  /// Title of distress-modes list.
  ///
  /// In en, this message translates to:
  /// **'Distress modes'**
  String get distressModesTitle;

  /// Title of the dialog shown when the user tries to delete a distress mode that is still bound to one or more modes.
  ///
  /// In en, this message translates to:
  /// **'Distress mode is in use'**
  String get distressModeInUseTitle;

  /// Body of the dependent-modes warning dialog.
  ///
  /// In en, this message translates to:
  /// **'This distress mode is still bound to: {modes}. Rebind those modes to a different distress mode before deleting.'**
  String distressModeInUseBody(Object modes);

  /// Empty state on distress modes.
  ///
  /// In en, this message translates to:
  /// **'No distress modes yet.'**
  String get distressModesEmpty;

  /// Add-distress-mode FAB.
  ///
  /// In en, this message translates to:
  /// **'Add distress mode'**
  String get distressModesAdd;

  /// Title when creating a distress mode.
  ///
  /// In en, this message translates to:
  /// **'New distress mode'**
  String get distressModeEditorTitleCreate;

  /// Title when editing a distress mode.
  ///
  /// In en, this message translates to:
  /// **'Edit distress mode'**
  String get distressModeEditorTitleEdit;

  /// Distress mode name field.
  ///
  /// In en, this message translates to:
  /// **'Distress mode name'**
  String get distressModeName;

  /// Label in distress confirmation overlay.
  ///
  /// In en, this message translates to:
  /// **'Triggering distress mode...'**
  String get distressCountdown;

  /// Stealth label in distress confirmation.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get distressCountdownStealth;

  /// Title of the templates list.
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get templatesTitle;

  /// Empty state on templates.
  ///
  /// In en, this message translates to:
  /// **'No templates yet.'**
  String get templatesEmpty;

  /// Add-template FAB.
  ///
  /// In en, this message translates to:
  /// **'Add template'**
  String get templatesAdd;

  /// Title when creating a template.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templateEditorTitleCreate;

  /// Title when editing a template.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get templateEditorTitleEdit;

  /// Template editor-side name field.
  ///
  /// In en, this message translates to:
  /// **'Editor name'**
  String get templateFieldName;

  /// Template reminder-title field.
  ///
  /// In en, this message translates to:
  /// **'Reminder title'**
  String get templateFieldTitle;

  /// Template body field.
  ///
  /// In en, this message translates to:
  /// **'Reminder body'**
  String get templateFieldBody;

  /// Confirmation-type picker.
  ///
  /// In en, this message translates to:
  /// **'Confirmation type'**
  String get templateFieldConfirmationType;

  /// Template keyword field.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get templateFieldKeyword;

  /// Template button-label field.
  ///
  /// In en, this message translates to:
  /// **'Button label'**
  String get templateFieldButtonLabel;

  /// Template display-style picker.
  ///
  /// In en, this message translates to:
  /// **'Display style'**
  String get templateFieldDisplayStyle;

  /// tapButton confirmation label.
  ///
  /// In en, this message translates to:
  /// **'Tap button'**
  String get templateConfirmTapButton;

  /// tapWord confirmation label.
  ///
  /// In en, this message translates to:
  /// **'Tap word'**
  String get templateConfirmTapWord;

  /// swipe confirmation label.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get templateConfirmSwipe;

  /// dismiss confirmation label.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get templateConfirmDismiss;

  /// Full-screen display style.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get templateDisplayFullscreen;

  /// Subtle display style.
  ///
  /// In en, this message translates to:
  /// **'Subtle'**
  String get templateDisplaySubtle;

  /// Title of the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Profile name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileFieldName;

  /// Profile age field.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileFieldAge;

  /// Profile blood type field.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get profileFieldBloodType;

  /// Profile allergies list.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get profileFieldAllergies;

  /// Profile medications list.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get profileFieldMedications;

  /// Profile conditions list.
  ///
  /// In en, this message translates to:
  /// **'Medical conditions'**
  String get profileFieldConditions;

  /// Profile emergency-instructions.
  ///
  /// In en, this message translates to:
  /// **'Emergency instructions'**
  String get profileFieldInstructions;

  /// Add-item action on profile list fields.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get profileAddItem;

  /// Title of the settings hub.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Security submenu entry.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// Stealth submenu entry.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get settingsSectionStealth;

  /// Defaults heading on settings.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get settingsSectionDefaults;

  /// History section header.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get settingsSectionHistory;

  /// Backup submenu entry.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsSectionBackup;

  /// About entry.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// Feedback entry.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsSectionFeedback;

  /// Contacts entry on settings.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get settingsSectionContacts;

  /// Modes entry on settings.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get settingsSectionModes;

  /// Profile entry on settings.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsSectionProfile;

  /// Distress modes entry.
  ///
  /// In en, this message translates to:
  /// **'Distress modes'**
  String get settingsSectionDistressModes;

  /// Templates entry.
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get settingsSectionReminderTemplates;

  /// Battery-alert entry.
  ///
  /// In en, this message translates to:
  /// **'Battery alert'**
  String get settingsSectionBatteryAlert;

  /// Event-defaults entry.
  ///
  /// In en, this message translates to:
  /// **'Step defaults'**
  String get settingsSectionEventDefaults;

  /// GPS logging entry.
  ///
  /// In en, this message translates to:
  /// **'GPS logging'**
  String get settingsSectionGpsLogging;

  /// Notifications entry.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// History retention entry.
  ///
  /// In en, this message translates to:
  /// **'History retention'**
  String get settingsSectionHistoryRetention;

  /// Appearance header.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// Theme mode setting.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeMode;

  /// Light theme label.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme label.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// System theme label.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Language setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Emergency dial number setting.
  ///
  /// In en, this message translates to:
  /// **'Emergency number'**
  String get settingsEmergencyNumber;

  /// DND override toggle.
  ///
  /// In en, this message translates to:
  /// **'Alarm overrides Do Not Disturb'**
  String get settingsAlarmDnd;

  /// Title of the security submenu.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// App-PIN section.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get securityAppPin;

  /// Session-end PIN section.
  ///
  /// In en, this message translates to:
  /// **'Session-end PIN'**
  String get securitySessionEndPin;

  /// Duress-PIN section.
  ///
  /// In en, this message translates to:
  /// **'Duress PIN'**
  String get securityDuressPin;

  /// PIN timeout slider.
  ///
  /// In en, this message translates to:
  /// **'PIN timeout (seconds)'**
  String get securityPinTimeout;

  /// Disable PIN button.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get securityDisablePin;

  /// Set-PIN button.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get securitySetPin;

  /// Change-PIN button.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get securityChangePin;

  /// Title of the PIN-setup screen.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get pinSetupTitle;

  /// Step 1 prompt in PIN setup.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get pinSetupEnter;

  /// Step 2 prompt in PIN setup.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinSetupConfirm;

  /// Error when PINs differ.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get pinSetupMismatch;

  /// Title of the PIN-entry dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pinEntryTitle;

  /// Subtitle of the PIN-entry dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue.'**
  String get pinEntrySubtitle;

  /// Title of stealth screen.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get stealthTitle;

  /// Master stealth toggle.
  ///
  /// In en, this message translates to:
  /// **'Enable stealth'**
  String get stealthEnable;

  /// Fake name field.
  ///
  /// In en, this message translates to:
  /// **'Fake app name'**
  String get stealthFakeName;

  /// Fake icon picker.
  ///
  /// In en, this message translates to:
  /// **'Fake icon'**
  String get stealthFakeIcon;

  /// Disguised notifications toggle.
  ///
  /// In en, this message translates to:
  /// **'Disguise notifications'**
  String get stealthNotificationDisguise;

  /// Timer display toggle.
  ///
  /// In en, this message translates to:
  /// **'Show timer in stealth'**
  String get stealthTimerDisplay;

  /// Session screen stealth toggle.
  ///
  /// In en, this message translates to:
  /// **'Strip branding on session screen'**
  String get stealthSessionScreen;

  /// Stealth icon preset picker title.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get stealthPickerTitle;

  /// Stealth icon preset picker intro.
  ///
  /// In en, this message translates to:
  /// **'Pick how the launcher icon looks.'**
  String get stealthPickerIntro;

  /// Stealth preset: Music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get stealthPresetMusic;

  /// Stealth preset: Calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get stealthPresetCalendar;

  /// Stealth preset: Fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get stealthPresetFitness;

  /// Stealth preset: Weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get stealthPresetWeather;

  /// Stealth preset: News.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get stealthPresetNews;

  /// Stealth preset: Photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get stealthPresetPhotos;

  /// Stealth preset: Notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get stealthPresetNotes;

  /// Stealth preset: Clock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get stealthPresetClock;

  /// Distress confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Are you in danger?'**
  String get distressConfirmationTitle;

  /// Distress cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get distressConfirmationCancel;

  /// Distress countdown copy.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s until distress fires'**
  String distressConfirmationCountdown(Object seconds);

  /// Swipe-to-confirm disarm slider label.
  ///
  /// In en, this message translates to:
  /// **'Swipe to confirm I\'m safe'**
  String get imSafeSliderLabel;

  /// Title of battery-alert screen.
  ///
  /// In en, this message translates to:
  /// **'Battery alert'**
  String get batteryAlertTitle;

  /// Enable battery-alert toggle.
  ///
  /// In en, this message translates to:
  /// **'Enable battery alert'**
  String get batteryAlertEnable;

  /// Threshold slider label.
  ///
  /// In en, this message translates to:
  /// **'Threshold: {percent}%'**
  String batteryAlertThreshold(Object percent);

  /// Title of event-defaults screen.
  ///
  /// In en, this message translates to:
  /// **'Step defaults'**
  String get eventDefaultsTitle;

  /// Lead text on event-defaults screen.
  ///
  /// In en, this message translates to:
  /// **'These defaults apply to any step that does not override them.'**
  String get eventDefaultsBody;

  /// Title of GPS logging screen.
  ///
  /// In en, this message translates to:
  /// **'GPS logging'**
  String get gpsLoggingTitle;

  /// Enable GPS toggle.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS logging'**
  String get gpsLoggingEnable;

  /// Sampling interval slider.
  ///
  /// In en, this message translates to:
  /// **'Sampling interval (seconds)'**
  String get gpsLoggingInterval;

  /// Accuracy picker.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get gpsLoggingAccuracy;

  /// Low accuracy preset.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get gpsAccuracyLow;

  /// Medium accuracy preset.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get gpsAccuracyMedium;

  /// High accuracy preset.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get gpsAccuracyHigh;

  /// Attach-location toggle.
  ///
  /// In en, this message translates to:
  /// **'Attach location to SMS'**
  String get gpsLoggingIncludeSms;

  /// GPS history-retention slider.
  ///
  /// In en, this message translates to:
  /// **'History retention (days)'**
  String get gpsLoggingHistoryDays;

  /// Title of notifications screen.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettingsTitle;

  /// Lead text on notifications screen.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela uses notifications to disguise and drive reminders.'**
  String get notificationSettingsBody;

  /// Title of history-retention screen.
  ///
  /// In en, this message translates to:
  /// **'History retention'**
  String get historyRetentionTitle;

  /// Lead text on history retention.
  ///
  /// In en, this message translates to:
  /// **'How long Guardian Angela keeps past session logs.'**
  String get historyRetentionBody;

  /// Retention slider label.
  ///
  /// In en, this message translates to:
  /// **'Retention: {days} days'**
  String historyRetentionDays(Object days);

  /// Title of backup screen.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// Export button.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get backupExport;

  /// Import button.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get backupImport;

  /// Placeholder message on backup screen.
  ///
  /// In en, this message translates to:
  /// **'Backup is not available yet. Coming soon.'**
  String get backupNotReady;

  /// Label for the optional encryption PIN field on the backup screen.
  ///
  /// In en, this message translates to:
  /// **'Optional PIN (encrypts the bundle)'**
  String get backupPinOptional;

  /// Success snackbar after importing a backup.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully.'**
  String get backupImportOk;

  /// Section header above the per-element backup toggles.
  ///
  /// In en, this message translates to:
  /// **'Include in export'**
  String get backupSelectionHeader;

  /// Always-on toggle showing that settings are always exported.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get backupToggleSettings;

  /// Explanation under the disabled Settings toggle.
  ///
  /// In en, this message translates to:
  /// **'Always included so the backup can be restored.'**
  String get backupToggleSettingsSubtitle;

  /// Toggle to include contacts in the export.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get backupToggleContacts;

  /// Toggle to include user-facing modes in the export.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get backupToggleModes;

  /// Toggle to include distress-flagged modes in the export.
  ///
  /// In en, this message translates to:
  /// **'Distress modes'**
  String get backupToggleDistressModes;

  /// Toggle to include reminder templates in the export.
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get backupToggleTemplates;

  /// Toggle to include session logs in the export.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get backupToggleSessionLogs;

  /// Toggle to include audio-evidence recordings in the export.
  ///
  /// In en, this message translates to:
  /// **'Audio recordings'**
  String get backupToggleRecordings;

  /// Title of the past-sessions screen.
  ///
  /// In en, this message translates to:
  /// **'Past sessions'**
  String get historyTitle;

  /// Empty state on history.
  ///
  /// In en, this message translates to:
  /// **'No past sessions yet.'**
  String get historyEmpty;

  /// Title of the session-detail screen.
  ///
  /// In en, this message translates to:
  /// **'Session details'**
  String get historyDetailTitle;

  /// Title of the evidence-export screen.
  ///
  /// In en, this message translates to:
  /// **'Export evidence'**
  String get evidenceExportTitle;

  /// Copy-as-text button.
  ///
  /// In en, this message translates to:
  /// **'Copy as text'**
  String get evidenceExportAsText;

  /// Copy-as-JSON button.
  ///
  /// In en, this message translates to:
  /// **'Copy as JSON'**
  String get evidenceExportAsJson;

  /// Clipboard-copied toast.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get evidenceCopied;

  /// Title of about screen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Version label on about.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// Credits line on about.
  ///
  /// In en, this message translates to:
  /// **'Built with care for people on their way home.'**
  String get aboutCredits;

  /// Title of feedback screen.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// Lead line on feedback.
  ///
  /// In en, this message translates to:
  /// **'We would love to hear from you.'**
  String get feedbackBody;

  /// Message field label.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackFieldMessage;

  /// Send button on feedback.
  ///
  /// In en, this message translates to:
  /// **'Open email'**
  String get feedbackSend;

  /// Placeholder in pickers when nothing is selected.
  ///
  /// In en, this message translates to:
  /// **'— none —'**
  String get pickerNoneLabel;

  /// Title of the emergency-confirm pre-dial screen.
  ///
  /// In en, this message translates to:
  /// **'Calling {number}'**
  String emergencyConfirmTitle(Object number);

  /// Subtitle of the emergency-confirm pre-dial screen.
  ///
  /// In en, this message translates to:
  /// **'Hold the cancel button to abort.'**
  String get emergencyConfirmSubtitle;

  /// Countdown line on the pre-dial screen.
  ///
  /// In en, this message translates to:
  /// **'Calling in {seconds}s'**
  String emergencyConfirmCountdown(Object seconds);

  /// Cancel button on the pre-dial screen.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get emergencyConfirmCancel;

  /// Header in the calendar stealth UI.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get stealthCalendarUpcoming;

  /// Stealth calendar event title placeholder.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get stealthCalendarUpcomingEvent;

  /// Stealth calendar countdown.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} min'**
  String stealthCalendarUntilEvent(Object minutes);

  /// Today header in the stealth calendar.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get stealthCalendarToday;

  /// Stealth calendar mock event.
  ///
  /// In en, this message translates to:
  /// **'Coffee with Alex'**
  String get stealthCalendarEvent1;

  /// Stealth calendar mock event.
  ///
  /// In en, this message translates to:
  /// **'Standup'**
  String get stealthCalendarEvent2;

  /// Stealth calendar mock event.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get stealthCalendarEvent3;

  /// Stealth calendar mock event.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get stealthCalendarEvent4;

  /// Stealth calendar mock event.
  ///
  /// In en, this message translates to:
  /// **'Dinner with Sam'**
  String get stealthCalendarEvent5;

  /// Hint shown on stealth screens for the disarm gesture.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to end'**
  String get stealthDisarmGestureHint;

  /// Default track title on the stealth music screen.
  ///
  /// In en, this message translates to:
  /// **'Untitled Track'**
  String get stealthMusicTrackTitle;

  /// Default artist on the stealth music screen.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get stealthMusicArtist;

  /// Default album on the stealth music screen.
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get stealthMusicAlbum;

  /// Now-playing label on the stealth music screen.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get stealthMusicNowPlaying;

  /// Disarm-gesture hint on the stealth music screen.
  ///
  /// In en, this message translates to:
  /// **'Swipe to disarm'**
  String get stealthMusicSwipeHint;

  /// Previous-track button label.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get stealthMusicPrevious;

  /// Pause button label.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get stealthMusicPause;

  /// Next-track button label.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get stealthMusicNext;

  /// Podcast show name placeholder.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get stealthPodcastShowName;

  /// Podcast episode title placeholder.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get stealthPodcastEpisodeTitle;

  /// Episodes-list header on the stealth podcast screen.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get stealthPodcastEpisodesHeader;

  /// Speed-toggle label on the stealth podcast screen.
  ///
  /// In en, this message translates to:
  /// **'1x'**
  String get stealthPodcastSpeedLabel;

  /// Stealth podcast episode placeholder.
  ///
  /// In en, this message translates to:
  /// **'Episode 1'**
  String get stealthPodcastEpisode1;

  /// Stealth podcast episode placeholder.
  ///
  /// In en, this message translates to:
  /// **'Episode 2'**
  String get stealthPodcastEpisode2;

  /// Stealth podcast episode placeholder.
  ///
  /// In en, this message translates to:
  /// **'Episode 3'**
  String get stealthPodcastEpisode3;

  /// Stealth podcast episode placeholder.
  ///
  /// In en, this message translates to:
  /// **'Episode 4'**
  String get stealthPodcastEpisode4;

  /// Stealth preset name shown in the picker.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get stealthPresetPodcast;

  /// Stealth preset: no disguise (real session screen).
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get stealthPresetNone;

  /// Label of the simulation speed slider.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get sessionSimSpeedLabel;

  /// Simulation speed value display.
  ///
  /// In en, this message translates to:
  /// **'{value}x'**
  String sessionSimSpeedValue(Object value);

  /// Indicator that simulation speed is capped while app is backgrounded.
  ///
  /// In en, this message translates to:
  /// **'Background-capped'**
  String get sessionSimSpeedBackgroundCap;

  /// Label of the advanced-controls toggle in simulation.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get sessionSimAdvancedLabel;

  /// Simulation button — fires the distress chain.
  ///
  /// In en, this message translates to:
  /// **'Trigger panic'**
  String get sessionSimTriggerPanic;

  /// Simulation button — fakes a GPS arrival event.
  ///
  /// In en, this message translates to:
  /// **'Trigger arrival'**
  String get sessionSimTriggerArrival;

  /// Simulation button — fakes a low-battery event.
  ///
  /// In en, this message translates to:
  /// **'Trigger low battery'**
  String get sessionSimTriggerBattery;

  /// Top-level simulate-arrival action.
  ///
  /// In en, this message translates to:
  /// **'Simulate arrival'**
  String get simulateGpsArrival;

  /// Top-level simulate-low-battery action.
  ///
  /// In en, this message translates to:
  /// **'Simulate low battery'**
  String get simulateLowBattery;

  /// Title of the Q14 launch-gate screen.
  ///
  /// In en, this message translates to:
  /// **'Unlock Guardian Angela'**
  String get launchGateTitle;

  /// Subtitle of the Q14 launch-gate screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN or use biometrics.'**
  String get launchGateSubtitle;

  /// Error label on the Q14 launch-gate screen.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get launchGateWrong;

  /// Reason string for biometric prompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock Guardian Angela'**
  String get launchGateBiometricReason;

  /// Button to fall back to biometric auth on the launch gate.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get launchGateUseBiometric;

  /// Submit button used by the launch-gate PIN entry.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get pinSubmit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'el',
    'en',
    'es',
    'fa',
    'fr',
    'he',
    'hi',
    'pl',
    'ru',
    'uk',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
