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

import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * Implementation of App Widget functionality.
 */
public class Co2ValueWidget extends AppWidgetProvider {

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.co2_value_widget);

        // Get reference to SharedPreferences
        String widgetData = HomeWidgetPlugin.Companion.getData(context).getString("airspot_home_widget", "---");

        Log.d("WidgetData", widgetData);

        // Set the device name
        views.setTextViewText(R.id.device_name, "AirSpot");

        // Set the CO2 value
        views.setTextViewText(R.id.co2_value, widgetData + " ppm");

        // Set the last updated time
        String lastUpdated = String.valueOf(System.currentTimeMillis());
        views.setTextViewText(R.id.last_updated, lastUpdated);

        // // Set dynamic background gradient
        // GradientDrawable gradientDrawable = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{Colors., Color.TRANSPARENT});
        // gradientDrawable.setCornerRadius(16); // Set rounded corners if needed

        // // Convert the gradient drawable to a bitmap
        // Bitmap bitmap = Bitmap.createBitmap(200, 200, Bitmap.Config.ARGB_8888);
        // Canvas canvas = new Canvas(bitmap);
        // gradientDrawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        // gradientDrawable.draw(canvas);

        // // Set the bitmap as the background
        // views.setImageViewBitmap(R.id.widget_container, bitmap);

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