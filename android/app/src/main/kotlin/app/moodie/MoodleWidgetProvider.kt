package app.moodie

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class MoodleWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout_listview)

            val widgetData = HomeWidgetPlugin.getData(context)
            val eventCount = widgetData.getInt("event_count", 0)
            val isEmpty = widgetData.getBoolean("is_empty", false)

            if (isEmpty || eventCount == 0) {
                // Show empty view
                views.setViewVisibility(R.id.task_list, android.view.View.GONE)
                views.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE)
            } else {
                // Show ListView with data
                views.setViewVisibility(R.id.task_list, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.empty_view, android.view.View.GONE)

                // Set up the RemoteViewsService for the ListView
                val serviceIntent = Intent(context, MoodleWidgetService::class.java)
                serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                views.setRemoteAdapter(R.id.task_list, serviceIntent)

                // Set empty view for ListView (in case factory returns 0 items)
                views.setEmptyView(R.id.task_list, R.id.empty_view)
            }

            // Set up click handler to open the app
            val appIntent = Intent(context, MainActivity::class.java)
            appIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            val appPendingIntent = PendingIntent.getActivity(
                context,
                0,
                appIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Set pending intent template for list items
            views.setPendingIntentTemplate(R.id.task_list, appPendingIntent)

            // Notify the widget manager to update
            appWidgetManager.updateAppWidget(widgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.task_list)
        }
    }
}