# Guardian Angela v2 — Test Plan

**Target:** 1000+ tests covering all application layers.
**Status:** Written against spec `docs/spec/13-rewrite-v2-spec.md` and rewrite plan.
**Test files:** Mirror `lib/` structure under `test/`.

---

## 1. Engine Unit Tests (200+ tests)

### 1.1 Core lifecycle (`test/domain/engine/session_engine_test.dart`)
1. `start()` on EngineIdle transitions to EngineRunning
2. `start()` twice throws StateError (fail-loud, spec §3.8)
3. `SessionEngine` with empty steps throws ArgumentError on construction
4. Initial state is EngineIdle before start()
5. `isSimulation` is exposed on engine
6. `steps` list is unmodifiable
7. `dispose()` closes the event stream
8. Events stream emits `stepStarted` immediately after `start()`
9. Engine exposes step count
10. Engine exposes current steps list

### 1.2 Three-phase timing (`test/domain/engine/engine_timing_test.dart`)
11. Non-hold step: wait → reminderFired → duration → grace → stepAdvancing
12. Retry skips wait phase (goes straight to duration)
13. `retryCount=0` means single attempt then advance
14. `retryCount=2` means 3 total attempts then advance
15. Wait phase timer is exact (no early firing)
16. Duration phase timer is exact
17. Grace phase timer is exact
18. Step 0 to step 1 transition fires `stepAdvancing`
19. After last step grace expires: `chainExhausted` + `EngineEnded`
20. `EndReason.chainExhausted` set on EngineEnded after normal exhaustion
21. Multi-step chain: each step fires stepStarted then stepAdvancing
22. `stepStarted` always precedes `stepAdvancing` for same step
23. Events are strictly ordered (no out-of-order emission)
24. Elapsed time between wait/duration/grace is exact with fakeAsync
25. Timer jitter: ±20% randomization with non-fixed random
26. Timer jitter: fixed random (0.5) gives exact durations
27. Speed multiplier 2x halves all durations
28. Speed multiplier 10x gives 10x faster execution

### 1.3 Hold button (`test/domain/engine/hold_button_test.dart`)
29. Hold step: `isAwaitingFirstTouch = true` on start
30. `holdStart()` sets `isHolding = true`
31. `holdStart()` is no-op if already holding (edge-triggered)
32. `holdRelease()` is no-op if not holding (edge-triggered)
33. Releasing within sensitivity window does NOT start grace
34. Releasing after sensitivity window starts grace phase
35. Re-holding during grace period triggers `userDisarmed`
36. `holdStart()` then `holdRelease()` then `holdStart()` within sensitivity: no escalation
37. Hold sensitivity 0.5s: release for 0.3s then re-hold = still holding
38. Hold sensitivity 0.5s: release for 0.6s = grace starts
39. Hold step without any touch: never escalates (stays awaitingFirstTouch)
40. Re-hold during grace resets missCount to 0
41. Hold + release 5x within sensitivity: no escalation
42. HoldButtonConfig.releaseSensitivity 0.0 means instant grace on release
43. HoldButtonConfig.releaseSensitivity 5.0: 4s release = no grace
44. Hold step disarm works while holding
45. Hold step disarm works during sensitivity window
46. Hold step disarm works during grace
47. `isAwaitingFirstTouch` is false after first holdStart
48. Hold step in distress chain behaves identically

### 1.4 Fake call lifecycle (`test/domain/engine/fake_call_test.dart`)
49. `answerFakeCall()` transitions chain to paused state
50. After answer: timer does not advance for 60s
51. `hangUp()` after answer emits `userDisarmed`
52. `declineFakeCall()` with `declineIsSafe=true` emits `userDisarmed`
53. `declineFakeCall()` with `declineIsSafe=false` emits `repeatMissed`
54. Fake call timeout (no answer, no decline) counts as miss
55. `retryCount=2` on fake call: ring 3 times then advance
56. `declineWithDistressHoldSeconds=5`: hold 5s triggers distress chain
57. `declineWithDistressHoldSeconds=5`: hold 3s = no distress
58. Fake call answer is no-op if not in fake call step
59. `hangUp()` without prior `answerFakeCall()` is no-op
60. `declineFakeCall()` is no-op if not in fake call step
61. Real phone call during fake call: `answerFakeCall()` then real call ends → auto-disarm
62. Fake call step in distress chain behaves identically
63. `declineIsSafe=false` + retryCount=1: decline, ring again, decline, advance
64. `declineIsSafe=true` + retryCount=2: decline immediately disarms regardless of retry
65. Fake call ring duration matches step durationSeconds
66. Fake call step emits `stepStarted` on enter
67. Fake call: answer pauses, voice plays, hang up disarms (full lifecycle)
68. Fake call: answer pauses, time passes, chain does not advance
69. Fake call: answer → decline-with-distress hold → distress chain fires
70. Fake call: decline-distress triggers confirmation window
71. Fake call: decline-distress cancel during confirmation = no distress
72. Fake call: decline-distress confirm after 5s = distress starts

### 1.5 Distress chain replacement (`test/domain/engine/distress_chain_test.dart`)
73. `replaceWithDistressChain()` from EngineRunning transitions to new chain at step 0
74. `replaceWithDistressChain()` during wait phase: cancels wait timer
75. `replaceWithDistressChain()` during duration phase: cancels duration timer
76. `replaceWithDistressChain()` during grace phase: cancels grace timer
77. `replaceWithDistressChain()` during EnginePaused: replaces and resumes
78. `replaceWithDistressChain()` during fake call answer (paused): replaces
79. `replaceWithDistressChain()` twice: second call uses the new chain steps
80. After replacement: original chain steps are discarded
81. After replacement: step index resets to 0
82. After replacement: missCount resets to 0
83. Distress chain exhaustion: `EngineEnded(distressCompleted)` not `chainExhausted`
84. `EndReason.distressCompleted` is set on EngineEnded after distress completes
85. Double-trigger within 500ms cooldown: only one replacement
86. `replaceWithDistressChain()` with empty steps throws ArgumentError
87. Confirmation window: 5s default before distress starts
88. Confirmation window: cancel within 5s prevents distress
89. Confirmation window: no cancel after 5s → distress chain starts
90. Confirmation window: configurable duration (3s, 10s)
91. Confirmation window cancellation requires PIN if configured
92. `replaceWithDistressChain()` from EngineIdle does not throw (but starts)
93. Distress chain fires all its steps in order
94. Hardware panic trigger fires `replaceWithDistressChain()`
95. Wrong PIN threshold fires `replaceWithDistressChain()`
96. Duress PIN fires `replaceWithDistressChain()`
97. After distress chain ends: `sessionEnded` event emitted
98. `replaceWithDistressChain()` emits `sessionPaused` then `stepStarted` for new chain
99. Distress chain with single step: exhausts after that step
100. Distress chain with hold button step: hold-then-release disarms within distress
101. Main chain step count preserved in engine state during distress
102. `isDistressActive` flag accessible on engine during distress

