package com.guardianangela.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.WorkManager

/**
 * Sentinel receiver declared per the platform rollout plan (D-PLATFORM-9).
 *
 * WorkManager's internal queue (including [SmsWorker] jobs) already persists across
 * reboots, so there's nothing we actually need to re-enqueue here. We still declare
 * the receiver so the OS will start our process on boot if we ever add retry work
 * that relies on a live process (e.g. re-registering TelephonyCallback).
 *
 * Requires `android.permission.RECEIVE_BOOT_COMPLETED` in the manifest.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_LOCKED_BOOT_COMPLETED
        ) {
            return
        }
        // Touch WorkManager so the singleton initialises; pending workers will
        // run on their own schedules after this.
        try {
            WorkManager.getInstance(context)
            Log.i(TAG, "BootReceiver: WorkManager touched after boot")
        } catch (t: Throwable) {
            Log.w(TAG, "BootReceiver: failed to init WorkManager", t)
        }
    }

    companion object {
        private const val TAG = "GuardianBoot"
    }
}
