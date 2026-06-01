package com.guardianangela.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget provider for Guardian Angela.
 *
 * Reads widget state from the [SharedPreferences] file written by the
 * `home_widget` Flutter plugin (`"HomeWidgetPreferences"`), then builds a
 * [RemoteViews] showing the session status, elapsed time, and two action
 * buttons (Quick Exit / Fake Call).
 *
 * Button taps are fired as [HomeWidgetLaunchIntent] PendingIntents that route
 * the `guardianangela://` deep-link URI back to the Flutter engine where
 * `HomeWidget.widgetClicked` / `initiallyLaunchedFromHomeWidget` pick it up.
 */
class GuardianAngelaAppWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        // Read keys written by Dart via HomeWidget.saveWidgetData.
        val statusText = widgetData.getString("ga_status_text", "Idle") ?: "Idle"
        val elapsed = widgetData.getString("ga_elapsed", "") ?: ""
        val quickExitLabel = widgetData.getString("ga_quick_exit", "Quick Exit") ?: "Quick Exit"
        val fakeCallLabel = widgetData.getString("ga_fake_call", "Fake Call") ?: "Fake Call"

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.guardian_angela_app_widget,
            ).apply {
                setTextViewText(R.id.widget_status_text, statusText)
                setTextViewText(R.id.widget_elapsed, elapsed)
                setTextViewText(R.id.widget_btn_quick_exit, quickExitLabel)
                setTextViewText(R.id.widget_btn_fake_call, fakeCallLabel)

                // Quick Exit button → guardianangela://quick-exit
                val quickExitIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("guardianangela://quick-exit"),
                )
                setOnClickPendingIntent(R.id.widget_btn_quick_exit, quickExitIntent)

                // Fake Call button → guardianangela://fake-call
                val fakeCallIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("guardianangela://fake-call"),
                )
                setOnClickPendingIntent(R.id.widget_btn_fake_call, fakeCallIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
