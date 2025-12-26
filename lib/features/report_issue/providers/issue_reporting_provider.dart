import 'package:airspothealth/core/services/issue_reporting_service.dart';
import 'package:airspothealth/features/report_issue/models/issue_report.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Submission status for the issue reporting form
enum IssueSubmissionStatus {
  idle,
  submitting,
  success,
  error,
}

/// State for the issue reporting form
class IssueReportingState {
  final IssueType? issueType;
  final String description;
  final String? attachmentPath;
  final String? selectedDeviceId;
  final String? selectedDeviceFirmware;
  final String? contactEmail;
  final IssueSubmissionStatus status;
  final String? errorMessage;

  const IssueReportingState({
    this.issueType,
    this.description = '',
    this.attachmentPath,
    this.selectedDeviceId,
    this.selectedDeviceFirmware,
    this.contactEmail,
    this.status = IssueSubmissionStatus.idle,
    this.errorMessage,
  });

  bool get isValid =>
      issueType != null &&
      description.trim().isNotEmpty &&
      description.trim().length >= 10;

  IssueReportingState copyWith({
    IssueType? issueType,
    String? description,
    String? attachmentPath,
    String? selectedDeviceId,
    String? selectedDeviceFirmware,
    String? contactEmail,
    IssueSubmissionStatus? status,
    String? errorMessage,
    bool clearAttachment = false,
    bool clearDevice = false,
  }) {
    return IssueReportingState(
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      attachmentPath:
          clearAttachment ? null : (attachmentPath ?? this.attachmentPath),
      selectedDeviceId:
          clearDevice ? null : (selectedDeviceId ?? this.selectedDeviceId),
      selectedDeviceFirmware: clearDevice
          ? null
          : (selectedDeviceFirmware ?? this.selectedDeviceFirmware),
      contactEmail: contactEmail ?? this.contactEmail,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for issue reporting state
final issueReportingProvider =
    NotifierProvider<IssueReportingNotifier, IssueReportingState>(
  IssueReportingNotifier.new,
);

class IssueReportingNotifier extends Notifier<IssueReportingState> {
  @override
  IssueReportingState build() => const IssueReportingState();

  void setIssueType(IssueType type) {
    state = state.copyWith(
      issueType: type,
      clearDevice:
          type == IssueType.app, // Clear device if switching to app issue
    );
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setAttachment(String? path) {
    if (path == null) {
      state = state.copyWith(clearAttachment: true);
    } else {
      state = state.copyWith(attachmentPath: path);
    }
  }

  void setSelectedDevice(String? deviceId, String? firmware) {
    state = state.copyWith(
      selectedDeviceId: deviceId,
      selectedDeviceFirmware: firmware,
    );
  }

  void setContactEmail(String? email) {
    state = state.copyWith(contactEmail: email);
  }

  /// Pre-fill the form with sensor error details for quick reporting
  /// Technical details (error code, recovery attempts) go in deviceDiagnostics
  void prefillFromSensorError({
    required String deviceId,
    String? firmware,
    required int errorCode,
    required int recoveryAttempts,
    required String errorMessage,
  }) {
    // Simple user-friendly description
    // Technical details are already captured in deviceDiagnostics
    const description =
        'My device is showing a sensor error and is unable to read CO2 levels.';

    state = IssueReportingState(
      issueType: IssueType.device,
      description: description,
      selectedDeviceId: deviceId,
      selectedDeviceFirmware: firmware,
      status: IssueSubmissionStatus.idle,
    );
  }

  /// Reset the form to initial state
  void reset() {
    state = const IssueReportingState();
  }

  Future<void> submitIssue() async {
    if (!state.isValid) {
      state = state.copyWith(
        status: IssueSubmissionStatus.error,
        errorMessage:
            'Please fill in all required fields (minimum 10 characters)',
      );
      return;
    }

    state = state.copyWith(
      status: IssueSubmissionStatus.submitting,
      errorMessage: null,
    );

    try {
      // Collect device diagnostics if this is a device issue
      Map<String, dynamic>? diagnostics;
      if (state.issueType == IssueType.device &&
          state.selectedDeviceId != null) {
        diagnostics = IssueReportingService.instance
            .collectDeviceDiagnostics(state.selectedDeviceId!);
      }

      var report = IssueReport(
        issueType: state.issueType!,
        description: state.description.trim(),
        attachmentPath: state.attachmentPath,
        airspotDeviceId: state.selectedDeviceId,
        firmwareVersion: state.selectedDeviceFirmware,
        deviceDiagnostics: diagnostics,
        userEmail: state.contactEmail,
      );

      // Enrich with auto-collected metadata
      report = await IssueReportingService.instance.enrichWithMetadata(report);

      // Submit to API
      await IssueReportingService.instance.submitIssue(report);

      state = state.copyWith(status: IssueSubmissionStatus.success);
    } catch (e) {
      debugPrint('Error submitting issue: $e');
      state = state.copyWith(
        status: IssueSubmissionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
