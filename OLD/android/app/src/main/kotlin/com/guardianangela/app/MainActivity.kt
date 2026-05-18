package com.guardianangela.app

import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Flutter host activity. Registers every platform channel used by the Dart service
 * layer: SMS, phone, call-state, hardware-buttons, system-UI, stealth-icon,
 * device-state. Each channel owner is a small Kotlin class in this package.
 */
class MainActivity : FlutterActivity() {

    private lateinit var smsChannel: SmsChannel
    private lateinit var phoneChannel: PhoneChannel
    private lateinit var callStateChannel: CallStateChannel
    private lateinit var hardwareButtonChannel: HardwareButtonChannel
    private lateinit var systemUiChannel: SystemUiChannel
    private lateinit var stealthIconChannel: StealthIconChannel
    private lateinit var deviceStateChannel: DeviceStateChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        // SMS method channel + event channel (retry/delivery updates).
        smsChannel = SmsChannel(this, binaryMessenger)
        smsChannel.attach()

        // Phone (auto-dial) method channel.
        phoneChannel = PhoneChannel(this, binaryMessenger)
        phoneChannel.attach()

        // Call-state method + event channel.
        callStateChannel = CallStateChannel(this, binaryMessenger)
        callStateChannel.attach()

        // Hardware buttons method + event channel. The event sink is shared
        // with MainActivity so dispatchKeyEvent can forward volume/power keys.
        hardwareButtonChannel = HardwareButtonChannel(binaryMessenger)
        hardwareButtonChannel.attach()

        // System UI (quickExit, battery exemption).
        systemUiChannel = SystemUiChannel(this, binaryMessenger)
        systemUiChannel.attach()

        // Stealth icon (activity-alias toggling).
        stealthIconChannel = StealthIconChannel(this, binaryMessenger)
        stealthIconChannel.attach()

        // Device state (DND / silent).
        deviceStateChannel = DeviceStateChannel(this, binaryMessenger)
        deviceStateChannel.attach()
    }

    /**
     * Intercept volume and power key events while a session is active so the user
     * can trigger the panic / distress chain without the system consuming them.
     * Falls through to super for normal handling when no session is active.
     */
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (SessionActiveState.isActive && event.action == KeyEvent.ACTION_DOWN) {
            val payload: String? = when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> "volume_up"
                KeyEvent.KEYCODE_VOLUME_DOWN -> "volume_down"
                KeyEvent.KEYCODE_POWER -> "power"
                else -> null
            }
            if (payload != null) {
                HardwareButtonChannel.forwardKey(payload)
                // Return false so default handling (volume adjust) still runs.
                // The panic pattern is detected Dart-side via the event stream.
            }
        }
        return super.dispatchKeyEvent(event)
    }
}

/**
 * Thread-safe flag consulted by [MainActivity.dispatchKeyEvent] to decide whether
 * to mirror volume / power keys into the Dart event stream. Toggled by the
 * `hardware_buttons` method channel via start/stop.
 */
object SessionActiveState {
    @Volatile
    var isActive: Boolean = false
}

/**
 * Small helper for emitting to an [EventChannel.EventSink] on the main (UI) thread.
 * EventSink methods must be called from the main thread per Flutter contract.
 */
internal object MainThread {
    private val handler = Handler(Looper.getMainLooper())
    fun run(action: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) action() else handler.post(action)
    }
}
