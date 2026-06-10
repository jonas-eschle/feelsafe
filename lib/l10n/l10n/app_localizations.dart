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
  /// **'Using SIM number {number}'**
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

  /// One-sentence description of the holdButton step type (spec 04:1622).
  ///
  /// In en, this message translates to:
  /// **'Hold to stay safe — releasing starts a grace countdown.'**
  String get chainStepDescHoldButton;

  /// One-sentence description of the disguisedReminder step type (spec 04:1623).
  ///
  /// In en, this message translates to:
  /// **'Sends a disguised notification — you must respond to confirm safety.'**
  String get chainStepDescDisguisedReminder;

  /// One-sentence description of the fakeCall step type (spec 04:1624).
  ///
  /// In en, this message translates to:
  /// **'Simulates an incoming call — answer or decline to show you\'re safe.'**
  String get chainStepDescFakeCall;

  /// One-sentence description of the smsContact step type (spec 04:1625).
  ///
  /// In en, this message translates to:
  /// **'Sends an SMS with your location to emergency contacts.'**
  String get chainStepDescSmsContact;

  /// One-sentence description of the countdownWarning step type (spec 04:1626).
  ///
  /// In en, this message translates to:
  /// **'Shows a countdown with sound and flash as a last warning.'**
  String get chainStepDescCountdownWarning;

  /// One-sentence description of the loudAlarm step type (spec 04:1627).
  ///
  /// In en, this message translates to:
  /// **'Plays a max-volume alarm with flash to attract attention.'**
  String get chainStepDescLoudAlarm;

  /// One-sentence description of the callEmergency step type (spec 04:1628).
  ///
  /// In en, this message translates to:
  /// **'Calls emergency services (112/911) automatically.'**
  String get chainStepDescCallEmergency;

  /// One-sentence description of the phoneCallContact step type (spec 04:1629).
  ///
  /// In en, this message translates to:
  /// **'Calls an emergency contact directly.'**
  String get chainStepDescPhoneCallContact;

  /// One-sentence description of the hardwareButton step type (spec 04:1630).
  ///
  /// In en, this message translates to:
  /// **'Watches a hardware button for a panic press pattern.'**
  String get chainStepDescHardwareButton;

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

  /// Comma-separated pool of short, neutral filler words shown as decoys alongside a tapWord reminder's real keyword. Must stay plausible and generic in each language (e.g. notification-button-style words) so the real word does not stand out; uppercased in the UI. At least 9 distinct words recommended.
  ///
  /// In en, this message translates to:
  /// **'LATER,SKIP,DONE,OPEN,VIEW,OKAY,NEXT,MORE,SNOOZE,CLOSE'**
  String get sessionReminderDecoyWords;

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

  /// Title of the persistent foreground-service notification shown while a safety session runs (non-stealth).
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela is active'**
  String get sessionServiceTitle;

  /// Body of the persistent foreground-service notification shown while a safety session runs (non-stealth).
  ///
  /// In en, this message translates to:
  /// **'Your safety session is running.'**
  String get sessionServiceBody;

  /// Minimal, innocuous body of the persistent notification when the session is disguised; reads like a music app so it avoids suspicion.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get sessionServiceStealthBody;

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

  /// Header of the mode icon selector in the mode editor (spec 04:1483).
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get modeFieldIcon;

  /// Accessibility label for the Shield mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get modeIconLabelShield;

  /// Accessibility label for the Favorite mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get modeIconLabelFavorite;

  /// Accessibility label for the Lock mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get modeIconLabelLock;

  /// Accessibility label for the DirectionsWalk mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get modeIconLabelDirectionsWalk;

  /// Accessibility label for the Restaurant mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get modeIconLabelRestaurant;

  /// Accessibility label for the Warning mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get modeIconLabelWarning;

  /// Accessibility label for the Nightlife mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get modeIconLabelNightlife;

  /// Accessibility label for the DirectionsRun mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get modeIconLabelDirectionsRun;

  /// Accessibility label for the DirectionsBike mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get modeIconLabelDirectionsBike;

  /// Accessibility label for the Home mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get modeIconLabelHome;

  /// Accessibility label for the Work mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get modeIconLabelWork;

  /// Accessibility label for the School mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get modeIconLabelSchool;

  /// Accessibility label for the LocalTaxi mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get modeIconLabelLocalTaxi;

  /// Accessibility label for the Flight mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get modeIconLabelFlight;

  /// Accessibility label for the Hiking mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get modeIconLabelHiking;

  /// Accessibility label for the Celebration mode icon in the mode-editor icon selector and anywhere a mode icon needs a spoken name (spec 04:1539).
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get modeIconLabelCelebration;

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

  /// Collapsed step-tile key-config summary for a holdButton step. {style} is the raw HoldStyle enum name.
  ///
  /// In en, this message translates to:
  /// **'Hold: {style}, {grace}s grace'**
  String stepSummaryHoldButton(Object style, int grace);

  /// Collapsed step-tile key-config summary for a disguisedReminder step (spec 04:1599 example: '30 min interval, 3 retries'). {interval} is a pre-formatted duration; {retries} comes from stepSummaryRetryCount.
  ///
  /// In en, this message translates to:
  /// **'{interval} interval, {retries}'**
  String stepSummaryDisguisedReminder(Object interval, Object retries);

  /// Retry-count fragment of stepSummaryDisguisedReminder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 retry} other{{count} retries}}'**
  String stepSummaryRetryCount(num count);

  /// Compact whole-minutes duration used inside step summaries.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String stepSummaryMinutes(int count);

  /// Compact seconds duration used inside step summaries.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String stepSummarySeconds(int count);

  /// Collapsed step-tile key-config summary for a countdownWarning step. {style} is the raw CountdownStyle enum name.
  ///
  /// In en, this message translates to:
  /// **'{duration}s countdown, {style}'**
  String stepSummaryCountdown(int duration, Object style);

  /// Collapsed step-tile key-config summary for a fakeCall step (spec 04:1599/1631 example: '30s ring, 5s grace').
  ///
  /// In en, this message translates to:
  /// **'{ring}s ring, {grace}s grace'**
  String stepSummaryFakeCall(int ring, int grace);

  /// Collapsed step-tile recipients summary for an smsContact step (spec 04:1631 example: 'Contacts: Alice, Bob'). {names} is the truncated name list, optionally ending with stepSummarySmsMore.
  ///
  /// In en, this message translates to:
  /// **'To: {names}'**
  String stepSummarySmsTo(Object names);

  /// Truncation suffix appended to stepSummarySmsTo when more recipients exist than are named ('Alice, Bob +3 more').
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 more} other{+{count} more}}'**
  String stepSummarySmsMore(num count);

  /// Collapsed step-tile summary for an smsContact step that currently resolves to zero reachable recipients.
  ///
  /// In en, this message translates to:
  /// **'No recipients selected'**
  String get stepSummarySmsNone;

  /// Collapsed step-tile summary for a phoneCallContact step. {name} is the contact the runtime would dial.
  ///
  /// In en, this message translates to:
  /// **'Calls {name}'**
  String stepSummaryPhoneCall(Object name);

  /// Collapsed step-tile summary for a phoneCallContact step when no contact resolves (the runtime would skip the call).
  ///
  /// In en, this message translates to:
  /// **'No contact to call'**
  String get stepSummaryPhoneCallNone;

  /// Collapsed step-tile key-config summary for a loudAlarm step. {sound} is the raw LoudAlarmSound enum name.
  ///
  /// In en, this message translates to:
  /// **'{volume}% volume, {sound}'**
  String stepSummaryLoudAlarm(int volume, Object sound);

  /// loudAlarm summary variant when the volume ramp is effective (step flag AND app-wide master both on).
  ///
  /// In en, this message translates to:
  /// **'{volume}% volume, {sound}, ramps up'**
  String stepSummaryLoudAlarmRamp(int volume, Object sound);

  /// Collapsed step-tile summary for a callEmergency step. {number} is the resolved number (per-step override or app-wide default).
  ///
  /// In en, this message translates to:
  /// **'Calls {number}'**
  String stepSummaryCallEmergency(Object number);

  /// callEmergency summary variant when a location SMS is sent before dialling.
  ///
  /// In en, this message translates to:
  /// **'Calls {number}, location SMS first'**
  String stepSummaryCallEmergencySmsFirst(Object number);

  /// Collapsed step-tile summary for a hardwareButton step with a repeat-press pattern. {button} is the raw ButtonType enum name.
  ///
  /// In en, this message translates to:
  /// **'{button} × {count}'**
  String stepSummaryHardwareRepeat(Object button, int count);

  /// Collapsed step-tile summary for a hardwareButton step with a long-press pattern. {seconds} is pre-formatted (trailing .0 trimmed).
  ///
  /// In en, this message translates to:
  /// **'{button}, hold {seconds}s'**
  String stepSummaryHardwareLong(Object button, Object seconds);

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

  /// Title of the dialog for editing the emergency services number.
  ///
  /// In en, this message translates to:
  /// **'Emergency number'**
  String get settingsEmergencyNumberEditTitle;

  /// Text-field label in the emergency-number edit dialog.
  ///
  /// In en, this message translates to:
  /// **'Number to dial'**
  String get settingsEmergencyNumberFieldLabel;

  /// Header above the list of preset emergency numbers in the edit dialog.
  ///
  /// In en, this message translates to:
  /// **'Common numbers'**
  String get settingsEmergencyNumberPresetsLabel;

  /// Non-blocking warning when an emergency/phone number contains disallowed characters.
  ///
  /// In en, this message translates to:
  /// **'Only digits, +, *, and # are allowed.'**
  String get phoneWarnInvalidChars;

  /// Non-blocking warning when the emergency number has fewer than 3 digits.
  ///
  /// In en, this message translates to:
  /// **'Emergency numbers are usually at least 3 digits.'**
  String get phoneWarnTooShort;

  /// Non-blocking warning when the emergency number has more than 6 digits.
  ///
  /// In en, this message translates to:
  /// **'This looks like a regular phone number, not an emergency services number.'**
  String get phoneWarnLooksLikeRegular;

  /// Blocking hint when the emergency-number field is empty (Save is disabled).
  ///
  /// In en, this message translates to:
  /// **'Enter a number — this can\'t be empty.'**
  String get phoneWarnEmergencyEmpty;

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

  /// Toggle: enable a biometric (fingerprint / Face ID) prompt before the PIN keypad when cancelling the distress confirmation window, as an alternative to typing the PIN.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to cancel distress'**
  String get securityDistressCancelBiometric;

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

  /// Reason text shown inside the system biometric (fingerprint / Face ID) prompt when ending a session, before falling back to the Session End PIN keypad. Brand-free so it does not reveal the safety app under stealth.
  ///
  /// In en, this message translates to:
  /// **'Confirm to end the session'**
  String get sessionEndBiometricReason;

  /// Reason text shown inside the system biometric (fingerprint / Face ID) prompt when cancelling the distress confirmation window, before falling back to the PIN keypad. Brand-free so it does not reveal the safety app under stealth.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to cancel'**
  String get distressCancelBiometricReason;

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

  /// Info bottom-sheet body explaining the lock-task / screen-pinning trade-off.
  ///
  /// In en, this message translates to:
  /// **'Pins Guardian Angela to the screen for the whole session so it can\'t be swiped away or switched out of. Trade-off: Android shows a system \"App is pinned\" banner and blocks app-switching until the session ends — visible to anyone watching the screen. Leave this off if you\'d rather move freely between apps during a session. No effect on platforms without screen-pinning.'**
  String get stealthLockTaskInfo;

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

  /// CTA in the interrupted modal that starts a brand-new session for the same mode (Extra 13). Not a resume.
  ///
  /// In en, this message translates to:
  /// **'Start same mode'**
  String get sessionInterruptedStartSameMode;

  /// Relative-time phrase shown in the interrupted modal when the prior session started less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get sessionInterruptedJustNow;

  /// Relative-time phrase for a prior session that started a number of whole minutes ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String sessionInterruptedMinutesAgo(int count);

  /// Relative-time phrase for a prior session that started a number of whole hours ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String sessionInterruptedHoursAgo(int count);

  /// Relative-time phrase for a prior session that started a number of whole days ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String sessionInterruptedDaysAgo(int count);

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

  /// Heading of the optional post-session feedback prompt on the session-completed screen.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get sessionCompletedFeedbackPrompt;

  /// Button on the post-session feedback prompt that opens the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sessionCompletedFeedbackSend;

  /// Button on the post-session feedback prompt that dismisses it without sending feedback.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get sessionCompletedFeedbackSkip;

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

  /// Snackbar shown when saving a template with an empty name, title, or body.
  ///
  /// In en, this message translates to:
  /// **'Name, title, and body required.'**
  String get templatesRequiredFieldsError;

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

  /// Section label for the fake-call ringtone picker (FakeCallConfig.customRingtonePath).
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get eventDefaultsFakeCallRingtone;

  /// Shown when no custom ringtone is chosen; the bundled default ring is used.
  ///
  /// In en, this message translates to:
  /// **'Default ring'**
  String get eventDefaultsFakeCallRingtoneDefault;

  /// Shown when a user-supplied ringtone file is chosen. {fileName} is the imported file name.
  ///
  /// In en, this message translates to:
  /// **'Custom: {fileName}'**
  String eventDefaultsFakeCallRingtoneCustom(String fileName);

  /// Button that opens the file picker to import a user-supplied fake-call ringtone.
  ///
  /// In en, this message translates to:
  /// **'Choose ringtone…'**
  String get eventDefaultsFakeCallRingtoneChoose;

  /// Button that clears the custom fake-call ringtone, reverting to the bundled default ring.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get eventDefaultsFakeCallRingtoneUseDefault;

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

  /// Info-sheet body for the holdButton holdStyle field (spec 04:1591 per-field info).
  ///
  /// In en, this message translates to:
  /// **'How the hold surface looks: a large button, the whole screen, or a fake lock screen that disguises what the app is doing.'**
  String get eventDefaultsHoldStyleInfo;

  /// Info-sheet body for the holdButton releaseSensitivity field.
  ///
  /// In en, this message translates to:
  /// **'How strictly a lifted finger counts as a release. Lower values forgive brief slips; higher values react immediately.'**
  String get eventDefaultsHoldSensitivityInfo;

  /// Info-sheet body for the holdButton vibrateOnRelease field.
  ///
  /// In en, this message translates to:
  /// **'Vibrates the phone the moment your finger leaves the button, so you notice an accidental release right away.'**
  String get eventDefaultsHoldVibrateInfo;

  /// Info-sheet body for the holdButton soundOnRelease field.
  ///
  /// In en, this message translates to:
  /// **'Plays a short sound when your finger leaves the button, so you notice an accidental release even without looking at the screen.'**
  String get eventDefaultsHoldSoundInfo;

  /// Info-sheet body for the shared blackScreenMode field (all step types).
  ///
  /// In en, this message translates to:
  /// **'Keeps the screen black during this step, mimicking a locked phone, so the app stays invisible to anyone watching. The step keeps running underneath.'**
  String get eventDefaultsBlackScreenInfo;

  /// Info-sheet body for the disguisedReminder randomizeInterval field.
  ///
  /// In en, this message translates to:
  /// **'Varies the time between reminders by about ±20%, so they look like ordinary app notifications instead of a fixed schedule.'**
  String get eventDefaultsReminderRandomIntervalInfo;

  /// Info-sheet body for the disguisedReminder randomizeTemplateOrder field.
  ///
  /// In en, this message translates to:
  /// **'Picks a different reminder template each time, so repeated reminders don\'t look identical to someone watching your notifications.'**
  String get eventDefaultsReminderRandomTemplateInfo;

  /// Info-sheet body for the disguisedReminder resetOnEarlyCheckIn field.
  ///
  /// In en, this message translates to:
  /// **'If you check in before the reminder fires, the timer restarts at the full interval instead of keeping its old schedule.'**
  String get eventDefaultsReminderResetOnEarlyInfo;

  /// Label of the per-step templateIds multi-select picker in the disguisedReminder form (spec 04:1635).
  ///
  /// In en, this message translates to:
  /// **'Eligible templates'**
  String get eventDefaultsReminderTemplateIds;

  /// Info-sheet body for the templateIds picker, mirroring the runtime selector semantics (empty selection = all eligible; all-stale selection falls back to the full pool).
  ///
  /// In en, this message translates to:
  /// **'Limits which reminder templates this step may show. With none selected, every template in the pool — global and this mode\'s local ones — is eligible. A selected template that is later deleted is simply ignored; if none of the selected templates exists anymore, every template becomes eligible again.'**
  String get eventDefaultsReminderTemplateIdsInfo;

  /// Summary line of the templateIds picker when no template is selected (and when the selection resolves to nothing) — every template in the pool is eligible.
  ///
  /// In en, this message translates to:
  /// **'All templates eligible'**
  String get eventDefaultsReminderTemplateIdsAll;

  /// Summary line of the templateIds picker listing the selected template names.
  ///
  /// In en, this message translates to:
  /// **'Eligible: {names}'**
  String eventDefaultsReminderTemplateIdsSelected(Object names);

  /// Header above the manage-reminder-templates link in the disguisedReminder form (spec 04:1635).
  ///
  /// In en, this message translates to:
  /// **'Reminder templates'**
  String get eventDefaultsReminderTemplatesTitle;

  /// Info-sheet body explaining what reminder templates are, shown above the manage-templates link (spec 04:1635).
  ///
  /// In en, this message translates to:
  /// **'Templates define what a disguised reminder looks like — its fake app name, title, and text (for example a calendar or language-app notification). Manage the shared pool here; every disguised-reminder step picks from it.'**
  String get eventDefaultsReminderTemplatesInfo;

  /// Info-sheet body for the countdownWarning style field.
  ///
  /// In en, this message translates to:
  /// **'How the countdown is shown: a full-screen warning or a minimal overlay that draws less attention.'**
  String get eventDefaultsCountdownStyleInfo;

  /// Info-sheet body for the countdownWarning vibrate field.
  ///
  /// In en, this message translates to:
  /// **'Vibrates the phone while the countdown runs, so you can notice it even with the phone in your pocket.'**
  String get eventDefaultsCountdownVibrateInfo;

  /// Info-sheet body for the countdownWarning sound field.
  ///
  /// In en, this message translates to:
  /// **'Plays an audible alert while the countdown runs. Turn it off if the warning must stay silent.'**
  String get eventDefaultsCountdownSoundInfo;

  /// Info-sheet body for the fakeCall callStyle field.
  ///
  /// In en, this message translates to:
  /// **'Which app\'s incoming-call screen the fake call imitates, so it looks believable on your phone.'**
  String get eventDefaultsFakeCallStyleInfo;

  /// Info-sheet body for the fakeCall callerName field.
  ///
  /// In en, this message translates to:
  /// **'The name shown as the caller on the fake-call screen. Pick someone it would be natural for you to answer.'**
  String get eventDefaultsFakeCallCallerNameInfo;

  /// Info-sheet body for the fakeCall ringDurationSeconds field.
  ///
  /// In en, this message translates to:
  /// **'How long the fake call rings before it counts as missed. A missed call lets the chain escalate.'**
  String get eventDefaultsFakeCallRingDurationInfo;

  /// Info-sheet body for the fakeCall voiceOutputMode field.
  ///
  /// In en, this message translates to:
  /// **'Where the voice audio plays after you answer: the earpiece (quiet and private) or the loudspeaker.'**
  String get eventDefaultsFakeCallVoiceOutputInfo;

  /// Info-sheet body for the fakeCall custom-ringtone picker.
  ///
  /// In en, this message translates to:
  /// **'The ringtone played for the fake call. Import your own audio file to match your real ringtone — if the file ever goes missing, the built-in ring plays instead.'**
  String get eventDefaultsFakeCallRingtoneInfo;

  /// Info-sheet body for the fakeCall declineIsSafe field.
  ///
  /// In en, this message translates to:
  /// **'When on, declining the call counts as a safe check-in and the chain resets. When off, declining counts as a miss and the call can ring again.'**
  String get eventDefaultsFakeCallDeclineIsSafeInfo;

  /// Info-sheet body for the smsContact channel field.
  ///
  /// In en, this message translates to:
  /// **'The messaging app used for this step: SMS, WhatsApp, Telegram, or Signal. Contacts that can\'t receive the chosen channel are greyed out.'**
  String get eventDefaultsSmsChannelInfo;

  /// Info-sheet body for the smsContact recipients grid.
  ///
  /// In en, this message translates to:
  /// **'Who receives this alert. Tap contacts to select them — selecting everyone keeps the list dynamic, so contacts you add later are included automatically.'**
  String get smsContactRecipientsInfo;

  /// Info-sheet body for the smsContact messageTemplate field. {name} and {location} receive the literal token strings ('{name}', '{location}') from code so the rendered text shows them verbatim — do not translate or alter them.
  ///
  /// In en, this message translates to:
  /// **'The text of the alert message. Placeholders like {name} and {location} are filled in with real values when the message is sent. Leave blank to use the built-in alert.'**
  String eventDefaultsSmsMessageTemplateInfo(Object name, Object location);

  /// Info-sheet body for the smsContact includeLocation field.
  ///
  /// In en, this message translates to:
  /// **'Appends your current GPS position to the message, so your contacts know where to find you.'**
  String get eventDefaultsSmsIncludeLocationInfo;

  /// Info-sheet body for the smsContact includeMedicalInfo field.
  ///
  /// In en, this message translates to:
  /// **'Adds the medical details from your profile (such as blood type or allergies) to the message for first responders.'**
  String get eventDefaultsSmsIncludeMedicalInfo;

  /// Info-sheet body for the smsContact autoRecordAudio field.
  ///
  /// In en, this message translates to:
  /// **'Starts an audio recording automatically when this step fires, preserving evidence of what is happening around you.'**
  String get eventDefaultsSmsAutoRecordInfo;

  /// Info-sheet body for the smsContact recordDurationSeconds field.
  ///
  /// In en, this message translates to:
  /// **'How many seconds the automatic audio recording lasts.'**
  String get eventDefaultsSmsRecordDurationInfo;

  /// Info-sheet body for the phoneCallContact contactId field.
  ///
  /// In en, this message translates to:
  /// **'The contact called first. Leave empty to call your first emergency contact. If they don\'t pick up, the alternatives are tried in order.'**
  String get eventDefaultsPhonePrimaryContactInfo;

  /// Info-sheet body for the loudAlarm volume field.
  ///
  /// In en, this message translates to:
  /// **'How loud the alarm plays, from silent (0) to the device maximum (1). The alarm is meant to attract attention from people nearby.'**
  String get eventDefaultsLoudAlarmVolumeInfo;

  /// Info-sheet body for the loudAlarm soundChoice field.
  ///
  /// In en, this message translates to:
  /// **'Which sound the alarm plays: the built-in siren or a custom sound of your own.'**
  String get eventDefaultsLoudAlarmSoundInfo;

  /// Info-sheet body for the loudAlarm flashScreen field.
  ///
  /// In en, this message translates to:
  /// **'Flashes the screen in bright colors while the alarm sounds. Off by default — flashing can affect people with photosensitivity.'**
  String get eventDefaultsLoudAlarmFlashScreenInfo;

  /// Info-sheet body for the loudAlarm flashLight field.
  ///
  /// In en, this message translates to:
  /// **'Strobes the camera flashlight while the alarm sounds, making you easier to locate in the dark.'**
  String get eventDefaultsLoudAlarmFlashLightInfo;

  /// Info-sheet body for the loudAlarm gradualVolume field.
  ///
  /// In en, this message translates to:
  /// **'Ramps the volume up from silent to the configured level instead of starting at full blast.'**
  String get eventDefaultsLoudAlarmGradualInfo;

  /// Info-sheet body for the callEmergency emergencyNumber field.
  ///
  /// In en, this message translates to:
  /// **'Overrides the emergency number dialled by this step. Leave empty to use the app-wide number (for example 112 or 911).'**
  String get eventDefaultsCallEmergencyNumberInfo;

  /// Info-sheet body for the callEmergency sendLocationSmsFirst field.
  ///
  /// In en, this message translates to:
  /// **'Sends a location SMS to your emergency contacts just before dialling, so they are informed even if the call doesn\'t connect.'**
  String get eventDefaultsCallEmergencySmsFirstInfo;

  /// Info-sheet body for the callEmergency showConfirmation field.
  ///
  /// In en, this message translates to:
  /// **'Shows a short countdown before dialling, giving you a last chance to cancel an accidental emergency call.'**
  String get eventDefaultsCallEmergencyConfirmInfo;

  /// Info-sheet body for the callEmergency confirmationDurationSeconds field.
  ///
  /// In en, this message translates to:
  /// **'How many seconds the cancel countdown lasts before the emergency call is placed.'**
  String get eventDefaultsCallEmergencyConfirmDurationInfo;

  /// Info-sheet body for the hardwareButton buttonType field.
  ///
  /// In en, this message translates to:
  /// **'Which physical button (volume up or volume down) this step watches for the panic press.'**
  String get eventDefaultsHardwareButtonInfo;

  /// Info-sheet body for the hardwareButton pressPattern field.
  ///
  /// In en, this message translates to:
  /// **'The press pattern that triggers the step: several quick presses in a row, or one long press.'**
  String get eventDefaultsHardwarePatternInfo;

  /// Info-sheet body for the hardwareButton pressCount field (repeat-press pattern).
  ///
  /// In en, this message translates to:
  /// **'How many quick presses in a row are required. More presses make accidental triggers less likely.'**
  String get eventDefaultsHardwarePressCountInfo;

  /// Info-sheet body for the hardwareButton longPressDurationSeconds field (long-press pattern).
  ///
  /// In en, this message translates to:
  /// **'How long the button must be held down to trigger the step.'**
  String get eventDefaultsHardwareLongDurationInfo;

  /// Small caption on the live preview cards in the fakeCall/smsContact/loudAlarm config forms (spec 04:1591).
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get eventPreviewCardLabel;

  /// Preview-card title for the fakeCall form. {name} is the configured caller name.
  ///
  /// In en, this message translates to:
  /// **'Incoming call from {name}'**
  String eventPreviewFakeCallCaller(Object name);

  /// Preview-card line summarising the fakeCall ring duration and call style.
  ///
  /// In en, this message translates to:
  /// **'Rings for {seconds}s · {style}'**
  String eventPreviewFakeCallRing(int seconds, Object style);

  /// Preview-card line when fakeCall declineIsSafe is on.
  ///
  /// In en, this message translates to:
  /// **'Declining counts as a safe check-in.'**
  String get eventPreviewFakeCallDeclineSafe;

  /// Preview-card line when fakeCall declineIsSafe is off.
  ///
  /// In en, this message translates to:
  /// **'Declining counts as a miss — the call can ring again.'**
  String get eventPreviewFakeCallDeclineNotSafe;

  /// Preview-card recipients line when the smsContact step targets every contact. {channel} is the messaging channel name.
  ///
  /// In en, this message translates to:
  /// **'To all contacts · {channel}'**
  String eventPreviewSmsToAll(Object channel);

  /// Preview-card recipients line when the smsContact step targets specific contacts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{To 1 contact · {channel}} other{To {count} contacts · {channel}}}'**
  String eventPreviewSmsToCount(num count, Object channel);

  /// Preview-card recipients line when the smsContact step targets only the first contact.
  ///
  /// In en, this message translates to:
  /// **'To your first contact · {channel}'**
  String eventPreviewSmsToFirst(Object channel);

  /// Preview-card line showing the message text (with its placeholders) that the smsContact step will send.
  ///
  /// In en, this message translates to:
  /// **'Message: {gist}'**
  String eventPreviewSmsMessage(Object gist);

  /// Preview-card title for the loudAlarm form: configured volume percentage and sound choice.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent}% · {sound}'**
  String eventPreviewLoudAlarmTitle(int percent, Object sound);

  /// Preview-card line when loudAlarm gradualVolume is on.
  ///
  /// In en, this message translates to:
  /// **'Volume ramps up gradually.'**
  String get eventPreviewLoudAlarmRampOn;

  /// Preview-card line when loudAlarm gradualVolume is off.
  ///
  /// In en, this message translates to:
  /// **'Starts at full volume.'**
  String get eventPreviewLoudAlarmRampOff;

  /// Preview-card line when the per-step gradualVolume is on but the app-wide master switch (AppSettings.alarmGradualVolume, Settings → Alarm) is off. The runtime ramps only when BOTH are on, so the alarm will actually start at full volume; the line says so and points at the master switch.
  ///
  /// In en, this message translates to:
  /// **'Starts at full volume — gradual ramp is disabled in Alarm settings.'**
  String get eventPreviewLoudAlarmRampMasterOff;

  /// Preview-card fragment when loudAlarm flashScreen is on. Joined with ' · ' to other flash fragments.
  ///
  /// In en, this message translates to:
  /// **'Screen flashes'**
  String get eventPreviewLoudAlarmFlashScreen;

  /// Preview-card fragment when loudAlarm flashLight is on. Joined with ' · ' to other flash fragments.
  ///
  /// In en, this message translates to:
  /// **'Camera light flashes'**
  String get eventPreviewLoudAlarmFlashLight;

  /// Preview-card fragment when neither loudAlarm flash option is on.
  ///
  /// In en, this message translates to:
  /// **'No flashing'**
  String get eventPreviewLoudAlarmNoFlash;

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

  /// Title of the rationale dialog shown before re-requesting the Android notification permission (Extra 42).
  ///
  /// In en, this message translates to:
  /// **'Allow notifications?'**
  String get permissionNotifRationaleTitle;

  /// Body of the rationale dialog explaining why notification permission is needed before re-requesting.
  ///
  /// In en, this message translates to:
  /// **'Guardian Angela uses notifications to alert you and your contacts during a safety session, including disguised reminders that wake your locked phone. Please allow notifications so the app can reach you.'**
  String get permissionNotifRationaleBody;

  /// Title of the dialog shown when the notification permission is permanently denied and a system-settings deep-link is offered.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get permissionNotifDeniedTitle;

  /// Body of the permanently-denied dialog directing the user to system settings.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Guardian Angela. Open system settings to turn them back on so the app can alert you during a session.'**
  String get permissionNotifDeniedBody;

  /// Confirm button on the notification-permission rationale dialog; proceeds to the OS prompt.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionNotifAllow;

  /// Button on the permanently-denied dialog that deep-links to the app's system notification settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionNotifOpenSettings;

  /// Dismiss button on the notification-permission dialogs; declines without granting.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionNotifNotNow;

  /// Title of the Active Triggers Summary dialog shown when the user taps Start (spec 04 §Start Session Button — On tap).
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get homeStartTriggersSummaryTitle;

  /// Section heading for the configured distress trigger in the Active Triggers Summary.
  ///
  /// In en, this message translates to:
  /// **'Distress trigger'**
  String get homeStartTriggersDistressHeading;

  /// Section heading for the configured disarm trigger in the Active Triggers Summary.
  ///
  /// In en, this message translates to:
  /// **'Auto-disarm trigger'**
  String get homeStartTriggersDisarmHeading;

  /// Shown under a trigger heading when the mode has no trigger of that kind configured.
  ///
  /// In en, this message translates to:
  /// **'None configured'**
  String get homeStartTriggersNone;

  /// Brief detail for a repeat-press hardware-button distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Press {button} {count} times'**
  String homeStartTriggerButtonRepeat(String button, String count);

  /// Brief detail for a long-press hardware-button distress trigger.
  ///
  /// In en, this message translates to:
  /// **'Hold {button} for {seconds}s'**
  String homeStartTriggerButtonLong(String button, String seconds);

  /// Name of the volume-up button in a trigger summary detail.
  ///
  /// In en, this message translates to:
  /// **'Volume up'**
  String get homeStartTriggerButtonVolumeUp;

  /// Name of the volume-down button in a trigger summary detail.
  ///
  /// In en, this message translates to:
  /// **'Volume down'**
  String get homeStartTriggerButtonVolumeDown;

  /// Brief detail for a GPS-arrival disarm trigger.
  ///
  /// In en, this message translates to:
  /// **'Ends on arrival within {radius} m of your destination'**
  String homeStartTriggerGpsArrival(String radius);

  /// Note appended to a GPS-arrival disarm trigger whose destination is prompted at session start (stays in-session per decision D4).
  ///
  /// In en, this message translates to:
  /// **'You\'ll be asked for the destination after starting'**
  String get homeStartTriggerGpsPrompt;

  /// Brief detail for a timer disarm trigger.
  ///
  /// In en, this message translates to:
  /// **'Ends automatically after {minutes} min'**
  String homeStartTriggerTimer(String minutes);

  /// Confirm button on the Active Triggers Summary dialog; proceeds to start the session.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get homeStartTriggersContinue;

  /// Cancel button on the Active Triggers Summary dialog; aborts the start.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeStartTriggersCancel;

  /// Title of the inline warning shown when start is blocked because the chain needs notifications but the permission was denied (Extra 42).
  ///
  /// In en, this message translates to:
  /// **'Notifications required'**
  String get homeStartBlockedNotifTitle;

  /// Body of the inline warning shown when start is blocked due to missing notification permission for a notification-dependent chain.
  ///
  /// In en, this message translates to:
  /// **'This mode uses notifications (disguised reminders or fake calls) to keep you safe, but notification permission is off. Enable notifications to start this mode.'**
  String get homeStartBlockedNotifBody;
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