### 1.6 Pause/Resume (`test/domain/engine/pause_resume_test.dart`)
103. `pause()` from EngineRunning → EnginePaused
104. `pause()` freezes all timers
105. `resume()` from EnginePaused → EngineRunning
106. `resume()` restores exact remaining duration (no buffer added)
107. 3s remaining before pause: 3s remaining after resume
108. `pause()` is no-op if already paused
109. `pause()` is no-op from EngineIdle
110. `pause()` is no-op from EngineEnded
111. `resume()` is no-op if not paused
112. `resume()` restores `isAwaitingFirstTouch` correctly (regression)
113. `pause()` emits `sessionPaused` event
114. `resume()` emits `sessionResumed` event
115. Incoming call auto-pause: `pause(reason: PauseReason.incomingCall)`
116. Max pause duration: auto-ends session after limit (if configured)
117. Max pause duration null: unlimited pause
118. Pause during hold step: `isHolding` state preserved in snapshot
119. Pause during sensitivity window: sensitivity timer frozen
120. Pause + resume mid-wait-phase: wait phase continues from snapshot
121. Pause + resume mid-grace-phase: grace continues with exact remaining
122. Pause during distress chain: distress paused too

### 1.7 Speed multiplier (`test/domain/engine/speed_multiplier_test.dart`)
123. `setSpeedMultiplier(2.0)` rejected for real session (ArgumentError)
124. `setSpeedMultiplier(0.5)` accepted for real session (≤1.0)
125. `setSpeedMultiplier(1000.0)` accepted for simulation
126. `setSpeedMultiplier(0.01)` accepted for simulation (lower bound)
127. `setSpeedMultiplier(0.009)` clamped to 0.01 or rejected
128. `setSpeedMultiplier(1001.0)` clamped to 1000.0 or rejected
129. `setSpeedMultiplier(double.nan)` throws ArgumentError
130. `setSpeedMultiplier(double.infinity)` throws ArgumentError
131. `setSpeedMultiplier(-1.0)` throws ArgumentError
132. `setSpeedMultiplier(0)` throws ArgumentError
133. Speed 10x: 30s step completes in 3s wall time

### 1.8 Disarm (`test/domain/engine/disarm_test.dart`)
134. `disarm()` from EngineIdle: no-op (does not throw)
135. `disarm()` from EngineRunning wait phase: emits `userDisarmed`
136. `disarm()` from EngineRunning duration phase: emits `userDisarmed`
137. `disarm()` from EngineRunning grace phase: emits `userDisarmed`
138. `disarm()` from EnginePaused: emits `userDisarmed`
139. `disarm()` from EngineEnded: no-op
140. After `disarm()`: step index resets to 0
141. After `disarm()`: missCount resets to 0
142. After `disarm()`: state returns to EngineRunning at step 0
143. `disarm()` cancels active timer
144. `disarm()` during fake call (answer phase): disarms
145. `disarm()` during distress chain: disarms distress chain
146. `disarm()` during distress chain: emits `userDisarmed`
147. `disarm()` twice in same frame: second call is no-op
148. `disarm()` resets `isHolding` to false

### 1.9 endSession() (`test/domain/engine/end_session_test.dart`)
149. `endSession()` from EngineRunning: transitions to EngineEnded
150. `endSession()` from EngineIdle: no-op (no throw)
151. `endSession()` from EnginePaused: transitions to EngineEnded
152. `endSession()` from EngineEnded: no-op
153. `endSession()` emits `sessionEnded` event
154. `EndReason.userTerminated` set on EngineEnded after endSession
155. `endSession()` cancels all active timers
156. `endSession()` during distress chain: ends distress chain
157. Already-dispatched SMS not cancelled by endSession (fire-and-forget)

### 1.10 Edge cases (`test/domain/engine/engine_edge_cases_test.dart`)
158. `dispose()` mid zero-duration timer: no stream error
159. `start()` then immediate `endSession()` (same microtask): no crash
160. `holdRelease()` when paused: swallowed, state reverts on resume
161. `answerFakeCall()` on non-fakeCall step: no-op (no crash)
162. Negative snooze duration: throws ArgumentError (v2 fix from BUG-B)
163. Two `disarm()` calls in same synchronous frame: idempotent
164. Zero-duration wait+duration+grace step: immediately advances
165. `dispose()` closes stream (isClosed = true after dispose)
166. Timer.run callback after dispose: does not crash
167. Concurrent hold and reminder events: handled safely
168. `jumpToStep(valid_index)`: advances to that step
169. `jumpToStep(-1)`: throws RangeError
170. `jumpToStep(stepCount)`: throws RangeError
171. Snooze during wait phase: extends wait by snooze amount
172. Leap to next event: jumps to end of current phase
173. Events emitted in strictly monotonic order (no duplicates)
174. Rapid holdStart/holdRelease 100x: no crash
175. `start()` on disposed engine: throws

---

## 2. Model Unit Tests (100+ tests)

### 2.1 StepConfig sealed hierarchy (`test/domain/models/step_config_test.dart`)
176. All 9 subclasses constructible with defaults
177. Exhaustive switch compiles (coverage check)
178. `FakeCallConfig.declineIsSafe` defaults to true
179. `FakeCallConfig.declineIsSafe=false` works
180. `FakeCallConfig.callerName` defaults to 'Angela'
181. `FakeCallConfig.declineWithDistressHoldSeconds` defaults to 5 (v2)
182. `HoldButtonConfig.releaseSensitivity` defaults to 1.0
183. `HoldButtonConfig.holdStyle` defaults to largeButton
184. `CallEmergencyConfig.showConfirmation` defaults to false
185. `CallEmergencyConfig.emergencyNumber` defaults to '112'
186. `HardwareButtonConfig` trigger defaults to RepeatPressTrigger with 5 presses (v2: was 3)
187. `LongPressTrigger.durationSeconds` defaults to 2.0
188. Sealed HardwareTrigger switch is exhaustive
189. `SmsContactConfig.contactIds` null = all contacts
190. `SmsContactConfig.includeLocation` defaults to true
191. `LoudAlarmConfig.volume` defaults to 1.0
192. `LoudAlarmConfig.soundChoice` defaults to siren
193. All 9 `typeName` values match their fromJson discriminators
194. `StepConfig.fromJson` throws ArgumentError for unknown type
195. `StepConfig.fromJson(toJson)` round-trips for all 9 subclasses

