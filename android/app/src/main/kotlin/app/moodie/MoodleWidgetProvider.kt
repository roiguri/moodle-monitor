package app.moodie

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.view.View
import android.util.Log
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import android.app.PendingIntent

class MoodleWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_REFRESH = "app.moodie.ACTION_REFRESH"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("MoodleWidget", "onUpdate called for ${appWidgetIds.size} widgets")
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout_listview)

            // Setup the Intent that triggers "onReceive" in THIS provider
            val refreshIntent = Intent(context, MoodleWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
                data = Uri.parse("moodie://refresh_click")
            }
            
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                widgetId,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent)

            // Ensure default state (Button Visible, Progress Gone)
            views.setViewVisibility(R.id.refresh_button, View.VISIBLE)
            views.setViewVisibility(R.id.refresh_progress, View.GONE)

            // Copy your existing adapter logic
            val serviceIntent = Intent(context, MoodleWidgetService::class.java)
            serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
            views.setRemoteAdapter(R.id.task_list, serviceIntent)
            views.setEmptyView(R.id.task_list, R.id.empty_view)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Log everything to help debugging
        Log.d("MoodleWidget", "onReceive called. Action: ${intent.action}, Data: ${intent.data}")

        // Check if this is OUR refresh click
        if (intent.action == ACTION_REFRESH) {
            Log.d("MoodleWidget", "✅ Refresh Click Detected! Updating Views...")

            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisAppWidget = android.content.ComponentName(context.packageName, javaClass.name)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisAppWidget)

            // Update ALL active widgets to show spinner
            appWidgetIds.forEach { widgetId ->
                val views = RemoteViews(context.packageName, R.layout.widget_layout_listview)
                
                // SWAP VISIBILITY
                views.setViewVisibility(R.id.refresh_button, View.GONE)
                views.setViewVisibility(R.id.refresh_progress, View.VISIBLE)
                
                // Partially update the widget (efficient)
                appWidgetManager.partiallyUpdateAppWidget(widgetId, views)
            }
        }

        // IMPORTANT: Call super to let HomeWidget plugin handle the background Dart call
        super.onReceive(context, intent)
    }
}