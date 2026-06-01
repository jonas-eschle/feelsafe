package com.guardianangela.app

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Implements `com.guardianangela.app/system_ui`.
 *
 * [toggleLockTaskMode] pins the app to the screen (screen-pinning /
 * lock-task mode) using [Activity.startLockTask] / [Activity.stopLockTask].
 * User-initiated screen-pinning needs no special permission.
 * Note: PACKAGE_USAGE_STATS is NOT required for user-confirmed pinning (§5-D5
 * of the contract; that perm is for usage-stats, not screen-pinning).
 */
class SystemUiChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "toggleLockTaskMode" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                if (enabled) {
                    activity.startLockTask()
                } else {
                    activity.stopLockTask()
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