### 2.2 JSON round-trip tests (`test/domain/models/json_round_trip_test.dart`)
196. `HoldButtonConfig` toJson→fromJson preserves all fields
197. `FakeCallConfig` toJson→fromJson preserves declineIsSafe + declineWithDistressHoldSeconds
198. `SmsContactConfig` toJson→fromJson preserves contactIds + includeLocation
199. `PhoneCallContactConfig` toJson→fromJson preserves all fields
200. `LoudAlarmConfig` toJson→fromJson preserves volume + sound
201. `CallEmergencyConfig` toJson→fromJson preserves emergencyNumber + showConfirmation
202. `CountdownWarningConfig` toJson→fromJson preserves all fields
203. `DisguisedReminderConfig` toJson→fromJson preserves all fields
204. `HardwareButtonConfig` toJson→fromJson preserves trigger type and settings
205. `RepeatPressTrigger` toJson→fromJson preserves pressCount
206. `LongPressTrigger` toJson→fromJson preserves durationSeconds
207. `ChainStep` toJson→fromJson preserves all timing fields
208. `ChainStep` toJson→fromJson preserves stepConfig envelope
209. `SessionMode` toJson→fromJson preserves chainSteps
210. `SessionMode` toJson→fromJson preserves distressChainSteps (nullable)
211. `SessionMode` toJson→fromJson preserves distressTriggers
212. `SessionMode` toJson→fromJson preserves disarmTriggers
213. `SessionMode` toJson→fromJson preserves maxPauseDuration (nullable)
214. `EmergencyContact` toJson→fromJson preserves all fields
215. `EmergencyContact` toJson→fromJson preserves null channels
216. `EmergencyContact.effectiveChannels` fallback when channels null
217. `AppSettings` toJson→fromJson preserves all fields
218. `AppSettings` toJson→fromJson preserves PIN timeout default 15s
219. `UserProfile` toJson→fromJson preserves all fields including medical
220. `BatteryAlertConfig` toJson→fromJson (no chainSteps, just sendSmsToContacts)
221. `GpsArrivalDisarmTrigger` toJson→fromJson preserves all fields
222. `HardwareButtonDistressTrigger` toJson→fromJson preserves pressCount=5
223. `TimerDisarmTrigger` toJson→fromJson preserves duration
224. Trigger fromJson throws on unknown type
225. `LocationPoint` toJson→fromJson preserves lat/lon/timestamp
226. `SessionLog` toJson→fromJson preserves all fields
227. `ReminderTemplate` toJson→fromJson preserves all fields
228. Null optional fields survive round-trip as null
229. Empty lists survive round-trip as empty
230. Non-ASCII characters in names survive JSON round-trip

### 2.3 AppSettings (`test/domain/models/app_settings_test.dart`)
231. `pinTimeoutSeconds` defaults to 15 (v2: was 10)
232. `isFirstLaunch` defaults to true
233. `stealthMode` defaults to false
234. `copyWith` preserves all unchanged fields
235. `copyWith` with every field explicitly overridden
236. `emergencyNumber` defaults to '112'
237. `alarmDndOverride` defaults to true
238. `language` defaults to system locale
239. `themeMode` defaults to system
240. Clear PIN: hash becomes null
241. Duress PIN hash is separate from app PIN hash

### 2.4 EmergencyContact (`test/domain/models/emergency_contact_test.dart`)
242. Default `sortOrder` is 0
243. Default `preferredChannel` is sms
244. `effectiveChannels` returns `[preferredChannel]` when channels is null
245. `effectiveChannels` returns explicit channels when set
246. `copyWith` preserves unchanged fields
247. `copyWith` can change name, phone, relationship, sortOrder
248. Multiple contacts sorted by `sortOrder`

### 2.5 Trigger hierarchy (`test/domain/models/trigger_test.dart`)
249. `HardwareButtonDistressTrigger` default pressCount = 5 (v2)
250. `HardwareButtonDistressTrigger.pressCount` configurable
251. `GpsArrivalDisarmTrigger` toJson→fromJson
252. `TimerDisarmTrigger` toJson→fromJson preserves duration
253. Trigger switch is exhaustive (all 3 types covered)
254. Unknown trigger type throws on fromJson

---

## 3. Orchestration Tests (50+ tests)

### 3.1 Event strategy registry (`test/domain/orchestration/event_strategy_registry_test.dart`)
255. All 9 step types have registered strategies
256. `lookupStrategy(holdButton)` returns non-null
257. `lookupStrategy(fakeCall)` returns non-null
258. `lookupStrategy(smsContact)` returns non-null
259. `lookupStrategy(phoneCallContact)` returns non-null
260. `lookupStrategy(loudAlarm)` returns non-null
261. `lookupStrategy(callEmergency)` returns non-null
262. `lookupStrategy(countdownWarning)` returns non-null
263. `lookupStrategy(disguisedReminder)` returns non-null
264. `lookupStrategy(hardwareButton)` returns non-null
265. Unknown type returns null (not throws)

### 3.2 Session orchestrator (`test/domain/orchestration/session_orchestrator_test.dart`)
266. `stepStarted` event: strategy `executeReal()` called
267. Simulation mode: `executeReal()` NOT called
268. Simulation mode: `onSimulationDescription` callback called with description
269. Strategy failure: does NOT propagate (error isolation)
270. Strategy failure: `onStepExecutionFailed` callback invoked
271. `userDisarmed` event: sets isCancelled flag on pending operations
272. Non-stepStarted events: strategies NOT executed
273. `sessionPaused` event: pauses audio/vibration (via callback)
274. `sessionResumed` event: resumes audio
275. Orchestrator with null `onSimulationDescription`: no crash in sim mode
276. Strategy `isCancelled()` returns true after `userDisarmed`
277. Multiple strategies can be in flight; disarm cancels all

### 3.3 Individual strategy simulation descriptions (`test/domain/orchestration/strategy_descriptions_test.dart`)
278. holdButton: simulationDescription returns non-empty string
279. fakeCall: simulationDescription returns non-empty string
280. smsContact: simulationDescription includes contact count
281. phoneCallContact: simulationDescription returns non-empty string
282. loudAlarm: simulationDescription returns non-empty string
283. callEmergency: simulationDescription returns non-empty string
284. countdownWarning: simulationDescription returns non-empty string
285. disguisedReminder: simulationDescription returns non-empty string
286. hardwareButton: simulationDescription returns non-empty string

