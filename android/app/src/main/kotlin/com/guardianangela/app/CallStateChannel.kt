package com.guardianangela.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Handles `com.guardianangela.app/call_state` (start/stop) plus the
 * `/call_state_events` event channel which emits the string states
 * `"idle"`, `"ringing"`, `"active"`, `"ended"`.
 *
 * Uses [TelephonyCallback] on Android 12+ (API 31) and falls back to the
 * deprecated [PhoneStateListener] on older versions.
 */
class CallStateChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)

    private var sink: EventChannel.EventSink? = null
    private var modernCallback: Any? = null // TelephonyCallback (API 31+)
    private var legacyListener: PhoneStateListener? = null
    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE

    fun attach() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> {
                    startListening()
                    result.success(null)
                }
                "stop" -> {
                    stopListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("call_state_error", t.message, t.stackTraceToString())
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun startListening() {
        if (!hasReadPhoneStatePermission()) {
            // Without READ_PHONE_STATE we cannot observe calls; emit nothing and fail loud.
            throw SecurityException("READ_PHONE_STATE permission not granted")
        }
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cb = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    handleStateChange(state)
                }
            }
            tm.registerTelephonyCallback(Executors.newSingleThreadExecutor(), cb)
            modernCallback = cb
        } else {
            @Suppress("DEPRECATION")
            val listener = object : PhoneStateListener() {
                override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                    handleStateChange(state)
                }
            }
            @Suppress("DEPRECATION")
            tm.listen(listener, PhoneStateListener.LISTEN_CALL_STATE)
            legacyListener = listener
        }
    }

    private fun stopListening() {
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            modernCallback?.let { tm.unregisterTelephonyCallback(it as TelephonyCallback) }
            modernCallback = null
        } else {
            @Suppress("DEPRECATION")
            legacyListener?.let { tm.listen(it, PhoneStateListener.LISTEN_NONE) }
            legacyListener = null
        }
    }

    private fun handleStateChange(state: Int) {
        // Map raw TelephonyManager states into the Dart-facing strings. We also
        // synthesise "ended" when the state transitions back to IDLE after a
        // non-idle state (Android does not fire an explicit end event).
        val emit = when (state) {
            TelephonyManager.CALL_STATE_IDLE ->
                if (lastState != TelephonyManager.CALL_STATE_IDLE) "ended" else "idle"
            TelephonyManager.CALL_STATE_RINGING -> "ringing"
            TelephonyManager.CALL_STATE_OFFHOOK -> "active"
            else -> null
        }
        lastState = state
        if (emit != null) {
            val current = sink ?: return
            MainThread.run { current.success(emit) }
        }
    }

    private fun hasReadPhoneStatePermission(): Boolean {
        return ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) ==
            PackageManager.PERMISSION_GRANTED
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/call_state"
        const val EVENT_CHANNEL = "com.guardianangela.app/call_state_events"
    }
}
