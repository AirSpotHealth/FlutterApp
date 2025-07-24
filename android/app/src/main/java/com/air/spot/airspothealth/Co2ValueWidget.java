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
 * Implementation of App Widget functionality for 2x3 CO2 monitoring widget.
 */
public class Co2ValueWidget extends AppWidgetProvider {

    private static final String TAG = "Co2ValueWidget";
    private static final String WIDGET_DATA_KEY = "widget_data_json";

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        Log.d(TAG, "Updating widget: " + appWidgetId);
        
        // Use the single 2x3 layout
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.co2_value_widget);
        
        try {
            // Get the single JSON payload
            String widgetDataJson = HomeWidgetPlugin.Companion.getData(context).getString(WIDGET_DATA_KEY, "{}");
            JSONObject widgetData = new JSONObject(widgetDataJson);
            
            // Extract all values from JSON with fallbacks
            // Note: co2Value and batteryLevel are now sent as integers from Flutter
            String co2Value = String.valueOf(widgetData.optInt("co2Value", 0));
            if (co2Value.equals("0")) co2Value = "----"; // Fallback for invalid data
            String deviceId = widgetData.optString("deviceId", "");
            String deviceName = widgetData.optString("deviceName", "No Device");
            String powerMode = widgetData.optString("powerMode", "Now");
            String batteryLevel = String.valueOf(widgetData.optInt("batteryLevel", 0));
            boolean isCharging = widgetData.optBoolean("isCharging", false);
            boolean alarmEnabled = widgetData.optBoolean("alarmEnabled", false);
            boolean vibrationEnabled = widgetData.optBoolean("vibrationEnabled", false);
            
            // Graph data
            JSONArray co2HistoryArray = widgetData.optJSONArray("co2History");
            List<Integer> co2History = parseJsonArrayToIntList(co2HistoryArray);
            int greenUpperLimit = widgetData.optInt("greenUpperLimit", 800);
            int yellowUpperLimit = widgetData.optInt("yellowUpperLimit", 1000);
            int graphMaxValue = widgetData.optInt("graphMaxValue", 1600);
            int graphMinValue = widgetData.optInt("graphMinValue", 0);
            
            Log.d(TAG, "Parsed widget data: CO2=" + co2Value + ", Device=" + deviceName + 
                      ", History=" + co2History.size() + " values, Thresholds=" + greenUpperLimit + "/" + yellowUpperLimit);

            // Set CO2 value and dynamic color based on device thresholds
            views.setTextViewText(R.id.co2_value, co2Value);
            int color = getColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
            views.setTextColor(R.id.co2_value, color);

            // Set power mode (in place of time display)
            views.setTextViewText(R.id.power_mode, powerMode);

            // Set battery level and charging status
            int batteryLevelInt = 0;
            try {
                batteryLevelInt = Integer.parseInt(batteryLevel);
            } catch (NumberFormatException ignored) {
            }
            
            // Check if device is charging (already parsed above)
            String batteryText = isCharging ? "CHG" : batteryLevelInt + "%";
            views.setTextViewText(R.id.battery_percentage, batteryText);

            // Set alarm/sound mode icon based on state
            int soundModeDrawable = alarmEnabled ? R.drawable.alarm_on : R.drawable.alarm_off;
            views.setImageViewResource(R.id.sound_mode, soundModeDrawable);
            views.setViewVisibility(R.id.sound_mode, View.VISIBLE);

            // Set vibration mode icon based on state
            int vibrationModeDrawable = vibrationEnabled ? R.drawable.vibrate_on : R.drawable.vibrate_off;
            views.setImageViewResource(R.id.vibration_mode, vibrationModeDrawable);
            views.setViewVisibility(R.id.vibration_mode, View.VISIBLE);

            // Create and setup dynamic graph
            setupDynamicCo2Graph(context, views, co2History, greenUpperLimit, yellowUpperLimit, 
                                 graphMaxValue, graphMinValue);

            // Set up refresh button with device ID
            setupRefreshButton(context, views, appWidgetId, deviceId);

            Log.d(TAG, "Widget updated successfully with JSON data");

        } catch (JSONException e) {
            Log.e(TAG, "Error parsing widget JSON data: " + e.getMessage());
        }

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static List<Integer> parseJsonArrayToIntList(JSONArray jsonArray) {
        List<Integer> intList = new ArrayList<>();
        if (jsonArray != null) {
            for (int i = 0; i < jsonArray.length(); i++) {
                try {
                    intList.add(jsonArray.getInt(i));
                } catch (JSONException e) {
                    Log.w(TAG, "Error parsing CO2 history value at index " + i + ": " + e.getMessage());
                }
            }
        }
        return intList;
    }

    private static void setupRefreshButton(Context context, RemoteViews views, int appWidgetId, String deviceId) {
        // When the refresh button is clicked, send the REFRESH_DATA broadcast
        Intent intent = new Intent(context, Co2ValueWidget.class);
        intent.setAction("com.air.spot.airspothealth.REFRESH_DATA");
        // Optionally, add deviceId as extra if needed
        if (deviceId != null && !deviceId.isEmpty()) {
            intent.putExtra("deviceId", deviceId);
        }
        PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(context, appWidgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent);
        Log.d(TAG, "Refresh button setup to send REFRESH_DATA broadcast");
    }

    private static void setupDynamicCo2Graph(Context context, RemoteViews views, List<Integer> co2History, 
                                             int greenUpperLimit, int yellowUpperLimit,
                                             int graphMaxValue, int graphMinValue) {
        try {
            // Generate dynamic graph bitmap (just like iOS SwiftUI approach)
            Bitmap graphBitmap = generateCo2GraphBitmap(co2History, greenUpperLimit, yellowUpperLimit, 
                                                       graphMaxValue, graphMinValue, context);
            
            // Set the generated bitmap to the ImageView
            views.setImageViewBitmap(R.id.co2_graph, graphBitmap);
            Log.d(TAG, "Dynamic graph bitmap generated and set with " + co2History.size() + " values");

        } catch (Exception e) {
            Log.e(TAG, "Error setting up dynamic CO2 graph: " + e.getMessage());
        }
    }
    
    private static Bitmap generateCo2GraphBitmap(List<Integer> co2History, int greenUpperLimit, 
                                                int yellowUpperLimit, int graphMaxValue, int graphMinValue, 
                                                Context context) {
        // Always generate graph even if no data - will show grey bars only
        
        // Graph dimensions (similar to iOS 70dp height)
        float density = context.getResources().getDisplayMetrics().density;
        int width = (int)(300 * density);  // Flexible width
        int height = (int)(60 * density); // 60dp height
        int padding = (int)(8 * density); // 8dp padding
        
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        
        // Background (matching graph_background.xml)
        Paint backgroundPaint = new Paint();
        backgroundPaint.setColor(Color.parseColor("#1A000000"));
        backgroundPaint.setAntiAlias(true);
        RectF backgroundRect = new RectF(0, 0, width, height);
        canvas.drawRoundRect(backgroundRect, 8 * density, 8 * density, backgroundPaint);
        
        // Calculate available drawing area
        float drawableWidth = width - (2 * padding);
        float drawableHeight = height - (2 * padding);
        
        // Handle null or empty history
        if (co2History == null) {
            co2History = new ArrayList<>();
        }
        
        // Limit to reasonable number of bars for readability
        int maxBars = Math.min(40, co2History.size()); // Show up to 40 bars like iOS
        int startIndex = Math.max(0, co2History.size() - maxBars);
        
        // Calculate bar width and spacing for 40 bars (just like iOS)
        float barSpacing = 2 * density; // 2dp spacing
        float barWidth = (drawableWidth - (barSpacing * (40 - 1))) / 40;
        
        // Always draw 40 grey background bars (full scale) - just like iOS
        Paint greyBarPaint = new Paint();
        greyBarPaint.setColor(Color.parseColor("#40808080")); // Semi-transparent grey
        greyBarPaint.setAntiAlias(true);
        
        for (int i = 0; i < 40; i++) {
            float barLeft = padding + (i * (barWidth + barSpacing));
            // Full height grey bar
            float barRight = barLeft + barWidth;
            float barBottom = height - padding;
            
            // Draw full-height grey background bar
            RectF greyBarRect = new RectF(barLeft, (float) padding, barRight, barBottom);
            canvas.drawRoundRect(greyBarRect, 2 * density, 2 * density, greyBarPaint);
        }
        
        // Draw colored overlay bars for actual CO2 values (like iOS foreground bars)
        Paint coloredBarPaint = new Paint();
        coloredBarPaint.setAntiAlias(true);
        
        for (int i = 0; i < maxBars; i++) {
            int co2Value = co2History.get(startIndex + i);
            
            // Calculate normalized height (same logic as iOS)
            float heightRatio = (float)(co2Value - graphMinValue) / (graphMaxValue - graphMinValue);
            heightRatio = Math.max(0.05f, Math.min(1.0f, heightRatio)); // Clamp between 5% and 100%
            
            float barHeight = drawableHeight * heightRatio;
            
            // Calculate bar position - align to RIGHT side (most recent data on rightmost positions)
            // Example: if maxBars=5, bars appear at positions 35,36,37,38,39 (rightmost positions)
            // Example: if maxBars=3, bars appear at positions 37,38,39 (rightmost positions)
            int barIndex = (40 - maxBars) + i;
            float barLeft = padding + (barIndex * (barWidth + barSpacing));
            float barTop = height - padding - barHeight; // Draw from bottom
            float barRight = barLeft + barWidth;
            float barBottom = height - padding;
            
            // Set bar color based on dynamic thresholds (same as iOS)
            int barColor = getDynamicColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
            coloredBarPaint.setColor(barColor);
            
            // Draw the colored overlay bar with rounded corners
            RectF coloredBarRect = new RectF(barLeft, barTop, barRight, barBottom);
            canvas.drawRoundRect(coloredBarRect, 2 * density, 2 * density, coloredBarPaint);
        }
        
        if (maxBars > 0) {
            Log.d(TAG, "Generated graph bitmap: " + width + "x" + height + "px with 40 grey bars + " + maxBars + " colored overlays");
        } else {
            Log.d(TAG, "Generated graph bitmap: " + width + "x" + height + "px with 40 grey bars (no data)");
        }
        return bitmap;
    }
    
    private static int getDynamicColorForCO2Value(int co2Value, int greenUpperLimit, int yellowUpperLimit) {
        // Dynamic color logic - exactly like iOS co2Color(for:green:yellow:)
        if (co2Value <= greenUpperLimit) {
            return Color.parseColor("#4CAF50"); // Green
        } else if (co2Value <= yellowUpperLimit) {
            return Color.parseColor("#FF9800"); // Orange  
        } else {
            return Color.parseColor("#F44336"); // Red
        }
    }
    
    // Legacy method with hardcoded thresholds (kept for compatibility)
    private static int getColorForCO2Value(String co2ValueStr) {
        try {
            int co2Value = Integer.parseInt(co2ValueStr);
            return getDynamicColorForCO2Value(co2Value, 800, 1000); // Use defaults
        } catch (NumberFormatException e) {
            return Color.parseColor("#4CAF50"); // Default green for invalid values
        }
    }
    
    // Dynamic method with custom thresholds (same as iOS)
    private static int getColorForCO2Value(String co2ValueStr, int greenUpperLimit, int yellowUpperLimit) {
        try {
            int co2Value = Integer.parseInt(co2ValueStr);
            return getDynamicColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
        } catch (NumberFormatException e) {
            return Color.parseColor("#4CAF50"); // Default green for invalid values
        }
    }

    // Add a static method to send the REFRESH_DATA broadcast
    public static void sendRefreshBroadcast(Context context) {
        Intent broadcastIntent = new Intent("com.air.spot.airspothealth.REFRESH_DATA");
        context.sendBroadcast(broadcastIntent);
        Log.d(TAG, "Sent REFRESH_DATA broadcast from Co2ValueWidget");
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

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if ("com.air.spot.airspothealth.REFRESH_DATA".equals(intent.getAction())) {
            // Send the broadcast to MainActivity (which will forward to Flutter)
            sendRefreshBroadcast(context);
        }
    }
}