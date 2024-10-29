package com.air.spot.airspothealth;


import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.widget.RemoteViews;
import android.util.Log;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.text.SimpleDateFormat;


import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * Implementation of App Widget functionality.
 */
public class Co2ValueWidget extends AppWidgetProvider {

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.co2_value_widget);

        // Get reference to SharedPreferences
        String co2Value = HomeWidgetPlugin.Companion.getData(context).getString("airspot_home_widget", "0000");

        // Set the CO2 value
        views.setTextViewText(R.id.co2_value, co2Value + " ppm");

        int color;

        if (Integer.parseInt(co2Value) < 800) {
            color = Color.parseColor("#63A103");
        } else if (Integer.parseInt(co2Value) < 1000) {
            color = Color.parseColor("#FE9A23");
        } else {
            color = Color.parseColor("#D9001B");
        }

        views.setTextColor(R.id.co2_value, color);

        // Get the current date and time
        Calendar calendar = Calendar.getInstance();

        // Define the format you want (e.g., OCT 12, 12:00 PM)
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, hh:mm a", Locale.getDefault());

        // Format the date
        String formattedDate = dateFormat.format(calendar.getTime());

        // Set the last updated time
        views.setTextViewText(R.id.last_updated, "Last updated: " + formattedDate);

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);

    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // There may be multiple widgets active, so update all of them
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    @Override
    public void onEnabled(Context context) {
        // Enter relevant functionality for when the first widget is created
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}