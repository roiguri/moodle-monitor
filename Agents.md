We are working on @docs/initial_plan.md we should work according to
the steps, guide the user carefully on set up phases (e.g using android
studio/tests outside the ide). use @docs/progress.md for creating work checklist and update progress.

## Android Widget Development Learnings

### Problem: Adding Visual Elements to Widgets Breaks Rendering

**Context:** We built a working Android widget (v5.3) with text fields. When we added simple colored indicator bars (v5.4), the widget stopped loading entirely, even though the change seemed minimal.

### What We Tried (Failed)

Plain `<View>` with hardcoded background:

```xml
<View android:id="@+id/indicator"
      android:layout_width="3dp"
      android:layout_height="40dp"
      android:background="#EF4444" />
```

**Result:** Widget failed to load on device

Changed height from `match_parent` to `40dp`:
- Fixed circular dependency issue, but widget still didn't load
- Problem wasn't the height calculation

### Root Cause

- Plain `<View>` elements are not officially supported in RemoteViews
- Hardcoded `android:background` colors in XML don't inflate properly across process boundaries
- Different Android launchers handle unsupported views differently (works on some, fails on others)

### The Fix That Worked ✅

3-part solution:

1. Use `<ImageView>` instead of `<View>`:

```xml
<ImageView android:id="@+id/task_1_indicator"
           android:layout_width="3dp"
           android:layout_height="40dp"
           android:contentDescription="Priority indicator" />
```

2. Remove hardcoded `android:background` from XML

3. Set colors programmatically in Kotlin:

```kotlin
views.setInt(R.id.task_1_indicator, "setBackgroundColor", Color.parseColor("#EF4444"))
```

### Key Takeaways

✅ **DO:**
- Use officially supported view types: ImageView, TextView, Button, LinearLayout, etc.
- Set dynamic properties (colors, text) programmatically via Kotlin
- Use RemoteViews.setInt() for background colors
- Test after EVERY small change

❌ **DON'T:**
- Use plain `<View>` elements in widgets
- Hardcode `android:background` colors in widget XML
- Use ConstraintLayout in widgets
- Use custom fonts (`@font/...`)
- Use theme attributes (`?attr/...`)
- Make multiple changes at once without testing