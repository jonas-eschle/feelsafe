# Issues v4 — 16 items from user testing

## Bug Fixes

### 1. Profile picture MissingPluginException
**Problem**: Loading a profile picture on web throws `MissingPluginException(No implementation found for method getApplicationDocumentsDirectory)`. `path_provider` doesn't work on web.
**Fix**: Guard image picker behind platform check. On web, use in-memory or skip file copy. Add test that image picker gracefully handles missing platform.

### 2. Divider styling — double bars (grey + white)
**Problem**: Settings have grey + white horizontal dividers side by side.
**Fix**: Remove the white PrideDivider or the grey Divider — keep only one, make it white/themed.

### 3. Emergency SMS text default
**Problem**: Automatically prepends "Automated safety alert..." to every message.
**Fix**: Don't auto-prepend. Instead, set the default message template to include it. User can edit/remove it.

### 7. Single-step chain deletion
**Problem**: When creating a chain with only 1 step, that step can't be deleted.
**Fix**: Allow deletion even of the last step. Show empty state "Add a step to begin" instead.

### 16. Hold button grace period default = 0
**Problem**: Grace period default for holdButton is 5s (from spec), but user wants 0.
**Fix**: Update seed data and event defaults: holdButton gracePeriodSeconds = 0. If countdown ends, escalate immediately.

## UX Improvements

### 4. Reminder settings info + reorder
**Changes**:
- Add info tooltips to "Repeat interval" and "Grace period" in reminder config
- Reorder: "Repeat Interval" first, then "Grace Period"
- Rename "Repeat Count" → "Number of retries"

### 5. Minimum reminder interval = 10s (not 1 min)
**Fix**: Change LogarithmicSlider min for disguisedReminder wait from 60 to 10.

### 6. Auto-record duration slider
**Problem**: Auto-record video/audio toggles exist but no duration slider.
**Fix**: Add LogarithmicSlider (5s–300s) for record duration, shown when toggle is ON.

### 8. Hardware trigger as top option in mode creation
**Fix**: Show 3 prominent options: Hold Button, Disguised Reminder, Hardware Trigger. Then "More..." for the rest.

### 9. Hardware button settings in mode editor
**Fix**: Add inline config for hardwareButton step: button type (volumeUp/volumeDown/lock), press pattern (double/triple/long), press count/duration.

### 10. Preview button per step in mode editor
**Fix**: Each step in the chain editor gets a "Preview" button that shows the event with simulation styling.

### 11. Randomize button on user-facing durations
**Add randomize toggle to**: Repetition interval, fake call ring duration. NOT on: SMS duration, alarm, emergency confirm.

### 12. Mode icons
**Fix**: Custom modes get a selectable icon. Walk/Date mode icons consistent everywhere. Use icon picker grid.

### 13. Real previews for Hold Button + Fake Call
**Fix**: Preview button for holdButton shows actual hold button UI. Preview for fakeCall shows actual fake call screen with ringtone.

### 14. Fake call simulation = real experience
**Fix**: In simulation AND preview, show the actual fake call screen (caller name, slide-to-answer, ringtone audio). Only difference: no real phone call placed.

### 15. Log tabs: Real + Simulated
**Fix**: Past Events screen gets 2 tabs: "Real" (isSimulation=false) and "Simulated" (isSimulation=true).
