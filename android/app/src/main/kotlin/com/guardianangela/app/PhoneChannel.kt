package com.guardianangela.app

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `com.guardianangela.app/phone` — auto-dial for escalation calls.
 *
 * Methods:
 *  - `call({number, isEmergency})` -> when CALL_PHONE granted and not emergency,
 *      uses [Intent.ACTION_CALL]. Emergency numbers always use [Intent.ACTION_DIAL]
 *      because Android blocks ACTION_CALL for 911-class numbers without system privilege.
 */
class PhoneChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val methodChannel = MethodChannel(messenger, CHANNEL)

    fun attach() {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "call" -> {
                    val number = call.argument<String>("number")
                        ?: throw IllegalArgumentException("number required")
                    val isEmergency = call.argument<Boolean>("isEmergency") ?: false
                    place(number, isEmergency)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("phone_error", t.message, t.stackTraceToString())
        }
    }

    private fun place(number: String, isEmergency: Boolean) {
        val uri = Uri.parse("tel:${Uri.encode(number)}")
        val action = if (isEmergency || !hasCallPhonePermission()) {
            Intent.ACTION_DIAL
        } else {
            Intent.ACTION_CALL
        }
        val intent = Intent(action, uri).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        activity.startActivity(intent)
    }

    private fun hasCallPhonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(activity, Manifest.permission.CALL_PHONE) ==
            PackageManager.PERMISSION_GRANTED
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/phone"
    }
}
