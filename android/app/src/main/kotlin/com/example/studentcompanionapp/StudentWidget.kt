package com.example.studentcompanionapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class StudentWidget : HomeWidgetProvider() {

    // ── Light theme colors ────────────────────────────────────────
    companion object {
        // Light
        private val LIGHT_BG          = Color.parseColor("#FFFFFF")
        private val LIGHT_CARD_BG     = Color.parseColor("#F7F8FA")
        private val LIGHT_TEXT_MAIN   = Color.parseColor("#1E293B")
        private val LIGHT_TEXT_SUB    = Color.parseColor("#64748B")
        private val LIGHT_TEXT_MUTED  = Color.parseColor("#94A3B8")
        private val LIGHT_PRIMARY     = Color.parseColor("#0E4DEC")
        private val LIGHT_PRIORITY    = Color.parseColor("#EF4444")
        private val LIGHT_ACCENT_BAR  = Color.parseColor("#E8EDF5")

        // Dark — modern deep dark palette
        private val DARK_BG           = Color.parseColor("#0F1123")
        private val DARK_CARD_BG      = Color.parseColor("#1A1D35")
        private val DARK_TEXT_MAIN    = Color.parseColor("#E8ECF4")
        private val DARK_TEXT_SUB     = Color.parseColor("#8B93A8")
        private val DARK_TEXT_MUTED   = Color.parseColor("#5A6178")
        private val DARK_PRIMARY      = Color.parseColor("#6C8CFF")
        private val DARK_PRIORITY     = Color.parseColor("#FF6B6B")
        private val DARK_ACCENT_BAR   = Color.parseColor("#1E2245")
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            try {
                val theme = widgetData.getString("widget_theme", "light") ?: "light"
                val isDark = theme == "dark"

                // Pick colors
                val bg        = if (isDark) DARK_BG else LIGHT_BG
                val cardBg    = if (isDark) DARK_CARD_BG else LIGHT_CARD_BG
                val textMain  = if (isDark) DARK_TEXT_MAIN else LIGHT_TEXT_MAIN
                val textSub   = if (isDark) DARK_TEXT_SUB else LIGHT_TEXT_SUB
                val textMuted = if (isDark) DARK_TEXT_MUTED else LIGHT_TEXT_MUTED
                val primary   = if (isDark) DARK_PRIMARY else LIGHT_PRIMARY
                val priority  = if (isDark) DARK_PRIORITY else LIGHT_PRIORITY
                val accentBar = if (isDark) DARK_ACCENT_BAR else LIGHT_ACCENT_BAR

                // ── Read data ─────────────────────────────────────────────
                val attendancePct = widgetData.getInt("attendance_int", 0)
                val attendanceTxt = widgetData.getString("attendance_pct", "--") ?: "--"
                val pendingTasks  = widgetData.getInt("pending_tasks_count", 0)

                val task1 = widgetData.getString("task_1_title", "") ?: ""
                val task2 = widgetData.getString("task_2_title", "") ?: ""
                val task3 = widgetData.getString("task_3_title", "") ?: ""
                val task1High = widgetData.getBoolean("task_1_high_priority", false)

                val class1Name = widgetData.getString("class_1_name", "") ?: ""
                val class1Room = widgetData.getString("class_1_room", "") ?: ""
                val class1Time = widgetData.getString("class_1_time", "") ?: ""
                val class1Eta  = widgetData.getString("class_1_eta",  "") ?: ""
                val class2Name = widgetData.getString("class_2_name", "") ?: ""
                val class2Room = widgetData.getString("class_2_room", "") ?: ""
                val class2Time = widgetData.getString("class_2_time", "") ?: ""

                // ── Build RemoteViews ──────────────────────────────────────
                val views = RemoteViews(context.packageName, R.layout.student_widget_medium)

                // ── Apply theme backgrounds ────────────────────────────────
                val rootBg = if (isDark) R.drawable.widget_background_dark else R.drawable.widget_background
                val cardBgRes = if (isDark) R.drawable.widget_card_background_dark else R.drawable.widget_card_background

                views.setInt(R.id.widget_root, "setBackgroundResource", rootBg)
                views.setInt(R.id.widget_attendance_card, "setBackgroundResource", cardBgRes)
                views.setInt(R.id.widget_tasks_card, "setBackgroundResource", cardBgRes)
                views.setInt(R.id.widget_schedule_card, "setBackgroundResource", cardBgRes)

                // ── Apply theme text colors ────────────────────────────────
                // Header
                views.setTextColor(R.id.widget_header_title, textMain)
                views.setTextColor(R.id.widget_header_plus, textMuted)

                // Attendance card
                views.setTextColor(R.id.widget_attendance_label, textSub)
                views.setTextColor(R.id.widget_attendance_pct, textMain)
                views.setTextColor(R.id.widget_attendance_goal, textMuted)

                // Tasks card
                views.setTextColor(R.id.widget_tasks_label, textSub)
                views.setTextColor(R.id.widget_tasks_count, primary)
                views.setTextColor(R.id.widget_task1_title, textMain)
                views.setTextColor(R.id.widget_task1_priority, priority)
                views.setTextColor(R.id.widget_task2_title, textSub)
                views.setTextColor(R.id.widget_task3_title, textSub)
                views.setTextColor(R.id.widget_task1_circle, primary)
                views.setTextColor(R.id.widget_task2_circle, primary)
                views.setTextColor(R.id.widget_task3_circle, primary)

                // Schedule section
                views.setTextColor(R.id.widget_schedule_label, textSub)
                views.setTextColor(R.id.widget_class1_name, textMain)
                views.setTextColor(R.id.widget_class1_room, textMuted)
                views.setTextColor(R.id.widget_class1_time, primary)
                views.setTextColor(R.id.widget_class1_eta, textMuted)
                views.setTextColor(R.id.widget_class2_name, textMain)
                views.setTextColor(R.id.widget_class2_room, textMuted)
                views.setTextColor(R.id.widget_class2_time, textSub)

                // Schedule bars + accent bar
                views.setInt(R.id.widget_schedule_bar1, "setBackgroundColor", primary)
                val barInactive = if (isDark) Color.parseColor("#3A3D55") else Color.parseColor("#CBD5E1")
                views.setInt(R.id.widget_schedule_bar2, "setBackgroundColor", barInactive)
                views.setInt(R.id.widget_accent_bar, "setBackgroundColor", accentBar)

                // ── Set data ──────────────────────────────────────────────
                views.setProgressBar(R.id.widget_attendance_progress, 100, attendancePct, false)
                views.setProgressBar(R.id.widget_attendance_progress_dark, 100, attendancePct, false)
                views.setViewVisibility(R.id.widget_attendance_progress, if (isDark) View.GONE else View.VISIBLE)
                views.setViewVisibility(R.id.widget_attendance_progress_dark, if (isDark) View.VISIBLE else View.GONE)
                views.setTextViewText(R.id.widget_attendance_pct, attendanceTxt)

                val taskLabel = if (pendingTasks == 0) "All done!" else "$pendingTasks Pending"
                views.setTextViewText(R.id.widget_tasks_count, taskLabel)

                // Task 1
                if (task1.isNotEmpty()) {
                    views.setTextViewText(R.id.widget_task1_title, task1)
                    views.setViewVisibility(R.id.widget_task1_priority,
                        if (task1High) View.VISIBLE else View.GONE)
                } else {
                    views.setTextViewText(R.id.widget_task1_title, "No pending tasks")
                    views.setViewVisibility(R.id.widget_task1_priority, View.GONE)
                }

                // Task 2
                if (task2.isNotEmpty()) {
                    views.setTextViewText(R.id.widget_task2_title, task2)
                    views.setViewVisibility(R.id.widget_task2_title, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.widget_task2_title, View.GONE)
                }

                // Task 3
                if (task3.isNotEmpty()) {
                    views.setTextViewText(R.id.widget_task3_title, task3)
                    views.setViewVisibility(R.id.widget_task3_title, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.widget_task3_title, View.GONE)
                }

                // Schedule Row 1
                if (class1Name.isNotEmpty()) {
                    views.setTextViewText(R.id.widget_class1_name, class1Name)
                    views.setTextViewText(R.id.widget_class1_room, class1Room)
                    views.setTextViewText(R.id.widget_class1_time, class1Time)
                    views.setTextViewText(R.id.widget_class1_eta, class1Eta)
                } else {
                    views.setTextViewText(R.id.widget_class1_name, "No classes today")
                    views.setTextViewText(R.id.widget_class1_room, "")
                    views.setTextViewText(R.id.widget_class1_time, "")
                    views.setTextViewText(R.id.widget_class1_eta, "")
                }

                // Schedule Row 2
                if (class2Name.isNotEmpty()) {
                    views.setTextViewText(R.id.widget_class2_name, class2Name)
                    views.setTextViewText(R.id.widget_class2_room, class2Room)
                    views.setTextViewText(R.id.widget_class2_time, class2Time)
                    views.setViewVisibility(R.id.widget_schedule_row2, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.widget_schedule_row2, View.GONE)
                }

                // Click to open app
                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                )

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) { }
        }
    }
}
