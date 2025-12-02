//
//  WidgetConfigurationHelper.swift
//  LiveActivityWidget
//
//  Helper for widget configuration
//

import Foundation

// MARK: - Widget Configuration Helper
struct WidgetConfigurationHelper {
    
    static func getAvailableDevices() -> [(id: String, name: String)] {
        guard let userDefaults = UserDefaults(suiteName: "group.com.airspot.lohas") else {
            print("❌ Config Helper: Failed to access App Group")
            return []
        }
        
        // Check all UserDefaults keys for debugging
        let allKeys = Array(userDefaults.dictionaryRepresentation().keys.sorted())
        print("🔑 Config Helper: All UserDefaults keys: \(allKeys)")
        
        // Try to get device list (preferred - includes ALL devices with aliases)
        if let deviceListJson = userDefaults.string(forKey: "widget_device_list"),
           !deviceListJson.isEmpty,
           let data = deviceListJson.data(using: .utf8),
           let deviceList = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            print("✅ Config Helper: Found device_list JSON with \(deviceList.count) devices")
            
            let devices = deviceList.compactMap { dict -> (id: String, name: String)? in
                guard let deviceId = dict["deviceId"] as? String,
                      let deviceName = dict["deviceName"] as? String else {  // This is alias ?? name
                    return nil
                }
                return (id: deviceId, name: deviceName)
            }
            
            print("✅ Config Helper: Parsed \(devices.count) devices from list:")
            for device in devices {
                print("   📱 \(device.name) (ID: \(device.id))")
            }
            
            return devices
        }
        
        print("⚠️ Config Helper: No 'widget_device_list' found, falling back to widget_devices_data")
        
        // Fallback: Try to extract from widget_devices_data
        if let devicesDataJson = userDefaults.string(forKey: "widget_devices_data"),
           let data = devicesDataJson.data(using: .utf8),
           let devicesData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("✅ Config Helper: Found widget_devices_data with \(devicesData.count) devices")
            
            let devices = devicesData.compactMap { (key, value) -> (id: String, name: String)? in
                guard let deviceDict = value as? [String: Any],
                      let deviceName = deviceDict["deviceName"] as? String else {
                    return nil
                }
                print("   📱 Device: \(deviceName) (ID: \(key))")
                return (id: key, name: deviceName)
            }
            
            return devices
        }
        
        print("❌ Config Helper: No device data found")
        return []
    }
}

