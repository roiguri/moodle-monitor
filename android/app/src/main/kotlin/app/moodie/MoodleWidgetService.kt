package app.moodie

import android.content.Intent
import android.widget.RemoteViewsService

class MoodleWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return MoodleWidgetFactory(applicationContext, intent)
    }
}
