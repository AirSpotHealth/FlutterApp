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
 * Implementation of App Widget functionality for Medium CO2 monitoring widget.
 */
public class Co2MediumWidget extends AppWidgetProvider {

    private static final String TAG = "Co2MediumWidget";
    private static final String WIDGET_DATA_KEY = "widget_data_json";

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        Log.d(TAG, "Updating medium widget: " + appWidgetId);
        
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.co2_medium_widget);
        
        try {
            // Get the single JSON payload
            String widgetDataJson = HomeWidgetPlugin.Companion.getData(context).getString(WIDGET_DATA_KEY, "{}");
            JSONObject widgetData = new JSONObject(widgetDataJson);
            
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

            // Graph data
            JSONArray co2HistoryArray = widgetData.optJSONArray("co2History");
            List<Integer> co2History = parseJsonArrayToIntList(co2HistoryArray);
            int greenUpperLimit = widgetData.optInt("greenUpperLimit", 800);
            int yellowUpperLimit = widgetData.optInt("yellowUpperLimit", 1000);

            // Check if we have a valid device connection
            boolean hasValidDevice = !deviceId.isEmpty() && isConnected;
            
            if (hasValidDevice) {
                // Device name and time
                views.setTextViewText(R.id.device_name, deviceName);
                views.setTextViewText(R.id.last_updated, getCurrentTime());
                
                // CO2 value with color coding
                views.setTextViewText(R.id.co2_value, co2Value);
                int co2Color = co2Int == 0 ? Color.GRAY : getDynamicColorForCO2Value(co2Int, greenUpperLimit, yellowUpperLimit);
                views.setTextColor(R.id.co2_value, co2Color);
                
                // Status icons
                updateStatusIcons(views, batteryLevel, isCharging, alarmEnabled, vibrationEnabled, powerMode, isConnected);
                
                // CO2 History Graph (bar-style like Co2ValueWidget)
                Bitmap graphBitmap = createBarGraph(context, co2History, greenUpperLimit, yellowUpperLimit);
                views.setImageViewBitmap(R.id.co2_graph, graphBitmap);
                
            } else {
                // No device connected state
                views.setTextViewText(R.id.device_name, "");
                views.setTextViewText(R.id.last_updated, "");
                views.setTextViewText(R.id.co2_value, "----");
                views.setTextColor(R.id.co2_value, Color.GRAY);
                
                // Hide all status icons
                views.setViewVisibility(R.id.battery_icon, View.GONE);
                views.setViewVisibility(R.id.battery_percentage, View.GONE);
                views.setViewVisibility(R.id.alarm_icon, View.GONE);
                views.setViewVisibility(R.id.timer_icon, View.GONE);
                views.setViewVisibility(R.id.power_mode, View.GONE);
                views.setViewVisibility(R.id.vibration_icon, View.GONE);
                
                // Show no data graph
                views.setImageViewResource(R.id.co2_graph, R.drawable.no_data_graph);
            }
            
            // Set up click intent
            Intent intent = new Intent(context, MainActivity.class);
            intent.putExtra("navigate_to", "devices");
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
        // Battery icon and percentage
        views.setViewVisibility(R.id.battery_icon, View.VISIBLE);
        views.setViewVisibility(R.id.battery_percentage, View.VISIBLE);
        int batteryLevelInt = Integer.parseInt(batteryLevel);
        int batteryIcon = getBatteryIcon(batteryLevelInt, isCharging);
        views.setImageViewResource(R.id.battery_icon, batteryIcon);
        views.setTextViewText(R.id.battery_percentage, batteryLevel + "%");
        
        // Alarm icon
        views.setViewVisibility(R.id.alarm_icon, View.VISIBLE);
        views.setImageViewResource(R.id.alarm_icon, alarmEnabled ? R.drawable.ic_bell : R.drawable.ic_bell_slash);
        
        // Timer icon and power mode
        views.setViewVisibility(R.id.timer_icon, View.VISIBLE);
        views.setViewVisibility(R.id.power_mode, View.VISIBLE);
        views.setImageViewResource(R.id.timer_icon, R.drawable.ic_timer);
        views.setTextViewText(R.id.power_mode, powerMode);
        
        // Vibration icon
        views.setViewVisibility(R.id.vibration_icon, View.VISIBLE);
        views.setImageViewResource(R.id.vibration_icon, vibrationEnabled ? R.drawable.ic_iphone_radiowaves : R.drawable.ic_iphone_slash);
    }

    private static Bitmap createBarGraph(Context context, List<Integer> co2History, int greenUpperLimit, int yellowUpperLimit) {
        float density = context.getResources().getDisplayMetrics().density;
        int width = (int)(300 * density);
        int height = (int)(60 * density);
        int padding = (int)(8 * density);
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        // Background rounded rect
        Paint bg = new Paint();
        bg.setAntiAlias(true);
        bg.setColor(Color.parseColor("#1A000000"));
        canvas.drawRoundRect(new android.graphics.RectF(0,0,width,height), 8 * density, 8 * density, bg);

        float drawableWidth = width - (2 * padding);
        float drawableHeight = height - (2 * padding);

        if (co2History == null) co2History = new ArrayList<>();
        int maxBars = Math.min(40, co2History.size());
        int startIndex = Math.max(0, co2History.size() - maxBars);

        float barSpacing = 2 * density;
        float barWidth = (drawableWidth - (barSpacing * (40 - 1))) / 40f;

        // Grey background bars
        Paint grey = new Paint();
        grey.setAntiAlias(true);
        grey.setColor(Color.parseColor("#40808080"));
        for (int i = 0; i < 40; i++) {
            float left = padding + (i * (barWidth + barSpacing));
            android.graphics.RectF r = new android.graphics.RectF(left, padding, left + barWidth, height - padding);
            canvas.drawRoundRect(r, 2 * density, 2 * density, grey);
        }

        // Colored overlay bars
        Paint bar = new Paint();
        bar.setAntiAlias(true);
        int graphMinValue = 0;
        int graphMaxValue = Math.max(yellowUpperLimit * 2, 1600);
        for (int i = 0; i < maxBars; i++) {
            int value = co2History.get(startIndex + i);
            float ratio = (float)(value - graphMinValue) / (graphMaxValue - graphMinValue);
            ratio = Math.max(0.05f, Math.min(1.0f, ratio));
            float barHeight = drawableHeight * ratio;
            int barIndex = (40 - maxBars) + i;
            float left = padding + (barIndex * (barWidth + barSpacing));
            float top = height - padding - barHeight;
            android.graphics.RectF r = new android.graphics.RectF(left, top, left + barWidth, height - padding);
            int color = getDynamicColorForCO2Value(value, greenUpperLimit, yellowUpperLimit);
            bar.setColor(color);
            canvas.drawRoundRect(r, 2 * density, 2 * density, bar);
        }
        return bitmap;
    }

    private static List<Integer> parseJsonArrayToIntList(JSONArray jsonArray) {
        List<Integer> list = new ArrayList<>();
        if (jsonArray != null) {
            for (int i = 0; i < jsonArray.length(); i++) {
                try {
                    list.add(jsonArray.getInt(i));
                } catch (JSONException e) {
                    Log.e(TAG, "Error parsing CO2 history array", e);
                }
            }
        }
        return list;
    }

    private static int getDynamicColorForCO2Value(int co2Value, int greenUpperLimit, int yellowUpperLimit) {
        if (co2Value <= greenUpperLimit) {
            return Color.parseColor("#4CAF50"); // Green
        } else if (co2Value <= yellowUpperLimit) {
            return Color.parseColor("#FF9800"); // Orange  
        } else {
            return Color.parseColor("#F44336"); // Red
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
        Log.d(TAG, "Medium widget enabled");
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
        Log.d(TAG, "Medium widget disabled");
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
        Log.d(TAG, "Sent REFRESH_DATA broadcast from Co2MediumWidget");
    }
}
