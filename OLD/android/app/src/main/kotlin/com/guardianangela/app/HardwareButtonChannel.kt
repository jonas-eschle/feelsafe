package com.guardianangela.app

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `com.guardianangela.app/hardware_buttons` plus its event channel
 * `/hardware_button_events`.
 *
 * Dart-side decides the pattern (e.g. 5x volume presses in 500 ms) — this class
 * only mirrors raw key events into the event stream while a session is active.
 * The Dart layer sends `start({buttonType, pattern, pressCount, pressWindowMs,
 * longPressDurationSeconds})` which we translate into a flip of
 * [SessionActiveState.isActive]; `stop` flips it back.
 *
 * Emitted payload (per key press): `{buttonType: "volume_up"|"volume_down"|"power",
 * pattern: "raw", timestampMs: Long}`. Pattern detection happens Dart-side.
 */
class HardwareButtonChannel(
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)

    fun attach() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> {
                    SessionActiveState.isActive = true
                    result.success(null)
                }
                "stop" -> {
                    SessionActiveState.isActive = false
                    result.success(null)
                }
                "setSessionActive" -> {
                    val active = call.arguments as? Boolean
                        ?: call.argument<Boolean>("active")
                        ?: throw IllegalArgumentException("active required")
                    SessionActiveState.isActive = active
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("hardware_buttons_error", t.message, t.stackTraceToString())
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/hardware_buttons"
        const val EVENT_CHANNEL = "com.guardianangela.app/hardware_button_events"

        @Volatile
        private var sink: EventChannel.EventSink? = null

        /**
         * Called from [MainActivity.dispatchKeyEvent]. Emits a raw key event
         * into the Dart event stream. Pattern matching is Dart-side.
         */
        fun forwardKey(button: String) {
            val current = sink ?: return
            val payload = mapOf(
                "buttonType" to button,
                "pattern" to "raw",
                "timestampMs" to System.currentTimeMillis(),
            )
            MainThread.run { current.success(payload) }
        }
    }
}
