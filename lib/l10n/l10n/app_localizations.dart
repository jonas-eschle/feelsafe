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

  /// Deceptive Angela dialog title (after wrong-PIN threshold).
  ///
  /// In en, this message translates to:
  /// **'Old PIN entered'**
  String get angelaDialogTitle;

  /// Deceptive Angela dialog body.
  ///
  /// In en, this message translates to:
  /// **'It looks like you used an old PIN. Are you sure you want to proceed?'**
  String get angelaDialogBody;

  /// Deceptive Angela dialog cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get angelaDialogCancel;

  /// Deceptive Angela dialog confirm button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get angelaDialogConfirm;

  /// Generic cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic confirm/OK action.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Title shown when the user tries to save a profile name containing 'Angela'.
  ///
  /// In en, this message translates to:
  /// **'Heads up about the name \"Angela\"'**
  String get profileAngelaWarningTitle;

  /// Body of the Angela-name warning dialog.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela uses \"Angela\" as a safety keyword. Using it as your own name could be confusing. Save anyway?'**
  String get profileAngelaWarningBody;

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

  /// Submit button used by the launch-gate PIN entry.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get pinSubmit;

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

  /// Title for the start-session confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Start a session?'**
  String get homeStartConfirmTitle;

  /// Body for the start-session confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Make sure your contacts and PIN are configured. The session will run in the foreground and your selected mode will guide check-ins.'**
  String get homeStartConfirmBody;

  /// Title for the dialog shown when one or more permissions needed by the selected mode were not granted.
  ///
  /// In en, this message translates to:
  /// **'Some permissions are missing'**
  String get homePermissionsMissingTitle;

  /// Body of the dialog explaining which permissions the selected mode needs but did not get.
  ///
  /// In en, this message translates to:
  /// **'The following permissions were not granted. Without them, the corresponding chain steps will fail silently:'**
  String get homePermissionsMissingBody;

  /// Button that starts the session even though some permissions were denied.
  ///
  /// In en, this message translates to:
  /// **'Start anyway'**
  String get homePermissionsContinueAnyway;

  /// Label for the notification permission in the missing-permissions dialog.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homePermissionsNotification;

  /// Label for the location permission in the missing-permissions dialog.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homePermissionsLocation;

  /// Label for the call-phone permission in the missing-permissions dialog.
  ///
  /// In en, this message translates to:
  /// **'Phone calls'**
  String get homePermissionsCallPhone;

  /// Label for the SMS permission in the missing-permissions dialog.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get homePermissionsSendSms;

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

  /// Banner shown when zero contacts are configured.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts configured.'**
  String get homeContactsBannerNone;

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

  /// Default option in the per-contact language dropdown.
  ///
  /// In en, this message translates to:
  /// **'Default (use app language)'**
  String get contactLanguageDefault;

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

  /// Title of the picker shown when creating a new mode.
  ///
  /// In en, this message translates to:
  /// **'Start from'**
  String get modesNewPickerTitle;

  /// Picker option that opens an empty mode editor.
  ///
  /// In en, this message translates to:
  /// **'Blank mode'**
  String get modesNewPickerBlank;

  /// Subtitle for the Blank-mode picker option.
  ///
  /// In en, this message translates to:
  /// **'Start with an empty chain'**
  String get modesNewPickerBlankSubtitle;

  /// Picker option that clones an existing mode as the starting template.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String modesNewPickerFromTemplate(String name);

  /// Subtitle for the From-template picker option.
  ///
  /// In en, this message translates to:
  /// **'Copy this mode\'s chain and triggers'**
  String get modesNewPickerFromTemplateSubtitle;

  /// Default name for a newly cloned mode.
  ///
  /// In en, this message translates to:
  /// **'Copy of {name}'**
  String modesNewPickerCopyName(String name);

  /// Badge label shown next to built-in templates in the new-mode picker.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get modesNewPickerBuiltinBadge;

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

  /// Distress-mode selector.
  ///
  /// In en, this message translates to:
  /// **'Distress mode'**
  String get modeFieldDistressMode;

  /// Default option in distress-mode selector.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get modeFieldDistressModeDefault;

  /// Header above the chain-step list.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
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

  /// Step-type picker: shows the rest of the step types when the top three (hold button, disguised reminder, hardware trigger) are not enough (Issues-v4 #8).
  ///
  /// In en, this message translates to:
  /// **'More options...'**
  String get stepPickerMore;

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

  /// Retry-count field. Renamed per Issues-v4 #4 from 'Retries' to clarify the count semantics.
  ///
  /// In en, this message translates to:
  /// **'Number of retries'**
  String get stepFieldRetryCount;

  /// Randomize field.
  ///
  /// In en, this message translates to:
  /// **'Timing jitter'**
  String get stepFieldRandomize;

  /// Per-step randomize switch label (Issues-v4 #11).
  ///
  /// In en, this message translates to:
  /// **'Randomize timing (±20%)'**
  String get stepFieldRandomizeToggle;

  /// Tooltip for the wait-seconds field.
  ///
  /// In en, this message translates to:
  /// **'How long to wait before this step starts.'**
  String get stepFieldWaitTooltip;

  /// Tooltip for the duration-seconds field.
  ///
  /// In en, this message translates to:
  /// **'How long the step is active before the grace window starts.'**
  String get stepFieldDurationTooltip;

  /// Tooltip for the grace-period field.
  ///
  /// In en, this message translates to:
  /// **'Time after the active phase to confirm safety before the next step fires.'**
  String get stepFieldGraceTooltip;

  /// Tooltip for the retry-count field.
  ///
  /// In en, this message translates to:
  /// **'How many times to repeat this step before escalating.'**
  String get stepFieldRetryCountTooltip;

  /// Tooltip for the reminder repeat-interval field (Issues-v4 #4).
  ///
  /// In en, this message translates to:
  /// **'How often the disguised reminder fires while waiting for a check-in.'**
  String get stepFieldReminderIntervalTooltip;

  /// Tooltip for the reminder grace-period field (Issues-v4 #4).
  ///
  /// In en, this message translates to:
  /// **'How long the user has to confirm safety after the reminder appears.'**
  String get stepFieldReminderGraceTooltip;

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

  /// AppBar title for the per-step preview screen (issues-v4 #10).
  ///
  /// In en, this message translates to:
  /// **'Step preview'**
  String get stepPreviewTitle;

  /// Shown when the preview screen is opened without the required query parameters.
  ///
  /// In en, this message translates to:
  /// **'Missing step or mode reference.'**
  String get stepPreviewMissingParams;

  /// Shown when the modeId in the preview URL does not resolve to a saved mode.
  ///
  /// In en, this message translates to:
  /// **'Mode not found.'**
  String get stepPreviewModeNotFound;

  /// Shown when the stepId in the preview URL does not exist in the resolved mode.
  ///
  /// In en, this message translates to:
  /// **'Step not found in this mode.'**
  String get stepPreviewStepNotFound;

  /// Shown when running the simulation strategy threw.
  ///
  /// In en, this message translates to:
  /// **'Preview failed: {error}'**
  String stepPreviewError(Object error);

  /// Button on the preview screen that re-runs the strategy.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get stepPreviewReplay;

  /// Caption above the preview hold button.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the button to feel the live response.'**
  String get stepPreviewHoldButtonHint;

  /// Visible label inside the preview hold button.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get stepPreviewHoldButtonLabel;

  /// Semantics label for the preview hold button.
  ///
  /// In en, this message translates to:
  /// **'Hold to preview'**
  String get stepPreviewHoldButtonSemantic;

  /// Confirmation shown after the user releases the preview hold button.
  ///
  /// In en, this message translates to:
  /// **'Released. The session would now enter the grace window.'**
  String get stepPreviewHoldButtonReleased;

  /// Caption shown beneath the Replay button on the fake-call preview.
  ///
  /// In en, this message translates to:
  /// **'The fake call screen will appear. Slide to answer or hold the red button to simulate distress.'**
  String get stepPreviewFakeCallHint;

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

  /// Auto-record-audio toggle (issues-v4 #6).
  ///
  /// In en, this message translates to:
  /// **'Auto-record audio'**
  String get stepConfigSmsAutoRecordAudio;

  /// Auto-record-video toggle (issues-v4 #6).
  ///
  /// In en, this message translates to:
  /// **'Auto-record video'**
  String get stepConfigSmsAutoRecordVideo;

  /// Slider label for the recording duration when auto-record is on (issues-v4 #6).
  ///
  /// In en, this message translates to:
  /// **'Recording duration'**
  String get stepConfigSmsRecordDuration;

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

  /// Maximum gap between presses for the repeat-press pattern.
  ///
  /// In en, this message translates to:
  /// **'Press window (ms)'**
  String get stepConfigHardwarePressWindow;

  /// Threshold seconds for the long-press pattern.
  ///
  /// In en, this message translates to:
  /// **'Long-press duration (s)'**
  String get stepConfigHardwareLongDuration;

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

  /// Title of templates screen.
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get templatesTitle;

  /// Empty state for templates list.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
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

  /// Title of profile editor.
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

  /// Profile own phone number field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profileFieldPhoneNumber;

  /// Free-form physical description (hair, height, etc.).
  ///
  /// In en, this message translates to:
  /// **'Physical description'**
  String get profileFieldPhysicalDescription;

  /// Blood type field.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get profileFieldBloodType;

  /// Allergies field.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get profileFieldAllergies;

  /// Medications field.
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

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// System theme option.
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

  /// Label for the language picker drop-down.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguagePicker;

  /// ListTile title for the emergency call number.
  ///
  /// In en, this message translates to:
  /// **'Emergency number'**
  String get settingsEmergencyNumberLabel;

  /// TextField hint inside the emergency-number dialog.
  ///
  /// In en, this message translates to:
  /// **'e.g., 112'**
  String get settingsEmergencyNumberHint;

  /// Save button inside the emergency-number dialog.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsEmergencyNumberSave;

  /// Redo onboarding row label.
  ///
  /// In en, this message translates to:
  /// **'Redo onboarding'**
  String get settingsRedoOnboarding;

  /// Confirmation body before redoing onboarding.
  ///
  /// In en, this message translates to:
  /// **'This will reset your setup. Continue?'**
  String get settingsRedoOnboardingConfirm;

  /// Body of the redo-onboarding confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Your current configuration is preserved.'**
  String get settingsRedoOnboardingBody;

  /// Confirm button in the redo-onboarding dialog.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get settingsRedoOnboardingProceed;

  /// Toggle: ramp volume gradually when the alarm fires.
  ///
  /// In en, this message translates to:
  /// **'Gradual alarm volume'**
  String get settingsAlarmGradualVolume;

  /// Slider label showing the gradual-volume ramp duration.
  ///
  /// In en, this message translates to:
  /// **'Ramp duration: {seconds}s'**
  String settingsAlarmGradualVolumeDuration(int seconds);

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

  /// Toggle: enable biometric prompt before App PIN keypad.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics for App PIN'**
  String get securityAppPinBiometric;

  /// Toggle: enable biometric prompt before session-end PIN.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics for Session-end PIN'**
  String get securitySessionEndPinBiometric;

  /// Toggle: biometric path for distress-trigger cancel.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to cancel distress'**
  String get securityDistressCancelBiometric;

  /// Row that opens a keypad to verify the duress PIN was entered correctly.
  ///
  /// In en, this message translates to:
  /// **'Test duress PIN'**
  String get securityDuressTest;

  /// Subtitle for the duress-test row.
  ///
  /// In en, this message translates to:
  /// **'Verify your duress PIN works.'**
  String get securityDuressTestSubtitle;

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

  /// Button to set a PIN.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get securitySetPin;

  /// Button to change a PIN.
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

  /// Error when the two PIN entries don't match.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
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

  /// Prompt shown to the user by the OS biometric sheet when the PIN dialog opens with a biometric service.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue'**
  String get pinEntryBiometricReason;

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

  /// Timer display selector label.
  ///
  /// In en, this message translates to:
  /// **'Timer display'**
  String get stealthTimerDisplay;

  /// Stealth timer display option: normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get stealthTimerDisplayNormal;

  /// Stealth timer display option: small corner.
  ///
  /// In en, this message translates to:
  /// **'Small (corner)'**
  String get stealthTimerDisplaySmall;

  /// Stealth timer display option: hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get stealthTimerDisplayNone;

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

  /// Title of battery alert screen.
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

  /// Title of event defaults screen.
  ///
  /// In en, this message translates to:
  /// **'Event defaults'**
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

  /// Title of history retention screen.
  ///
  /// In en, this message translates to:
  /// **'History & retention'**
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
  /// **'Backup & restore'**
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

  /// Tab label for real (non-simulated) sessions on the past-events screen.
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get historyTabReal;

  /// Tab label for simulated sessions on the past-events screen.
  ///
  /// In en, this message translates to:
  /// **'Simulated'**
  String get historyTabSimulated;

  /// Hint text for the history search field.
  ///
  /// In en, this message translates to:
  /// **'Search by mode name'**
  String get historySearchHint;

  /// Mode filter dropdown — all option.
  ///
  /// In en, this message translates to:
  /// **'All modes'**
  String get historyFilterModeAll;

  /// Mode filter dropdown label.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get historyFilterModeLabel;

  /// Button label that opens the date-range picker.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get historyDateRangePick;

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

  /// Version line on about.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String aboutVersion(Object version);

  /// Credits line on about.
  ///
  /// In en, this message translates to:
  /// **'Built with care for people on their way home.'**
  String get aboutCredits;

  /// Title of feedback form.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
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

  /// Send button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
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

  /// Indicator that simulation speed is capped at 60x while app is backgrounded.
  ///
  /// In en, this message translates to:
  /// **'Capped at 60× in background'**
  String get sessionSimSpeedBackgroundCap;

  /// Label of the advanced-controls toggle in simulation.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get sessionSimAdvancedLabel;

  /// Simulation button — fires the distress mode.
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

  /// TTS fallback phrase spoken when the bundled fake-call voice asset is missing. Read aloud, so plain spoken language.
  ///
  /// In en, this message translates to:
  /// **'Hi, I am running late. I will call you back soon.'**
  String get audioRunningLatePhrase;

  /// Default SMS body template used by smsContact steps when no per-step template is set. Placeholders: {name}, {location}, {time}.
  ///
  /// In en, this message translates to:
  /// **'{name} may need help. Location: {location}. Time: {time}.'**
  String smsDefaultTemplate(Object name, Object location, Object time);

  /// Default pre-call SMS body sent ahead of a phone-call-contact step. Placeholders: {name}.
  ///
  /// In en, this message translates to:
  /// **'{name} is trying to reach you. Please expect a call.'**
  String smsDefaultPreCallTemplate(Object name);

  /// Simulation summary for a loud-alarm step. {tail} is either the localized 'flash' or 'vibrate' word.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Loud alarm + {tail}'**
  String simLoudAlarm(Object tail);

  /// Word substituted into simLoudAlarm when the step's flashScreen=true.
  ///
  /// In en, this message translates to:
  /// **'flash'**
  String get simLoudAlarmTailFlash;

  /// Word substituted into simLoudAlarm when the step's flashScreen=false.
  ///
  /// In en, this message translates to:
  /// **'vibrate'**
  String get simLoudAlarmTailVibrate;

  /// Simulation summary for an smsContact step. {channel} is sms/whatsapp/telegram, {count} is the number of contacts that match the step's channel.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would send {channel} to {count} contacts'**
  String simSmsContact(Object channel, int count);

  /// Simulation summary for a fakeCall step. {caller} is the configured caller name (defaults to 'Angela').
  ///
  /// In en, this message translates to:
  /// **'[SIM] Incoming call from {caller}'**
  String simFakeCallRing(Object caller);

  /// Simulation summary for a countdownWarning step. {seconds} is the step duration.
  ///
  /// In en, this message translates to:
  /// **'[SIM] {seconds}s countdown warning'**
  String simCountdownWarning(int seconds);

  /// Simulation summary for a phoneCallContact step when a contact resolves. {name} is the target contact's name.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would call {name}'**
  String simPhoneCall(Object name);

  /// Simulation summary for a phoneCallContact step that has no resolvable contact.
  ///
  /// In en, this message translates to:
  /// **'[SIM] No contact to call'**
  String get simNoContactToCall;

  /// Simulation summary for a callEmergency step. {number} is the resolved emergency number.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would dial {number}'**
  String simCallEmergency(Object number);

  /// Simulation summary for a hardwareButton step (no-op strategy).
  ///
  /// In en, this message translates to:
  /// **'[SIM] Hardware trigger armed'**
  String get simHardwareButton;

  /// Simulation summary for a holdButton step (no-op strategy).
  ///
  /// In en, this message translates to:
  /// **'[SIM] Waiting for hold button'**
  String get simHoldButton;

  /// Simulation summary for a disguisedReminder step that resolves a template. {title} is the template title.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would show \"{title}\"'**
  String simDisguisedReminder(Object title);

  /// Simulation summary for a disguisedReminder step when no templates are available.
  ///
  /// In en, this message translates to:
  /// **'[SIM] No reminder template available'**
  String get simDisguisedReminderEmpty;

  /// Simulation summary toast emitted when the user invokes simulateGpsArrival().
  ///
  /// In en, this message translates to:
  /// **'[SIM] GPS arrival trigger fired'**
  String get simGpsArrivalTrigger;

  /// Simulation summary toast emitted when the user invokes simulateLowBattery().
  ///
  /// In en, this message translates to:
  /// **'[SIM] Low-battery alert fired'**
  String get simLowBatteryAlert;

  /// Tagline shown below the Guardian Angela logo.
  ///
  /// In en, this message translates to:
  /// **'Your angel\'s got your back.'**
  String get homeTagline;

  /// Header of the post-onboarding safety setup checklist on home.
  ///
  /// In en, this message translates to:
  /// **'Safety setup'**
  String get homeSafetyChecklistTitle;

  /// Tooltip/label for the checklist dismiss button.
  ///
  /// In en, this message translates to:
  /// **'Dismiss checklist'**
  String get homeSafetyChecklistDismiss;

  /// Checklist item: add contact.
  ///
  /// In en, this message translates to:
  /// **'Add an emergency contact'**
  String get homeSafetyChecklistContact;

  /// Checklist item: set session-end PIN.
  ///
  /// In en, this message translates to:
  /// **'Set a session-end PIN'**
  String get homeSafetyChecklistPin;

  /// Checklist item: configure stealth.
  ///
  /// In en, this message translates to:
  /// **'Configure stealth mode'**
  String get homeSafetyChecklistStealth;

  /// Checklist item: simulate a session.
  ///
  /// In en, this message translates to:
  /// **'Test a simulation'**
  String get homeSafetyChecklistSimulation;

  /// Checklist item: customize a mode.
  ///
  /// In en, this message translates to:
  /// **'Customize a safety mode'**
  String get homeSafetyChecklistMode;

  /// Checklist item: grant permissions.
  ///
  /// In en, this message translates to:
  /// **'Grant required permissions'**
  String get homeSafetyChecklistPermissions;

  /// Checklist progress indicator.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String homeSafetyChecklistProgress(int done, int total);

  /// Greeting on welcome page.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Angela'**
  String get onboardingWelcomeGreeting;

  /// Welcome body text on onboarding.
  ///
  /// In en, this message translates to:
  /// **'I\'m your personal guardian. I walk with you, watch over your evening out, and take action if something feels wrong.'**
  String get onboardingWelcomeBodyFull;

  /// CTA on the welcome page.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Name input label on profile page.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingProfileNameLabel;

  /// Phone input label on profile page.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get onboardingProfilePhoneLabel;

  /// Helper text below phone field.
  ///
  /// In en, this message translates to:
  /// **'Included in emergency messages.'**
  String get onboardingProfilePhoneHelper;

  /// Button to copy SIM phone number into profile (Android only).
  ///
  /// In en, this message translates to:
  /// **'Use my SIM number'**
  String get onboardingProfileUseSimNumber;

  /// SnackBar when SIM number read is unsupported.
  ///
  /// In en, this message translates to:
  /// **'Not available on this platform; please enter manually.'**
  String get onboardingProfileUseSimUnsupported;

  /// Section header for emergency contact on onboarding.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get onboardingEmergencyContactHeader;

  /// Prompt above emergency contact card.
  ///
  /// In en, this message translates to:
  /// **'Who should we contact if something goes wrong?'**
  String get onboardingEmergencyContactPrompt;

  /// Empty-state text on onboarding.
  ///
  /// In en, this message translates to:
  /// **'No contact added yet'**
  String get onboardingEmergencyContactNoneAdded;

  /// Button to launch contact form from onboarding.
  ///
  /// In en, this message translates to:
  /// **'Add emergency contact'**
  String get onboardingEmergencyContactAdd;

  /// Intro text on permissions page.
  ///
  /// In en, this message translates to:
  /// **'These permissions keep you safe during sessions.'**
  String get onboardingPermissionsIntro;

  /// Button that requests all permissions.
  ///
  /// In en, this message translates to:
  /// **'Grant all'**
  String get onboardingPermissionsGrantAll;

  /// Disabled-state label when every permission is granted.
  ///
  /// In en, this message translates to:
  /// **'All granted'**
  String get onboardingPermissionsAllGranted;

  /// Per-tile grant button.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get onboardingPermissionsGrant;

  /// Per-tile open-settings link for permanently denied permissions.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get onboardingPermissionsOpenSettings;

  /// Badge label for required permissions.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get onboardingPermissionsRequired;

  /// Badge label for optional permissions.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get onboardingPermissionsOptional;

  /// Microphone permission label.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get onboardingPermissionsMicrophone;

  /// Camera permission label.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get onboardingPermissionsCamera;

  /// Notification permission description.
  ///
  /// In en, this message translates to:
  /// **'Required for session alerts and reminders.'**
  String get onboardingPermissionsNotificationDesc;

  /// SMS permission description.
  ///
  /// In en, this message translates to:
  /// **'Required to send emergency text alerts.'**
  String get onboardingPermissionsSmsDesc;

  /// Phone permission description.
  ///
  /// In en, this message translates to:
  /// **'Required to make emergency and fake calls.'**
  String get onboardingPermissionsPhoneDesc;

  /// Location permission description.
  ///
  /// In en, this message translates to:
  /// **'Included in emergency messages when GPS logging is on.'**
  String get onboardingPermissionsLocationDesc;

  /// Microphone permission description.
  ///
  /// In en, this message translates to:
  /// **'Used for audio recording during distress.'**
  String get onboardingPermissionsMicrophoneDesc;

  /// Camera permission description.
  ///
  /// In en, this message translates to:
  /// **'Used for flash SOS signaling.'**
  String get onboardingPermissionsCameraDesc;

  /// Title of the session-interrupted modal (Extra 13).
  ///
  /// In en, this message translates to:
  /// **'Session interrupted'**
  String get sessionInterruptedTitle;

  /// Body text of the session-interrupted modal.
  ///
  /// In en, this message translates to:
  /// **'A session was running when the app stopped. The session state is gone — nothing was restored. We\'re showing this so you know.'**
  String get sessionInterruptedBody;

  /// CTA to start a fresh session with the same mode.
  ///
  /// In en, this message translates to:
  /// **'Start same mode'**
  String get sessionInterruptedStartSameMode;

  /// CTA to dismiss the modal.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get sessionInterruptedAcknowledge;

  /// Mode line in the interrupted modal.
  ///
  /// In en, this message translates to:
  /// **'Mode: {name}'**
  String sessionInterruptedMode(Object name);

  /// Started-at line in the interrupted modal.
  ///
  /// In en, this message translates to:
  /// **'Started: {time}'**
  String sessionInterruptedStarted(Object time);

  /// Title of the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get sessionGpsDestinationTitle;

  /// Body of the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Set the destination for GPS-arrival disarm.'**
  String get sessionGpsDestinationBody;

  /// Latitude field label.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get sessionGpsDestinationLat;

  /// Longitude field label.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get sessionGpsDestinationLng;

  /// Button that fills in the current GPS coordinates.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get sessionGpsDestinationUseCurrent;

  /// Skip button on the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get sessionGpsDestinationSkip;

  /// Confirm button on the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get sessionGpsDestinationConfirm;

  /// Section header for chain summary on home.
  ///
  /// In en, this message translates to:
  /// **'Chain summary'**
  String get sessionStartChainSummary;

  /// Title of the end-session confirmation.
  ///
  /// In en, this message translates to:
  /// **'End session?'**
  String get sessionEndConfirmTitle;

  /// Swipe slider label on the end-session dialog.
  ///
  /// In en, this message translates to:
  /// **'Swipe to confirm you want to end the session'**
  String get sessionEndConfirmSwipe;

  /// Title of the emergency-call disarm confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get sessionEmergencyDisarmTitle;

  /// Body of the emergency-call disarm confirmation.
  ///
  /// In en, this message translates to:
  /// **'The emergency call will NOT be made if you disarm now.'**
  String get sessionEmergencyDisarmBody;

  /// Disarm confirmation: cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel (keep disarming)'**
  String get sessionEmergencyDisarmCancel;

  /// Disarm confirmation: go-back button.
  ///
  /// In en, this message translates to:
  /// **'Go back (keep session)'**
  String get sessionEmergencyDisarmGoBack;

  /// Title shown during the distress confirmation window.
  ///
  /// In en, this message translates to:
  /// **'Distress activated'**
  String get distressConfirmTitle;

  /// Countdown subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to cancel — you have {seconds} seconds'**
  String distressConfirmCountdown(int seconds);

  /// Cancel button on distress confirmation.
  ///
  /// In en, this message translates to:
  /// **'Tap to cancel'**
  String get distressConfirmCancel;

  /// Footer text on distress confirmation.
  ///
  /// In en, this message translates to:
  /// **'If not cancelled, distress chain will begin immediately.'**
  String get distressConfirmFooter;

  /// Title shown for the simulation PIN prompt.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get simulationPinPromptTitle;

  /// Body text on simulation PIN prompt.
  ///
  /// In en, this message translates to:
  /// **'Practice entering your Session End PIN'**
  String get simulationPinPromptBody;

  /// Skip button on simulation PIN prompt.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get simulationPinPromptSkip;

  /// Shake feedback on wrong PIN in simulation.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get simulationPinIncorrect;

  /// Section header for general settings.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralHeader;

  /// Section header for app settings.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsAppHeader;

  /// Section header for configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get settingsConfigurationHeader;

  /// Theme label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// Language label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// Prompt shown when an action is blocked during an active session.
  ///
  /// In en, this message translates to:
  /// **'End your session first.'**
  String get settingsSessionLockedBlocker;

  /// Security section link.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurityRow;

  /// Subtitle for the security row.
  ///
  /// In en, this message translates to:
  /// **'App PIN, Session End PIN, Duress PIN'**
  String get settingsSecuritySubtitle;

  /// Stealth row label.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get settingsStealthRow;

  /// Stealth row subtitle when disabled.
  ///
  /// In en, this message translates to:
  /// **'Stealth: OFF'**
  String get settingsStealthSummaryOff;

  /// Stealth row subtitle when enabled.
  ///
  /// In en, this message translates to:
  /// **'Stealth: ON'**
  String get settingsStealthSummaryOn;

  /// Profile row label.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileRow;

  /// Modes row label.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get settingsModesRow;

  /// Distress modes row label.
  ///
  /// In en, this message translates to:
  /// **'Distress modes'**
  String get settingsDistressModesRow;

  /// Battery alert row label.
  ///
  /// In en, this message translates to:
  /// **'Battery alert'**
  String get settingsBatteryAlertRow;

  /// Event defaults row label.
  ///
  /// In en, this message translates to:
  /// **'Event defaults'**
  String get settingsEventDefaultsRow;

  /// GPS logging row label.
  ///
  /// In en, this message translates to:
  /// **'GPS logging'**
  String get settingsGpsLoggingRow;

  /// Reminder templates row label.
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get settingsRemindersRow;

  /// Notifications row label.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsRow;

  /// History & retention row label.
  ///
  /// In en, this message translates to:
  /// **'History & retention'**
  String get settingsHistoryRetentionRow;

  /// About row label.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutRow;

  /// Feedback row label.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsFeedbackRow;

  /// Backup & restore row label.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get settingsBackupRow;

  /// Open source licenses row.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get settingsOssLicenses;

  /// Export settings button.
  ///
  /// In en, this message translates to:
  /// **'Export settings'**
  String get settingsExport;

  /// Import settings button.
  ///
  /// In en, this message translates to:
  /// **'Import settings'**
  String get settingsImport;

  /// Backup import confirmation.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite all current data. Continue?'**
  String get settingsImportConfirmBody;

  /// Header for the App PIN section.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get securityAppPinTitle;

  /// App PIN explanation.
  ///
  /// In en, this message translates to:
  /// **'Locks the app each time you open it.'**
  String get securityAppPinBody;

  /// Header for session end PIN.
  ///
  /// In en, this message translates to:
  /// **'Session End PIN'**
  String get securitySessionEndPinTitle;

  /// Session end PIN explanation.
  ///
  /// In en, this message translates to:
  /// **'Required to disarm or end a running session.'**
  String get securitySessionEndPinBody;

  /// Header for duress PIN.
  ///
  /// In en, this message translates to:
  /// **'Duress PIN'**
  String get securityDuressPinTitle;

  /// Duress PIN explanation.
  ///
  /// In en, this message translates to:
  /// **'Entered at any prompt to silently fire the distress chain.'**
  String get securityDuressPinBody;

  /// Button to remove a PIN.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get securityRemovePin;

  /// Biometric toggle.
  ///
  /// In en, this message translates to:
  /// **'Allow biometric'**
  String get securityBiometricToggle;

  /// PIN timeout slider label.
  ///
  /// In en, this message translates to:
  /// **'PIN timeout (seconds)'**
  String get securityPinTimeoutLabel;

  /// Wrong PIN threshold slider label.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN attempts before escalation'**
  String get securityWrongPinThresholdLabel;

  /// Deceptive dialog toggle label.
  ///
  /// In en, this message translates to:
  /// **'Show deceptive dialog on wrong PIN'**
  String get securityDeceptiveDialogToggle;

  /// Heading for entering a new PIN.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get pinSetupEnterNew;

  /// Heading for confirming a new PIN.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get pinSetupConfirmNew;

  /// Validation when PIN is shorter than 4 digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits.'**
  String get pinSetupTooShort;

  /// Validation when PIN collides with another configured PIN.
  ///
  /// In en, this message translates to:
  /// **'This PIN conflicts with another configured PIN.'**
  String get pinSetupCollision;

  /// Snackbar when the PIN is saved.
  ///
  /// In en, this message translates to:
  /// **'PIN saved'**
  String get pinSetupSaved;

  /// Master toggle for stealth mode.
  ///
  /// In en, this message translates to:
  /// **'Enable stealth'**
  String get stealthEnabledLabel;

  /// Stealth fake-name input label.
  ///
  /// In en, this message translates to:
  /// **'Fake app name'**
  String get stealthFakeNameLabel;

  /// Stealth icon preset selector label.
  ///
  /// In en, this message translates to:
  /// **'Fake icon'**
  String get stealthFakeIconLabel;

  /// Stealth notification disguise toggle.
  ///
  /// In en, this message translates to:
  /// **'Notification disguise'**
  String get stealthNotificationDisguiseLabel;

  /// Stealth timer display selector.
  ///
  /// In en, this message translates to:
  /// **'Timer display'**
  String get stealthTimerDisplayLabel;

  /// Toggle to remove branding from session screen.
  ///
  /// In en, this message translates to:
  /// **'Session screen stealth'**
  String get stealthSessionScreenLabel;

  /// GPS logging master toggle.
  ///
  /// In en, this message translates to:
  /// **'Log GPS during sessions'**
  String get gpsLoggingEnabled;

  /// GPS interval slider label.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get gpsLoggingIntervalLabel;

  /// GPS accuracy selector.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get gpsLoggingAccuracyLabel;

  /// GPS accuracy high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get gpsLoggingAccuracyHigh;

  /// GPS accuracy balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get gpsLoggingAccuracyBalanced;

  /// GPS accuracy low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get gpsLoggingAccuracyLow;

  /// GPS coordinate format label.
  ///
  /// In en, this message translates to:
  /// **'Coordinate format'**
  String get gpsLoggingFormatLabel;

  /// GPS format decimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal'**
  String get gpsLoggingFormatDecimal;

  /// GPS format DMS.
  ///
  /// In en, this message translates to:
  /// **'DMS'**
  String get gpsLoggingFormatDms;

  /// GPS format address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get gpsLoggingFormatAddress;

  /// Toggle to include GPS in SMS.
  ///
  /// In en, this message translates to:
  /// **'Append location to SMS'**
  String get gpsLoggingIncludeInSms;

  /// GPS history retention slider label.
  ///
  /// In en, this message translates to:
  /// **'History retention (days)'**
  String get gpsLoggingHistoryRetentionLabel;

  /// Session log retention slider label.
  ///
  /// In en, this message translates to:
  /// **'Session log retention (days)'**
  String get historyRetentionLogsLabel;

  /// Helper text for session log retention.
  ///
  /// In en, this message translates to:
  /// **'Logs older than this move into the trash.'**
  String get historyRetentionLogsHelper;

  /// Trash retention slider label.
  ///
  /// In en, this message translates to:
  /// **'Trash retention (days)'**
  String get historyRetentionTrashLabel;

  /// Helper text for trash retention.
  ///
  /// In en, this message translates to:
  /// **'Trashed logs are permanently deleted after this window.'**
  String get historyRetentionTrashHelper;

  /// Snackbar shown after a retention slider change.
  ///
  /// In en, this message translates to:
  /// **'Retention updated'**
  String get historyRetentionUpdated;

  /// Battery alert enable toggle.
  ///
  /// In en, this message translates to:
  /// **'Enable battery alert'**
  String get batteryAlertEnableLabel;

  /// Battery threshold slider label.
  ///
  /// In en, this message translates to:
  /// **'Battery threshold (%)'**
  String get batteryAlertThresholdLabel;

  /// Section header for the battery alert chain.
  ///
  /// In en, this message translates to:
  /// **'Alert chain'**
  String get batteryAlertChainHeader;

  /// Reset chain button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get batteryAlertResetChain;

  /// Section header for check-in methods.
  ///
  /// In en, this message translates to:
  /// **'Check-in methods'**
  String get eventDefaultsCheckInHeader;

  /// Section header for escalation steps.
  ///
  /// In en, this message translates to:
  /// **'Escalation steps'**
  String get eventDefaultsEscalationHeader;

  /// Section header for panic triggers.
  ///
  /// In en, this message translates to:
  /// **'Panic trigger'**
  String get eventDefaultsPanicHeader;

  /// Create template button.
  ///
  /// In en, this message translates to:
  /// **'Create template'**
  String get templatesCreate;

  /// Bottom sheet entry for cloning a template.
  ///
  /// In en, this message translates to:
  /// **'From template'**
  String get templatesFromTemplateSheet;

  /// Bottom sheet entry for blank template.
  ///
  /// In en, this message translates to:
  /// **'From scratch'**
  String get templatesFromScratchSheet;

  /// Title of template editor when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get templatesEditTitle;

  /// Title of template editor when creating.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templatesCreateTitle;

  /// Template name label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get templatesNameLabel;

  /// Template title label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get templatesTitleLabel;

  /// Template body label.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get templatesBodyLabel;

  /// Tooltip on disabled delete for built-in templates.
  ///
  /// In en, this message translates to:
  /// **'Built-in templates cannot be deleted'**
  String get templatesBuiltinNoDelete;

  /// Title of notification settings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Granted status label.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get notificationsStatusGranted;

  /// Denied status label.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get notificationsStatusDenied;

  /// Unknown status label.
  ///
  /// In en, this message translates to:
  /// **'Not yet asked'**
  String get notificationsStatusUnknown;

  /// Request permission button.
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get notificationsRequest;

  /// Open settings button.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get notificationsOpenSettings;

  /// Profile phone field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profileFieldPhone;

  /// Profile description field.
  ///
  /// In en, this message translates to:
  /// **'Physical description'**
  String get profileFieldDescription;

  /// Medical conditions field.
  ///
  /// In en, this message translates to:
  /// **'Medical conditions'**
  String get profileFieldMedicalConditions;

  /// Emergency instructions field.
  ///
  /// In en, this message translates to:
  /// **'Emergency instructions'**
  String get profileFieldEmergencyInstructions;

  /// Profile photo label.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get profilePhotoLabel;

  /// Profile save confirmation.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// Author line.
  ///
  /// In en, this message translates to:
  /// **'Author: Jonas Eschle'**
  String get aboutAuthor;

  /// Contact email.
  ///
  /// In en, this message translates to:
  /// **'guardian.angela.app@gmail.com'**
  String get aboutEmail;

  /// Privacy policy link.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacyPolicy;

  /// Terms of service link.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get aboutTermsOfService;

  /// Source code link.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;

  /// Support link.
  ///
  /// In en, this message translates to:
  /// **'Support / donate'**
  String get aboutSupport;

  /// Licenses link.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// Bottom tagline on about screen.
  ///
  /// In en, this message translates to:
  /// **'Made with love for LGBTQ+ safety.'**
  String get aboutTagline;

  /// Top heading of feedback form.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you'**
  String get feedbackHeading;

  /// Category label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackCategoryLabel;

  /// Bug option.
  ///
  /// In en, this message translates to:
  /// **'Bug report'**
  String get feedbackCategoryBug;

  /// Feature option.
  ///
  /// In en, this message translates to:
  /// **'Feature request'**
  String get feedbackCategoryFeature;

  /// Other option.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackCategoryOther;

  /// Email label.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get feedbackEmailLabel;

  /// Message label.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackMessageLabel;

  /// Include log checkbox.
  ///
  /// In en, this message translates to:
  /// **'Include last session log'**
  String get feedbackIncludeLog;

  /// Snackbar after sending.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedbackSent;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 10 characters.'**
  String get feedbackMessageRequired;

  /// Backup include logs toggle.
  ///
  /// In en, this message translates to:
  /// **'Include session logs'**
  String get backupIncludeLogs;

  /// Backup include media toggle.
  ///
  /// In en, this message translates to:
  /// **'Include media'**
  String get backupIncludeMedia;

  /// Backup export button.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupExportButton;

  /// Backup import button.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get backupImportButton;

  /// Backup overwrite warning.
  ///
  /// In en, this message translates to:
  /// **'Importing overwrites all current data.'**
  String get backupOverwriteWarning;

  /// Title of past events screen.
  ///
  /// In en, this message translates to:
  /// **'Past sessions'**
  String get pastEventsTitle;

  /// Tab label for real sessions.
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get pastEventsTabReal;

  /// Tab label for simulated sessions.
  ///
  /// In en, this message translates to:
  /// **'Simulated'**
  String get pastEventsTabSimulated;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get pastEventsEmpty;

  /// Search field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by mode name'**
  String get pastEventsSearch;

  /// Delete confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete session log?'**
  String get pastEventsDeleteConfirm;

  /// Delete all action.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get pastEventsDeleteAll;

  /// Trash action.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get pastEventsTrash;

  /// Undo snackbar action.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get pastEventsUndo;

  /// Snackbar after soft delete.
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get pastEventsSoftDeleted;

  /// Title of past event detail.
  ///
  /// In en, this message translates to:
  /// **'Session log'**
  String get pastEventsDetailTitle;

  /// Share button in detail screen.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pastEventsDetailShare;

  /// Delete button in detail screen.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pastEventsDetailDelete;

  /// Button to import from device contacts (Extra 27).
  ///
  /// In en, this message translates to:
  /// **'Import from contacts'**
  String get contactImportFromDevice;

  /// Snackbar when contacts permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied — open Settings to enable.'**
  String get contactImportPermissionDenied;

  /// Unsaved changes title for contact form.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get contactUnsavedDiscardTitle;

  /// Keep editing button.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get contactUnsavedDiscardKeep;

  /// Discard button.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get contactUnsavedDiscardDiscard;

  /// Title of the new mode picker.
  ///
  /// In en, this message translates to:
  /// **'New mode'**
  String get modesNewModeChoiceTitle;

  /// Duplicate action for modes.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get modesDuplicate;

  /// Delete confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete mode?'**
  String get modesDeleteConfirmTitle;

  /// Delete confirmation body.
  ///
  /// In en, this message translates to:
  /// **'{name} will be permanently removed.'**
  String modesDeleteConfirmBody(Object name);

  /// Badge for default distress mode.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get modesDistressDefaultBadge;

  /// Set as default action.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get modesDistressSetDefault;

  /// Tooltip when delete is disabled for last distress mode.
  ///
  /// In en, this message translates to:
  /// **'At least one distress mode is required.'**
  String get modesDistressCantDeleteLast;

  /// Title of distress modes list.
  ///
  /// In en, this message translates to:
  /// **'Distress modes'**
  String get modesDistressTitle;

  /// Toggle in distress mode editor (G-014).
  ///
  /// In en, this message translates to:
  /// **'Allow disarm while active as distress'**
  String get modesAllowDisarmAsDistress;

  /// Title of quick exit prompt.
  ///
  /// In en, this message translates to:
  /// **'Quick exit'**
  String get quickExitTitle;

  /// Body of quick exit prompt.
  ///
  /// In en, this message translates to:
  /// **'Session data will be preserved and encrypted.'**
  String get quickExitBody;

  /// Quick exit confirm button.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get quickExitConfirm;

  /// Validation: name required.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get validationNameRequired;

  /// Validation: name too short.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get validationNameTooShort;

  /// Validation: phone required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required.'**
  String get validationPhoneRequired;

  /// Validation: at least one channel required.
  ///
  /// In en, this message translates to:
  /// **'Select at least one channel.'**
  String get validationChannelsRequired;
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