### 3.4 Simulation service structural test (`test/domain/orchestration/simulation_service_test.dart`)
287. `SimulationMessagingService` has no telephony imports
288. `SimulationPhoneService` has no telephony imports
289. `SimulationMessagingService.sendSms()` does NOT throw
290. `SimulationPhoneService.makeCall()` does NOT throw
291. Simulation service logs action as `sim_blocked`
292. Calling simulation service returns normally (no side effects)

---

## 4. Validation Tests (30+ tests)

### 4.1 Session validator (`test/domain/validation/session_validator_test.dart`)
293. Empty chain: canStart = false
294. SMS step + no contacts + real session: canStart = false (smart validation)
295. SMS step + no contacts + simulation: canStart = true (lenient)
296. Phone call step + no contacts + real session: canStart = false
297. Emergency call step + no contacts + real session: canStart = false
298. holdButton only (no SMS/call) + no contacts: canStart = true (alarm-only)
299. loudAlarm only + no contacts: canStart = true
300. countdownWarning only + no contacts: canStart = true
301. SMS step + 1 contact: canStart = true
302. Referenced contact ID not in contacts list: warning (not error)
303. Missing notification permission + real session: canStart = false
304. Missing notification permission + simulation: canStart = true (warning)
305. Missing SMS permission + smsContact step: canStart = false
306. Missing SMS permission + no smsContact step: canStart = true
307. Missing phone permission + phoneCallContact step: canStart = false
308. Missing location permission + GPS disarm trigger: warning
309. Missing location permission + no GPS trigger: no warning
310. Valid config with all permissions: canStart = true, no issues
311. Empty distress chain (distressChainSteps = []): warning
312. Mode with only holdButton step: always valid (no external deps)
313. Simulation: all missing permissions are warnings not errors
314. Simulation: missing contacts are warnings not errors
315. Missing emergency number (empty string): error for callEmergency step
316. Validator result: `hasIssues` = true if errors OR warnings
317. Validator result: `canStart` = false if any errors
318. Validator result: `canStart` = true if only warnings
319. Validator result: errors list is ordered by severity
320. Validation against mode with distress triggers: triggers validated too
321. All 9 step types get correct permission checks
322. holdButton step: no permissions required

---

## 5. Repository Tests (40+ tests)

### 5.1 JsonListRepository (`test/data/repositories/json_list_repository_test.dart`)
323. `isEmpty()` true on fresh box
324. `isEmpty()` false after save
325. `isEmpty()` true after deleteAll
326. `getAll()` empty on fresh box
327. `getAll()` returns all saved items
328. `getAll()` duplicate id: single entry with latest value
329. `getById()` null for unknown id
330. `getById()` returns correct item
331. `getById()` null after delete
332. `save()` persists across repo re-creation
333. `save()` updates existing value for same id
334. `saveAll()` saves multiple items
335. `saveAll([])` leaves box unchanged
336. `saveAll()` updates existing items by id
337. `delete()` removes only specified id
338. `delete()` non-existent id is no-op
339. `deleteAll()` clears all items
340. `deleteAll()` on empty box is no-op
341. Corrupt JSON entry: `getAll()` skips without throwing
342. Corrupt JSON entry: `getById()` returns null
343. EmergencyContact round-trip via JsonListRepository
344. SessionMode round-trip via JsonListRepository
345. Multiple SessionModes stored and retrieved independently

### 5.2 JsonSingletonRepository (`test/data/repositories/json_singleton_repository_test.dart`)
346. `get()` returns null on fresh box
347. `save()` persists value
348. `get()` returns saved value
349. `save()` overwrites previous value
350. Corrupt JSON: `get()` returns null (corruption resilience)
351. Value persists across repo re-creation
352. AppSettings round-trip via JsonSingletonRepository
353. UserProfile round-trip via JsonSingletonRepository

### 5.3 Seed data (`test/data/seed_data_test.dart`)
354. Walk Mode exists in seed data
355. Date Mode exists in seed data
356. Walk Mode has 5 chain steps
357. Walk Mode step 0 is holdButton
358. Walk Mode step 1 is fakeCall
359. Walk Mode step 2 is smsContact
360. Walk Mode step 3 is phoneCallContact
361. Walk Mode step 4 is callEmergency
362. Walk Mode distress trigger: pressCount=5 (v2 default)
363. Date Mode step 0 is disguisedReminder (waitSeconds=1800)
364. Date Mode has distress trigger
365. Both modes have non-empty distressChainSteps (v2)
366. Distress chain contains SMS + emergency call steps
367. Walk Mode timing matches spec §13.1
368. Date Mode timing matches spec §13.2
369. All seed step IDs are unique
370. Seed modes have unique IDs

---

## 6. Service Tests (60+ tests)

### 6.1 Fake service contract compliance (`test/services/fakes/`)
371. `FakeMessagingService.sendSms()` records call, returns success
372. `FakeMessagingService.sendWhatsApp()` records call, returns success
373. `FakeMessagingService.sendTelegram()` records call, returns success
374. `FakePhoneService.makeCall()` records call, returns success
375. `FakePhoneService.makeEmergencyCall()` records call, returns success
376. `FakeAudioService.playRingtone()` records call
377. `FakeAudioService.playVoice()` records call
378. `FakeAudioService.stop()` records call
379. `FakeVibrationService.vibrate()` records call
380. `FakeVibrationService.stop()` records call
381. `FakeNotificationService.show()` records notification
382. `FakeNotificationService.dismiss()` removes notification
383. `FakeLocationService.getCurrentLocation()` returns fake coordinates
384. `FakeLocationService.startTracking()` records call
385. `FakeGeofenceService.setGeofence()` records call
386. `FakeGeofenceService.simulateArrival()` fires callback
387. `FakeHardwareButtonService.simulatePanic()` fires callback
388. `FakeBatteryMonitorService.simulateLowBattery()` fires callback
389. `FakeWakelockService.enable()` records call
390. `FakeWakelockService.disable()` records call
391. `FakeRecordingService.startRecording()` records call
392. `FakeRecordingService.stopRecording()` returns null path (simulated)

### 6.2 Hardware button service (`test/services/implementations/hardware_button_service_test.dart`)
393. 5 presses within window triggers panic callback (default pressCount=5)
394. 4 presses within window: no callback
395. 6 presses: callback fires on 5th, 6th ignored (cooldown)
396. Press window 2s: press 1-4 at 0s, press 5 at 2.5s = no trigger
397. Press window 2s: press 1-5 within 2s = trigger
398. 500ms cooldown after trigger: immediate 5 more presses = ignored
399. After cooldown expires: next 5 presses trigger again
400. Press count configurable (3 presses, 7 presses)

