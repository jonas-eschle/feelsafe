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

  /// Generic dismiss action acknowledging an informational message.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

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

  /// Empty state shown on home when no modes exist.
  ///
  /// In en, this message translates to:
  /// **'No modes yet. Tap Modes to add one.'**
  String get homeNoModes;

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

  /// History button on home.
  ///
  /// In en, this message translates to:
  /// **'Past sessions'**
  String get homeMenuHistory;

  /// Title on onboarding profile page.
  ///
  /// In en, this message translates to:
  /// **'Profile & first contact'**
  String get onboardingProfileTitle;

  /// Title on onboarding permissions page.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get onboardingPermissionsTitle;

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

  /// Button below the Your Name field on onboarding page 2 (spec 04 Extra 28).
  ///
  /// In en, this message translates to:
  /// **'Use my SIM number'**
  String get onboardingUseSimNumber;

  /// Read-only hint displaying the SIM phone number.
  ///
  /// In en, this message translates to:
  /// **'{number}'**
  String onboardingUseSimNumberHint(Object number);

  /// Snackbar shown when SIM read is unavailable on iOS.
  ///
  /// In en, this message translates to:
  /// **'Not available on iOS'**
  String get onboardingUseSimNumberUnsupported;

  /// Snackbar shown when the platform cannot read the SIM number.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read number'**
  String get onboardingUseSimNumberUnavailable;

  /// Snackbar shown when the user denied the runtime permission.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get onboardingUseSimNumberPermissionDenied;

  /// Title of the active-session screen.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// Label of the disarm swipe slider in normal (non-stealth) sessions. Stealth sessions swap this for sessionDisarmStealth.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe'**
  String get sessionDisarm;

  /// Stealth-variant label of the grace-period disarm slider. Replaces sessionDisarm whenever the resolved StealthConfig.enabled is true so the surface no longer reads as a safety-app affordance. Spec 04 §Grace Period Slider.
  ///
  /// In en, this message translates to:
  /// **'No Angela needed'**
  String get sessionDisarmStealth;

  /// Header above the Chain Summary horizontal-pill row on the home screen (spec 04 §Chain Summary).
  ///
  /// In en, this message translates to:
  /// **'Chain Summary'**
  String get homeChainSummaryTitle;

  /// Helper text shown inside the Chain Summary card when the selected mode has zero chain steps.
  ///
  /// In en, this message translates to:
  /// **'This mode has no steps yet — tap the mode to edit.'**
  String get homeChainSummaryEmpty;

  /// Title of the timing-details bottom sheet opened when the user taps a chain summary pill.
  ///
  /// In en, this message translates to:
  /// **'Step: {name}'**
  String homeChainSummaryTimingTitle(Object name);

  /// Wait-phase duration row in the timing-details sheet.
  ///
  /// In en, this message translates to:
  /// **'Wait: {seconds}s'**
  String homeChainSummaryWait(Object seconds);

  /// Active-phase duration row in the timing-details sheet.
  ///
  /// In en, this message translates to:
  /// **'Active: {seconds}s'**
  String homeChainSummaryDuration(Object seconds);

  /// Grace-period duration row in the timing-details sheet.
  ///
  /// In en, this message translates to:
  /// **'Grace period: {seconds}s'**
  String homeChainSummaryGrace(Object seconds);

  /// Retry-count row in the timing-details sheet.
  ///
  /// In en, this message translates to:
  /// **'Retries: {count}'**
  String homeChainSummaryRetry(Object count);

  /// Next-step label in the timing-details sheet. Shown when there is at least one step after the current one.
  ///
  /// In en, this message translates to:
  /// **'Next step: {name}'**
  String homeChainSummaryNextStep(Object name);

  /// Next-step row in the timing-details sheet when the tapped step is the last in the chain.
  ///
  /// In en, this message translates to:
  /// **'Next step: end of chain'**
  String get homeChainSummaryNextStepNone;

  /// Close-button label on the timing-details bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeChainSummaryClose;

  /// Display name for the holdButton chain step type.
  ///
  /// In en, this message translates to:
  /// **'Hold to stay safe'**
  String get chainStepNameHoldButton;

  /// Display name for the disguisedReminder chain step type.
  ///
  /// In en, this message translates to:
  /// **'Disguised reminder'**
  String get chainStepNameDisguisedReminder;

  /// Display name for the countdownWarning chain step type.
  ///
  /// In en, this message translates to:
  /// **'Countdown warning'**
  String get chainStepNameCountdownWarning;

  /// Display name for the fakeCall chain step type.
  ///
  /// In en, this message translates to:
  /// **'Fake call'**
  String get chainStepNameFakeCall;

  /// Display name for the smsContact chain step type.
  ///
  /// In en, this message translates to:
  /// **'SMS contact'**
  String get chainStepNameSmsContact;

  /// Display name for the phoneCallContact chain step type.
  ///
  /// In en, this message translates to:
  /// **'Phone call contact'**
  String get chainStepNamePhoneCallContact;

  /// Display name for the loudAlarm chain step type.
  ///
  /// In en, this message translates to:
  /// **'Loud alarm'**
  String get chainStepNameLoudAlarm;

  /// Display name for the callEmergency chain step type.
  ///
  /// In en, this message translates to:
  /// **'Emergency call'**
  String get chainStepNameCallEmergency;

  /// Display name for the hardwareButton chain step type.
  ///
  /// In en, this message translates to:
  /// **'Hardware button'**
  String get chainStepNameHardwareButton;

  /// Header of the Safety Setup Checklist card on the home screen (spec 04 §Safety Setup Checklist).
  ///
  /// In en, this message translates to:
  /// **'Safety Setup'**
  String get homeChecklistTitle;

  /// Tooltip on the [×] button that permanently dismisses the checklist card.
  ///
  /// In en, this message translates to:
  /// **'Dismiss checklist'**
  String get homeChecklistDismissTooltip;

  /// Tooltip on the chevron button that expands the collapsed checklist card.
  ///
  /// In en, this message translates to:
  /// **'Show checklist'**
  String get homeChecklistExpandTooltip;

  /// Tooltip on the chevron button that collapses the expanded checklist card.
  ///
  /// In en, this message translates to:
  /// **'Hide checklist'**
  String get homeChecklistCollapseTooltip;

  /// Progress text shown next to the progress bar.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String homeChecklistProgress(Object done, Object total);

  /// Brief banner shown the moment the last item is checked. The card auto-dismisses next visit.
  ///
  /// In en, this message translates to:
  /// **'All set — you\'re protected!'**
  String get homeChecklistAllDoneBanner;

  /// Tooltip on the (ℹ) info icon at the end of each checklist row.
  ///
  /// In en, this message translates to:
  /// **'Why this matters'**
  String get homeChecklistInfoTooltip;

  /// Single primary action on info and confirm-only tutorial sheets.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get homeChecklistGotIt;

  /// Primary action on tutorial sheets that deep-link into a settings or modes screen.
  ///
  /// In en, this message translates to:
  /// **'Go there'**
  String get homeChecklistGoThere;

  /// Title of checklist item 1. Completes when at least one EmergencyContact exists.
  ///
  /// In en, this message translates to:
  /// **'Add an emergency contact'**
  String get homeChecklistItem1Title;

  /// Title of checklist item 2. Completes when AppSettings.sessionEndPinHash is non-null.
  ///
  /// In en, this message translates to:
  /// **'Set a session-end PIN'**
  String get homeChecklistItem2Title;

  /// Title of checklist item 3. Completes when AppSettings.defaults.stealth.enabled is true.
  ///
  /// In en, this message translates to:
  /// **'Configure stealth mode'**
  String get homeChecklistItem3Title;

  /// Title of checklist item 4. Completes after the first Simulate session.
  ///
  /// In en, this message translates to:
  /// **'Test a simulation'**
  String get homeChecklistItem4Title;

  /// Title of checklist item 5. Completes when any non-seed SessionMode exists.
  ///
  /// In en, this message translates to:
  /// **'Customize a safety mode'**
  String get homeChecklistItem5Title;

  /// Title of checklist item 6. Completes when Permission.notification.status.isGranted.
  ///
  /// In en, this message translates to:
  /// **'Grant required permissions'**
  String get homeChecklistItem6Title;

  /// Info sheet body for checklist item 1 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts are the people Guardian Angela messages and calls when you fail to check in. Without at least one contact, the chain has nowhere to escalate.'**
  String get checklistInfo1Body;

  /// Info sheet body for checklist item 2 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'A session-end PIN prevents an attacker from quietly ending an active session. They can still attempt it, but typing the wrong PIN five times silently fires your distress chain.'**
  String get checklistInfo2Body;

  /// Info sheet body for checklist item 3 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Stealth mode disguises the active session as something innocuous on your screen — a music player, a paused timer, a blank lock screen. Use it when somebody nearby cannot see you running a safety app.'**
  String get checklistInfo3Body;

  /// Info sheet body for checklist item 4 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Simulation runs your safety mode end-to-end without sending real SMS, placing real calls, or sounding the loud alarm. Use it to learn the timings before you ever need them.'**
  String get checklistInfo4Body;

  /// Info sheet body for checklist item 5 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Custom modes let you tune the steps, timings, and triggers to a specific situation — walking home, a first date, a late shift. The two seed modes are starting points, not the destination.'**
  String get checklistInfo5Body;

  /// Info sheet body for checklist item 6 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Without notification permission, Guardian Angela cannot keep its persistent foreground status, deliver disguised reminders, or warn you that the chain is about to escalate.'**
  String get checklistInfo6Body;

  /// Tutorial sheet body for item 3 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Open the stealth defaults and toggle \'Enable stealth mode\'. From there you can pick a fake music brand, hide the session timer, or disguise the home-screen icon.'**
  String get checklistTutorial3Body;

  /// Tutorial sheet body for item 4 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Tap the outlined \'Simulate\' button on the home screen after selecting a mode. The session runs with an orange border and the [SIM] badge — nothing leaves your phone.'**
  String get checklistTutorial4Body;

  /// Tutorial sheet body for item 5 (kept under 80 words).
  ///
  /// In en, this message translates to:
  /// **'Open the Modes screen and either edit a seed mode (Walk / Date) or create a new one from scratch. Tweak the chain, add a fake call, set custom timings.'**
  String get checklistTutorial5Body;

  /// Prompt on hold-button step.
  ///
  /// In en, this message translates to:
  /// **'Hold to stay safe'**
  String get sessionHoldPrompt;

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

  /// Label shown when session is paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get sessionPausedBadge;

  /// Badge shown when the session auto-paused for a real incoming phone call (spec 01 A2).
  ///
  /// In en, this message translates to:
  /// **'Paused — incoming call'**
  String get sessionPausedIncomingCall;

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

  /// Hint shown during a disguisedReminder wait phase; tapping checks in early (spec 02 Early Check-in D4).
  ///
  /// In en, this message translates to:
  /// **'Tap to check in now'**
  String get sessionReminderEarlyCheckInHint;

  /// Fallback button label for a tapButton disguisedReminder confirmation when the template defines no buttonLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sessionReminderDefaultButton;

  /// Discreet prompt above the tapWord choices on a disguisedReminder; must not reveal the correct word.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get sessionReminderTapWordHint;

  /// Label on the swipe-to-confirm track for a swipe disguisedReminder confirmation.
  ///
  /// In en, this message translates to:
  /// **'Swipe to dismiss'**
  String get sessionReminderSwipeLabel;

  /// Button label for a dismiss-type disguisedReminder confirmation.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get sessionReminderDismissLabel;

  /// Status text shown during an smsContact step while messages are being sent. Updates with delivery status when available.
  ///
  /// In en, this message translates to:
  /// **'Sending message to contacts…'**
  String get sessionStepSmsStatus;

  /// Status text shown during a phoneCallContact step while the contact is being called.
  ///
  /// In en, this message translates to:
  /// **'Calling emergency contact…'**
  String get sessionStepPhoneCallStatus;

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

  /// Minimalist header on the stealth fake-music-player session screen.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get sessionStealthNowPlaying;

  /// Generic track-title chrome shown on the stealth fake music player so it reads as an ordinary music app.
  ///
  /// In en, this message translates to:
  /// **'Untitled Track'**
  String get sessionStealthTrackTitle;

  /// Generic artist-name chrome shown beneath the track title on the stealth fake music player.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get sessionStealthArtistName;

  /// Accessibility label for the album-art placeholder on the stealth fake music player.
  ///
  /// In en, this message translates to:
  /// **'Album art'**
  String get sessionStealthAlbumArtLabel;

  /// Tooltip and accessibility label for the play button on the stealth fake music player (resumes the session).
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get sessionStealthPlay;

  /// Tooltip and accessibility label for the pause button on the stealth fake music player (pauses the session).
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get sessionStealthPause;

  /// Label beside the stealth on/off toggle at the bottom of the fake music player.
  ///
  /// In en, this message translates to:
  /// **'Stealth Mode'**
  String get sessionStealthToggleLabel;

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

  /// Brand badge in the Android native fake-call style.
  ///
  /// In en, this message translates to:
  /// **'PHONE'**
  String get fakeCallBrandAndroid;

  /// Brand badge in the iOS native fake-call style.
  ///
  /// In en, this message translates to:
  /// **'PHONE'**
  String get fakeCallBrandIos;

  /// Brand badge in the minimal fake-call style.
  ///
  /// In en, this message translates to:
  /// **'CALL'**
  String get fakeCallBrandMinimal;

  /// Decline button label when declineIsSafe = true (declining disarms the chain).
  ///
  /// In en, this message translates to:
  /// **'Decline (I\'m Safe)'**
  String get fakeCallDeclineSafeLabel;

  /// Decline button label when declineIsSafe = false (declining keeps the chain running).
  ///
  /// In en, this message translates to:
  /// **'Decline (Stay on alert)'**
  String get fakeCallDeclineUnsafeLabel;

  /// Hint shown next to the decline button explaining the long-press distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Hold 5s for distress'**
  String get fakeCallHoldForDistress;

  /// Indicator chip showing the active voice prompt name when configured.
  ///
  /// In en, this message translates to:
  /// **'TTS prompt: {name}'**
  String fakeCallVoicePrompt(String name);

  /// Indicator chip showing the active vibration pattern name.
  ///
  /// In en, this message translates to:
  /// **'Vibration: {pattern}'**
  String fakeCallVibrationLabel(String pattern);

  /// Vibration pattern name for the OS default pattern.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get fakeCallVibrationPatternDefault;

  /// Label above the slide-to-answer track.
  ///
  /// In en, this message translates to:
  /// **'Slide to answer'**
  String get fakeCallSlideToAnswerHint;

  /// Elapsed call duration mm:ss formatting.
  ///
  /// In en, this message translates to:
  /// **'{mm}:{ss}'**
  String fakeCallActiveDuration(String mm, String ss);

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

  /// Warning shown under the contact form on iOS when SMS is enabled (spec 04:1379).
  ///
  /// In en, this message translates to:
  /// **'On iOS, SMS opens the Messages app. You must tap Send manually.'**
  String get contactFormIosSmsWarning;

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

  /// Compact summary shown on a collapsed timing panel.
  ///
  /// In en, this message translates to:
  /// **'wait {wait}s / duration {duration}s / grace {grace}s'**
  String stepTimingSummary(Object wait, Object duration, Object grace);

  /// Header of the timing subsection in a step's config panel.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get stepConfigTimingHeader;

  /// Header of the type-specific configuration subsection in a step's config panel.
  ///
  /// In en, this message translates to:
  /// **'Event configuration'**
  String get stepConfigEventHeader;

  /// Header of the retry/advanced subsection in a step's config panel.
  ///
  /// In en, this message translates to:
  /// **'Retry & advanced'**
  String get stepConfigAdvancedHeader;

  /// Label for the wait-phase duration field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Wait before firing (seconds)'**
  String get stepFieldWait;

  /// Label for the active-phase duration field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Active duration (seconds)'**
  String get stepFieldDuration;

  /// Label for the grace-period field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Grace period (seconds)'**
  String get stepFieldGrace;

  /// Label for the retry-count field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Retries'**
  String get stepFieldRetryCount;

  /// Label for the per-step timing randomisation toggle.
  ///
  /// In en, this message translates to:
  /// **'Randomise timing (±20%)'**
  String get stepFieldRandomize;

  /// Action to duplicate the current chain step.
  ///
  /// In en, this message translates to:
  /// **'Duplicate step'**
  String get stepDuplicate;

  /// Action to reset a step's configuration to the global defaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get stepResetDefaults;

  /// Header above the SMS-contact recipient grid in a step config.
  ///
  /// In en, this message translates to:
  /// **'Contacts to message'**
  String get smsContactRecipientsHeader;

  /// Recipient summary when every channel-capable contact is selected.
  ///
  /// In en, this message translates to:
  /// **'To: all enabled contacts'**
  String get smsContactSummaryAll;

  /// Recipient summary when no contacts are selected.
  ///
  /// In en, this message translates to:
  /// **'No recipients selected'**
  String get smsContactSummaryNone;

  /// Recipient summary listing the selected contact names.
  ///
  /// In en, this message translates to:
  /// **'To: {names}'**
  String smsContactSummaryTo(Object names);

  /// Tooltip on a greyed contact chip whose channel the contact lacks.
  ///
  /// In en, this message translates to:
  /// **'Not enabled for this contact — edit the contact to add this channel.'**
  String get smsContactChannelDisabledTooltip;

  /// Empty-state row shown when there are no emergency contacts; deep-links to Contacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet — add one in Contacts'**
  String get smsContactEmptyAddPrompt;

  /// Header of the collapsible Safety Options section at the bottom of the mode editor.
  ///
  /// In en, this message translates to:
  /// **'Safety options'**
  String get safetyOptionsHeader;

  /// Label for the distress-mode picker in Safety Options.
  ///
  /// In en, this message translates to:
  /// **'Distress mode'**
  String get safetyOptionsDistressModeTitle;

  /// Dropdown option meaning the mode inherits the app-wide default distress mode.
  ///
  /// In en, this message translates to:
  /// **'Use default distress mode'**
  String get safetyOptionsDistressModeUseDefault;

  /// Dropdown option for inheriting the app-wide default distress mode, naming which mode that resolves to.
  ///
  /// In en, this message translates to:
  /// **'Use default ({name})'**
  String safetyOptionsDistressModeUseDefaultNamed(Object name);

  /// Info-sheet body explaining what the distress mode does.
  ///
  /// In en, this message translates to:
  /// **'When a distress trigger fires (duress PIN, hardware panic, or a wrong-PIN threshold), this mode\'s chain is replaced by the chosen distress mode\'s chain. Leave on the default to use the app-wide distress mode.'**
  String get safetyOptionsDistressModeInfo;

  /// Link below the distress-mode picker that opens the distress-modes screen.
  ///
  /// In en, this message translates to:
  /// **'Manage distress modes'**
  String get safetyOptionsManageDistressModes;

  /// Subsection header for the list of distress triggers.
  ///
  /// In en, this message translates to:
  /// **'Distress triggers'**
  String get safetyOptionsDistressTriggersTitle;

  /// Info-sheet body explaining distress triggers.
  ///
  /// In en, this message translates to:
  /// **'Distress triggers fire the distress chain immediately, in parallel with the main chain. The hardware panic button watches a physical button for the configured press pattern.'**
  String get safetyOptionsDistressTriggersInfo;

  /// Empty state when a mode has no distress triggers configured.
  ///
  /// In en, this message translates to:
  /// **'No distress triggers'**
  String get safetyOptionsDistressTriggersEmpty;

  /// Action to add a hardware-button distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Add hardware panic button'**
  String get safetyOptionsAddHardwarePanic;

  /// Summary of a repeat-press hardware panic trigger.
  ///
  /// In en, this message translates to:
  /// **'{button}: {count}× press'**
  String safetyOptionsTriggerHardwareRepeat(Object button, Object count);

  /// Summary of a long-press hardware panic trigger.
  ///
  /// In en, this message translates to:
  /// **'{button}: hold {seconds}s'**
  String safetyOptionsTriggerHardwareLong(Object button, Object seconds);

  /// Label for the volume-up hardware button.
  ///
  /// In en, this message translates to:
  /// **'Volume up'**
  String get safetyOptionsButtonVolumeUp;

  /// Label for the volume-down hardware button.
  ///
  /// In en, this message translates to:
  /// **'Volume down'**
  String get safetyOptionsButtonVolumeDown;

  /// Label for the hardware-button press-pattern selector.
  ///
  /// In en, this message translates to:
  /// **'Press pattern'**
  String get safetyOptionsTriggerPattern;

  /// Press-pattern option: rapid repeated presses.
  ///
  /// In en, this message translates to:
  /// **'Repeat press'**
  String get safetyOptionsPatternRepeat;

  /// Press-pattern option: a single sustained hold.
  ///
  /// In en, this message translates to:
  /// **'Long press'**
  String get safetyOptionsPatternLong;

  /// Label for the hardware-button selector in a distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get safetyOptionsTriggerButton;

  /// Label for the press-count field of a repeat-press trigger.
  ///
  /// In en, this message translates to:
  /// **'Press count'**
  String get safetyOptionsTriggerPressCount;

  /// Label for the hold-duration field of a long-press trigger.
  ///
  /// In en, this message translates to:
  /// **'Hold duration (seconds)'**
  String get safetyOptionsTriggerHoldDuration;

  /// Subsection header for automatic disarm conditions.
  ///
  /// In en, this message translates to:
  /// **'Disarm triggers'**
  String get safetyOptionsDisarmTriggersTitle;

  /// Toggle label for the GPS-arrival disarm trigger.
  ///
  /// In en, this message translates to:
  /// **'GPS arrival disarm'**
  String get safetyOptionsGpsArrivalTitle;

  /// Info-sheet body explaining GPS-arrival disarm.
  ///
  /// In en, this message translates to:
  /// **'Session ends automatically when you arrive within the configured radius of your destination. You set the destination when starting a session.'**
  String get safetyOptionsGpsArrivalInfo;

  /// Label for the GPS-arrival radius slider.
  ///
  /// In en, this message translates to:
  /// **'Arrival radius'**
  String get safetyOptionsGpsArrivalRadius;

  /// Formats a radius in metres.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String safetyOptionsRadiusMeters(Object meters);

  /// Formats a radius in kilometres.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String safetyOptionsRadiusKilometers(Object km);

  /// Label for the GPS-arrival destination-source selector.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get safetyOptionsDestinationSource;

  /// Destination-source option: prompt the user when a session starts.
  ///
  /// In en, this message translates to:
  /// **'Set destination at session start'**
  String get safetyOptionsDestinationPrompt;

  /// Destination-source option: a stored latitude/longitude.
  ///
  /// In en, this message translates to:
  /// **'Fixed coordinates'**
  String get safetyOptionsDestinationFixed;

  /// Label for the fixed-destination latitude field.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get safetyOptionsLatitude;

  /// Label for the fixed-destination longitude field.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get safetyOptionsLongitude;

  /// Toggle label for the timer disarm trigger.
  ///
  /// In en, this message translates to:
  /// **'Timer disarm'**
  String get safetyOptionsTimerDisarmTitle;

  /// Info-sheet body explaining timer disarm.
  ///
  /// In en, this message translates to:
  /// **'Session ends automatically after the configured time, regardless of whether escalation has started.'**
  String get safetyOptionsTimerDisarmInfo;

  /// Label for the timer-disarm duration slider.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get safetyOptionsTimerDuration;

  /// Formats a duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String safetyOptionsDurationMinutes(Object minutes);

  /// Formats a duration in hours and minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String safetyOptionsDurationHoursMinutes(Object hours, Object minutes);

  /// Subsection header for the GPS-logging tri-state selector.
  ///
  /// In en, this message translates to:
  /// **'GPS logging'**
  String get safetyOptionsGpsLoggingTitle;

  /// Info-sheet body explaining the GPS-logging tri-state.
  ///
  /// In en, this message translates to:
  /// **'Choose whether this mode records your location during a session. Inherit uses your global GPS-logging settings; Custom overrides them for this mode; Off disables logging entirely.'**
  String get safetyOptionsGpsLoggingInfo;

  /// Subsection header for the stealth tri-state selector.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get safetyOptionsStealthTitle;

  /// Info-sheet body explaining the stealth tri-state.
  ///
  /// In en, this message translates to:
  /// **'Choose whether this mode disguises the app during a session. Inherit uses your global stealth settings; Custom overrides them for this mode; Off disables stealth entirely.'**
  String get safetyOptionsStealthInfo;

  /// Tri-state option: inherit the global default.
  ///
  /// In en, this message translates to:
  /// **'Inherit'**
  String get safetyOptionsTriStateInherit;

  /// Tri-state option: override with custom values.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get safetyOptionsTriStateCustom;

  /// Tri-state option: disable the feature for this mode.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get safetyOptionsTriStateOff;

  /// Subsection header for mode-local reminder templates.
  ///
  /// In en, this message translates to:
  /// **'Local templates'**
  String get safetyOptionsLocalTemplatesTitle;

  /// Info-sheet body explaining mode-local templates.
  ///
  /// In en, this message translates to:
  /// **'Local templates are added to the global reminder-template pool for this mode only. Use them for disguised-reminder steps specific to this mode.'**
  String get safetyOptionsLocalTemplatesInfo;

  /// Empty state when a mode has no local templates.
  ///
  /// In en, this message translates to:
  /// **'No local templates'**
  String get safetyOptionsLocalTemplatesEmpty;

  /// Button that opens the editor to create a new mode-local reminder template.
  ///
  /// In en, this message translates to:
  /// **'Add template'**
  String get safetyOptionsAddTemplate;

  /// Link that opens the global reminder-templates screen.
  ///
  /// In en, this message translates to:
  /// **'Manage reminder templates'**
  String get safetyOptionsManageTemplates;

  /// Subsection header for the per-mode event-defaults tri-state.
  ///
  /// In en, this message translates to:
  /// **'Event defaults'**
  String get safetyOptionsEventDefaultsTitle;

  /// Info-sheet body explaining the per-mode event-defaults tri-state.
  ///
  /// In en, this message translates to:
  /// **'Event defaults set the starting configuration for each step type. Inherit uses your global event defaults; Custom overrides them for steps in this mode that have no explicit configuration.'**
  String get safetyOptionsEventDefaultsInfo;

  /// Two-state event-defaults option: inherit the global defaults.
  ///
  /// In en, this message translates to:
  /// **'Inherit'**
  String get safetyOptionsEventDefaultsTwoStateInherit;

  /// Toggle label for allowDisarmAsDistress (distress modes only).
  ///
  /// In en, this message translates to:
  /// **'Allow disarm while active as distress'**
  String get safetyOptionsAllowDisarmAsDistressTitle;

  /// Info-sheet body explaining the allowDisarmAsDistress trade-off.
  ///
  /// In en, this message translates to:
  /// **'Enabling allows you to stop the alert by reaching safety or letting a timer expire. Disabling means only chain completion or shutting down the app stops the alert — stronger against coercion.'**
  String get safetyOptionsAllowDisarmAsDistressInfo;

  /// Empty state on distress modes.
  ///
  /// In en, this message translates to:
  /// **'No distress modes yet.'**
  String get distressModesEmpty;

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

  /// ListTile title for the emergency call number.
  ///
  /// In en, this message translates to:
  /// **'Emergency number'**
  String get settingsEmergencyNumberLabel;

  /// Tooltip on the disabled Redo Onboarding row while a session runs.
  ///
  /// In en, this message translates to:
  /// **'Cannot redo onboarding during an active session'**
  String get settingsRedoOnboardingActiveSessionTooltip;

  /// Title of the bottom sheet for picking an emergency-number preset.
  ///
  /// In en, this message translates to:
  /// **'Choose emergency number'**
  String get settingsEmergencyNumberCountryPickerTitle;

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

  /// Toggle: enable biometric prompt before session-end PIN.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics for Session-end PIN'**
  String get securitySessionEndPinBiometric;

  /// Toggle: enable biometric (fingerprint / Face ID) unlock at the App-lock launch gate, as an alternative to typing the App PIN.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics for App lock'**
  String get securityAppPinBiometric;

  /// Title on the App-lock launch screen shown over the whole app on cold start when an App PIN is set.
  ///
  /// In en, this message translates to:
  /// **'Enter your App PIN'**
  String get launchPinTitle;

  /// Reason text shown inside the system biometric (fingerprint / Face ID) prompt at the launch gate.
  ///
  /// In en, this message translates to:
  /// **'Unlock Guardian Angela'**
  String get launchPinBiometricReason;

  /// Inline error shown beneath the launch-gate keypad after a wrong PIN entry.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get launchPinIncorrect;

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

  /// Error when the two PIN entries don't match.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinSetupMismatch;

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

  /// Title of event defaults screen.
  ///
  /// In en, this message translates to:
  /// **'Event defaults'**
  String get eventDefaultsTitle;

  /// Title of history retention screen.
  ///
  /// In en, this message translates to:
  /// **'History & retention'**
  String get historyRetentionTitle;

  /// Title of backup screen.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

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

  /// Title of feedback form.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackTitle;

  /// Send button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

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

  /// Lock-task / pinned-app mode toggle label (spec 04 §Stealth Settings).
  ///
  /// In en, this message translates to:
  /// **'Pin app during session'**
  String get stealthLockTaskLabel;

  /// Helper subtitle below the lock-task toggle.
  ///
  /// In en, this message translates to:
  /// **'Prevents leaving the app while a session is running. On Android this engages screen-pinning; on other platforms this is a no-op.'**
  String get stealthLockTaskSubtitle;

  /// Tagline shown below the Guardian Angela logo.
  ///
  /// In en, this message translates to:
  /// **'Your angel\'s got your back.'**
  String get homeTagline;

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

  /// Title of the GPS destination prompt sheet.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get sessionGpsDestinationTitle;

  /// Body of the GPS destination prompt sheet.
  ///
  /// In en, this message translates to:
  /// **'Enter the destination coordinates for the GPS arrival disarm trigger.'**
  String get sessionGpsDestinationBody;

  /// Label for the latitude field on the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get sessionGpsDestinationLat;

  /// Label for the longitude field on the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get sessionGpsDestinationLng;

  /// Skip button on the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Skip for this session'**
  String get sessionGpsDestinationSkip;

  /// Confirm button on the GPS destination sheet.
  ///
  /// In en, this message translates to:
  /// **'Use destination'**
  String get sessionGpsDestinationConfirm;

  /// Heading on the swipe-to-confirm end-session overlay.
  ///
  /// In en, this message translates to:
  /// **'End session?'**
  String get sessionEndOverlayTitle;

  /// Body text above the end-session swipe slider.
  ///
  /// In en, this message translates to:
  /// **'Swipe to confirm you want to end the session'**
  String get sessionEndOverlayBody;

  /// Track label inside the end-session swipe slider.
  ///
  /// In en, this message translates to:
  /// **'Swipe to end'**
  String get sessionEndOverlaySwipeLabel;

  /// Badge shown on the end-session overlay during a simulation session.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Practice mode'**
  String get sessionEndOverlaySimBadge;

  /// Title above the PIN keypad shown after a successful end-session swipe.
  ///
  /// In en, this message translates to:
  /// **'Enter Session End PIN'**
  String get sessionEndPinPromptTitle;

  /// Inline hint shown when the user types the app lock PIN at the end-session prompt instead of the Session End PIN.
  ///
  /// In en, this message translates to:
  /// **'Use the Session End PIN, not the app lock PIN.'**
  String get sessionEndPinAppPinMismatch;

  /// Inline error shown beneath the keypad after a wrong PIN entry.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get sessionEndPinIncorrect;

  /// Button shown only in simulation mode that bypasses the PIN check on the end-session prompt.
  ///
  /// In en, this message translates to:
  /// **'Skip (sim only)'**
  String get sessionEndPinSimSkip;

  /// Snack-bar shown when the user hits the wrong-PIN threshold during a simulation session, where the distress chain is suppressed.
  ///
  /// In en, this message translates to:
  /// **'Distress chain would fire (5 wrong PINs)'**
  String get sessionEndSimDistressWouldFire;

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

  /// Title above the PIN keypad shown when the user taps Cancel on the distress confirmation overlay and a Session End PIN is configured.
  ///
  /// In en, this message translates to:
  /// **'Enter Session End PIN'**
  String get distressCancelPinPromptTitle;

  /// Countdown label shown beside the PIN keypad while the 15-second distress-cancel PIN timeout is running.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s remaining'**
  String distressCancelPinTimeoutLabel(int seconds);

  /// Inline error beneath the keypad when a wrong PIN is entered at the distress-cancel gate.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get distressCancelPinIncorrect;

  /// Inline hint when the user types the app lock PIN at the distress-cancel PIN gate instead of the Session End PIN.
  ///
  /// In en, this message translates to:
  /// **'Use the Session End PIN, not the app lock PIN.'**
  String get distressCancelPinAppPinMismatch;

  /// Button visible only in simulation mode that bypasses the distress-cancel PIN gate.
  ///
  /// In en, this message translates to:
  /// **'Skip (sim only)'**
  String get distressCancelPinSimSkip;

  /// Snack-bar shown in simulation when the user hits the wrong-PIN threshold at the distress-cancel PIN gate — the distress chain is suppressed.
  ///
  /// In en, this message translates to:
  /// **'Distress chain would fire (5 wrong PINs)'**
  String get distressCancelSimDistressWouldFire;

  /// Cancel button that returns from the distress-cancel PIN keypad to the distress confirmation overlay.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get distressCancelPinBack;

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

  /// Duration row on the simulation summary.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String simulationSummaryDuration(String duration);

  /// Header above the event-timeline section.
  ///
  /// In en, this message translates to:
  /// **'Event timeline'**
  String get simulationSummaryTimelineHeader;

  /// Share button label on simulation summary.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get simulationSummaryShare;

  /// Badge showing the number of missed events.
  ///
  /// In en, this message translates to:
  /// **'Missed: {count}'**
  String simulationSummaryMissedEventsBadge(int count);

  /// Badge showing the number of distress confirmations.
  ///
  /// In en, this message translates to:
  /// **'Distress: {count}'**
  String simulationSummaryDistressBadge(int count);

  /// Badge showing the number of steps fired.
  ///
  /// In en, this message translates to:
  /// **'Steps fired: {count}'**
  String simulationSummaryStepsFiredBadge(int count);

  /// Subject line when sharing the summary.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela simulation summary'**
  String get simulationSummaryShareSubject;

  /// Notification channel toggle for alarm escalations.
  ///
  /// In en, this message translates to:
  /// **'Alarm escalation'**
  String get notificationsChannelAlarm;

  /// Subtitle for the alarm channel toggle.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts that bypass DND'**
  String get notificationsChannelAlarmDescription;

  /// Notification channel toggle for disguised reminders.
  ///
  /// In en, this message translates to:
  /// **'Disguised reminder'**
  String get notificationsChannelReminder;

  /// Subtitle for the reminders channel toggle.
  ///
  /// In en, this message translates to:
  /// **'Check-in reminders during active session'**
  String get notificationsChannelReminderDescription;

  /// Notification channel toggle for fake-call notifications.
  ///
  /// In en, this message translates to:
  /// **'Fake call'**
  String get notificationsChannelFakeCall;

  /// Subtitle for the fake-call channel toggle.
  ///
  /// In en, this message translates to:
  /// **'Full-screen incoming-call notifications'**
  String get notificationsChannelFakeCallDescription;

  /// Status label when a channel is enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get notificationsChannelEnabled;

  /// Status label when a channel is disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationsChannelDisabled;

  /// Header above the channel toggles list.
  ///
  /// In en, this message translates to:
  /// **'Notification channels'**
  String get notificationsChannelsHeader;

  /// Button to import a contact from the device address book.
  ///
  /// In en, this message translates to:
  /// **'Import from contacts'**
  String get contactsImportFromDevice;

  /// Snackbar shown when import is invoked on an unsupported platform.
  ///
  /// In en, this message translates to:
  /// **'Not available on this platform'**
  String get contactsImportNotSupported;

  /// Snackbar shown when contact-read permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Contact access denied. Enable in system settings.'**
  String get contactsImportPermissionDenied;

  /// Overflow menu entry for the delete-all action.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get contactsDeleteAllMenu;

  /// Title of the first delete-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete all contacts?'**
  String get contactsDeleteAllConfirmTitle;

  /// Body of the first delete-all confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This removes every emergency contact. There is no undo.'**
  String get contactsDeleteAllConfirmBody;

  /// Title of the typed-confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm by typing'**
  String get contactsDeleteAllTypeConfirmTitle;

  /// Hint inside the typed-confirmation text field.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE ALL to continue'**
  String get contactsDeleteAllTypeConfirmHint;

  /// Exact text the user must type to confirm delete-all.
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL'**
  String get contactsDeleteAllTypeConfirmSentinel;

  /// Confirm button on the typed dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get contactsDeleteAllConfirmButton;

  /// Chip label on the built-in modes.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get modesBuiltinBadge;

  /// Tooltip explaining why the delete option is disabled on built-in modes.
  ///
  /// In en, this message translates to:
  /// **'Built-in modes cannot be deleted'**
  String get modesBuiltinNoDelete;

  /// Orange banner shown when the completed session was a simulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation completed'**
  String get sessionCompletedSimulationBanner;

  /// Button to open the per-session event log detail.
  ///
  /// In en, this message translates to:
  /// **'View event log'**
  String get sessionCompletedViewEventLog;

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

  /// Body of the dialog shown before removing a PIN — the user must re-enter the PIN being removed to confirm their identity.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN to remove it.'**
  String get securityRemovePinPrompt;

  /// Inline error beneath the keypad when the entered PIN does not match the one being removed.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get securityRemovePinIncorrect;

  /// Info button label on PIN cards.
  ///
  /// In en, this message translates to:
  /// **'What is this?'**
  String get securityWhatIsThis;

  /// Explanatory dialog body for the App PIN card.
  ///
  /// In en, this message translates to:
  /// **'Locks the app when you open it. The keypad appears before any screen. Useful if someone briefly handles your unlocked phone.'**
  String get securityAppPinInfo;

  /// Explanatory dialog body for the Session End PIN card.
  ///
  /// In en, this message translates to:
  /// **'Required to disarm or end a running safety session. Without it, an attacker who takes your phone cannot stop the chain. Set a different code from your App PIN.'**
  String get securitySessionEndPinInfo;

  /// Explanatory dialog body for the Duress PIN card.
  ///
  /// In en, this message translates to:
  /// **'If you ever enter this PIN at any prompt, the distress chain runs silently — your contacts get alerted and the alarm primes without the attacker noticing. Pick a code different from every other PIN.'**
  String get securityDuressPinInfo;

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

  /// GPS format Plus Code (Open Location Code).
  ///
  /// In en, this message translates to:
  /// **'Plus Code'**
  String get gpsLoggingFormatAddress;

  /// Toggle to include GPS in SMS.
  ///
  /// In en, this message translates to:
  /// **'Append location to SMS'**
  String get gpsLoggingIncludeInSms;

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

  /// Button label that runs purgeExpiredLogs immediately.
  ///
  /// In en, this message translates to:
  /// **'Purge now'**
  String get historyRetentionPurgeNow;

  /// Snackbar shown after a successful purge.
  ///
  /// In en, this message translates to:
  /// **'Purged {count} logs'**
  String historyRetentionPurged(Object count);

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

  /// Bottom-sheet option that opens the built-in template picker.
  ///
  /// In en, this message translates to:
  /// **'From template'**
  String get templatesAddFromTemplate;

  /// Bottom-sheet option that opens the empty template editor.
  ///
  /// In en, this message translates to:
  /// **'From scratch'**
  String get templatesAddFromScratch;

  /// Delete-confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String templatesDeleteConfirmTitle(Object name);

  /// Delete-confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'This template will be removed permanently.'**
  String get templatesDeleteConfirmBody;

  /// Button under the empty-state illustration.
  ///
  /// In en, this message translates to:
  /// **'Add your first template'**
  String get templatesEmptyAddFirst;

  /// Title of the built-in-template picker bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Pick a built-in template'**
  String get templatesPickFromBuiltinTitle;

  /// Icon picker field label in the template editor.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get templatesIconLabel;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get templatesIconCalendar;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'App notification'**
  String get templatesIconAppNotification;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get templatesIconFitness;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get templatesIconHealth;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get templatesIconFood;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get templatesIconCoffee;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get templatesIconBattery;

  /// Built-in icon category.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get templatesIconWeather;

  /// Section header above the live preview panel.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get templatesPreviewHeading;

  /// Dialog title when leaving a dirty editor.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get templatesDiscardChangesTitle;

  /// Dialog body when leaving a dirty editor.
  ///
  /// In en, this message translates to:
  /// **'Unsaved edits will be lost.'**
  String get templatesDiscardChangesBody;

  /// Stay-on-editor action.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get templatesDiscardKeep;

  /// Discard action.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get templatesDiscardDiscard;

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

  /// Header above the technical-info ListTiles.
  ///
  /// In en, this message translates to:
  /// **'Technical information'**
  String get aboutTechnicalSection;

  /// Bundle ID tile.
  ///
  /// In en, this message translates to:
  /// **'Bundle ID: {id}'**
  String aboutBundleId(Object id);

  /// Platform list tile.
  ///
  /// In en, this message translates to:
  /// **'Platforms: {list}'**
  String aboutPlatforms(Object list);

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

  /// Snackbar shown after a successful import.
  ///
  /// In en, this message translates to:
  /// **'Import complete. Restart to apply.'**
  String get backupImportSuccess;

  /// Snackbar shown when an import throws.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {message}'**
  String backupImportError(Object message);

  /// Banner on the Backup screen while a session is running.
  ///
  /// In en, this message translates to:
  /// **'Backup is unavailable during an active session.'**
  String get backupActiveSessionBanner;

  /// ListTile label showing the last backup timestamp.
  ///
  /// In en, this message translates to:
  /// **'Last backup at {when}'**
  String backupLastBackupAtLabel(Object when);

  /// ListTile label when no backup has been exported yet.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get backupNeverExportedLabel;

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

  /// Delete confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Delete session log?'**
  String get pastEventsDeleteConfirm;

  /// Share menu — text option.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get pastEventsDetailShareText;

  /// Share menu — PDF option.
  ///
  /// In en, this message translates to:
  /// **'Share as PDF'**
  String get pastEventsDetailSharePdf;

  /// Delete button in detail screen.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pastEventsDetailDelete;

  /// Outcome badge: clean completion.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get pastEventsOutcomeCompleted;

  /// Outcome badge: distress chain fired.
  ///
  /// In en, this message translates to:
  /// **'Distress'**
  String get pastEventsOutcomeDistress;

  /// Outcome badge: any other end reason.
  ///
  /// In en, this message translates to:
  /// **'Interrupted'**
  String get pastEventsOutcomeInterrupted;

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

  /// Tooltip / snackbar when delete is disabled because another mode references this one as its distressModeId.
  ///
  /// In en, this message translates to:
  /// **'This distress mode is in use by another mode.'**
  String get modesDistressInUse;

  /// Title of distress modes list.
  ///
  /// In en, this message translates to:
  /// **'Distress modes'**
  String get modesDistressTitle;

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

  /// Mode-editor save validation: the escalation chain must have at least one step (spec 04:1598).
  ///
  /// In en, this message translates to:
  /// **'Add at least one step before saving.'**
  String get validationChainEmpty;

  /// Mode-editor save validation: a GPS-arrival disarm trigger with a fixed destination needs both coordinates (spec 03 GpsArrivalDisarmTrigger).
  ///
  /// In en, this message translates to:
  /// **'Set both latitude and longitude for the fixed arrival destination.'**
  String get validationGpsFixedCoords;

  /// Mode-editor save validation: a hardware-button distress trigger is internally inconsistent (spec 03 DistressTrigger).
  ///
  /// In en, this message translates to:
  /// **'Hardware panic trigger is incomplete — check its press count or hold duration.'**
  String get validationHardwareTrigger;

  /// Mode-editor save validation: an smsContact step targets contacts but none has the step's send channel enabled (spec 02:319).
  ///
  /// In en, this message translates to:
  /// **'None of the chosen contacts can receive on this step\'s channel. Pick a different channel or add it to a contact.'**
  String get validationSmsChannelNotOnContacts;

  /// Title of the non-blocking warning dialog shown when a distress mode has no SMS or call step (spec 04:1659).
  ///
  /// In en, this message translates to:
  /// **'No outbound alert step'**
  String get validationDistressNoActionTitle;

  /// Body of the non-blocking warning dialog shown when a distress mode has no SMS or call action step (spec 04:1659).
  ///
  /// In en, this message translates to:
  /// **'This distress mode has no SMS or call step, so it leaves no outbound trail. Save it anyway?'**
  String get validationDistressNoActionBody;

  /// Confirm button on the non-blocking save-validation warning dialog; proceeds with the save.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get validationSaveAnyway;

  /// Hold-button step prompt before the first press.
  ///
  /// In en, this message translates to:
  /// **'Touch to begin'**
  String get sessionHoldTouchToBegin;

  /// Hold-button countdown after release.
  ///
  /// In en, this message translates to:
  /// **'Countdown: {seconds}s'**
  String sessionHoldReleaseCountdown(Object seconds);

  /// Hold-button grace-period countdown.
  ///
  /// In en, this message translates to:
  /// **'Grace: {seconds}s — re-hold to stay safe'**
  String sessionHoldGraceCountdown(Object seconds);

  /// Prompt after the user released the hold button.
  ///
  /// In en, this message translates to:
  /// **'Hold again to stay safe'**
  String get sessionHoldAgain;

  /// Countdown to the next disguised-reminder.
  ///
  /// In en, this message translates to:
  /// **'Next check-in in {time}'**
  String sessionStepNextCheckIn(Object time);

  /// Status text shown while a fake call is ringing.
  ///
  /// In en, this message translates to:
  /// **'Incoming call from {caller}'**
  String sessionStepFakeCallActive(Object caller);

  /// Button that opens the full-screen fake-call UI.
  ///
  /// In en, this message translates to:
  /// **'Open call screen'**
  String get sessionStepFakeCallOpen;

  /// Simulation-mode placeholder card for the SMS step.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would send SMS to {count} contacts'**
  String sessionStepSimBlockedSms(Object count);

  /// Simulation-mode placeholder card for the phone-call step.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would call emergency contact'**
  String get sessionStepSimBlockedPhone;

  /// Simulation-mode placeholder card for the emergency-call step.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Would call emergency services'**
  String get sessionStepSimBlockedEmergency;

  /// Simulation-mode placeholder card for the loud-alarm step.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Alarm would have sounded at full volume'**
  String get sessionStepSimBlockedAlarm;

  /// Title of the dialog shown when session start validation fails.
  ///
  /// In en, this message translates to:
  /// **'Cannot start session'**
  String get sessionStartFailedTitle;

  /// Body of the dialog shown when session start validation fails.
  ///
  /// In en, this message translates to:
  /// **'Fix the following issues before starting:'**
  String get sessionStartFailedBody;

  /// Title of the quick-exit confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Quick exit'**
  String get sessionQuickExitTitle;

  /// Body of the quick-exit confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Session data will be preserved and encrypted. Reopen the app any time to recover it.'**
  String get sessionQuickExitBody;

  /// Confirm button on the quick-exit dialog.
  ///
  /// In en, this message translates to:
  /// **'Exit app'**
  String get sessionQuickExitConfirm;

  /// Restore action shown on the past-events SnackBar (undo soft delete).
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get pastEventsRestore;

  /// Label for the wait-seconds field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Wait (s)'**
  String get stepEditorWait;

  /// Label for the duration-seconds field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Duration (s)'**
  String get stepEditorDuration;

  /// Label for the grace-period-seconds field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Grace (s)'**
  String get stepEditorGrace;

  /// Label for the retry-count field of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Retry count'**
  String get stepEditorRetryCount;

  /// Label for the randomize toggle of a chain step.
  ///
  /// In en, this message translates to:
  /// **'Randomize timing (±20%)'**
  String get stepEditorRandomize;

  /// Button label that removes the step.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get stepEditorRemove;

  /// Field label for HoldButtonConfig.holdStyle.
  ///
  /// In en, this message translates to:
  /// **'Hold style'**
  String get eventDefaultsHoldStyle;

  /// Field label for HoldButtonConfig.releaseSensitivity (range 0.3–3.0).
  ///
  /// In en, this message translates to:
  /// **'Release sensitivity'**
  String get eventDefaultsHoldSensitivity;

  /// Field label for HoldButtonConfig.vibrateOnRelease.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on release'**
  String get eventDefaultsHoldVibrate;

  /// Field label for HoldButtonConfig.soundOnRelease.
  ///
  /// In en, this message translates to:
  /// **'Sound on release'**
  String get eventDefaultsHoldSound;

  /// Field label for the StepConfig.blackScreenMode flag (per step type).
  ///
  /// In en, this message translates to:
  /// **'Black screen overlay'**
  String get eventDefaultsBlackScreen;

  /// Field label for DisguisedReminderConfig.randomizeInterval.
  ///
  /// In en, this message translates to:
  /// **'Randomize interval'**
  String get eventDefaultsReminderRandomInterval;

  /// Field label for DisguisedReminderConfig.randomizeTemplateOrder.
  ///
  /// In en, this message translates to:
  /// **'Randomize template order'**
  String get eventDefaultsReminderRandomTemplate;

  /// Field label for DisguisedReminderConfig.resetOnEarlyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Reset on early check-in'**
  String get eventDefaultsReminderResetOnEarly;

  /// Field label for CountdownWarningConfig.style.
  ///
  /// In en, this message translates to:
  /// **'Countdown style'**
  String get eventDefaultsCountdownStyle;

  /// Field label for CountdownWarningConfig.vibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get eventDefaultsCountdownVibrate;

  /// Field label for CountdownWarningConfig.sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get eventDefaultsCountdownSound;

  /// Field label for FakeCallConfig.callStyle.
  ///
  /// In en, this message translates to:
  /// **'Call style'**
  String get eventDefaultsFakeCallStyle;

  /// Field label for FakeCallConfig.callerName.
  ///
  /// In en, this message translates to:
  /// **'Caller name'**
  String get eventDefaultsFakeCallCallerName;

  /// Field label for FakeCallConfig.ringDurationSeconds (5–120).
  ///
  /// In en, this message translates to:
  /// **'Ring duration (s)'**
  String get eventDefaultsFakeCallRingDuration;

  /// Field label for FakeCallConfig.declineIsSafe.
  ///
  /// In en, this message translates to:
  /// **'Decline counts as safe'**
  String get eventDefaultsFakeCallDeclineIsSafe;

  /// Field label for FakeCallConfig.voiceOutputMode.
  ///
  /// In en, this message translates to:
  /// **'Voice output'**
  String get eventDefaultsFakeCallVoiceOutput;

  /// Field label for SmsContactConfig.channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get eventDefaultsSmsChannel;

  /// Field label for SmsContactConfig.includeLocation.
  ///
  /// In en, this message translates to:
  /// **'Include location'**
  String get eventDefaultsSmsIncludeLocation;

  /// Field label for SmsContactConfig.includeMedicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Include medical info'**
  String get eventDefaultsSmsIncludeMedical;

  /// Field label for SmsContactConfig.autoRecordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record audio before sending'**
  String get eventDefaultsSmsAutoRecord;

  /// Field label for SmsContactConfig.recordDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'Recording duration (s)'**
  String get eventDefaultsSmsRecordDuration;

  /// Field label for the SMS message-template editor (SmsContactConfig.messageTemplate). Spec 02:287-304.
  ///
  /// In en, this message translates to:
  /// **'Message template'**
  String get eventDefaultsSmsMessageTemplate;

  /// Hint shown under the SMS message-template field explaining that a blank value uses the seeded default and chips insert placeholders.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use the default alert. Tap a placeholder to insert it.'**
  String get eventDefaultsSmsMessageTemplateHint;

  /// iOS platform-limitation warning shown in the mode editor when an smsContact step uses the SMS channel (spec 02:325).
  ///
  /// In en, this message translates to:
  /// **'On iPhone, SMS requires you to manually press Send in the Messages app. If you cannot interact with your phone, the message will not send. Consider using WhatsApp or Telegram instead.'**
  String get eventDefaultsSmsIosWarning;

  /// Field label for LoudAlarmConfig.volume (0.0–1.0).
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get eventDefaultsLoudAlarmVolume;

  /// Field label for LoudAlarmConfig.soundChoice.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get eventDefaultsLoudAlarmSound;

  /// Field label for LoudAlarmConfig.flashScreen.
  ///
  /// In en, this message translates to:
  /// **'Flash screen'**
  String get eventDefaultsLoudAlarmFlashScreen;

  /// Field label for LoudAlarmConfig.flashLight.
  ///
  /// In en, this message translates to:
  /// **'Flash camera light'**
  String get eventDefaultsLoudAlarmFlashLight;

  /// Field label for LoudAlarmConfig.gradualVolume.
  ///
  /// In en, this message translates to:
  /// **'Gradual volume ramp'**
  String get eventDefaultsLoudAlarmGradual;

  /// Field label for CallEmergencyConfig.emergencyNumber (null = inherit).
  ///
  /// In en, this message translates to:
  /// **'Emergency number (override)'**
  String get eventDefaultsCallEmergencyNumber;

  /// Field label for CallEmergencyConfig.showConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation countdown'**
  String get eventDefaultsCallEmergencyConfirm;

  /// Field label for CallEmergencyConfig.confirmationDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'Confirmation seconds'**
  String get eventDefaultsCallEmergencyConfirmDuration;

  /// Field label for CallEmergencyConfig.sendLocationSmsFirst.
  ///
  /// In en, this message translates to:
  /// **'Send location SMS first'**
  String get eventDefaultsCallEmergencySmsFirst;

  /// iOS platform-limitation warning shown in the mode editor when a callEmergency step is configured (spec 02:479).
  ///
  /// In en, this message translates to:
  /// **'On iPhone, a confirmation dialog will appear before dialing. Tap \'Call\' quickly.'**
  String get eventDefaultsCallEmergencyIosWarning;

  /// Field label for PhoneCallContactConfig.contactId (null = first sorted).
  ///
  /// In en, this message translates to:
  /// **'Primary contact (id)'**
  String get eventDefaultsPhonePrimaryContact;

  /// Field label for HardwareButtonConfig.buttonType.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get eventDefaultsHardwareButton;

  /// Field label for HardwareButtonConfig.pressPattern.
  ///
  /// In en, this message translates to:
  /// **'Press pattern'**
  String get eventDefaultsHardwarePattern;

  /// Field label for HardwareButtonConfig.pressCount (repeat-press only).
  ///
  /// In en, this message translates to:
  /// **'Press count'**
  String get eventDefaultsHardwarePressCount;

  /// Field label for HardwareButtonConfig.longPressDurationSeconds (long-press only).
  ///
  /// In en, this message translates to:
  /// **'Long-press duration (s)'**
  String get eventDefaultsHardwareLongDuration;

  /// Title of the past-events trash screen.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get pastEventsTrashTitle;

  /// Empty-state copy for the past-events trash screen.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get pastEventsTrashEmpty;

  /// Overflow menu action to delete every trashed log.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get pastEventsTrashEmptyAll;

  /// Empty-trash confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Empty trash?'**
  String get pastEventsTrashEmptyAllConfirmTitle;

  /// Empty-trash confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'Type EMPTY TRASH below to confirm. This deletes every trashed log permanently.'**
  String get pastEventsTrashEmptyAllConfirmBody;

  /// Snackbar after empty-trash.
  ///
  /// In en, this message translates to:
  /// **'Trash emptied ({count} logs)'**
  String pastEventsTrashEmptyAllSuccess(Object count);

  /// Retention note shown at the top of the trash screen.
  ///
  /// In en, this message translates to:
  /// **'Logs in the trash are permanently deleted after {days} days.'**
  String pastEventsTrashRetentionNote(int days);

  /// Per-row remaining-restore countdown.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) until permanent deletion'**
  String pastEventsTrashRemainingDays(int days);

  /// Per-row Delete Permanently action / confirm-dialog title on the trash screen.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get pastEventsTrashDeletePermanently;

  /// Confirm-dialog body for permanent deletion from the trash screen.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get pastEventsTrashDeletePermanentlyBody;

  /// Headline of the pre-dial emergency-confirmation overlay shown during the duration phase of a callEmergency step. Spec 02:457-460.
  ///
  /// In en, this message translates to:
  /// **'Calling {number} in {seconds}s'**
  String sessionEmergencyConfirmTitle(String number, int seconds);

  /// Label rendered along the SwipeSlider on the emergency-confirmation overlay (Extra 56).
  ///
  /// In en, this message translates to:
  /// **'Swipe to cancel'**
  String get sessionEmergencyConfirmSwipe;

  /// FilledButton on the emergency-confirmation overlay that dismisses the overlay so the dial proceeds (spec 02:460).
  ///
  /// In en, this message translates to:
  /// **'Keep calling'**
  String get sessionEmergencyConfirmKeep;

  /// Orange [SIM] badge atop the emergency-confirmation overlay when the session is a simulation.
  ///
  /// In en, this message translates to:
  /// **'[SIM] Practice mode'**
  String get sessionEmergencyConfirmSimBadge;

  /// Snackbar shown after the user swipes-to-cancel inside a simulated emergency-confirmation overlay; no real call ever happens in simulation.
  ///
  /// In en, this message translates to:
  /// **'Simulated cancel — call would not have been placed'**
  String get sessionEmergencyConfirmSimCancelled;

  /// Default screen-reader hint for SwipeSlider — read aloud after the slider's caller-supplied label.
  ///
  /// In en, this message translates to:
  /// **'Swipe to confirm'**
  String get swipeSliderSemantics;

  /// Home-screen widget status text shown when no session is running.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get homeWidgetStatusIdle;

  /// Home-screen widget status text shown while a real safety session is active.
  ///
  /// In en, this message translates to:
  /// **'Session active'**
  String get homeWidgetStatusSession;

  /// Home-screen widget status text shown while a simulation session is active.
  ///
  /// In en, this message translates to:
  /// **'Simulation active'**
  String get homeWidgetStatusSim;

  /// Home-screen widget button label for Quick Exit (ends session, PIN-gated).
  ///
  /// In en, this message translates to:
  /// **'Quick Exit'**
  String get homeWidgetQuickExit;

  /// Home-screen widget button label for Fake Call (deep-links to /fake-call).
  ///
  /// In en, this message translates to:
  /// **'Fake Call'**
  String get homeWidgetFakeCall;

  /// Section header for the app-wide alarm settings (spec 06 Alarm Section).
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get settingsAlarmHeader;

  /// Toggle label for AppSettings.alarmDndOverride.
  ///
  /// In en, this message translates to:
  /// **'Alarm overrides silent/vibrate mode'**
  String get settingsAlarmDndOverrideLabel;

  /// Warning shown beneath the DND-override toggle when it is OFF.
  ///
  /// In en, this message translates to:
  /// **'Warning: the alarm will be silent if your phone is on silent mode.'**
  String get settingsAlarmDndOverrideWarning;

  /// Info-sheet body explaining the DND-override toggle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the loud alarm plays at full volume even if your phone is on silent or vibrate. On Android it uses the alarm audio stream to bypass Do Not Disturb. The alarm is the only event that can override your phone\'s sound settings.'**
  String get settingsAlarmDndOverrideInfo;

  /// Toggle label for AppSettings.alarmGradualVolume (app-wide master).
  ///
  /// In en, this message translates to:
  /// **'Gradually increase alarm volume'**
  String get settingsAlarmGradualLabel;

  /// Info-sheet body explaining the gradual-volume master toggle.
  ///
  /// In en, this message translates to:
  /// **'Starts the alarm quietly and ramps it up to full volume. This is the app-wide master switch; each alarm step also has its own gradual-volume option, and both must be on for the ramp to apply.'**
  String get settingsAlarmGradualInfo;

  /// Label for the alarm gradual-volume ramp-duration slider (1-60s).
  ///
  /// In en, this message translates to:
  /// **'Ramp duration'**
  String get settingsAlarmRampLabel;

  /// Info-sheet body explaining the ramp-duration slider.
  ///
  /// In en, this message translates to:
  /// **'How long the alarm takes to reach full volume from zero, ramping evenly over this time. Has no effect when gradual volume is off.'**
  String get settingsAlarmRampInfo;
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
