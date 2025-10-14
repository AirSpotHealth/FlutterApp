package com.air.spot.airspothealth;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;

import java.util.Calendar;
import java.util.Locale;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import es.antonborri.home_widget.HomeWidgetBackgroundIntent;
import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * Implementation of App Widget functionality for Small CO2 monitoring widget.
 */
public class Co2SmallWidget extends AppWidgetProvider {

    private static final String TAG = "Co2SmallWidget";
    private static final String WIDGET_DATA_KEY = "widget_data_json";
    private static final String WIDGET_DEVICES_DATA_KEY = "widget_devices_data";

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        Log.d(TAG, "Updating small widget: " + appWidgetId);
        
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.co2_small_widget);
        
        try {
            // Get the configured device ID for this widget instance
            String configuredDeviceId = WidgetConfigurationActivity.loadDeviceIdPref(context, appWidgetId);
            Log.d(TAG, "Widget " + appWidgetId + " configured for device: " + configuredDeviceId);
            
            JSONObject widgetData;
            
            if (configuredDeviceId != null) {
                // Load multi-device data and extract the specific device's data
                String allDevicesJson = HomeWidgetPlugin.Companion.getData(context).getString(WIDGET_DEVICES_DATA_KEY, "{}");
                JSONObject allDevices = new JSONObject(allDevicesJson);
                
                if (allDevices.has(configuredDeviceId)) {
                    widgetData = allDevices.getJSONObject(configuredDeviceId);
                    Log.d(TAG, "Loaded data for configured device: " + configuredDeviceId);
                } else {
                    // Configured device not found in data - use fallback
                    Log.w(TAG, "Configured device " + configuredDeviceId + " not found in data");
                    widgetData = new JSONObject();
                }
            } else {
                // No device configured - use legacy single device data for backward compatibility
                Log.d(TAG, "No device configured, using legacy data");
                String widgetDataJson = HomeWidgetPlugin.Companion.getData(context).getString(WIDGET_DATA_KEY, "{}");
                widgetData = new JSONObject(widgetDataJson);
            }
            
            // Extract all values from JSON with fallbacks
            int co2Int = widgetData.optInt("co2Value", 0);
            String co2Value = co2Int == 0 ? "----" : String.valueOf(co2Int);
            String deviceId = widgetData.optString("deviceId", "");
            String deviceName = widgetData.optString("deviceName", "AirSpot Device");
            String powerMode = widgetData.optString("powerMode", "Now");
            String batteryLevel = String.valueOf(widgetData.optInt("batteryLevel", 0));
            boolean isCharging = widgetData.optBoolean("isCharging", false);
            boolean alarmEnabled = widgetData.optBoolean("alarmEnabled", false);
            boolean vibrationEnabled = widgetData.optBoolean("vibrationEnabled", false);
            boolean isConnected = widgetData.optBoolean("isConnected", false);
            boolean isRefreshing = widgetData.optBoolean("isRefreshing", false);

            // Check if we have a valid device connection
            boolean hasValidDevice = !deviceId.isEmpty() && isConnected;
            
            if (hasValidDevice) {
                // Device name and time
                views.setTextViewText(R.id.device_name, deviceName);
                views.setTextViewText(R.id.last_updated, getCurrentTime());
                
                // CO2 value with color coding
                views.setTextViewText(R.id.co2_value, co2Value);
                int co2Color = co2Int == 0 ? Color.GRAY : getDynamicColorForCO2Value(co2Int, 800, 1000);
                views.setTextColor(R.id.co2_value, co2Color);
                
                // Status icons
                updateStatusIcons(views, batteryLevel, isCharging, alarmEnabled, vibrationEnabled, powerMode, isConnected);
                
                // Handle refresh state and setup refresh button
                setupRefreshState(views, isRefreshing, isConnected);
                setupRefreshButton(context, views, appWidgetId, deviceId);
                
            } else {
                // No device connected state
                views.setTextViewText(R.id.device_name, "");
                views.setTextViewText(R.id.last_updated, "");
                views.setTextViewText(R.id.co2_value, "----");
                views.setTextColor(R.id.co2_value, Color.GRAY);

                views.setViewVisibility(R.id.battery_icon, View.GONE);
                views.setViewVisibility(R.id.alarm_icon, View.GONE);
                views.setViewVisibility(R.id.vibration_icon, View.GONE);
            }
            
            // Set up click intent using deep link with widget flag
            Intent intent = new Intent(context, MainActivity.class);
            intent.setData(Uri.parse("airspothealth://devices?from=widget"));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);
            
        } catch (JSONException e) {
            Log.e(TAG, "Error parsing widget data", e);
            // Set fallback values
            views.setTextViewText(R.id.device_name, "AirSpot Device");
            views.setTextViewText(R.id.co2_value, "----");
            views.setTextColor(R.id.co2_value, Color.GRAY);
        }
        
        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static void updateStatusIcons(RemoteViews views, String batteryLevel, boolean isCharging, 
                                        boolean alarmEnabled, boolean vibrationEnabled, String powerMode, boolean isConnected) {
        // Battery icon (no percentage text in small widget)
        views.setViewVisibility(R.id.battery_icon, View.VISIBLE);
        int batteryLevelInt = Integer.parseInt(batteryLevel);
        int batteryIcon = getBatteryIcon(batteryLevelInt, isCharging);
        views.setImageViewResource(R.id.battery_icon, batteryIcon);
        
        // Alarm icon
        views.setViewVisibility(R.id.alarm_icon, View.VISIBLE);
        views.setImageViewResource(R.id.alarm_icon, alarmEnabled ? R.drawable.ic_bell : R.drawable.ic_bell_slash);
        
        
        // Vibration icon
        views.setViewVisibility(R.id.vibration_icon, View.VISIBLE);
        views.setImageViewResource(R.id.vibration_icon, vibrationEnabled ? R.drawable.ic_iphone_radiowaves : R.drawable.ic_iphone_slash);
    }

    private static void setupRefreshState(RemoteViews views, boolean isRefreshing, boolean isConnected) {
        Log.d(TAG, "Setting up refresh state - isRefreshing: " + isRefreshing + ", isConnected: " + isConnected);
        
        if (isRefreshing && isConnected) {
            // Show progress bar, hide refresh button
            Log.d(TAG, "Showing refresh animation");
            views.setViewVisibility(R.id.progress_refresh, View.VISIBLE);
            views.setViewVisibility(R.id.refresh_button, View.GONE);
        } else {
            // Hide progress bar, show refresh button
            Log.d(TAG, "Hiding refresh animation");
            views.setViewVisibility(R.id.progress_refresh, View.GONE);
            views.setViewVisibility(R.id.refresh_button, View.VISIBLE);
            
            // Set appropriate refresh button icon based on connection state
            if (isConnected && !isRefreshing) {
                // Show normal refresh icon when connected
                views.setImageViewResource(R.id.refresh_button, R.drawable.refresh_button_widget);
            } else {
                // Show disabled/disconnected icon when not connected
                views.setImageViewResource(R.id.refresh_button, R.drawable.ic_bt_off);
            }
        }
    }

    private static void setupRefreshButton(Context context, RemoteViews views, int appWidgetId, String deviceId) {
        // When the refresh button is clicked, send the REFRESH_DATA broadcast
        Intent intent = new Intent(context, Co2SmallWidget.class);
        intent.setAction("com.air.spot.airspothealth.REFRESH_DATA");
        // Optionally, add deviceId as extra if needed
        if (deviceId != null && !deviceId.isEmpty()) {
            intent.putExtra("deviceId", deviceId);
        }
        PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(context, appWidgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent);
        Log.d(TAG, "Refresh button setup to send REFRESH_DATA broadcast");
    }

    private static int getDynamicColorForCO2Value(int co2Value, int greenUpperLimit, int yellowUpperLimit) {
        if (co2Value <= greenUpperLimit) {
            return Color.parseColor("#4CAF50"); // Brand Green
        } else if (co2Value <= yellowUpperLimit) {
            return Color.parseColor("#FF9800"); // Brand Amber
        } else {
            return Color.parseColor("#F44336"); // Brand Red
        }
    }

    private static int getBatteryIcon(int level, boolean isCharging) {
        if (isCharging) {
            return R.drawable.battery_100percent_bolt;
        } else if (level > 75) {
            return R.drawable.battery_100percent;
        } else if (level > 50) {
            return R.drawable.battery_75percent;
        } else if (level > 25) {
            return R.drawable.battery_50percent;
        } else if (level > 10) {
            return R.drawable.battery_25percent;
        } else {
            return R.drawable.battery_0percent;
        }
    }

    private static String getCurrentTime() {
        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a", Locale.getDefault());
        return "at " + timeFormat.format(calendar.getTime());
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
        Log.d(TAG, "Small widget enabled");
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
        Log.d(TAG, "Small widget disabled");
    }

    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
        // Clean up preferences when widgets are deleted
        for (int appWidgetId : appWidgetIds) {
            WidgetConfigurationActivity.deleteDeviceIdPref(context, appWidgetId);
            Log.d(TAG, "Cleaned up preferences for widget: " + appWidgetId);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if ("com.air.spot.airspothealth.REFRESH_DATA".equals(intent.getAction())) {
            // Send the broadcast to MainActivity (which will forward to Flutter)
            sendRefreshBroadcast(context);
        }
    }

    // Add a static method to send the REFRESH_DATA broadcast
    public static void sendRefreshBroadcast(Context context) {
        Intent broadcastIntent = new Intent("com.air.spot.airspothealth.REFRESH_DATA");
        context.sendBroadcast(broadcastIntent);
        Log.d(TAG, "Sent REFRESH_DATA broadcast from Co2SmallWidget");
    }
}