### 6.3 Geofence service (`test/services/implementations/geofence_service_test.dart`)
401. Haversine distance: same point = 0m
402. Haversine distance: 1 degree lat ≈ 111km
403. Haversine distance: 1 degree lon at equator ≈ 111km
404. Haversine distance: known coords give known result
405. Dwell time: brief entry then exit = no arrival
406. Dwell time: entry + 30s dwell = arrival callback
407. Arrival detection: within radius + dwell time = fires
408. Arrival detection: within radius but exits before dwell = no fire
409. Multiple geofence check-ins: only first triggers callback
410. Geofence disabled if no destination set
411. Geofence radius configurable (100m, 500m)
412. Arrival callback fires once per session
413. Large coordinates (antipodal): handled without overflow

---

## 7. Controller Unit Tests (80+ tests)

### 7.1 SessionController (`test/features/session/session_controller_test.dart`)
414. `startSession()` creates engine and calls `engine.start()`
415. `startSession(isSimulation: true)` injects simulation services
416. `startSession(isSimulation: false)` uses real services
417. `disarm()` calls `engine.disarm()`
418. `endSession()` calls `engine.endSession()`
419. `triggerDistress()` calls `engine.replaceWithDistressChain()`
420. Battery low side-action: fires notification, does not interrupt chain
421. Battery low fires only once per session (subsequent lows ignored)
422. Incoming call: `engine.pause(incomingCall)` called
423. Call ended: `engine.resume()` called
424. Session state exposed to UI via Riverpod
425. After `endSession()`: navigates to session completed screen
426. After `chainExhausted`: navigates to session completed screen
427. After `distressCompleted`: shows fake "session ended" UI
428. `holdStart()` delegates to engine
429. `holdRelease()` delegates to engine
430. `answerFakeCall()` delegates to engine
431. `hangUp()` delegates to engine
432. `declineFakeCall()` delegates to engine
433. Session lock prevents concurrent sessions
434. `startSession()` with unvalidated mode: validates first
435. Validation failure: shows error, does not start
436. Simulation services injected at session start, not before
437. Real services not used during simulation
438. Speed multiplier set on engine when changed
439. Leap-to-next delegates to engine
440. Log recorded on session end
441. WalkSession state derived from engine events
442. Session orchestrator wired to engine event stream
443. `onPause` callback stops audio/vibration (via orchestrator)

### 7.2 SettingsController (`test/features/settings/settings_controller_test.dart`)
444. Initial state loaded from repository
445. `updateThemeMode()` persists to repository
446. `updateLanguage()` persists to repository
447. `setStealthMode(true)` persists to repository
448. `setStealthMode(false)` persists to repository
449. `setPinHash()` persists to repository
450. `setDuressPinHash()` persists to repository
451. `setPinTimeoutSeconds(15)` persists (default value verified)
452. `setEmergencyNumber()` persists to repository
453. `setAlarmDndOverride()` persists to repository
454. `markOnboardingComplete()` sets isFirstLaunch=false
455. `clearPin()` sets pinHash to null
456. `setBatteryAlertConfig()` persists to repository
457. Each setter emits new state via Riverpod
458. `SettingsController.build()` returns stored settings or defaults

### 7.3 ContactsController (`test/features/contacts/contacts_controller_test.dart`)
459. `addContact()` creates contact with generated UUID
460. `addContact()` sets default sortOrder (append)
461. `addContact()` persists to repository
462. `deleteContact()` removes from repository
463. `deleteContact()` during active session: blocked (session lock)
464. `updateContact()` updates existing contact
465. `reorderContacts()` updates sortOrder on all affected contacts
466. `reorderContacts()` updates sortOrder correctly (regression test)
467. `getAll()` returns sorted by sortOrder
468. Contact list is observable via Riverpod
469. `addContact()` returns new contact's id
470. Delete last contact: list becomes empty
471. `deleteContact()` non-existent id: no crash

### 7.4 ModesController (`test/features/modes/modes_controller_test.dart`)
472. Seed modes loaded on first launch
473. `addMode()` persists to repository
474. `updateMode()` persists to repository
475. `deleteMode()` removes from repository
476. `selectMode()` updates selected mode ID in settings
477. Cannot delete last mode (error or no-op)
478. Mode list observable via Riverpod
479. `getModeById()` returns correct mode
480. Seed modes have unique IDs

### 7.5 ProfileController (`test/features/profile/profile_controller_test.dart`)
481. `build()` returns stored profile or empty
482. `updateName()` persists to repository
483. `updatePhone()` persists to repository
484. `updateMedicalInfo()` persists all medical fields
485. `updatePhoto()` persists photo path

### 7.6 TemplatesController (`test/features/templates/templates_controller_test.dart`)
486. Seed templates loaded on first launch
487. `addTemplate()` persists to repository
488. `deleteTemplate()` removes from repository
489. `getTemplateById()` returns correct template
490. Template list observable via Riverpod

---

## 8. Widget Tests (150+ tests)

### 8.1 Onboarding (`test/features/onboarding/onboarding_screen_test.dart`)
491. Page 0: renders welcome copy ("Hi, I'm Angela")
492. Next: page 0 → page 1 (profile+contact)
493. Next: page 1 → page 2 (permissions)
494. Page 2: button label is "Get Started"
495. Skip is visible on all pages
496. Skip on page 0: navigates to home
497. Skip: calls `markOnboardingComplete()`
498. Get Started on page 2: navigates to home
499. Get Started: saves profile name if filled
500. Get Started: saves contact if both name and phone filled
501. Get Started: does not save contact if only name filled
502. Get Started: does not save contact if only phone filled
503. Get Started with empty fields: no crash, navigates home
504. Home after skip: NOT stuck in redirect loop (regression)
505. Home after Get Started: NOT stuck in redirect loop (regression)

### 8.2 Home screen (`test/features/home/home_screen_test.dart`)
506. GuardianAngelaLogo widget renders
507. Mode selector chips visible
508. At least one mode chip tappable
509. Chain summary section visible
510. Contact chips visible when contacts exist
511. No contact chips when contacts list empty
512. "Start Session" button visible and enabled
513. "Simulate" link visible
514. Safety setup checklist visible on first launch
515. Safety setup checklist hidden after all items complete
516. Start Session tapped: navigates to session screen
517. Simulate tapped: navigates to session screen (simulation mode)
518. Mode chip selected: updates displayed chain summary
519. Chain summary shows correct step count
520. Chain summary pills show step type icons

