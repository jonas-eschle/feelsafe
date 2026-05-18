package com.guardianangela.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import androidx.core.content.ContextCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

/**
 * Background SMS sender. Dispatched by [SmsChannel.enqueue].
 *
 * Pushes delivery updates into [SmsEventSink] so the Dart layer can react. On
 * success: `{workId, status:"sent"}`. On retryable failure: `{workId, status:"queued"}`
 * and [androidx.work.ListenableWorker.Result.retry] returned (exponential backoff
 * handled by WorkManager). After MAX_ATTEMPTS: emits `{workId, status:"failed"}`
 * plus a `{type:"retry_exhausted", workId, recipient, message}` event.
 */
class SmsWorker(
    appContext: Context,
    private val workerParams: WorkerParameters,
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        val workId = inputData.getString(KEY_WORK_ID) ?: return Result.failure()
        val recipient = inputData.getString(KEY_RECIPIENT) ?: return Result.failure()
        val message = inputData.getString(KEY_MESSAGE) ?: return Result.failure()

        if (!hasPermission()) {
            emitFailed(workId)
            emitRetryExhausted(workId, recipient, message)
            return Result.failure()
        }

        return try {
            sendSms(recipient, message)
            emit(workId, "sent")
            Result.success()
        } catch (t: Throwable) {
            if (runAttemptCount + 1 >= MAX_ATTEMPTS) {
                emitFailed(workId)
                emitRetryExhausted(workId, recipient, message)
                Result.failure()
            } else {
                emit(workId, "queued")
                Result.retry()
            }
        }
    }

    private fun sendSms(recipient: String, message: String) {
        val manager = getSmsManager()
        // Split long messages into multipart if needed.
        val parts = manager.divideMessage(message)
        if (parts.size == 1) {
            manager.sendTextMessage(recipient, null, message, null, null)
        } else {
            manager.sendMultipartTextMessage(recipient, null, parts, null, null)
        }
    }

    @Suppress("DEPRECATION")
    private fun getSmsManager(): SmsManager {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            applicationContext.getSystemService(SmsManager::class.java)
        } else {
            SmsManager.getDefault()
        }
    }

    private fun hasPermission(): Boolean {
        return ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.SEND_SMS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun emit(workId: String, status: String) {
        SmsEventSink.emit(mapOf("type" to "delivery", "workId" to workId, "status" to status))
    }

    private fun emitFailed(workId: String) {
        emit(workId, "failed")
    }

    private fun emitRetryExhausted(workId: String, recipient: String, message: String) {
        SmsEventSink.emit(
            mapOf(
                "type" to "retry_exhausted",
                "workId" to workId,
                "recipient" to recipient,
                "message" to message,
            ),
        )
    }

    companion object {
        const val KEY_WORK_ID = "workId"
        const val KEY_RECIPIENT = "recipient"
        const val KEY_MESSAGE = "message"
        const val MAX_ATTEMPTS = 10
    }
}
