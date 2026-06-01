package com.guardianangela.app

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Primary host activity.
 *
 * Extends [FlutterFragmentActivity] (required by `local_auth`'s
 * BiometricPrompt which needs a FragmentActivity host).
 *
 * In [configureFlutterEngine] all 7 custom platform channels are registered:
 * - `…/sms` (MethodChannel, bidirectional)
 * - `…/call_state` (MethodChannel + EventChannel, same name)
 * - `…/hardware_button` (EventChannel)
 * - `…/system_ui` (MethodChannel)
 * - `…/stealth_icon` (MethodChannel)
 * - `…/device_info` (MethodChannel)
 * - `…/quick_exit` (MethodChannel)
 *
 * [dispatchKeyEvent] intercepts VOLUME_UP / VOLUME_DOWN and forwards them to
 * the `hardware_button` EventChannel while a Dart listener is active,
 * suppressing the system volume HUD during a session.
 */
class MainActivity : FlutterFragmentActivity() {

    private val hardwareButtonChannel = HardwareButtonChannel()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // ── SMS channel ──────────────────────────────────────────────────────
        val smsChannel = SmsChannel(applicationContext)
        val smsMethodChannel = MethodChannel(messenger, "com.guardianangela.app/sms")
        smsMethodChannel.setMethodCallHandler(smsChannel)
        smsChannel.attach(smsMethodChannel)

        // ── Call state: MethodChannel + EventChannel (same name) ─────────────
        val callStateHandler = CallStateChannel(applicationContext)
        MethodChannel(messenger, "com.guardianangela.app/call_state")
            .setMethodCallHandler(callStateHandler)
        EventChannel(messenger, "com.guardianangela.app/call_state")
            .setStreamHandler(callStateHandler)

        // ── Hardware button EventChannel ─────────────────────────────────────
        EventChannel(messenger, "com.guardianangela.app/hardware_button")
            .setStreamHandler(hardwareButtonChannel)

        // ── System UI ────────────────────────────────────────────────────────
        MethodChannel(messenger, "com.guardianangela.app/system_ui")
            .setMethodCallHandler(SystemUiChannel(this))

        // ── Stealth icon ─────────────────────────────────────────────────────
        MethodChannel(messenger, "com.guardianangela.app/stealth_icon")
            .setMethodCallHandler(StealthIconChannel(applicationContext))

        // ── Device info ──────────────────────────────────────────────────────
        MethodChannel(messenger, "com.guardianangela.app/device_info")
            .setMethodCallHandler(DeviceInfoChannel(applicationContext))

        // ── Quick exit ───────────────────────────────────────────────────────
        MethodChannel(messenger, "com.guardianangela.app/quick_exit")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "quickExit" -> {
                        result.success(null)
                        // finishAndRemoveTask terminates the app and removes it
                        // from the Recents list (spec 04:1020-1021).
                        finishAndRemoveTask()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Intercepts volume keys and forwards them to the `hardware_button`
     * EventChannel while a Dart listener is subscribed.
     *
     * Returns `true` (consuming the event and suppressing the volume HUD)
     * only while [HardwareButtonChannel.sink] is non-null, i.e. the Dart
     * `hardware_button_service` has an active subscription. Otherwise falls
     * through to the system for normal volume adjustment.
     */
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val sink = hardwareButtonChannel.sink
        if (sink != null) {
            val keyName = when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> "volume_up"
                KeyEvent.KEYCODE_VOLUME_DOWN -> "volume_down"
                else -> null
            }
            if (keyName != null) {
                val action = when (event.action) {
                    KeyEvent.ACTION_DOWN -> "down"
                    KeyEvent.ACTION_UP -> "up"
                    else -> null
                }
                if (action != null) {
                    sink.success(mapOf("action" to action, "key" to keyName))
                    return true // suppress volume HUD
                }
            }
        }
        return super.dispatchKeyEvent(event)
    }
}
