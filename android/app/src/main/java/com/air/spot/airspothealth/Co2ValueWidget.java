package com.air.spot.airspothealth;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;

import java.util.Calendar;
import java.util.Locale;
import java.text.SimpleDateFormat;

import es.antonborri.home_widget.HomeWidgetBackgroundIntent;
import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * Implementation of App Widget functionality for 2x3 CO2 monitoring widget.
 */
public class Co2ValueWidget extends AppWidgetProvider {

    private static final String TAG = "Co2ValueWidget";

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        Log.d(TAG, "Updating widget: " + appWidgetId);
        
        // Use the single 2x3 layout
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.co2_value_widget);
        
        // Get widget data
        String co2Value = HomeWidgetPlugin.Companion.getData(context).getString("airspot_home_widget", "----");
        String lastUpdatedString = HomeWidgetPlugin.Companion.getData(context).getString("last_updated", "");
        String deviceId = HomeWidgetPlugin.Companion.getData(context).getString("device_id", "");
        String powerMode = HomeWidgetPlugin.Companion.getData(context).getString("power_mode", "Now");
        String batteryLevel = HomeWidgetPlugin.Companion.getData(context).getString("battery_level", "0");
        String isCharging = HomeWidgetPlugin.Companion.getData(context).getString("is_charging", "false");
        String alarmEnabled = HomeWidgetPlugin.Companion.getData(context).getString("alarm_enabled", "false");
        String vibrationEnabled = HomeWidgetPlugin.Companion.getData(context).getString("vibration_enabled", "false");

        // Set CO2 value and color
        views.setTextViewText(R.id.co2_value, co2Value);
        int color = getColorForCO2Value(co2Value);
        views.setTextColor(R.id.co2_value, color);

        // Set power mode (in place of time display)
        views.setTextViewText(R.id.time_display, powerMode);

        // Set battery level
        int batteryLevelInt = 0;
        try {
            batteryLevelInt = Integer.parseInt(batteryLevel);
        } catch (NumberFormatException e) {
            batteryLevelInt = 0;
        }
        views.setTextViewText(R.id.battery_percentage, batteryLevelInt + "%");

        // Set alarm/sound mode icon based on state
        boolean alarmEnabledBool = Boolean.parseBoolean(alarmEnabled);
        int soundModeDrawable = alarmEnabledBool ? R.drawable.sound_mode_icon_on : R.drawable.sound_mode_icon_off;
        views.setImageViewResource(R.id.sound_mode, soundModeDrawable);
        views.setViewVisibility(R.id.sound_mode, View.VISIBLE);

        // Set vibration mode icon based on state
        boolean vibrationEnabledBool = Boolean.parseBoolean(vibrationEnabled);
        int vibrationModeDrawable = vibrationEnabledBool ? R.drawable.vibration_mode_icon_on : R.drawable.vibration_mode_icon_off;
        views.setImageViewResource(R.id.vibration_mode, vibrationModeDrawable);
        views.setViewVisibility(R.id.vibration_mode, View.VISIBLE);

        // Set up refresh button with device ID
        setupRefreshButton(context, views, appWidgetId, deviceId);

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
        Log.d(TAG, "Widget updated with CO2: " + co2Value + ", DeviceID: " + deviceId + ", PowerMode: " + powerMode + 
              ", Battery: " + batteryLevel + "%, Alarm: " + alarmEnabled + ", Vibration: " + vibrationEnabled);
    }

    private static void setupRefreshButton(Context context, RemoteViews views, int appWidgetId, String deviceId) {
        Intent intent = new Intent(context, Co2ValueWidget.class);
        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, new int[] {appWidgetId});

        // Create URI with device ID as query parameter
        String uriString = "airspothealthapp://refresh";
        if (deviceId != null && !deviceId.isEmpty()) {
            uriString += "?deviceId=" + deviceId;
        }
        
        PendingIntent refreshPendingIntent = HomeWidgetBackgroundIntent.INSTANCE.getBroadcast(context, Uri.parse(uriString));
        views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent);
        
        Log.d(TAG, "Refresh button setup with URI: " + uriString);
    }

    private static int getColorForCO2Value(String co2ValueStr) {
        try {
            int co2Value = Integer.parseInt(co2ValueStr);
            if (co2Value < 800) {
                return Color.parseColor("#4CAF50"); // Green
            } else if (co2Value < 1000) {
                return Color.parseColor("#FF9800"); // Orange
            } else {
                return Color.parseColor("#F44336"); // Red
            }
        } catch (NumberFormatException e) {
            return Color.parseColor("#4CAF50"); // Default green for invalid values
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // Update all widget instances
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager, int appWidgetId, Bundle newOptions) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions);
        updateAppWidget(context, appWidgetManager, appWidgetId);
    }

    @Override
    public void onEnabled(Context context) {
        // Enter relevant functionality for when the first widget is created
        Log.d(TAG, "Widget enabled");
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
        Log.d(TAG, "Widget disabled");
    }
}