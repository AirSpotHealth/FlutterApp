import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/report_issue/models/issue_report.dart';
import 'package:airspothealth/features/report_issue/providers/issue_reporting_provider.dart';
import 'package:airspothealth/features/report_issue/widgets/attachment_picker.dart';
import 'package:airspothealth/features/report_issue/widgets/description_field.dart';
import 'package:airspothealth/features/report_issue/widgets/device_selector.dart';
import 'package:airspothealth/features/report_issue/widgets/email_field.dart';
import 'package:airspothealth/features/report_issue/widgets/info_banner.dart';
import 'package:airspothealth/features/report_issue/widgets/issue_type_selector.dart';
import 'package:airspothealth/features/report_issue/widgets/section_title.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReportIssuePage extends ConsumerStatefulWidget {
  const ReportIssuePage({super.key});

  @override
  ConsumerState<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends ConsumerState<ReportIssuePage> {
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Sync controller with pre-filled state (if any)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(issueReportingProvider);
      if (state.description.isNotEmpty) {
        _descriptionController.text = state.description;
      }
      if (state.contactEmail != null) {
        _emailController.text = state.contactEmail!;
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(issueReportingProvider);
    final savedDevices = ref.watch(bleSavedDevicesProvider);

    // Listen for success/error states
    ref.listen<IssueReportingState>(issueReportingProvider, (previous, next) {
      if (next.status == IssueSubmissionStatus.success) {
        context.showSnackBar('Issue reported successfully!');
        context.pop();
      } else if (next.status == IssueSubmissionStatus.error &&
          next.errorMessage != null) {
        context.showSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Report an Issue'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const InfoBanner(
              message:
                  'Help us improve! Report any issues you encounter with the app or your AirSpot device.',
            ),
            const SizedBox(height: 24),

            // Issue Type
            const SectionTitle('Issue Type *'),
            const SizedBox(height: 8),
            IssueTypeSelector(
              value: state.issueType,
              onChanged: (value) {
                if (value != null) {
                  ref.read(issueReportingProvider.notifier).setIssueType(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Device Selector (only shown for device issues)
            if (state.issueType == IssueType.device) ...[
              const SectionTitle('Select Device'),
              const SizedBox(height: 8),
              DeviceSelector(
                devices: savedDevices,
                selectedDeviceId: state.selectedDeviceId,
                onChanged: (BleDevice? device) {
                  ref.read(issueReportingProvider.notifier).setSelectedDevice(
                        device?.deviceId,
                        device?.firmwareVersion,
                      );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Description
            const SectionTitle('Description *'),
            const SizedBox(height: 8),
            DescriptionField(
              controller: _descriptionController,
              onChanged: (value) {
                ref.read(issueReportingProvider.notifier).setDescription(value);
              },
            ),
            const SizedBox(height: 16),

            // Contact Email
            const SectionTitle('Email for Follow-up (Optional)'),
            const SizedBox(height: 8),
            EmailField(
              controller: _emailController,
              onChanged: (value) {
                ref
                    .read(issueReportingProvider.notifier)
                    .setContactEmail(value);
              },
            ),
            const SizedBox(height: 16),

            // Attachment
            const SectionTitle('Attachment (Optional)'),
            const SizedBox(height: 8),
            AttachmentPicker(
              attachmentPath: state.attachmentPath,
              onPickAttachment: _pickAttachment,
              onRemoveAttachment: () {
                ref.read(issueReportingProvider.notifier).setAttachment(null);
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            Button(
              label: 'Submit Issue',
              loading: state.status == IssueSubmissionStatus.submitting,
              onPressed: state.status == IssueSubmissionStatus.submitting
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref.read(issueReportingProvider.notifier).submitIssue();
                      }
                    },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          ref.read(issueReportingProvider.notifier).setAttachment(path);
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        context.showSnackBar('Failed to pick image');
      }
    }
  }
}
