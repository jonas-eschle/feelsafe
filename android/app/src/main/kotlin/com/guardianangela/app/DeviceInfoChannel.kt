package com.guardianangela.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Implements `com.guardianangela.app/device_info`.
 *
 * [getSimPhoneNumber] reads the SIM's own MSISDN. Returns a non-null,
 * non-empty [String] on success, or throws a [io.flutter.plugin.common.PlatformException]
 * with code `"permissionDenied"` or `"unavailable"` per contract §2.6.
 *
 * Dart hard-depends on those two exact error-code strings; do not change them.
 */
class DeviceInfoChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSimPhoneNumber" -> getSimPhoneNumber(result)
            else -> result.notImplemented()
        }
    }

    private fun getSimPhoneNumber(result: MethodChannel.Result) {
        // READ_PHONE_NUMBERS required on API 26+ for getLine1Number.
        val hasPhoneNumbers = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_PHONE_NUMBERS,
        ) == PackageManager.PERMISSION_GRANTED

        val hasPhoneState = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_PHONE_STATE,
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPhoneNumbers && !hasPhoneState) {
            result.error("permissionDenied", "READ_PHONE_NUMBERS permission not granted", null)
            return
        }

        try {
            val number = readSimNumber()
            if (number.isNullOrEmpty()) {
                result.error("unavailable", "SIM phone number is not available on this device", null)
            } else {
                result.success(number)
            }
        } catch (e: SecurityException) {
            result.error("permissionDenied", e.message, null)
        } catch (e: Exception) {
            result.error("unavailable", e.message, null)
        }
    }

    private fun readSimNumber(): String? {
        // On API 33+ use SubscriptionManager for per-subscription number.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val sm = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE)
                as SubscriptionManager
            val subscriptions = sm.activeSubscriptionInfoList ?: return null
            for (info in subscriptions) {
                val number = sm.getPhoneNumber(info.subscriptionId)
                if (!number.isNullOrEmpty()) return number
            }
            return null
        }

        // API 26..32: fall back to TelephonyManager.line1Number.
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        @Suppress("HardwareIds")
        return tm.line1Number?.takeIf { it.isNotEmpty() }
    }
}
