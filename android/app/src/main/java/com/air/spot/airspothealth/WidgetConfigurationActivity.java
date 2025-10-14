package com.air.spot.airspothealth;

import android.app.Activity;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.cardview.widget.CardView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import es.antonborri.home_widget.HomeWidgetPlugin;

/**
 * The configuration screen for CO2 monitoring widgets.
 * Allows users to select which device to display in the widget.
 */
public class WidgetConfigurationActivity extends Activity {
    
    private static final String TAG = "WidgetConfig";
    private static final String PREFS_NAME = "com.air.spot.airspothealth.widget_prefs";
    private static final String PREF_PREFIX_KEY = "widget_device_";
    
    private int appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;
    private ListView deviceListView;
    private List<DeviceInfo> availableDevices;
    private CardView previewCard;
    private TextView previewDeviceName;
    private TextView previewCo2Value;
    private TextView previewStatus;
    private Button confirmButton;
    private DeviceInfo selectedDevice = null;
    
    private static class DeviceInfo {
        String deviceId;
        String deviceName;
        boolean isConnected;
        
        DeviceInfo(String deviceId, String deviceName, boolean isConnected) {
            this.deviceId = deviceId;
            this.deviceName = deviceName;
            this.isConnected = isConnected;
        }
        
        @Override
        public String toString() {
            return deviceName + (isConnected ? " (Connected)" : " (Disconnected)");
        }
    }
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Set the result to CANCELED. This will cause the widget host to cancel
        // out of the widget placement if the user presses the back button.
        setResult(RESULT_CANCELED);
        
        setContentView(R.layout.widget_configuration_activity);
        
        // Find the widget id from the intent
        Intent intent = getIntent();
        Bundle extras = intent.getExtras();
        if (extras != null) {
            appWidgetId = extras.getInt(
                    AppWidgetManager.EXTRA_APPWIDGET_ID,
                    AppWidgetManager.INVALID_APPWIDGET_ID);
        }
        
