/// Issue type enum for categorizing reports
enum IssueType {
  device,
  app;

  String get displayName {
    switch (this) {
      case IssueType.device:
        return 'Device Issue';
      case IssueType.app:
        return 'App Issue';
    }
  }

  String get apiValue => name;
}

/// Model representing an issue report to be submitted
class IssueReport {
  final IssueType issueType;
  final String description;
  final String? attachmentPath;

  // Auto-collected metadata
  final String? appVersion;
  final String? platform;
  final String? deviceModel;
  final String? osVersion;

  // Device-specific info (when issueType is device)
  final String? airspotDeviceId;
  final String? firmwareVersion;

  // Device diagnostics (auto-collected when device is selected)
  final Map<String, dynamic>? deviceDiagnostics;

  // User info
  final String? userId;
  final String? userEmail;

  const IssueReport({
    required this.issueType,
    required this.description,
    this.attachmentPath,
    this.appVersion,
    this.platform,
    this.deviceModel,
    this.osVersion,
    this.airspotDeviceId,
    this.firmwareVersion,
    this.deviceDiagnostics,
    this.userId,
    this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'issue_type': issueType.apiValue,
      'description': description,
      if (appVersion != null) 'app_version': appVersion,
      if (platform != null) 'platform': platform,
      if (deviceModel != null) 'device_model': deviceModel,
      if (osVersion != null) 'os_version': osVersion,
      if (airspotDeviceId != null) 'airspot_device_id': airspotDeviceId,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (deviceDiagnostics != null) 'device_diagnostics': deviceDiagnostics,
      if (userId != null) 'user_id': userId,
      if (userEmail != null) 'user_email': userEmail,
    };
  }

  IssueReport copyWith({
    IssueType? issueType,
    String? description,
    String? attachmentPath,
    String? appVersion,
    String? platform,
    String? deviceModel,
    String? osVersion,
    String? airspotDeviceId,
    String? firmwareVersion,
    Map<String, dynamic>? deviceDiagnostics,
    String? userId,
    String? userEmail,
  }) {
    return IssueReport(
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      airspotDeviceId: airspotDeviceId ?? this.airspotDeviceId,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      deviceDiagnostics: deviceDiagnostics ?? this.deviceDiagnostics,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
