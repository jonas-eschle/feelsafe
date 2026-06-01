package com.guardianangela.app

import io.flutter.plugin.common.EventChannel

/**
 * Owns the [EventChannel.StreamHandler] for `com.guardianangela.app/hardware_button`.
 *
 * [MainActivity.dispatchKeyEvent] writes volume-key down/up maps into [sink]
 * while a Dart listener is attached. When no listener is attached [sink] is
 * null and [MainActivity.dispatchKeyEvent] must call super (normal volume
 * behaviour).
 */
class HardwareButtonChannel : EventChannel.StreamHandler {

    /** Non-null only while Dart is subscribed to the hardware_button stream. */
    @Volatile
    var sink: EventChannel.EventSink? = null
        private set

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}
