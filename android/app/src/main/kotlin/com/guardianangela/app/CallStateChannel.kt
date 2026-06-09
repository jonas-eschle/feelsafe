package com.guardianangela.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Implements `com.guardianangela.app/call_state` as BOTH a [MethodChannel]
 * (startListening / stopListening) and an [EventChannel] (idle / ringing /
 * offhook strings).
 *
 * The two channels share the exact same name string per the contract §2.2.
 */
class CallStateChannel(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var telephonyManager: TelephonyManager? = null

    // API 31+ callback
    private var telephonyCallback: TelephonyCallback? = null

    // API < 31 listener
    @Suppress("DEPRECATION")
    private var phoneStateListener: PhoneStateListener? = null

    // ── MethodChannel handler ────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startListening" -> {
                startTelephonyListener()
                result.success(null)
            }
            "stopListening" -> {
                stopTelephonyListener()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // ── EventChannel StreamHandler ───────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        // Start the telephony listener on EventChannel subscription, not only on
        // the `startListening` MethodChannel call. A MethodChannel and an
        // EventChannel registered under the SAME channel name share one
        // BinaryMessenger message-handler slot, so the EventChannel's
        // StreamHandler (registered second in MainActivity) SHADOWS the
        // MethodChannel handler — `invokeMethod("startListening")` then resolves
        // to MissingPluginException and is swallowed by RealCallStateService.
        // Without this line the telephony listener would never register and a
        // real incoming call would NOT pause the session. `onCancel` already
        // stops it symmetrically. (Surfaced by the #11 device-e2e on the
        // emulator via `adb emu gsm call`; host tests use the sim seam and could
        // not catch it.)
        startTelephonyListener()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopTelephonyListener()
    }

    // ── Telephony listener management ────────────────────────────────────────

    private fun startTelephonyListener() {
        if (!hasPhoneStatePermission()) {
            eventSink?.error("permissionDenied", "READ_PHONE_STATE not granted", null)
            return
        }
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        telephonyManager = tm

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cb = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    emitState(state)
                }
            }
            telephonyCallback = cb
            tm.registerTelephonyCallback(context.mainExecutor, cb)
        } else {
            @Suppress("DEPRECATION")
            val listener = object : PhoneStateListener() {
                @Deprecated("Deprecated in Java")
                override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                    emitState(state)
                }
            }
            phoneStateListener = listener
            @Suppress("DEPRECATION")
            tm.listen(listener, PhoneStateListener.LISTEN_CALL_STATE)
        }
    }

    private fun stopTelephonyListener() {
        val tm = telephonyManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyCallback?.let { tm.unregisterTelephonyCallback(it) }
            telephonyCallback = null
        } else {
            @Suppress("DEPRECATION")
            phoneStateListener?.let { tm.listen(it, PhoneStateListener.LISTEN_NONE) }
            phoneStateListener = null
        }
        telephonyManager = null
    }

    private fun emitState(state: Int) {
        val stateString = when (state) {
            TelephonyManager.CALL_STATE_IDLE -> "idle"
            TelephonyManager.CALL_STATE_RINGING -> "ringing"
            TelephonyManager.CALL_STATE_OFFHOOK -> "offhook"
            else -> return
        }
        eventSink?.success(stateString)
    }

    private fun hasPhoneStatePermission(): Boolean =
        ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_PHONE_STATE,
        ) == PackageManager.PERMISSION_GRANTED
}