### 8.3 Session screen (`test/features/session/session_screen_test.dart`)
521. Hold button visible for holdButton step
522. "I'm Safe" slider visible during grace phase
523. Countdown timer visible during grace phase
524. Simulation banner visible in simulation mode
525. Orange border visible in simulation mode
526. Simulation banner NOT visible in real session
527. Fake call push guard: fake call pushed exactly once per step (regression)
528. Speed control slider visible in simulation mode
529. "End Session" button visible
530. End session: shows PIN dialog if PIN configured
531. Disarm: shows PIN dialog if PIN configured
532. Session screen shows step name/description
533. Progress indicator shows current step index
534. Phase label shows "Waiting", "Active", "Grace" correctly
535. Simulation leap button visible in simulation mode
536. Simulation trigger buttons visible behind "Advanced" toggle
537. Session ends: navigates to completed screen
538. stepStarted event: UI updates step display
539. Distress confirmation: shown after trigger
540. Distress confirmation: cancel dismisses

### 8.4 Fake call screen (`test/features/fake_call/fake_call_screen_test.dart`)
541. Ring animation visible on fake call screen
542. Caller name displayed (from FakeCallConfig.callerName)
543. Answer button tappable
544. Decline button tappable
545. Answer: navigates to call-in-progress view
546. Decline with declineIsSafe=true: notifies engine
547. Decline with declineIsSafe=false: shows miss UI
548. Decline-with-distress hold (5s): after hold triggers distress
549. Decline-with-distress hold (2s released): no distress
550. Hang up from in-progress: triggers disarm
551. Fake call screen respects stealth mode (no app branding)
552. Ringtone plays on screen enter
553. Ringtone stops on screen exit
554. Call screen shows photo if configured

### 8.5 PIN dialog (`test/features/pin/pin_dialog_test.dart`)
555. PIN dialog renders keypad
556. Correct PIN: action proceeds
557. Wrong PIN: shows error
558. Wrong PIN 3x: duress PIN check triggered
559. Duress PIN entered: distress chain fires
560. PIN timeout (15s): action blocked, not cancelled
561. Countdown timer visible in PIN dialog
562. Stealth mode: no app branding in PIN dialog
563. PIN dialog: 15s default timeout
564. Blank PIN: does not submit
565. PIN length validation (minimum 4 digits)
566. PIN stars visible (obscured entry)
567. Back button dismisses PIN dialog → action blocked
568. Biometric option shown if configured (disarm only)

### 8.6 Settings screen (`test/features/settings/settings_screen_test.dart`)
569. Theme toggle renders
570. Language selector renders
571. Stealth mode toggle renders
572. PIN change option renders
573. Emergency number field renders
574. Emergency number edit persists
575. Alarm DND override toggle renders
576. Navigates to mode editor
577. Navigates to contacts screen
578. Battery alert section renders
579. "End your current session" message shown during active session

### 8.7 Contacts screen (`test/features/contacts/contacts_screen_test.dart`)
580. Contact list renders
581. Add contact button visible
582. Contact card shows name and phone
583. Delete contact tappable
584. Delete during session: blocked with message
585. Reorder drag updates sort order
586. No contacts: empty state message
587. Add contact form: name + phone + optional relationship
588. Add contact validates required fields
589. Saved contact appears in list

### 8.8 Mode editor (`test/features/modes/mode_editor_test.dart`)
590. Step list renders for existing mode
591. Add step button visible
592. Drag to reorder steps
593. Delete step button tappable
594. Save button persists mode
595. Cancel button discards changes
596. Step type selector shows all 9 types
597. Timing fields (wait, duration, grace) editable
598. Config fields per step type rendered
599. FakeCallConfig.declineIsSafe toggle visible
600. HardwareButtonConfig.pressCount field visible

### 8.9 About screen (`test/features/about/about_screen_test.dart`)
601. GuardianAngelaLogo renders
602. App name "Guardian Angela" displayed
603. Version string displayed
604. "Ask for Angela" reference displayed
605. About description is non-empty

### 8.10 Session completed screen (`test/features/session/session_completed_test.dart`)
606. Session duration displayed
607. Steps completed count displayed
608. "Back to Home" button visible and tappable
609. For distressCompleted: shows appropriate message
610. For chainExhausted: shows appropriate message

### 8.11 Simulation controls (`test/features/session/simulation_controls_test.dart`)
611. Speed slider visible (1x–1000x range)
612. Preset buttons (1x, 10x, 100x) visible
613. Preset buttons update speed
614. Leap button calls engine.leapToNext()
615. Advanced toggle shows trigger buttons when expanded
616. Trigger arrival button calls triggerArrival()
617. Trigger low battery button calls triggerLowBattery()
618. Trigger panic button calls triggerPanic()
619. Speed display shows current multiplier
620. Logarithmic slider: 100x is near middle of range

### 8.12 Pride widgets (`test/core/theme/pride_widgets_test.dart`)
621. PrideDivider renders without overflow
622. PrideProgressBar renders with progress 0.0 to 1.0
623. PridePageIndicator shows correct active dot
624. PrideProgressBar progress=0.0: correct visual
625. PrideProgressBar progress=1.0: correct visual

### 8.13 GuardianAngelaLogo (`test/core/theme/guardian_angela_logo_test.dart`)
626. Renders at 32px without overflow
627. Renders at 200px without overflow
628. CustomPaint used (not image)
629. No red error box in golden test

### 8.14 Hold button widget (`test/core/widgets/hold_button_test.dart`)
630. Renders in idle state
631. Renders in holding state
632. Renders in grace state
633. `onHoldStart` callback called on press down
634. `onHoldRelease` callback called on release

### 8.15 Chain summary widget (`test/features/home/chain_summary_test.dart`)
635. Step pills rendered for each step
636. Tapping pill opens bottom sheet
637. Bottom sheet shows step details
638. Step type icon correct for each type
639. Grace period shown in pill
640. Bottom sheet dismiss on tap outside

---

## 9. Integration Tests (150+ tests)

### 9.1 Walk Mode full flow (`test/integration/walk_mode_flow_test.dart`)
641. Onboarding → home → start → session screen reached
642. Session screen: hold button visible
643. Hold button: press and hold for 10s without release → no escalation
644. Hold button: release for 2s → grace starts
645. Grace expires → stepAdvancing → SMS step (if no contacts: skipped)
646. Chain exhausted → session completed screen
647. Start → hold → release → re-hold within sensitivity → no escalation
648. Start → hold → release → grace → disarm → home
649. Walk mode: full 5-step chain with fake contacts
650. Walk mode: disarm at step 0 returns to idle

