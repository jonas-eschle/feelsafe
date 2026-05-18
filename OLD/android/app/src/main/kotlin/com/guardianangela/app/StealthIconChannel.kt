package com.guardianangela.app

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `com.guardianangela.app/stealth_icon`.
 *
 * Switches between launcher activity-aliases so the home-screen icon / label
 * changes at runtime. Dart-side sends the preset key (e.g. "calendar"); this
 * class enables the matching alias and disables all others.
 *
 * NOTE: The actual alias entries live in AndroidManifest.xml. Until Phase 12
 * Group F adds dedicated drawables, every alias reuses `@mipmap/ic_launcher`.
 */
class StealthIconChannel(
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
                "setPreset" -> {
                    val preset = call.argument<String>("preset")
                        ?: throw IllegalArgumentException("preset required")
                    if (!PRESETS.contains(preset)) {
                        throw IllegalArgumentException("unknown preset: $preset")
                    }
                    applyPreset(preset)
                    result.success(null)
                }
                "getCurrentPreset" -> {
                    result.success(currentPreset())
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("stealth_icon_error", t.message, t.stackTraceToString())
        }
    }

    private fun applyPreset(preset: String) {
        val pm = context.packageManager
        val pkg = context.packageName
        for (key in PRESETS) {
            val alias = ComponentName(pkg, "$pkg.$ALIAS_PREFIX$key")
            val desired = if (key == preset) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            try {
                pm.setComponentEnabledSetting(alias, desired, PackageManager.DONT_KILL_APP)
            } catch (_: Throwable) {
                // Alias may not exist until Phase 12 Group F lands drawables.
                // Swallowing is safe — failure to toggle a missing alias is a no-op.
            }
        }
    }

    private fun currentPreset(): String {
        val pm = context.packageManager
        val pkg = context.packageName
        for (key in PRESETS) {
            val alias = ComponentName(pkg, "$pkg.$ALIAS_PREFIX$key")
            val state = try {
                pm.getComponentEnabledSetting(alias)
            } catch (_: Throwable) {
                PackageManager.COMPONENT_ENABLED_STATE_DEFAULT
            }
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) return key
        }
        return DEFAULT_PRESET
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/stealth_icon"
        const val ALIAS_PREFIX = "StealthAlias_"
        const val DEFAULT_PRESET = "angela"
        val PRESETS = listOf(
            "music",
            "calendar",
            "fitness",
            "weather",
            "news",
            "photos",
            "notes",
            "clock",
        )
    }
}
