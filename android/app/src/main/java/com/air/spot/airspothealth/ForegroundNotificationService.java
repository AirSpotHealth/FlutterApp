package com.air.spot.airspothealth;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.net.Uri;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.widget.RemoteViews;

import androidx.core.app.NotificationCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import es.antonborri.home_widget.HomeWidgetBackgroundIntent;
import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * Foreground Service that displays a persistent notification with real-time CO2 data
 * Similar to iOS Live Activity functionality
 */
public class ForegroundNotificationService extends Service {

    private static final String TAG = "ForegroundNotificationService";
    private static final int NOTIFICATION_ID = 1001;
    private static final String CHANNEL_ID = "CO2_MONITORING_CHANNEL";
    private static final String WIDGET_DATA_KEY = "widget_data_json";

    private NotificationManager notificationManager;
    private boolean isServiceRunning = false;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "ForegroundNotificationService created");
        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "ForegroundNotificationService onStartCommand called");

        Log.d(TAG, "Intent action: " + (intent != null ? intent.getAction() : "null"));
        Log.d(TAG, "Service running state: " + isServiceRunning);

        if (intent != null) {
            String action = intent.getAction();
            if ("STOP_SERVICE".equals(action)) {
                Log.d(TAG, "Received STOP_SERVICE action");
                stopForegroundService();
                return START_NOT_STICKY;
            } else if ("UPDATE_DATA".equals(action)) {
                Log.d(TAG, "Received UPDATE_DATA action");
                // If service is not running, start it first, then update
                if (!isServiceRunning) {
                    Log.d(TAG, "Service not running, starting foreground service first");
                    startForegroundService();
                } else {
                    Log.d(TAG, "Service already running, updating notification");
                    updateNotification();
                }
                return START_STICKY;
            }
        }

        // Start foreground service with initial notification
        Log.d(TAG, "Starting foreground service with notification (no action)");
        startForegroundService();
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null; // We don't provide binding
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "ForegroundNotificationService destroyed");
        isServiceRunning = false;
    }

    private void createNotificationChannel() {
        Log.d(TAG, "Creating notification channel");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "CO2 Monitoring",
                    NotificationManager.IMPORTANCE_MAX  // Use MAX to force lock screen visibility
            );
            channel.setDescription("Real-time CO2 monitoring notification - Always show on lock screen");
            channel.setShowBadge(true);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            channel.setBypassDnd(false);
            channel.enableLights(true);
            channel.setLightColor(Color.GREEN);
            channel.enableVibration(false); // Disable to avoid blocking
            channel.setSound(null, null); // No sound to avoid aggressive filtering

            // Force the channel to be visible on lock screen
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                channel.setAllowBubbles(false);
            }

            notificationManager.createNotificationChannel(channel);
            Log.d(TAG, "Notification channel created with MAX importance for lock screen visibility");
        } else {
            Log.d(TAG, "Notification channel not needed for API " + Build.VERSION.SDK_INT);
        }
    }

    private void startForegroundService() {
        Log.d(TAG, "startForegroundService called, isServiceRunning: " + isServiceRunning);
        if (!isServiceRunning) {
            try {
                Log.d(TAG, "Creating notification...");
                
                Notification notification = createNotification();
                Log.d(TAG, "Notification created, starting foreground...");
                startForeground(NOTIFICATION_ID, notification);
                isServiceRunning = true;
                Log.d(TAG, "Foreground service started with notification");
            } catch (Exception e) {
                Log.e(TAG, "Error starting foreground service: " + e.getMessage(), e);
                // Try with default notification on error
                try {
                    Notification defaultNotification = createDefaultNotification();
                    startForeground(NOTIFICATION_ID, defaultNotification);
                    isServiceRunning = true;
                    Log.d(TAG, "Foreground service started with default notification");
                } catch (Exception ex) {
                    Log.e(TAG, "Failed to start with default notification: " + ex.getMessage(), ex);
                }
            }
        } else {
            Log.d(TAG, "Service already running, skipping start");
        }
    }

    private void stopForegroundService() {
        if (isServiceRunning) {
            stopForeground(true);
            stopSelf();
            isServiceRunning = false;
            Log.d(TAG, "Foreground service stopped");
        }
    }

    public void updateNotification() {
        Log.d(TAG, "updateNotification called, isServiceRunning: " + isServiceRunning);
        if (isServiceRunning) {
            try {
                Log.d(TAG, "Creating updated notification...");
                Notification notification = createNotification();
                Log.d(TAG, "Updating existing notification...");
                notificationManager.notify(NOTIFICATION_ID, notification);
                Log.d(TAG, "Notification updated successfully");
            } catch (Exception e) {
                Log.e(TAG, "Error updating notification: " + e.getMessage(), e);
            }
        } else {
            Log.d(TAG, "Service not running, cannot update notification");
        }
    }

    private Notification createNotification() {
        Log.d(TAG, "createNotification called");

        // Get widget data from SharedPreferences
        String widgetDataJson = HomeWidgetPlugin.Companion.getData(this).getString(WIDGET_DATA_KEY, "{}");
        Log.d(TAG, "Widget data JSON: " + widgetDataJson);

        try {
            JSONObject widgetData = new JSONObject(widgetDataJson);

            // Extract data with fallbacks
            // Note: co2Value and batteryLevel are now sent as integers from Flutter
            String co2Value = String.valueOf(widgetData.optInt("co2Value", 0));
            if (co2Value.equals("0")) co2Value = "----"; // Fallback for invalid data
            String deviceName = widgetData.optString("deviceName", "No Device");
            String deviceId = widgetData.optString("deviceId", "");
            String batteryLevel = String.valueOf(widgetData.optInt("batteryLevel", 0));
            boolean isCharging = widgetData.optBoolean("isCharging", false);

            Log.d(TAG, "Parsed data - CO2: " + co2Value + ", Device: " + deviceName);

            // Create a simple notification without custom layouts for Honor compatibility
            String title = "AirSpot Health • " + co2Value + " ppm";
            String text = deviceName + " • Battery: " + (isCharging ? "Charging" : batteryLevel + "%");

            // Create open app intent
            Intent openAppIntent = new Intent(this, MainActivity.class);
            openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            // Create full screen intent for lock screen visibility
            Intent fullScreenIntent = new Intent(this, MainActivity.class);
            fullScreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(this, 1, fullScreenIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            // Create notification with simple text only - no custom layouts
            Log.d(TAG, "Building simple notification for Honor compatibility...");
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setSmallIcon(android.R.drawable.stat_sys_warning)  // Use system icon
                    .setContentTitle(title)
                    .setContentText(text)
                    .setSubText("Tap to open • Always visible")
                    .setOngoing(true)
                    .setPriority(NotificationCompat.PRIORITY_MAX)  // Use MAX to match channel
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setCategory(NotificationCompat.CATEGORY_SERVICE)  // Use SERVICE for persistent
                    .setContentIntent(openAppPendingIntent)
                    .setFullScreenIntent(fullScreenPendingIntent, false)  // Add for lock screen
                    .setAutoCancel(false)
                    .setShowWhen(true)
                    .setWhen(System.currentTimeMillis())
                    .setTicker(title)  // Add ticker for lock screen
                    .setOnlyAlertOnce(true)  // Don't spam with updates
                    .setLocalOnly(false)     // Allow on lock screen
                    .setDefaults(0);  // No defaults

            // Add simple action buttons without custom icons
            addSimpleNotificationActions(builder, deviceId);

            Log.d(TAG, "Simple notification built successfully");
            return builder.build();

        } catch (JSONException e) {
            Log.e(TAG, "Error parsing notification data: " + e.getMessage());
            return createDefaultNotification();
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error creating notification: " + e.getMessage(), e);
            return createDefaultNotification();
        }
    }

    private RemoteViews createNotificationLayout(String co2Value, String deviceName,
                                                 String powerMode, String batteryLevel, boolean isCharging,
                                                 boolean alarmEnabled, boolean vibrationEnabled, List<Integer> co2History,
                                                 int greenUpperLimit, int yellowUpperLimit, int graphMaxValue, int graphMinValue) {

        RemoteViews views = new RemoteViews(getPackageName(), R.layout.notification_compact);

        // Set CO2 value with color
        views.setTextViewText(R.id.co2_value_compact, co2Value);
        int co2Color = getColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
        views.setTextColor(R.id.co2_value_compact, co2Color);

        // Set device name
        views.setTextViewText(R.id.device_name_compact, deviceName);

        // Set battery info
        String batteryText = isCharging ? "CHG" : batteryLevel + "%";
        views.setTextViewText(R.id.battery_compact, batteryText);

        return views;
    }

    private RemoteViews createExpandedNotificationLayout(String co2Value, String deviceName,
                                                         String powerMode, String batteryLevel, boolean isCharging,
                                                         boolean alarmEnabled, boolean vibrationEnabled, List<Integer> co2History,
                                                         int greenUpperLimit, int yellowUpperLimit, int graphMaxValue, int graphMinValue,
                                                         String deviceId) {

        RemoteViews views = new RemoteViews(getPackageName(), R.layout.notification_expanded);

        // Set CO2 value with color
        views.setTextViewText(R.id.co2_value_expanded, co2Value);
        int co2Color = getColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
        views.setTextColor(R.id.co2_value_expanded, co2Color);

        // Set device name
        views.setTextViewText(R.id.device_name_expanded, deviceName);

        // Set power mode
        views.setTextViewText(R.id.power_mode_expanded, powerMode);

        // Set battery info
        String batteryText = isCharging ? "CHG" : batteryLevel + "%";
        views.setTextViewText(R.id.battery_expanded, batteryText);

        // Set alarm status
        int alarmIcon = alarmEnabled ? R.drawable.alarm_on : R.drawable.alarm_off;
        views.setImageViewResource(R.id.alarm_status_expanded, alarmIcon);

        // Set vibration status
        int vibrationIcon = vibrationEnabled ? R.drawable.vibrate_on : R.drawable.vibrate_off;
        views.setImageViewResource(R.id.vibration_status_expanded, vibrationIcon);

        // Create and set graph
        if (!co2History.isEmpty()) {
            Bitmap graphBitmap = generateCo2GraphBitmap(co2History, greenUpperLimit,
                    yellowUpperLimit, graphMaxValue, graphMinValue);
            views.setImageViewBitmap(R.id.co2_graph_expanded, graphBitmap);
        }

        // Set up refresh button
        setupRefreshButton(views, deviceId);

        return views;
    }

    private void addNotificationActions(NotificationCompat.Builder builder, String deviceId) {
        // Refresh action
        Intent refreshIntent = new Intent(this, ForegroundNotificationService.class);
        refreshIntent.setAction("UPDATE_DATA");
        PendingIntent refreshPendingIntent = PendingIntent.getService(this, 0, refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        builder.addAction(R.drawable.ic_refresh, "Refresh", refreshPendingIntent);

        // Open app action
        Intent openAppIntent = new Intent(this, MainActivity.class);
        openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        builder.addAction(R.drawable.ic_open_app, "Open App", openAppPendingIntent);

        // Stop service action
        Intent stopIntent = new Intent(this, ForegroundNotificationService.class);
        stopIntent.setAction("STOP_SERVICE");
        PendingIntent stopPendingIntent = PendingIntent.getService(this, 0, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        builder.addAction(R.drawable.ic_close, "Stop", stopPendingIntent);
    }

    private void addSimpleNotificationActions(NotificationCompat.Builder builder, String deviceId) {
        // Only add Open App action to keep it simple for Honor devices
        Intent openAppIntent = new Intent(this, MainActivity.class);
        openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        builder.addAction(android.R.drawable.ic_menu_view, "Open App", openAppPendingIntent);

        // Stop service action
        Intent stopIntent = new Intent(this, ForegroundNotificationService.class);
        stopIntent.setAction("STOP_SERVICE");
        PendingIntent stopPendingIntent = PendingIntent.getService(this, 0, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        builder.addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPendingIntent);
    }

    private void setupRefreshButton(RemoteViews views, String deviceId) {
        // Create refresh intent similar to widget
        String uriString = "airspothealthapp://refresh";
        if (deviceId != null && !deviceId.isEmpty()) {
            uriString += "?deviceId=" + deviceId;
        }

        PendingIntent refreshPendingIntent = HomeWidgetBackgroundIntent.INSTANCE.getBroadcast(
                this, Uri.parse(uriString));
        views.setOnClickPendingIntent(R.id.refresh_button_expanded, refreshPendingIntent);
    }

    private Bitmap generateCo2GraphBitmap(List<Integer> co2History, int greenUpperLimit,
                                          int yellowUpperLimit, int graphMaxValue, int graphMinValue) {
        // Reuse the same graph generation logic from Co2ValueWidget
        float density = getResources().getDisplayMetrics().density;
        int width = (int) (320 * density);  // Slightly wider for notification
        int height = (int) (60 * density);
        int padding = (int) (8 * density);

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        // Background
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

        // Limit to reasonable number of bars
        int maxBars = Math.min(40, co2History.size());
        int startIndex = Math.max(0, co2History.size() - maxBars);

        // Calculate bar width and spacing
        float barSpacing = 2 * density;
        float barWidth = (drawableWidth - (barSpacing * (40 - 1))) / 40;

        // Draw grey background bars
        Paint greyBarPaint = new Paint();
        greyBarPaint.setColor(Color.parseColor("#40808080"));
        greyBarPaint.setAntiAlias(true);

        for (int i = 0; i < 40; i++) {
            float barLeft = padding + (i * (barWidth + barSpacing));
            float barRight = barLeft + barWidth;
            float barBottom = height - padding;

            RectF greyBarRect = new RectF(barLeft, (float) padding, barRight, barBottom);
            canvas.drawRoundRect(greyBarRect, 2 * density, 2 * density, greyBarPaint);
        }

        // Draw colored overlay bars for actual CO2 values
        Paint coloredBarPaint = new Paint();
        coloredBarPaint.setAntiAlias(true);

        for (int i = 0; i < maxBars; i++) {
            int co2Value = co2History.get(startIndex + i);

            // Calculate normalized height
            float heightRatio = (float) (co2Value - graphMinValue) / (graphMaxValue - graphMinValue);
            heightRatio = Math.max(0.05f, Math.min(1.0f, heightRatio));

            float barHeight = drawableHeight * heightRatio;

            // Calculate bar position
            int barIndex = (40 - maxBars) + i;
            float barLeft = padding + (barIndex * (barWidth + barSpacing));
            float barTop = height - padding - barHeight;
            float barRight = barLeft + barWidth;
            float barBottom = height - padding;

            // Set bar color based on thresholds
            int barColor = getDynamicColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
            coloredBarPaint.setColor(barColor);

            // Draw the colored overlay bar
            RectF coloredBarRect = new RectF(barLeft, barTop, barRight, barBottom);
            canvas.drawRoundRect(coloredBarRect, 2 * density, 2 * density, coloredBarPaint);
        }

        return bitmap;
    }

    private Notification createDefaultNotification() {
        Log.d(TAG, "Creating default notification");

        // Create open app intent
        Intent openAppIntent = new Intent(this, MainActivity.class);
        openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.stat_sys_warning) // Use system warning icon
                .setContentTitle("AirSpot Health")
                .setContentText("CO2 Monitoring Active")
                .setSubText("Tap to open app")
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_MAX)  // Use MAX priority
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_STATUS)
                .setContentIntent(openAppPendingIntent)
                .setShowWhen(true)
                .setWhen(System.currentTimeMillis())
                .setTicker("AirSpot Health - CO2 Monitoring Active")
                .setOnlyAlertOnce(true)
                .setLocalOnly(false)
                .setDefaults(0)
                .build();
    }

    // Helper methods (reused from Co2ValueWidget)
    private List<Integer> parseJsonArrayToIntList(JSONArray jsonArray) {
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

    private int getColorForCO2Value(String co2ValueStr, int greenUpperLimit, int yellowUpperLimit) {
        try {
            int co2Value = Integer.parseInt(co2ValueStr);
            return getDynamicColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit);
        } catch (NumberFormatException e) {
            return Color.parseColor("#4CAF50"); // Default green
        }
    }

    private int getDynamicColorForCO2Value(int co2Value, int greenUpperLimit, int yellowUpperLimit) {
        if (co2Value <= greenUpperLimit) {
            return Color.parseColor("#4CAF50"); // Green
        } else if (co2Value <= yellowUpperLimit) {
            return Color.parseColor("#FF9800"); // Orange  
        } else {
            return Color.parseColor("#F44336"); // Red
        }
    }

    // Static methods to control the service from outside
    public static void startService(Context context) {
        Intent intent = new Intent(context, ForegroundNotificationService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent);
            Log.d(TAG, "Starting foreground notification service");
        }
    }

    public static void stopService(Context context) {
        Intent intent = new Intent(context, ForegroundNotificationService.class);
        intent.setAction("STOP_SERVICE");
        context.startService(intent);
        Log.d(TAG, "Stopping foreground notification service");
    }

    public static void updateService(Context context) {
        Intent intent = new Intent(context, ForegroundNotificationService.class);
        intent.setAction("UPDATE_DATA");
        context.startService(intent);
        Log.d(TAG, "Updating foreground notification service");
    }

    // Helper method to check if service is running
    public static boolean isServiceRunning(Context context) {
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (ForegroundNotificationService.class.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }
}
