# Honor/Huawei Lock Screen Notification Troubleshooting

## Current Issue

Notifications appear in the notification panel but do not show on the lock screen despite app notification settings being configured correctly.

## Honor/Huawei Specific Settings to Check

### 1. Lock Screen Notifications

**Path:** Settings → Notifications & status bar → Lock screen notifications

- Set to **"Show all notifications"** (NOT "Hide all" or "Hide sensitive content")
- Alternative path: Settings → Privacy & security → Lock screen & passwords → Lock screen notifications

### 2. Phone Manager / Optimizer

**Path:** Phone Manager app → Protected apps

- Find **"AirSpot Health"**
- Enable/toggle it ON
- This prevents system from killing the foreground service

### 3. Battery Optimization (Critical)

**Path:** Settings → Battery → App launch

- Find **"AirSpot Health"**
- Tap on it and select **"Manage manually"**
- Enable ALL three options:
  - ✅ Auto-launch
  - ✅ Secondary launch
  - ✅ Run in background

### 4. Advanced App Notifications

**Path:** Settings → Apps → AirSpot Health → Notifications

- ✅ Allow notifications
- ✅ Lock screen (enable this specifically)
- Set **Behavior** to **"Make sound and pop on screen"**
- ✅ Override Do Not Disturb
- ✅ Show on top

### 5. EMUI/Magic UI Power Settings

**Path:** Settings → Apps → AirSpot Health → Battery

- Set **Power-intensive prompt** to **"Allow"**
- Set **Keep running after screen off** to **"Allow"**
- Disable **Power saving mode** if active

### 6. Additional Honor Settings

**Path:** Settings → Apps → AirSpot Health → Permissions

- Check that **"Display pop-up windows while running in background"** is enabled

### 7. System-Level Settings

**Path:** Settings → Display & brightness → Sleep

- Check if **"Lift to wake"** or **"Tap to wake"** are enabled (helps see notifications)

## Testing Steps

1. **Connect your Honor device and run the app:**

   ```bash
   flutter run
   ```

2. **Enable the notification** from the same button as iOS Live Activity

3. **Lock your screen immediately** after enabling

4. **Look for both notifications:**

   - Test notification: "AirSpot CO2: 850 ppm" (appears briefly with sound/vibration)
   - Main notification: "AirSpot Health • [CO2 value] ppm"

5. **If still not working, try this Honor-specific ADB command:**
   ```bash
   adb shell settings put secure lock_screen_show_notifications 1
   ```

## Code Changes Made

1. **Simplified notification approach** - removed custom layouts that Honor might block
2. **Used system icons** instead of custom drawables
3. **Added ticker text** for better lock screen compatibility
4. **Reduced notification priority** from MAX to HIGH (MAX can be blocked)
5. **Added default notification sound** to channel
6. **Simplified action buttons** to reduce complexity

## If Still Not Working

Honor devices are known to be very restrictive. Consider these alternatives:

1. **Use a different notification approach** - create a simple text-only notification
2. **Request user to manually configure** all Honor settings above
3. **Add a settings screen** in the app to guide users through Honor-specific setup
4. **Consider using FCM push notifications** as they have better Honor compatibility

## Device Information Needed

Please check your device model and EMUI/Magic UI version:

- Go to Settings → About phone
- Note down:
  - Device model (e.g., Honor 20, Honor 50, etc.)
  - EMUI/Magic UI version
  - Android version

Different Honor models may have slightly different settings paths.
