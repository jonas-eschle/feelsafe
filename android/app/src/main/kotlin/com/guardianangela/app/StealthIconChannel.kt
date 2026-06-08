package com.guardianangela.app

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Implements `com.guardianangela.app/stealth_icon`.
 *
 * [setStealthIcon] applies a per-preset launcher disguise by enabling exactly
 * ONE `<activity-alias>` and disabling all the others, via
 * [PackageManager.setComponentEnabledSetting] with [PackageManager.DONT_KILL_APP].
 *
 * The launcher MAIN/LAUNCHER intent-filter lives on the aliases (never on
 * [MainActivity] itself), so swapping which alias is enabled changes the
 * home-screen icon/label without ever making the app unlaunchable. The real
 * Guardian Angela launcher is `.MainActivityAlias` (preset `none`); each
 * disguise preset maps to a `StealthAlias_<preset>` alias declared in
 * AndroidManifest.xml.
 *
 * INVARIANT: after every [setStealthIcon] call, exactly one launcher alias is
 * enabled. The chosen alias is enabled first, then every other alias disabled,
 * so there is no transient window with zero launcher entries.
 *
 * Mid-session safety: [DONT_KILL_APP] mitigates but does not guarantee the
 * process survives a component-enabled change. This channel is therefore driven
 * only at stealth-config-save time (never during an active session) — stealth
 * settings are immutable while a session runs, so a possible process-kill on
 * the alias swap cannot interrupt a live safety session.
 */
class StealthIconChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    /**
     * Maps each [com.guardianangela.app] stealth preset to its launcher alias
     * short name (relative to the package). `none` is the real Guardian Angela
     * launcher; every other key is a disguise alias. The set of values here MUST
     * stay in lockstep with the `<activity-alias>` entries in AndroidManifest.xml
     * and the Dart `StealthIconPreset` enum.
     */
    private val aliasByPreset: Map<String, String> = mapOf(
        "none" to ".MainActivityAlias",
        "music" to ".StealthAlias_music",
        "calendar" to ".StealthAlias_calendar",
        "fitness" to ".StealthAlias_fitness",
        "weather" to ".StealthAlias_weather",
        "news" to ".StealthAlias_news",
        "photos" to ".StealthAlias_photos",
        "notes" to ".StealthAlias_notes",
        "clock" to ".StealthAlias_clock",
        "podcast" to ".StealthAlias_podcast",
    )

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setStealthIcon" -> {
                val preset = call.argument<String>("preset")
                val targetAlias = aliasByPreset[preset]
                if (targetAlias == null) {
                    result.error(
                        "unknown_preset",
                        "Unknown stealth icon preset: $preset",
                        null,
                    )
                    return
                }
                applyPreset(targetAlias)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Enables [targetAlias] and disables every other launcher alias, keeping the
     * exactly-one-enabled invariant. Enable-then-disable ordering avoids any
     * transient state with no launcher entry.
     */
    private fun applyPreset(targetAlias: String) {
        val pm = context.packageManager
        val targetComponent = component(targetAlias)
        pm.setComponentEnabledSetting(
            targetComponent,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (alias in aliasByPreset.values) {
            if (alias == targetAlias) continue
            pm.setComponentEnabledSetting(
                component(alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    private fun component(aliasShortName: String): ComponentName =
        ComponentName(context.packageName, "${context.packageName}$aliasShortName")
}
