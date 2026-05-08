package com.guardianangela.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget receiver for Guardian Angela.
 *
 * Extends [HomeWidgetProvider] so the `home_widget` package can bridge
 * Dart-side [HomeWidget.updateWidget] calls directly to [onUpdate].
 * The Dart service layer writes three SharedPreferences keys before
 * requesting the update:
 *
 * * `ga_status`    — human-readable status label (e.g. "Idle", "Running")
 * * `ga_mode_name` — active mode name (e.g. "Walk Mode")
 * * `ga_running`   — `true` while a session is in progress
 *
 * Tapping the **Arm** or **Exit** buttons deep-links into the app via
 * the `guardianangela://widget?marker=<name>` URI scheme; the Dart
 * [HomeWidgetService] reads the marker on next resume.
 */
class GuardianAngelaAppWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val status = widgetData.getString("ga_status", null) ?: "Idle"
        val modeName = widgetData.getString("ga_mode_name", null) ?: ""

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.guardian_angela_widget,
            ).apply {
                setTextViewText(R.id.widget_status, status)
                setTextViewText(R.id.widget_mode_name, modeName)

                val armIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("guardianangela://widget?marker=arm"),
                )
                setOnClickPendingIntent(R.id.widget_arm, armIntent)

                val exitIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("guardianangela://widget?marker=quick-exit"),
                )
                setOnClickPendingIntent(R.id.widget_quick_exit, exitIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