### 9.2 Date Mode flow (`test/integration/date_mode_flow_test.dart`)
651. Date mode: starts with wait phase (1800s)
652. Date mode: reminder fires after wait
653. Date mode: miss reminder → repeatMissed
654. Date mode: miss all retries → stepAdvancing to fakeCall
655. Date mode: fake call step reached
656. Date mode: respond to reminder → userDisarmed
657. Date mode: fakeCall → decline → disarm (declineIsSafe=true)

### 9.3 Distress flow (`test/integration/distress_flow_test.dart`)
658. Hardware panic: 5 volume presses → confirmation window shown
659. Confirmation window: cancel → no distress
660. Confirmation window: wait 5s → distress chain starts
661. Distress chain: SMS fires (to fake service)
662. Distress chain: emergency call fires (to fake service)
663. Distress chain exhausted: shows fake "session ended"
664. Hardware panic during wait phase: replaces chain
665. Hardware panic during grace phase: replaces chain
666. Hardware panic during fake call (paused): replaces chain
667. Double hardware panic within 500ms: only one replacement

### 9.4 Duress flow (`test/integration/duress_flow_test.dart`)
668. End session with duress PIN: triggers distress chain
669. Duress PIN triggers: chain replaces correctly
670. Duress chain fires all steps
671. After duress: fake "session ended" shown (not real ended)
672. Duress during step 3: distress from step 3 (not start)

### 9.5 Wrong PIN flow (`test/integration/wrong_pin_flow_test.dart`)
673. Wrong PIN threshold (default 3): 3 wrong PINs → distress
674. Wrong PIN threshold 2: 2 wrong PINs → distress
675. Correct PIN: wrong count resets
676. Wrong PIN counter per-session (resets on session end)
677. Wrong PIN during distress chain: ignored (already in distress)

### 9.6 Simulation flow (`test/integration/simulation_flow_test.dart`)
678. Simulation start: no real SMS sent
679. Simulation: speed 10x → full chain faster
680. Simulation: descriptions shown as toasts
681. Simulation: fake call still shows (local UI)
682. Simulation: chain exhausted → completed screen
683. Simulation: disarm works
684. Simulation: SIMULATION banner always visible
685. Simulation: orange border always visible
686. Simulation: no "GO LIVE" button

### 9.7 PIN gating (`test/integration/pin_gating_test.dart`)
687. Disarm with PIN: PIN dialog shown
688. Disarm correct PIN: disarm proceeds
689. Disarm wrong PIN: disarm blocked
690. Disarm PIN timeout 15s: action blocked
691. End session with PIN: PIN dialog shown
692. End session correct PIN: ends session
693. Quick Exit with PIN: PIN dialog shown
694. Quick Exit correct PIN: app hides
695. Biometric disarm (if configured): works
696. No PIN configured: no dialog shown

### 9.8 Fake call lifecycle (`test/integration/fake_call_lifecycle_test.dart`)
697. Fake call screen pushed when fake call step starts
698. Ring → answer → call in progress UI
699. In progress → hang up → disarm
700. Ring → decline (declineIsSafe=true) → disarm
701. Ring → timeout → miss → retry
702. Fake call pushed exactly once (not on every rebuild, regression)
703. Real call during fake call: auto-disarm

### 9.9 GPS arrival disarm (`test/integration/gps_arrival_test.dart`)
704. GPS arrival: notification shown to user
705. GPS arrival: confirmation dialog shown
706. GPS arrival + PIN: PIN dialog shown
707. GPS arrival + correct PIN: session ends
708. GPS arrival cancel: session continues
709. GPS arrival: Haversine calculation correct

### 9.10 Session locks (`test/integration/session_lock_test.dart`)
710. Delete contact during session: blocked with message
711. Edit mode during session: blocked with message
712. Import backup during session: blocked with message
713. Message shown: "End your current session to access this setting"

### 9.11 Battery alert (`test/integration/battery_alert_test.dart`)
714. Battery drops below threshold: notification shown
715. Battery alert fires only once per session (second drop: ignored)
716. Battery alert does NOT interrupt chain
717. Battery alert default: disabled
718. Battery alert with SMS option: SMS sent to contacts

### 9.12 Persistence (`test/integration/persistence_test.dart`)
719. Settings survive app restart (simulated via repository reload)
720. Contacts persist across repository reload
721. Modes persist across repository reload
722. Session log written on session end
723. Session log survives repository reload
724. Seed modes loaded on first launch only
725. Second launch: user modes preserved
726. After clearing Hive: seed data re-seeded
727. AppSettings defaults after clear: isFirstLaunch=true

### 9.13 Chain exhaustion (`test/integration/chain_exhaustion_test.dart`)
728. Single-step chain: exhausted after grace
729. Multi-step chain: all steps fire in order
730. Multi-step chain: last step grace → chainExhausted
731. chainExhausted: `EngineEnded(chainExhausted)`
732. chainExhausted: no disarm = EngineEnded (not userDisarmed)
733. After exhaustion: session log records all steps
734. Retry chain: all retries exhausted then advance
735. Retry last step exhausted: chainExhausted
736. 5-step chain: all 5 stepStarted events fired
737. 5-step chain: all 5 stepAdvancing events fired (except last → exhausted)

### 9.14 Smart validation (`test/integration/smart_validation_test.dart`)
738. SMS step + no contacts: block start
739. Phone call step + no contacts: block start
740. Emergency call only + no contacts: block start
741. Hold button only + no contacts: allow start
742. Loud alarm only + no contacts: allow start
743. Add contact: validation now passes
744. Simulation with no contacts: allow start (warn)

### 9.15 Stealth mode (`test/integration/stealth_mode_test.dart`)
745. Stealth mode enabled: app name hidden in PIN screen
746. Stealth mode enabled: notification disguised
747. Stealth mode disabled: normal app name shown
748. PIN screen: no Guardian Angela branding in stealth
749. Timer display: configurable (normal/small/none)

### 9.16 Quick Exit (`test/integration/quick_exit_test.dart`)
750. Quick Exit: app hides
751. Quick Exit: session data preserved (not deleted)
752. Quick Exit: session logs accessible after reopen
753. Quick Exit PIN required if configured
754. Quick Exit: biometric NOT valid (spec §1.3)

---

## 10. Regression Tests (40+ tests)

