package com.guardianangela.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.WorkManager

/**
 * Re-initialises WorkManager after a device reboot so that any pending
 * [SmsWorker] jobs that were enqueued before the reboot are rescheduled.
 *
 * WorkManager persists job metadata across reboots in its internal Room
 * database. Receiving [android.intent.action.BOOT_COMPLETED] is sufficient to
 * trigger re-scheduling; we merely ensure WorkManager is initialised by
 * calling [WorkManager.getInstance].
 *
 * Requires `android.permission.RECEIVE_BOOT_COMPLETED` in the manifest.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        Log.d(TAG, "BOOT_COMPLETED received — ensuring WorkManager is initialised")
        // Accessing getInstance() is enough to kick WorkManager into re-scheduling
        // any persisted work that survived the reboot.
        WorkManager.getInstance(context)
    }

    companion object {
        private const val TAG = "BootReceiver"
    }
}
