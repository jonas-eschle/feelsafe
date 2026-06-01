package com.guardianangela.app

import android.content.Context
import android.util.Log
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

/**
 * Implements `com.guardianangela.app/sms` (bidirectional MethodChannel).
 *
 * Dart→native methods:
 * - [enqueueSms] — enqueue a persistent WorkManager SMS job, returns the
 *   work-id String for later cancellation.
 * - [cancelWork] — cancel jobs by work-id list.
 *
 * native→Dart callback:
 * - `smsRetryExhausted` — fired from [SmsWorker] (via [invokeRetryExhausted])
 *   when all 10 retry attempts are exhausted.
 */
class SmsChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    private var channel: MethodChannel? = null

    /** Called once from [MainActivity.configureFlutterEngine] after the channel is created. */
    fun attach(methodChannel: MethodChannel) {
        channel = methodChannel
        synchronized(lock) {
            instance = this
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enqueueSms" -> {
                val phoneNumber = call.argument<String>("phoneNumber") ?: run {
                    result.error("invalidArgs", "phoneNumber is required", null)
                    return
                }
                val message = call.argument<String>("message") ?: run {
                    result.error("invalidArgs", "message is required", null)
                    return
                }
                val contactName = call.argument<String>("contactName") ?: ""
                val workId = enqueueSms(phoneNumber, message, contactName)
                result.success(workId)
            }
            "cancelWork" -> {
                @Suppress("UNCHECKED_CAST")
                val workIds = call.argument<List<String>>("workIds") ?: emptyList()
                cancelWork(workIds)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun enqueueSms(phoneNumber: String, message: String, contactName: String): String {
        val request = buildSmsWorkRequest(phoneNumber, message, contactName)
        WorkManager.getInstance(context).enqueue(request)
        val workId = request.id.toString()
        Log.d(TAG, "Enqueued SMS work id=$workId to $phoneNumber")
        return workId
    }

    private fun cancelWork(workIds: List<String>) {
        val wm = WorkManager.getInstance(context)
        for (workId in workIds) {
            try {
                wm.cancelWorkById(java.util.UUID.fromString(workId))
                Log.d(TAG, "Cancelled SMS work id=$workId")
            } catch (e: IllegalArgumentException) {
                Log.w(TAG, "Invalid work id format: $workId")
            }
        }
    }

    /** Invoke the `smsRetryExhausted` callback on the Dart side. */
    fun invokeRetryExhaustedOnMainThread(
        workId: String,
        phoneNumber: String,
        contactName: String,
        message: String,
        error: String?,
    ) {
        val args = mutableMapOf<String, Any?>(
            "workId" to workId,
            "phoneNumber" to phoneNumber,
            "contactName" to contactName,
            "message" to message,
        )
        if (error != null) args["error"] = error

        channel?.invokeMethod("smsRetryExhausted", args)
            ?: Log.e(TAG, "smsRetryExhausted: channel not attached yet (workId=$workId)")
    }

    companion object {
        private const val TAG = "SmsChannel"

        /** Initial backoff delay for WorkManager retry, 30 seconds per spec. */
        private const val BACKOFF_DELAY_SECONDS = 30L

        @Volatile
        private var instance: SmsChannel? = null
        private val lock = Any()

        /**
         * Called by [SmsWorker] on the worker thread when all retries are
         * exhausted. Routes to [invokeRetryExhaustedOnMainThread] on the
         * currently attached [SmsChannel] instance.
         */
        fun invokeRetryExhausted(
            workId: String,
            phoneNumber: String,
            contactName: String,
            message: String,
            error: String?,
        ) {
            val ch = synchronized(lock) { instance }
            if (ch == null) {
                Log.e(TAG, "invokeRetryExhausted: no SmsChannel instance attached")
                return
            }
            // MethodChannel must be called on the main (platform) thread.
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                ch.invokeRetryExhaustedOnMainThread(workId, phoneNumber, contactName, message, error)
            }
        }

        fun buildSmsWorkRequest(
            phoneNumber: String,
            message: String,
            contactName: String,
        ): OneTimeWorkRequest {
            // The work-id is generated by WorkManager; we store it in the input
            // data so SmsWorker can pass it back in the exhausted callback.
            // We build a temporary request first to capture the UUID.
            val tempRequest = OneTimeWorkRequest.Builder(SmsWorker::class.java).build()
            val workId = tempRequest.id.toString()

            val inputData = Data.Builder()
                .putString(SmsWorker.KEY_PHONE_NUMBER, phoneNumber)
                .putString(SmsWorker.KEY_MESSAGE, message)
                .putString(SmsWorker.KEY_CONTACT_NAME, contactName)
                .putString(SmsWorker.KEY_WORK_ID, workId)
                .build()

            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            return OneTimeWorkRequest.Builder(SmsWorker::class.java)
                .setId(tempRequest.id) // reuse the same UUID
                .setInputData(inputData)
                .setConstraints(constraints)
                .setBackoffCriteria(
                    BackoffPolicy.EXPONENTIAL,
                    BACKOFF_DELAY_SECONDS,
                    TimeUnit.SECONDS,
                )
                .build()
        }
    }
}