        // If this activity was started with an intent without an app widget ID, finish with an error.
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            Log.e(TAG, "Invalid widget ID");
            finish();
            return;
        }
        
        deviceListView = findViewById(R.id.device_list);
        previewCard = findViewById(R.id.preview_card);
        previewDeviceName = findViewById(R.id.preview_device_name);
        previewCo2Value = findViewById(R.id.preview_co2_value);
        previewStatus = findViewById(R.id.preview_status);
        confirmButton = findViewById(R.id.confirm_button);
        
        // Setup confirm button click listener
        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (selectedDevice != null) {
                    configureWidget(selectedDevice.deviceId, selectedDevice.deviceName);
                }
            }
        });
        
        // Load available devices
        loadAvailableDevices();
    }
    
    private void loadAvailableDevices() {
        availableDevices = new ArrayList<>();
        
        try {
            // First try to get device list (includes ALL saved devices with aliases)
            String deviceListJson = HomeWidgetPlugin.Companion.getData(this)
                    .getString("widget_device_list", "[]");
            
            Log.d(TAG, "Loading devices from widget_device_list: " + deviceListJson);
            
            // Get device data to check connection status
            String devicesDataJson = HomeWidgetPlugin.Companion.getData(this)
                    .getString("widget_devices_data", "{}");
            JSONObject devicesData = new JSONObject(devicesDataJson);
            
            if (deviceListJson.isEmpty() || deviceListJson.equals("[]")) {
                Log.w(TAG, "No device list found, falling back to widget_devices_data");
                // Fallback to device data
                if (devicesDataJson.isEmpty() || devicesDataJson.equals("{}")) {
                    showNoDevicesMessage();
                    return;
                }
                
                // Parse devices from data
                Iterator<String> keys = devicesData.keys();
                while (keys.hasNext()) {
                    String deviceId = keys.next();
                    JSONObject deviceData = devicesData.getJSONObject(deviceId);
                    String deviceName = deviceData.optString("deviceName", "Unknown Device");
                    boolean isConnected = deviceData.optBoolean("isConnected", false);
                    availableDevices.add(new DeviceInfo(deviceId, deviceName, isConnected));
                    Log.d(TAG, "Added device from data: " + deviceName + " (" + deviceId + ")");
                }
            } else {
                // Parse device list (preferred, includes aliases)
                JSONArray deviceList = new JSONArray(deviceListJson);
                for (int i = 0; i < deviceList.length(); i++) {
                    JSONObject device = deviceList.getJSONObject(i);
                    String deviceId = device.getString("deviceId");
                    String deviceName = device.getString("deviceName"); // This is alias ?? name
                    
                    // Check if device has data and is connected
                    boolean isConnected = false;
                    if (devicesData.has(deviceId)) {
                        JSONObject deviceData = devicesData.getJSONObject(deviceId);
                        isConnected = deviceData.optBoolean("isConnected", false);
                    }
                    
                    availableDevices.add(new DeviceInfo(deviceId, deviceName, isConnected));
                    Log.d(TAG, "Added device: " + deviceName + " (" + deviceId + ") - Connected: " + isConnected);
                }
            }
            
            if (availableDevices.isEmpty()) {
                showNoDevicesMessage();
                return;
            }
            
            // If only one device, auto-configure it
            if (availableDevices.size() == 1) {
                Log.d(TAG, "Only one device available, auto-configuring");
                DeviceInfo device = availableDevices.get(0);
                configureWidget(device.deviceId, device.deviceName);
                return;
            }
            
            // Multiple devices - show selection UI
            showDeviceSelectionList();
            
        } catch (JSONException e) {
            Log.e(TAG, "Error parsing device data", e);
            showNoDevicesMessage();
        }
    }
    
    private void showNoDevicesMessage() {
        TextView messageView = findViewById(R.id.no_devices_message);
        messageView.setVisibility(View.VISIBLE);
        deviceListView.setVisibility(View.GONE);
        
        // Auto-finish after showing message
        messageView.postDelayed(() -> {
            Toast.makeText(this, "Please connect a device first", Toast.LENGTH_LONG).show();
            finish();
        }, 2000);
    }
    
    private void showDeviceSelectionList() {
        TextView messageView = findViewById(R.id.no_devices_message);
        messageView.setVisibility(View.GONE);
        deviceListView.setVisibility(View.VISIBLE);
        
        // Create adapter for device list
        ArrayAdapter<DeviceInfo> adapter = new ArrayAdapter<DeviceInfo>(
                this,
                android.R.layout.simple_list_item_1,
                availableDevices) {
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                View view = super.getView(position, convertView, parent);
                TextView textView = view.findViewById(android.R.id.text1);
                DeviceInfo device = getItem(position);
                if (device != null) {
                    textView.setText(device.toString());
                    textView.setTextSize(18);
                    textView.setPadding(32, 32, 32, 32);
                }
                return view;
            }
        };
        
        deviceListView.setAdapter(adapter);
        deviceListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                selectedDevice = availableDevices.get(position);
                Log.d(TAG, "Device tapped: " + selectedDevice.deviceName + " (" + selectedDevice.deviceId + ")");
                showPreview(selectedDevice);
            }
        });
    }
    
    private void showPreview(DeviceInfo device) {
        try {
            // Load device data from multi-device payload
            String allDevicesJson = HomeWidgetPlugin.Companion.getData(this)
                    .getString("widget_devices_data", "{}");
            JSONObject allDevices = new JSONObject(allDevicesJson);
            
            if (allDevices.has(device.deviceId)) {
                JSONObject deviceData = allDevices.getJSONObject(device.deviceId);
                
                // Extract data
                int co2Value = deviceData.optInt("co2Value", 0);
                boolean isConnected = deviceData.optBoolean("isConnected", false);
                
                // Update preview UI
                previewDeviceName.setText(device.deviceName);
                
                if (co2Value > 0) {
                    previewCo2Value.setText(co2Value + " ppm");
                    
                    // Color based on CO2 level
                    int color;
                    if (co2Value <= 800) {
                        color = Color.parseColor("#4CAF50"); // Green
                    } else if (co2Value <= 1000) {
                        color = Color.parseColor("#FF9800"); // Orange
                    } else {
                        color = Color.parseColor("#F44336"); // Red
                    }
                    previewCo2Value.setTextColor(color);
                    previewStatus.setTextColor(color);
                } else {
                    previewCo2Value.setText("----");
                    previewCo2Value.setTextColor(Color.GRAY);
                    previewStatus.setTextColor(Color.GRAY);
                }
                
                previewStatus.setText(isConnected ? "●" : "○");
                
                // Show preview card and enable confirm button
                previewCard.setVisibility(View.VISIBLE);
                confirmButton.setVisibility(View.VISIBLE);
                confirmButton.setEnabled(true);
                
            } else {
                Log.w(TAG, "Device data not found for preview");
            }
        } catch (JSONException e) {
            Log.e(TAG, "Error loading preview data", e);
        }
    }
    
    private void configureWidget(String deviceId, String deviceName) {
        // Save the device ID for this widget instance
        saveDeviceIdPref(this, appWidgetId, deviceId);
        
        // Update the widget
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(this);
        updateWidgetForType(this, appWidgetManager, appWidgetId);
        
        // Make sure we pass back the original appWidgetId
        Intent resultValue = new Intent();
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        setResult(RESULT_OK, resultValue);
        
        Toast.makeText(this, "Widget configured for " + deviceName, Toast.LENGTH_SHORT).show();
        finish();
    }
    
    /**
     * Update the widget based on its type
     */
    private static void updateWidgetForType(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        // Try to determine which widget type this is by checking the provider
        String providerClass = appWidgetManager.getAppWidgetInfo(appWidgetId)
                .provider.getClassName();
        
        Log.d(TAG, "Updating widget of type: " + providerClass);
        
        if (providerClass.contains("Co2SmallWidget")) {
            Co2SmallWidget.updateAppWidget(context, appWidgetManager, appWidgetId);
        } else if (providerClass.contains("Co2MediumWidget")) {
            Co2MediumWidget.updateAppWidget(context, appWidgetManager, appWidgetId);
        } else if (providerClass.contains("Co2LargeWidget")) {
            Co2LargeWidget.updateAppWidget(context, appWidgetManager, appWidgetId);
        } else if (providerClass.contains("Co2ValueWidget")) {
            Co2ValueWidget.updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }
    
    /**
     * Save the device ID preference for a widget
     */
    static void saveDeviceIdPref(Context context, int appWidgetId, String deviceId) {
        SharedPreferences.Editor prefs = context.getSharedPreferences(PREFS_NAME, 0).edit();
        prefs.putString(PREF_PREFIX_KEY + appWidgetId, deviceId);
        prefs.apply();
        Log.d(TAG, "Saved device ID " + deviceId + " for widget " + appWidgetId);
    }
    
    /**
     * Load the device ID preference for a widget
     * Returns null if no device is configured
     */
    public static String loadDeviceIdPref(Context context, int appWidgetId) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, 0);
        String deviceId = prefs.getString(PREF_PREFIX_KEY + appWidgetId, null);
        Log.d(TAG, "Loaded device ID " + deviceId + " for widget " + appWidgetId);
        return deviceId;
    }
    
    /**
     * Delete the device ID preference for a widget
     */
    static void deleteDeviceIdPref(Context context, int appWidgetId) {
        SharedPreferences.Editor prefs = context.getSharedPreferences(PREFS_NAME, 0).edit();
        prefs.remove(PREF_PREFIX_KEY + appWidgetId);
        prefs.apply();
        Log.d(TAG, "Deleted device ID preference for widget " + appWidgetId);
    }
}

