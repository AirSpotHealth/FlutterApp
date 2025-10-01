package com.air.spot.airspothealth;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
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
import java.util.Map;
import java.util.HashMap;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * Foreground Service that displays persistent notifications with real-time CO2 data for multiple devices
 * Similar to iOS Live Activity functionality - supports up to 3 devices
 */
public class ForegroundNotificationService extends Service {

    private static final String TAG = "ForegroundNotificationService";
    private static final int BASE_NOTIFICATION_ID = 1001;
    private static final int MAX_DEVICES = 3;
    private static final String CHANNEL_ID = "CO2_MONITORING_CHANNEL";
    private static final String WIDGET_DATA_KEY = "widget_data_json";
    private static final String ACTION_NOTIFICATION_DISMISSED = "com.air.spot.airspothealth.NOTIFICATION_DISMISSED";

    private NotificationManager notificationManager;
    private boolean isServiceRunning = false;
    
    // Track active device notifications (max 3)
    private final Map<String, Integer> deviceNotificationIds = new HashMap<>();
    private final Map<String, JSONObject> deviceData = new HashMap<>();
    private int nextNotificationId = BASE_NOTIFICATION_ID;

    // Broadcast receiver for notification dismissal
    private BroadcastReceiver dismissalReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "Dismissal receiver triggered with action: " + (intent != null ? intent.getAction() : "null"));
            if (intent != null && ACTION_NOTIFICATION_DISMISSED.equals(intent.getAction())) {
                String deviceId = intent.getStringExtra("deviceId");
                Log.d(TAG, "Notification dismissed by user - sending dismissal event to Flutter for deviceId: " + deviceId);
                sendDismissalEventToFlutter(deviceId);
            } else {
                Log.w(TAG, "Dismissal receiver received unexpected action: " + (intent != null ? intent.getAction() : "null"));
            }
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "ForegroundNotificationService created");
        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        createNotificationChannel();

        // Register broadcast receiver for dismissal events
        IntentFilter filter = new IntentFilter(ACTION_NOTIFICATION_DISMISSED);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(dismissalReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
            Log.d(TAG, "Registered dismissal receiver with RECEIVER_NOT_EXPORTED for action: " + ACTION_NOTIFICATION_DISMISSED);
        } else {
            registerReceiver(dismissalReceiver, filter);
            Log.d(TAG, "Registered dismissal receiver for action: " + ACTION_NOTIFICATION_DISMISSED);
        }
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
            } else if ("REFRESH_DATA".equals(action)) {
                Log.d(TAG, "Received REFRESH_DATA action - sending broadcast to Flutter");
                Intent broadcastIntent = new Intent("com.air.spot.airspothealth.REFRESH_DATA");
                sendBroadcast(broadcastIntent);
                return START_STICKY;
            } else if ("ADD_DEVICE_NOTIFICATION".equals(action)) {
                Log.d(TAG, "Received ADD_DEVICE_NOTIFICATION action");
                String deviceId = intent.getStringExtra("deviceId");
                String dataJson = intent.getStringExtra("data");
                if (deviceId != null && dataJson != null) {
                    try {
                        JSONObject data = new JSONObject(dataJson);
                        addDeviceNotification(deviceId, data);
                    } catch (JSONException e) {
                        Log.e(TAG, "Error parsing device data JSON: " + e.getMessage());
                    }
                }
                return START_STICKY;
            } else if ("UPDATE_DEVICE_NOTIFICATION".equals(action)) {
                Log.d(TAG, "Received UPDATE_DEVICE_NOTIFICATION action");
                String deviceId = intent.getStringExtra("deviceId");
                String dataJson = intent.getStringExtra("data");
                if (deviceId != null) {
                    // If service is not running, start it first
                    if (!isServiceRunning) {
                        Log.d(TAG, "Service not running, starting foreground service first");
                        startForegroundService();
                    }
                    
                    if (dataJson != null) {
                        try {
                            JSONObject data = new JSONObject(dataJson);
                            deviceData.put(deviceId, data);
                            Log.d(TAG, "Updated device data for: " + deviceId);
                            
                            // If device is not tracked yet, add it
                            if (!deviceNotificationIds.containsKey(deviceId)) {
                                Log.d(TAG, "Device not tracked yet, adding notification for: " + deviceId);
                                addDeviceNotification(deviceId, data);
                            } else {
                                updateDeviceNotification(deviceId, deviceNotificationIds.get(deviceId));
                            }
                        } catch (JSONException e) {
                            Log.e(TAG, "Error parsing device data JSON: " + e.getMessage());
                        }
                    } else {
                        // If no data provided, just try to update existing notification
                        updateDeviceNotification(deviceId, deviceNotificationIds.get(deviceId));
                    }
                }
                return START_STICKY;
            } else if ("REMOVE_DEVICE_NOTIFICATION".equals(action)) {
                Log.d(TAG, "Received REMOVE_DEVICE_NOTIFICATION action");
                String deviceId = intent.getStringExtra("deviceId");
                if (deviceId != null) {
                    removeDeviceNotification(deviceId);
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

        // Unregister broadcast receiver
        try {
            unregisterReceiver(dismissalReceiver);
        } catch (IllegalArgumentException e) {
            Log.w(TAG, "Dismissal receiver not registered, skipping unregister");
        }
    }

    private void createNotificationChannel() {
        Log.d(TAG, "Creating notification channel");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "CO2 Monitoring", NotificationManager.IMPORTANCE_DEFAULT  // Use DEFAULT for better action visibility
            );
            channel.setDescription("Real-time CO2 monitoring notification with refresh actions");
            channel.setShowBadge(false);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            channel.setBypassDnd(false);
            channel.enableLights(false);
            channel.enableVibration(false); // Disable to avoid blocking
            channel.setSound(null, null); // No sound to avoid aggressive filtering

            // Ensure the channel allows lock screen interactions
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                channel.setAllowBubbles(false);
            }

            notificationManager.createNotificationChannel(channel);
            Log.d(TAG, "Notification channel created with DEFAULT importance for lock screen action visibility");
        } else {
            Log.d(TAG, "Notification channel not needed for API " + Build.VERSION.SDK_INT);
        }
    }

    private void startForegroundService() {
        Log.d(TAG, "startForegroundService called, isServiceRunning: " + isServiceRunning);
        if (!isServiceRunning) {
            try {
                Log.d(TAG, "Starting foreground service for multiple devices...");
                
                // Start with a basic service notification
                Notification serviceNotification = createServiceNotification();
                startForeground(BASE_NOTIFICATION_ID, serviceNotification);
                isServiceRunning = true;
                Log.d(TAG, "Foreground service started with service notification");
            } catch (Exception e) {
                Log.e(TAG, "Error starting foreground service: " + e.getMessage(), e);
                isServiceRunning = false;
                stopSelf();
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
        Log.d(TAG, "updateNotification called - updating all device notifications");
        if (isServiceRunning) {
            for (Map.Entry<String, Integer> entry : deviceNotificationIds.entrySet()) {
                String deviceId = entry.getKey();
                Integer notificationId = entry.getValue();
                updateDeviceNotification(deviceId, notificationId);
            }
        } else {
            Log.w(TAG, "Cannot update notifications - service not running");
        }
    }
    
    public void updateDeviceNotification(String deviceId, int notificationId) {
        Log.d(TAG, "updateDeviceNotification called for device: " + deviceId);
        if (isServiceRunning && deviceNotificationIds.containsKey(deviceId)) {
            try {
                Notification notification = createDeviceNotification(deviceId);
                if (notification != null) {
                    notificationManager.notify(notificationId, notification);
                    Log.d(TAG, "Device notification updated successfully for: " + deviceId);
                } else {
                    Log.w(TAG, "Failed to create notification for device: " + deviceId);
                }
            } catch (Exception e) {
                Log.e(TAG, "Error updating device notification for " + deviceId + ": " + e.getMessage(), e);
            }
        } else {
            Log.w(TAG, "Cannot update notification for device " + deviceId + " - service not running or device not tracked");
        }
    }
    
    public void addDeviceNotification(String deviceId, JSONObject data) {
        Log.d(TAG, "addDeviceNotification called for device: " + deviceId);
        
        // Check if we've reached the maximum number of devices
        if (deviceNotificationIds.size() >= MAX_DEVICES) {
            Log.w(TAG, "Maximum number of devices (" + MAX_DEVICES + ") reached, cannot add device: " + deviceId);
            return;
        }
        
        // Check if device already has a notification
        if (deviceNotificationIds.containsKey(deviceId)) {
            Log.d(TAG, "Device " + deviceId + " already has a notification, updating instead");
            updateDeviceNotification(deviceId, deviceNotificationIds.get(deviceId));
            return;
        }
        
        try {
            // Store device data
            deviceData.put(deviceId, data);
            
            // Assign notification ID
            int notificationId = nextNotificationId++;
            deviceNotificationIds.put(deviceId, notificationId);
            
            // Create and show notification
            Notification notification = createDeviceNotification(deviceId);
            if (notification != null) {
                notificationManager.notify(notificationId, notification);
                Log.d(TAG, "Device notification added successfully for: " + deviceId + " with ID: " + notificationId);
            } else {
                Log.w(TAG, "Failed to create notification for device: " + deviceId);
                // Clean up if notification creation failed
                deviceNotificationIds.remove(deviceId);
                deviceData.remove(deviceId);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error adding device notification for " + deviceId + ": " + e.getMessage(), e);
        }
    }
    
    public void removeDeviceNotification(String deviceId) {
        Log.d(TAG, "removeDeviceNotification called for device: " + deviceId);
        
        if (deviceNotificationIds.containsKey(deviceId)) {
            int notificationId = deviceNotificationIds.get(deviceId);
            notificationManager.cancel(notificationId);
            deviceNotificationIds.remove(deviceId);
            deviceData.remove(deviceId);
            Log.d(TAG, "Device notification removed for: " + deviceId);
            
            // If no more device notifications, stop the service
            if (deviceNotificationIds.isEmpty()) {
                Log.d(TAG, "No more device notifications, stopping service");
                stopForegroundService();
            }
        } else {
            Log.w(TAG, "Device " + deviceId + " not found in active notifications");
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

            int co2IntValue = widgetData.optInt("co2Value", 0);
            String deviceName = widgetData.optString("deviceName", "No Device");
            String deviceId = widgetData.optString("deviceId", "");
            String powerMode = widgetData.optString("powerMode", "Now");
            String batteryLevel = String.valueOf(widgetData.optInt("batteryLevel", 0));
            boolean isCharging = widgetData.optBoolean("isCharging", false);
            boolean alarmEnabled = widgetData.optBoolean("alarmEnabled", false);
            boolean vibrationEnabled = widgetData.optBoolean("vibrationEnabled", false);
            boolean isConnected = widgetData.optBoolean("isConnected", false);
            boolean isRefreshing = widgetData.optBoolean("isRefreshing", false);

            // Extract graph data
            JSONArray co2HistoryArray = widgetData.optJSONArray("co2History");
            List<Integer> co2History = parseJsonArrayToIntList(co2HistoryArray);
            int greenUpperLimit = widgetData.optInt("greenUpperLimit", 800);
            int yellowUpperLimit = widgetData.optInt("yellowUpperLimit", 1000);
            int graphMaxValue = widgetData.optInt("graphMaxValue", 1600);
            int graphMinValue = widgetData.optInt("graphMinValue", 0);

            Log.d(TAG, "Parsed data - CO2: " + co2Value + ", Device: " + deviceName + ", History: " + co2History.size() + " values");

            // Format custom timestamp
            String customTimestamp = "at " + new SimpleDateFormat("h:mm a", Locale.getDefault()).format(new Date());

            Log.d(TAG, "Custom timestamp: " + customTimestamp);
            Log.d(TAG, "Locale: " + Locale.getDefault());

            // Create open app intent
            Intent openAppIntent = new Intent(this, MainActivity.class);
            openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            // Create full screen intent for lock screen visibility
            Intent fullScreenIntent = new Intent(this, MainActivity.class);
            fullScreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

            // Create our custom expanded layout
            RemoteViews expandedLayout = createNotificationLayout(co2Value, true, powerMode, batteryLevel, isCharging, alarmEnabled, vibrationEnabled, co2History, greenUpperLimit, yellowUpperLimit, graphMaxValue, graphMinValue, deviceId, deviceName, isConnected, isRefreshing);
            RemoteViews compactLayout = createNotificationLayout(co2Value, false, powerMode, batteryLevel, isCharging, alarmEnabled, vibrationEnabled, co2History, greenUpperLimit, yellowUpperLimit, graphMaxValue, graphMinValue, deviceId, deviceName, isConnected, isRefreshing);


            // Create delete intent for dismissal detection
            Intent deleteIntent = new Intent(ACTION_NOTIFICATION_DISMISSED);
            deleteIntent.putExtra("deviceId", deviceId);
            PendingIntent deletePendingIntent = PendingIntent.getBroadcast(this, 3, deleteIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            Log.d(TAG, "Created delete intent for dismissal detection with deviceId: " + deviceId);

            // Create notification with custom layouts - clean minimal style
            Log.d(TAG, "Building clean custom notification with refresh state: " + isRefreshing);
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID).setSmallIcon(R.drawable.ic_launcher_foreground)  // Minimal transparent icon
                    .setCustomContentView(compactLayout)        // Custom compact layout
                    .setCustomBigContentView(expandedLayout).setOngoing(true)                          // Allow dismissal to trigger delete intent
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT).setVisibility(NotificationCompat.VISIBILITY_PUBLIC).setCategory(NotificationCompat.CATEGORY_SERVICE).setContentIntent(openAppPendingIntent).setAutoCancel(false).setShowWhen(true)                         // Show system timestamp
                    .setOnlyAlertOnce(true).setLocalOnly(false).setDefaults(0).setContentText(customTimestamp).setContentTitle(null).setSilent(co2IntValue < greenUpperLimit).setDeleteIntent(deletePendingIntent);  // Add delete intent for dismissal detection

            // Open website action
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://airspothealth.com"));
            PendingIntent refreshPendingIntent = PendingIntent.getActivity(this, 1, browserIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            builder.addAction(R.drawable.ic_refresh, "Open Website", refreshPendingIntent);

            Log.d(TAG, "Custom expanded notification built successfully");
            return builder.build();

        } catch (JSONException e) {
            Log.e(TAG, "Error parsing notification data: " + e.getMessage());
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error creating notification: " + e.getMessage(), e);
        }
        return null;
    }

    private Notification createFallbackNotification() {
        Log.d(TAG, "Creating fallback notification");

        // Create open app intent
        Intent openAppIntent = new Intent(this, MainActivity.class);
        openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        // Create a simple fallback notification
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID).setSmallIcon(R.drawable.ic_launcher_foreground).setContentTitle("AirSpot CO2 Monitor").setContentText("CO2 monitoring active").setOngoing(true).setPriority(NotificationCompat.PRIORITY_MAX).setVisibility(NotificationCompat.VISIBILITY_PUBLIC).setCategory(NotificationCompat.CATEGORY_SERVICE).setContentIntent(openAppPendingIntent).setAutoCancel(false).setShowWhen(false).setOnlyAlertOnce(true).setLocalOnly(false).setDefaults(0);

        return builder.build();
    }
    
    private Notification createServiceNotification() {
        Log.d(TAG, "createServiceNotification called");
        
        // Create open app intent
        Intent openAppIntent = new Intent(this, MainActivity.class);
        openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        
        // Create a simple service notification
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_launcher_foreground)
                .setContentTitle("AirSpot CO2 Monitor")
                .setContentText("Monitoring multiple devices")
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setContentIntent(openAppPendingIntent)
                .setAutoCancel(false)
                .setShowWhen(false)
                .setOnlyAlertOnce(true)
                .setLocalOnly(false)
                .setDefaults(0);
        
        return builder.build();
    }
    
    private Notification createDeviceNotification(String deviceId) {
        Log.d(TAG, "createDeviceNotification called for device: " + deviceId);
        
        JSONObject deviceDataObj = deviceData.get(deviceId);
        if (deviceDataObj == null) {
            Log.w(TAG, "No data found for device: " + deviceId);
            return createFallbackNotification();
        }
        
        try {
            // Extract data with fallbacks
            String co2Value = String.valueOf(deviceDataObj.optInt("co2Value", 0));
            if (co2Value.equals("0")) co2Value = "----";
            
            int co2IntValue = deviceDataObj.optInt("co2Value", 0);
            String deviceName = deviceDataObj.optString("deviceName", "AirSpot Device");
            String powerMode = deviceDataObj.optString("powerMode", "Now");
            String batteryLevel = String.valueOf(deviceDataObj.optInt("batteryLevel", 0));
            boolean isCharging = deviceDataObj.optBoolean("isCharging", false);
            boolean alarmEnabled = deviceDataObj.optBoolean("alarmEnabled", false);
            boolean vibrationEnabled = deviceDataObj.optBoolean("vibrationEnabled", false);
            boolean isConnected = deviceDataObj.optBoolean("isConnected", true);
            boolean isRefreshing = deviceDataObj.optBoolean("isRefreshing", false);
            
            // Parse CO2 history
            List<Integer> co2History = new ArrayList<>();
            JSONArray historyArray = deviceDataObj.optJSONArray("co2History");
            if (historyArray != null) {
                for (int i = 0; i < historyArray.length(); i++) {
                    co2History.add(historyArray.optInt(i, 0));
                }
            }
            
            int greenUpperLimit = deviceDataObj.optInt("greenUpperLimit", 1000);
            int yellowUpperLimit = deviceDataObj.optInt("yellowUpperLimit", 1200);
            int graphMaxValue = deviceDataObj.optInt("graphMaxValue", 1600);
            int graphMinValue = deviceDataObj.optInt("graphMinValue", 0);
            
            // Format custom timestamp
            String customTimestamp = "at " + new SimpleDateFormat("h:mm a", Locale.getDefault()).format(new Date());
            
            // Create open app intent
            Intent openAppIntent = new Intent(this, MainActivity.class);
            openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            
            // Create our custom expanded layout
            RemoteViews expandedLayout = createNotificationLayout(co2Value, true, powerMode, batteryLevel, isCharging, alarmEnabled, vibrationEnabled, co2History, greenUpperLimit, yellowUpperLimit, graphMaxValue, graphMinValue, deviceId, deviceName, isConnected, isRefreshing);
            RemoteViews compactLayout = createNotificationLayout(co2Value, false, powerMode, batteryLevel, isCharging, alarmEnabled, vibrationEnabled, co2History, greenUpperLimit, yellowUpperLimit, graphMaxValue, graphMinValue, deviceId, deviceName, isConnected, isRefreshing);
            
            // Create delete intent for dismissal detection
            Intent deleteIntent = new Intent(ACTION_NOTIFICATION_DISMISSED);
            deleteIntent.putExtra("deviceId", deviceId);
            PendingIntent deletePendingIntent = PendingIntent.getBroadcast(this, deviceId.hashCode(), deleteIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            
            // Create the notification
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_launcher_foreground)
                    .setContentTitle(deviceName + " - " + co2Value + " ppm")
                    .setContentText(customTimestamp)
                    .setOngoing(true)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setCategory(NotificationCompat.CATEGORY_SERVICE)
                    .setContentIntent(openAppPendingIntent)
                    .setAutoCancel(false)
                    .setShowWhen(false)
                    .setOnlyAlertOnce(true)
                    .setLocalOnly(false)
                    .setDefaults(0)
                    .setCustomBigContentView(expandedLayout)
                    .setCustomContentView(compactLayout)
                    .setDeleteIntent(deletePendingIntent);
            
            // Add refresh action
            Intent refreshIntent = new Intent(this, ForegroundNotificationService.class);
            refreshIntent.setAction("REFRESH_DATA");
            refreshIntent.putExtra("deviceId", deviceId);
            PendingIntent refreshPendingIntent = PendingIntent.getService(this, deviceId.hashCode() + 1000, refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            builder.addAction(R.drawable.ic_refresh, "Refresh", refreshPendingIntent);
            
            Log.d(TAG, "Device notification created successfully for: " + deviceId);
            return builder.build();
            
        } catch (Exception e) {
            Log.e(TAG, "Error creating device notification for " + deviceId + ": " + e.getMessage(), e);
            return createFallbackNotification();
        }
    }

    private RemoteViews createNotificationLayout(String co2Value, boolean isExpanded, String powerMode, String batteryLevel, boolean isCharging, boolean alarmEnabled, boolean vibrationEnabled, List<Integer> co2History, int greenUpperLimit, int yellowUpperLimit, int graphMaxValue, int graphMinValue, String deviceId, String deviceName, boolean isConnected, boolean isRefreshing) {
        boolean isSamsung = Build.MANUFACTURER.equalsIgnoreCase("samsung");

        int layoutId = isExpanded ? R.layout.notification_expanded : isSamsung ? R.layout.notification_compact_samsung : R.layout.notification_compact;
        RemoteViews views = new RemoteViews(getPackageName(), layoutId);

        views.setTextViewText(R.id.co2_value, co2Value);
        int co2Color = isConnected ? getColorForCO2Value(co2Value, greenUpperLimit, yellowUpperLimit) : Color.parseColor("#808080"); // Grey when disconnected
        views.setTextColor(R.id.co2_value, co2Color);

        // Set device name only for expanded layout
        if (isExpanded) {
            try {
                if (deviceName != null && !deviceName.trim().isEmpty()) {
                    views.setTextViewText(R.id.device_name, deviceName);
                    views.setViewVisibility(R.id.device_name, android.view.View.VISIBLE);
                } else {
                    views.setViewVisibility(R.id.device_name, android.view.View.GONE);
                }
            } catch (Exception e) {
                Log.d(TAG, "Device name TextView not found in expanded layout: " + e.getMessage());
            }
        }

        if (isRefreshing && isConnected) {
            Log.d(TAG, "Setting refresh animation VISIBLE for " + (isExpanded ? "expanded" : "compact") + " layout");
            views.setViewVisibility(R.id.progress_refresh, android.view.View.VISIBLE);
            views.setViewVisibility(R.id.ic_refresh, android.view.View.GONE);
        } else {
            Log.d(TAG, "Setting refresh animation GONE for " + (isExpanded ? "expanded" : "compact") + " layout");
            views.setViewVisibility(R.id.progress_refresh, android.view.View.GONE);
            views.setViewVisibility(R.id.ic_refresh, android.view.View.VISIBLE);
        }

        int batteryPercentage = Integer.parseInt(batteryLevel);
        views.setImageViewResource(R.id.battery_icon, getBatteryIconResource(batteryPercentage, isCharging));
        String batteryText = isCharging ? "CHG" : batteryLevel + "%";
        views.setTextViewText(R.id.battery, batteryText);

        views.setTextViewText(R.id.power_mode, powerMode);

        views.setImageViewResource(R.id.vibrate_mode, vibrationEnabled ? R.drawable.ic_vibrate_on : R.drawable.ic_vibrate_off);
        views.setImageViewResource(R.id.alarm_mode, alarmEnabled ? R.drawable.ic_alarm_on : R.drawable.ic_alarm_off);

        // Add refresh functionality directly in the UI
        Intent refreshIntent = new Intent(this, ForegroundNotificationService.class);
        refreshIntent.setAction("REFRESH_DATA");
        PendingIntent refreshPendingIntent = PendingIntent.getService(this, 2, refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        if (isConnected && !isRefreshing) {
            // Show refresh icon when connected (set appropriate resource for layout)
            views.setImageViewResource(R.id.ic_refresh, R.drawable.refresh_button_dark);

            // Add refresh click to the refresh icon
            try {
                views.setOnClickPendingIntent(R.id.ic_refresh, refreshPendingIntent);
            } catch (Exception e) {
                Log.d(TAG, "Refresh icon not found in layout, trying alternative: " + e.getMessage());
            }
        } else if (!isConnected) {
            // Show disconnected icon when not connected
            views.setImageViewResource(R.id.ic_refresh, R.drawable.ic_bt_off);
            // Remove click action for disconnected state
            try {
                views.setOnClickPendingIntent(R.id.ic_refresh, null);
            } catch (Exception e) {
                Log.d(TAG, "Error removing click action from disconnect icon: " + e.getMessage());
            }
        } else {
            // Show disabled icon when refreshing
            views.setImageViewResource(R.id.ic_refresh, R.drawable.ic_bt_off);
        }

        // Add click actions to map and graph icons
        // Map icon click action - deep link into app for secure handoff
        Intent mapIntent = new Intent(this, MainActivity.class);
        mapIntent.setData(Uri.parse("airspothealth://map-handoff?deviceId=" + deviceId));
        mapIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent mapPendingIntent = PendingIntent.getActivity(this, 102, mapIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.ic_map, mapPendingIntent);

        // Graph icon click action - deep link to graph with notification flag
        Intent graphIntent = new Intent(this, MainActivity.class);
        graphIntent.setData(Uri.parse("airspothealth://devices/" + deviceId + "/graph?from=notification"));
        graphIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent graphPendingIntent = PendingIntent.getActivity(this, 101, graphIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.ic_graph, graphPendingIntent);

        // Open Website action button (only available in expanded layout)
        if (isExpanded) {
            try {
                Intent websiteIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://airspothealth.com"));
                PendingIntent websitePendingIntent = PendingIntent.getActivity(this, 102, websiteIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                views.setOnClickPendingIntent(R.id.txt_open_website, websitePendingIntent);
            } catch (Exception e) {
                Log.d(TAG, "Open Website action not found in expanded layout, skipping: " + e.getMessage());
            }
        }

        // Create and set graph (using appropriate ID for layout)
        if (!co2History.isEmpty() && !(isSamsung && !isExpanded)) {
            Bitmap graphBitmap = generateCo2GraphBitmap(co2History, greenUpperLimit, yellowUpperLimit, graphMaxValue, graphMinValue);
            views.setImageViewBitmap(R.id.co2_graph, graphBitmap);
        }

        return views;
    }

    private int getBatteryIconResource(int batteryPercentage, boolean isCharging) {
        if (isCharging) {
            return R.drawable.battery_100percent_bolt; // Charging icon
        } else if (batteryPercentage >= 90) {
            return R.drawable.battery_100percent; // Full battery
        } else if (batteryPercentage >= 50) {
            return R.drawable.battery_75percent; // Half battery
        } else if (batteryPercentage >= 20) {
            return R.drawable.battery_25percent; // Low battery
        } else {
            return R.drawable.battery_0percent; // Empty battery
        }
    }

    private Bitmap generateCo2GraphBitmap(List<Integer> co2History, int greenUpperLimit, int yellowUpperLimit, int graphMaxValue, int graphMinValue) {
        // Reuse the same graph generation logic from Co2ValueWidget
        float density = getResources().getDisplayMetrics().density;
        int width = (int) (320 * density);  // Slightly wider for notification
        int height = (int) (60 * density);
        int padding = (int) (4 * density);

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

            // Calculate bar position - align bars to the right side
            // For example: if maxBars=5, bars appear at positions 35,36,37,38,39 (rightmost)
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

    private void sendDismissalEventToFlutter(String deviceId) {
        Intent broadcastIntent = new Intent("com.air.spot.airspothealth.LIVE_ACTIVITY_DISMISSED");
        if (deviceId != null) {
            broadcastIntent.putExtra("deviceId", deviceId);
        }
        sendBroadcast(broadcastIntent);
        Log.d(TAG, "Dismissal event sent to Flutter via broadcast for device: " + deviceId);

        // Stop the service when notification is dismissed to avoid system killing it
        Log.d(TAG, "Stopping foreground service due to notification dismissal");
        stopForegroundService();
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
    
    public static void addDeviceNotification(Context context, String deviceId, Map<String, Object> data) {
        Intent intent = new Intent(context, ForegroundNotificationService.class);
        intent.setAction("ADD_DEVICE_NOTIFICATION");
        intent.putExtra("deviceId", deviceId);
        intent.putExtra("data", new JSONObject(data).toString());
        context.startService(intent);
    }
    
    public static void updateDeviceNotification(Context context, String deviceId, Map<String, Object> data) {
        Intent intent = new Intent(context, ForegroundNotificationService.class);
        intent.setAction("UPDATE_DEVICE_NOTIFICATION");
        intent.putExtra("deviceId", deviceId);
        if (data != null) {
            try {
                JSONObject jsonData = new JSONObject(data);
                intent.putExtra("data", jsonData.toString());
            } catch (Exception e) {
                Log.e(TAG, "Error converting data to JSON: " + e.getMessage());
            }
        }
        context.startService(intent);
    }
    
    public static void removeDeviceNotification(Context context, String deviceId) {
        Intent intent = new Intent(context, ForegroundNotificationService.class);
        intent.setAction("REMOVE_DEVICE_NOTIFICATION");
        intent.putExtra("deviceId", deviceId);
        context.startService(intent);
    }

}
