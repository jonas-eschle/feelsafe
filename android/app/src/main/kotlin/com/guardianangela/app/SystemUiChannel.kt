package com.guardianangela.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `com.guardianangela.app/system_ui`:
 *  - `quickExit`                           -> finishAndRemoveTask
 *  - `requestBatteryOptimizationExemption` -> launch settings intent
 *  - `isBatteryOptimized`                  -> Boolean
 */
class SystemUiChannel(
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
                "quickExit" -> {
                    activity.finishAndRemoveTask()
                    result.success(null)
                }
                "requestBatteryOptimizationExemption" -> {
                    val intent = Intent(
                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                        Uri.parse("package:${activity.packageName}"),
                    ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    activity.startActivity(intent)
                    result.success(null)
                }
                "isBatteryOptimized" -> {
                    val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
                    // Returns `true` when we are *optimized* (i.e. NOT exempted).
                    val exempted = pm.isIgnoringBatteryOptimizations(activity.packageName)
                    result.success(!exempted)
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("system_ui_error", t.message, t.stackTraceToString())
        }
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/system_ui"
    }
}
