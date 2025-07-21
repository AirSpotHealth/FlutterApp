package com.air.spot.airspothealth

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    
    private val CHANNEL = "liveActivityChannel"
    private val TAG = "MainActivity"
    
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
    
    private fun handleDeepLink(intent: Intent?) {
        intent?.data?.let { uri ->
            if (uri.scheme == "airspothealthapp" && uri.host == "refresh") {
                Log.d(TAG, "Received refresh request from notification/widget")
                // Notify Flutter about the refresh request
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                    .invokeMethod("onRefreshRequested", null)
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
            Log.d(TAG, "Updating foreground notification service")
            ForegroundNotificationService.updateService(this)
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
