package com.guardianangela.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.TimeUnit

/**
 * Handles `com.guardianangela.app/sms` method calls plus the companion event
 * channel `com.guardianangela.app/sms_events` which streams delivery / retry
 * status updates pushed by [SmsWorker].
 *
 * Supported method calls:
 *  - `canAutoSend`          -> Boolean (true iff SEND_SMS is granted)
 *  - `send({workId, recipient, message})`        -> String (work UUID)
 *  - `retry({workId, recipient, message})`       -> String (work UUID)
 *  - `cancelPending({workIds: List<String>})`    -> null
 */
class SmsChannel(
    private val context: Context,
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
                "canAutoSend" -> result.success(hasSendSmsPermission())
                "send" -> {
                    val workId = call.argument<String>("workId")
                        ?: throw IllegalArgumentException("workId required")
                    val recipient = call.argument<String>("recipient")
                        ?: throw IllegalArgumentException("recipient required")
                    val message = call.argument<String>("message")
                        ?: throw IllegalArgumentException("message required")
                    val uuid = enqueue(workId, recipient, message)
                    result.success(uuid.toString())
                }
                "retry" -> {
                    val workId = call.argument<String>("workId")
                        ?: throw IllegalArgumentException("workId required")
                    val recipient = call.argument<String>("recipient")
                        ?: throw IllegalArgumentException("recipient required")
                    val message = call.argument<String>("message")
                        ?: throw IllegalArgumentException("message required")
                    val uuid = enqueue(workId, recipient, message)
                    result.success(uuid.toString())
                }
                "cancelPending" -> {
                    val ids = call.argument<List<String>>("workIds").orEmpty()
                    val wm = WorkManager.getInstance(context)
                    for (id in ids) {
                        try {
                            wm.cancelWorkById(UUID.fromString(id))
                        } catch (_: IllegalArgumentException) {
                            // Not a UUID — probably a workId only tracked by tag.
                            wm.cancelAllWorkByTag(id)
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("sms_error", t.message, t.stackTraceToString())
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        SmsEventSink.attach(events)
    }

    override fun onCancel(arguments: Any?) {
        SmsEventSink.detach()
    }

    private fun enqueue(workId: String, recipient: String, message: String): UUID {
        val input = Data.Builder()
            .putString(SmsWorker.KEY_WORK_ID, workId)
            .putString(SmsWorker.KEY_RECIPIENT, recipient)
            .putString(SmsWorker.KEY_MESSAGE, message)
            .build()
        val request = OneTimeWorkRequestBuilder<SmsWorker>()
            .setInputData(input)
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                    .build(),
            )
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 10, TimeUnit.SECONDS)
            .addTag(TAG)
            .addTag(workId)
            .build()
        WorkManager.getInstance(context).enqueue(request)
        return request.id
    }

    private fun hasSendSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(context, Manifest.permission.SEND_SMS) ==
            PackageManager.PERMISSION_GRANTED
    }

    companion object {
        const val CHANNEL = "com.guardianangela.app/sms"
        const val EVENT_CHANNEL = "com.guardianangela.app/sms_events"
        const val TAG = "guardian_sms"
    }
}

/**
 * Thread-safe process-wide hook the [SmsWorker] uses to push delivery events back
 * to Dart. Multiple sinks aren't supported — Flutter creates a single stream per
 * subscription and Dart only listens once.
 */
object SmsEventSink {
    @Volatile
    private var sink: EventChannel.EventSink? = null

    fun attach(eventSink: EventChannel.EventSink) {
        sink = eventSink
    }

    fun detach() {
        sink = null
    }

    fun emit(payload: Map<String, Any?>) {
        val current = sink ?: return
        MainThread.run { current.success(payload) }
    }
}
