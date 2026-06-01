package com.guardianangela.app

import android.content.Context
import android.telephony.SmsManager
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * WorkManager [CoroutineWorker] that sends a single SMS using
 * [SmsManager.sendTextMessage] / [SmsManager.sendMultipartTextMessage].
 *
 * Retry policy: exponential back-off starting at 30 s, up to 10 attempts
 * (configured in [SmsChannel.buildSmsWorkRequest]). On the 10th failure
 * [doWork] returns [Result.failure] so WorkManager stops retrying; the final
 * failure triggers the [SmsChannel.invokeRetryExhausted] callback which fires
 * `smsRetryExhausted` back on the Dart MethodChannel.
 *
 * Input data keys (written by [SmsChannel]):
 * - [KEY_PHONE_NUMBER] — sanitized phone number
 * - [KEY_MESSAGE] — full SMS body (may include GPS URL)
 * - [KEY_CONTACT_NAME] — display name for the exhausted notification
 * - [KEY_WORK_ID] — the WorkManager work-id (UUID string)
 */
class SmsWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val phoneNumber = inputData.getString(KEY_PHONE_NUMBER)
            ?: return Result.failure()
        val message = inputData.getString(KEY_MESSAGE)
            ?: return Result.failure()
        val contactName = inputData.getString(KEY_CONTACT_NAME) ?: ""
        val workId = inputData.getString(KEY_WORK_ID) ?: id.toString()

        return try {
            sendSms(phoneNumber, message)
            Log.d(TAG, "SMS sent to $phoneNumber (attempt ${runAttemptCount + 1})")
            Result.success()
        } catch (e: Exception) {
            Log.w(TAG, "SMS attempt ${runAttemptCount + 1} failed: ${e.message}")
            if (runAttemptCount + 1 >= MAX_ATTEMPTS) {
                // Final failure — notify Dart.
                Log.e(TAG, "SMS exhausted for $phoneNumber after $MAX_ATTEMPTS attempts")
                SmsChannel.invokeRetryExhausted(
                    workId = workId,
                    phoneNumber = phoneNumber,
                    contactName = contactName,
                    message = message,
                    error = e.message,
                )
                Result.failure()
            } else {
                Result.retry()
            }
        }
    }

    @Suppress("DEPRECATION")
    private suspend fun sendSms(phoneNumber: String, message: String) =
        suspendCancellableCoroutine { cont ->
            try {
                val smsManager: SmsManager =
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                        applicationContext.getSystemService(SmsManager::class.java)
                    } else {
                        SmsManager.getDefault()
                    }

                val parts = smsManager.divideMessage(message)
                if (parts.size == 1) {
                    smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                } else {
                    smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
                }
                cont.resume(Unit)
            } catch (e: Exception) {
                cont.resumeWithException(e)
            }
        }

    companion object {
        private const val TAG = "SmsWorker"

        /** Maximum number of WorkManager retry attempts before giving up. */
        const val MAX_ATTEMPTS = 10

        const val KEY_PHONE_NUMBER = "phoneNumber"
        const val KEY_MESSAGE = "message"
        const val KEY_CONTACT_NAME = "contactName"
        const val KEY_WORK_ID = "workId"
    }
}
