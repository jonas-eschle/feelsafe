package com.guardianangela.app

import android.app.NotificationManager
import android.content.Context
import android.media.AudioManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `com.guardianangela.app/device_state`:
 *  - `isDndOn`  -> Boolean (current filter != INTERRUPTION_FILTER_ALL)
 *  - `isSilent` -> Boolean (ringer mode == silent or vibrate)
 */
class DeviceStateChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val methodChannel = MethodChannel(messenger, CHANNEL)

    fun attach() {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "isDndOn" -> result.success(isDnd())
                "isSilent" -> result.success(isSilent())
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("device_state_error", t.message, t.stackTraceToString())
        }
    }

    private fun isDnd(): Boolean {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL &&
            nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_UNKNOWN
    }

    private fun isSilent(): Boolean {
        val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return am.ringerMode != AudioManager.RINGER_MODE_NORMAL
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/device_state"
    }
}