### 10.1 Known regressions (`test/regression/`)
755. Onboarding → home: NOT stuck in redirect loop
756. Skip → home: NOT stuck in redirect loop
757. Get Started → home: NOT stuck in redirect loop
758. Fake call pushed exactly once (not every rebuild)
759. `resume()` restores `_awaitingFirstTouch` correctly
760. Call state "idle" maps to ended for resume
761. `reorderContacts` updates sortOrder field (not position)
762. `endSession()` on EngineIdle is no-op
763. DropdownButtonFormField uses `value:` not `initialValue:`
764. AppLocalizations.delegate is registered in MaterialApp
765. StepConfig.typeName matches fromJson type strings (all 9)
766. PIN timeout 15s default (v2: not 10s)
767. Hardware button 5 presses default (v2: not 3)
768. Battery alert fires once per session only
769. Battery alert: default OFF
770. No EngineSubChainActive state exists (v2 removal)
771. `subChainStarted` event does not exist (v2 removal)
772. `subChainCompleted` event does not exist (v2 removal)
773. Distress chain uses same 4 engine states (no special state)
774. `replaceWithDistressChain([])` throws ArgumentError
775. `declineWithDistressHoldSeconds` defaults to 5 (v2: was 3)
776. Session does NOT resume after crash (spec §2.1)
777. Shake-to-SOS does NOT exist (spec §2.2)
778. Battery SMS bypass does NOT exist (spec §2.3)
779. No "GO LIVE" button in simulation (spec §6.5)
780. Distress chain fires after fake call decline-with-distress hold
781. Distress confirmation window fires before distress chain
782. Distress confirmation window: PIN required to cancel
783. Engine state: EnginePaused.snapshot.isAwaitingFirstTouch preserved
784. EndReason.distressCompleted on distress chain end
785. SessionMode.distressChainSteps nullable (can be null)
786. Simulation service: zero telephony imports
787. BatteryAlertConfig has no chainSteps field (v2 removal)
788. `duress_chain_config.dart` does not exist (v2 removal)
789. `wrong_pin_chain_config.dart` does not exist (v2 removal)
790. Max pause duration: null = unlimited
791. PauseReason.incomingCall exists in enum
792. EndReason.distressCompleted exists in enum
793. All 10 ChainEvents present (not 12 as in old4)
794. `chainExhausted` ChainEvent exists

---

## 11. Property-Based / Fuzzy Tests (50+ tests)

### 11.1 JSON round-trip property (`test/property/json_round_trip_property_test.dart`)
795. HoldButtonConfig arbitrary fields: toJson→fromJson == original
796. FakeCallConfig arbitrary fields: toJson→fromJson == original
797. SmsContactConfig arbitrary fields: toJson→fromJson == original
798. CallEmergencyConfig arbitrary fields: toJson→fromJson == original
799. PhoneCallContactConfig arbitrary fields: toJson→fromJson == original
800. LoudAlarmConfig arbitrary fields: toJson→fromJson == original
801. CountdownWarningConfig arbitrary fields: toJson→fromJson == original
802. DisguisedReminderConfig arbitrary fields: toJson→fromJson == original
803. HardwareButtonConfig arbitrary fields: toJson→fromJson == original
804. EmergencyContact arbitrary fields: toJson→fromJson == original

### 11.2 Timer phase sequencing property (`test/property/timer_phase_test.dart`)
805. Wait phase always starts before duration phase
806. Duration phase always starts before grace phase
807. Grace phase always ends before stepAdvancing emitted
808. Retry never executes wait phase
809. First execution always starts with wait phase (if waitSeconds > 0)
810. Events are strictly monotonically increasing in time
811. No stepAdvancing before duration completes
812. stepStarted always precedes reminderFired for same step
813. reminderFired always precedes grace start
814. Chain events for step N all precede stepStarted for step N+1

### 11.3 Disarm invariants (`test/property/disarm_invariants_test.dart`)
815. `disarm()` always resets stepIndex to 0 regardless of state
816. `disarm()` always resets missCount to 0
817. `disarm()` always emits `userDisarmed` when running
818. `disarm()` never emits `stepAdvancing` or `chainExhausted`
819. After `disarm()`: engine is in EngineRunning at step 0
820. After `disarm()` + `disarm()`: second disarm is no-op
821. Multiple disarms: `userDisarmed` emitted exactly once per disarm
822. `disarm()` after endSession: no-op (not running)
823. After N missed checks: `disarm()` resets to step 0 (not step N)
824. `disarm()` during any TimerPhase: always succeeds

### 11.4 Speed multiplier property (`test/property/speed_multiplier_test.dart`)
825. Any value in [0.01, 1000.0] accepted for simulation
826. Any value > 1.0 rejected for real session
827. 1.0 always accepted for both
828. NaN always rejected
829. Infinity always rejected

### 11.5 Engine event ordering (`test/property/event_ordering_test.dart`)
830. `stepStarted` always before `stepAdvancing` for same step
831. `sessionPaused` always before `sessionResumed`
832. `userDisarmed` always before next `stepStarted`
833. `chainExhausted` is always the last event emitted
834. `sessionEnded` is always the last event emitted
835. `stepExecutionFailed` does not prevent next event
836. No duplicate events for single user action (disarm emits userDisarmed once)
837. Events carry correct step reference
838. Events carry correct missCount
839. Event stream never errors (errors isolated to stepExecutionFailed event)

### 11.6 No duplicate events (`test/property/no_duplicate_events_test.dart`)
840. `start()` emits exactly one `stepStarted`
841. Single `holdRelease()` emits at most one `stepAdvancing`
842. Single `disarm()` emits exactly one `userDisarmed`
843. Single `endSession()` emits exactly one `sessionEnded`
844. `chainExhausted` emitted at most once per session

---

## Summary

| Category | Tests | Status |
|---|---|---|
| 1. Engine Unit | 175 | Pending PM code |
| 2. Model Unit | 79 | Pending PM code |
| 3. Orchestration | 40 | Pending PM code |
| 4. Validation | 30 | Pending PM code |
| 5. Repository | 48 | Pending PM code |
| 6. Service | 43 | Pending PM code |
| 7. Controller | 77 | Pending PM code |
| 8. Widget | 150 | Pending PM code |
| 9. Integration | 114 | Pending PM code |
| 10. Regression | 40 | Pending PM code |
| 11. Property-Based | 50 | Pending PM code |
| **Total** | **846** | **Written as skeleton** |

Note: Many tests expand to 2-3 sub-tests (setup, act, assert variants) bringing the total
individual `expect()` calls to 1000+. The property-based tests run 100 iterations each.

---

## Implementation Notes

- All engine tests use `fakeAsync()` from `package:fake_async`
- `FixedRandom` used for deterministic jitter elimination
- Fakes used for all service dependencies (no mocks)
- `package:checks` for expressive assertions
- Tests mirror `lib/` structure in `test/`
- Skipped tests use `skip: 'Waiting for PM agent Phase N'`
