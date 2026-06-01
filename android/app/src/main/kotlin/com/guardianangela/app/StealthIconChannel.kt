package com.guardianangela.app

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Implements `com.guardianangela.app/stealth_icon`.
 *
 * [setStealthIconEnabled] toggles the launcher `<activity-alias>`
 * `.MainActivityAlias` using [PackageManager.setComponentEnabledSetting].
 *
 * IMPORTANT: the alias (not MainActivity itself) is the toggled component.
 * Disabling MainActivity directly would make the app permanently unlaunchable.
 * The alias carries the MAIN/LAUNCHER intent-filter; MainActivity has no
 * launcher filter of its own (see AndroidManifest.xml).
 *
 * Note: Android may kill the process when its only launcher component is
 * disabled — this is expected behaviour per the stealth-mode spec.
 */
class StealthIconChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    /** Fully-qualified component name of the launcher alias in AndroidManifest.xml. */
    private val launcherAliasComponent = ComponentName(
        context.packageName,
        "${context.packageName}.MainActivityAlias",
    )

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setStealthIconEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                val newState = if (enabled) {
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                } else {
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                }
                context.packageManager.setComponentEnabledSetting(
                    launcherAliasComponent,
                    newState,
                    PackageManager.DONT_KILL_APP,
                )
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
