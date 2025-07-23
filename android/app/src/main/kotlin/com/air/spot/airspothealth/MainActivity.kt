package com.air.spot.airspothealth

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context.RECEIVER_EXPORTED
import android.os.Build
import androidx.annotation.RequiresApi

class MainActivity: FlutterActivity() {
    
    private val CHANNEL = "liveActivityChannel"
    private val TAG = "MainActivity"
    
    // Add BroadcastReceiver for refresh
    private val refreshReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: android.content.Context?, intent: android.content.Intent?) {
            Log.d(TAG, "Received REFRESH_DATA broadcast in MainActivity")
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                .invokeMethod("onRefreshRequested", null)
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLiveActivity" -> {
                    // Start Android foreground notification service
                    startForegroundNotificationService()
                    result.success(null)
                }
                "updateLiveActivity" -> {
                    // Update Android foreground notification
                    updateForegroundNotificationService()
                    result.success(null)
                }
                "endLiveActivity" -> {
                    // Stop Android foreground notification service
                    stopForegroundNotificationService()
                    result.success(null)
                }
                "isLiveActivityActive" -> {
                    // Check if notification service is running
                    val isActive = isNotificationServiceRunning()
                    result.success(isActive)
                }
                "resetDismissalState" -> {
                    // Android doesn't need dismissal state reset
                    result.success(null)
                }
                "wasUserDismissedThisSession" -> {
                    // Android persistent notifications don't get dismissed the same way
                    result.success(false)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }
    
    override fun onResume() {
        super.onResume()
        handleDeepLink(intent)
    }
    
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Register the refresh broadcast receiver
        val filter = android.content.IntentFilter("com.air.spot.airspothealth.REFRESH_DATA")
        registerReceiver(refreshReceiver, filter, RECEIVER_EXPORTED)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(refreshReceiver)
    }
    
    private fun handleDeepLink(intent: Intent?) {
        intent?.data?.let { uri ->
            Log.d(TAG, "Received deep link: $uri")
            
            when {
                // Handle refresh requests
                uri.scheme == "airspothealthapp" && uri.host == "refresh" -> {
                    Log.d(TAG, "Received refresh request from notification/widget")
                    // Notify Flutter about the refresh request
                    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                        .invokeMethod("onRefreshRequested", null)
                }
                
                // Handle graph navigation
                uri.scheme == "airspothealth" && uri.path?.contains("/graph") == true -> {
                    Log.d(TAG, "Received graph request from notification: ${uri.path}")
                    // Extract device ID and notify Flutter to navigate to graph
                    val deviceId = uri.pathSegments?.getOrNull(1) // devices/{deviceId}/graph
                    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                        .invokeMethod("onGraphRequested", mapOf("deviceId" to deviceId))
                }

                // Handle map redirect
                uri.scheme == "airspothealth" && uri.host == "open_map" -> {
                    Log.d(TAG, "Received map request from notification/widget")
                    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                        .invokeMethod("onMapRequested", null)
                }
                
                else -> {
                    Log.d(TAG, "Unhandled deep link: $uri")
                }
            }
        }
    }
    
    private fun startForegroundNotificationService() {
        try {
            Log.d(TAG, "Starting foreground notification service")
            ForegroundNotificationService.startService(this)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting foreground notification service: ${e.message}")
        }
    }
    
    private fun updateForegroundNotificationService() {
        try {
            Log.d(TAG, "Updating foreground notification service: ${isNotificationServiceRunning()}")
            if (isNotificationServiceRunning()) {
                ForegroundNotificationService.updateService(this)
            } else {
                startForegroundNotificationService()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating foreground notification service: ${e.message}")
        }
    }
    
    private fun stopForegroundNotificationService() {
        try {
            Log.d(TAG, "Stopping foreground notification service")
            ForegroundNotificationService.stopService(this)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping foreground notification service: ${e.message}")
        }
    }
    
    private fun isNotificationServiceRunning(): Boolean {
        return ForegroundNotificationService.isServiceRunning(this)
    }
}
