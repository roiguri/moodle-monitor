package app.moodie

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONException

class MoodleWidgetFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private data class TaskEvent(
        val name: String,
        val course: String,
        val date: String,
        val priority: String
    )

    private var events: List<TaskEvent> = emptyList()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val eventsJson = widgetData.getString("all_events_json", "[]") ?: "[]"
        events = parseJsonToEvents(eventsJson)
    }

    override fun onDestroy() {
        events = emptyList()
    }

    override fun getCount(): Int {
        return events.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        if (position >= events.size) {
            return getEmptyView()
        }

        val event = events[position]

        val views = RemoteViews(context.packageName, R.layout.widget_list_item)

        // Set task data
        views.setTextViewText(R.id.task_name, event.name)
        views.setTextViewText(R.id.task_course, event.course)
        views.setTextViewText(R.id.task_date, event.date)

        // Set priority color indicator
        val color = when (event.priority) {
            "high" -> context.getColor(R.color.priority_high)
            "medium" -> context.getColor(R.color.priority_medium)
            "low" -> context.getColor(R.color.priority_low)
            else -> context.getColor(R.color.priority_default)
        }
        views.setInt(R.id.task_indicator, "setBackgroundColor", color)

        // Set up click listener to open the app
        val fillIntent = Intent()
        views.setOnClickFillInIntent(R.id.task_name, fillIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        // Return null to use default loading view
        return null
    }

    override fun getViewTypeCount(): Int {
        // We only have one type of view
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }

    private fun parseJsonToEvents(jsonString: String): List<TaskEvent> {
        val eventList = mutableListOf<TaskEvent>()

        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val jsonObject = jsonArray.getJSONObject(i)
                val event = TaskEvent(
                    name = jsonObject.getString("name"),
                    course = jsonObject.getString("course"),
                    date = jsonObject.getString("date"),
                    priority = jsonObject.getString("priority")
                )
                eventList.add(event)
            }
        } catch (e: JSONException) {
            // Silent fail - return empty list
        }

        return eventList
    }

    private fun getEmptyView(): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)
        views.setTextViewText(R.id.task_name, context.getString(R.string.widget_no_task))
        views.setTextViewText(R.id.task_course, "")
        views.setTextViewText(R.id.task_date, "")
        return views
    }
}
