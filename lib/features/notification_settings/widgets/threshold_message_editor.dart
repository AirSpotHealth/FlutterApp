import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThresholdMessageEditor extends ConsumerStatefulWidget {
  final String deviceId;
  final NotificationThreshold threshold;
  final int thresholdIndex;

  const ThresholdMessageEditor({
    super.key,
    required this.deviceId,
    required this.threshold,
    required this.thresholdIndex,
  });

  @override
  ConsumerState<ThresholdMessageEditor> createState() =>
      _ThresholdMessageEditorState();
}

class _ThresholdMessageEditorState
    extends ConsumerState<ThresholdMessageEditor> {
  late TextEditingController _messageController;
  late FocusNode _focusNode;
  late Color _primaryColor;

  @override
  void initState() {
    super.initState();
    _messageController =
        TextEditingController(text: widget.threshold.message ?? '');
    _focusNode = FocusNode();

    // Request focus after a short delay to ensure smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture theme color during didChangeDependencies to avoid accessing it during disposal
    _primaryColor = Theme.of(context).primaryColor;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSave() {
    ref
        .read(notificationPreferencesProvider(widget.deviceId).notifier)
        .updateThreshold(
          widget.thresholdIndex,
          widget.threshold.copyWith(
            message: _messageController.text.isEmpty
                ? null
                : _messageController.text,
          ),
        );

    if (mounted) {
      Navigator.pop(context);
      context.showSnackBar('Message updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Custom Alert Message',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Customize the notification message for ${widget.threshold.co2Threshold} ppm',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),

            const SizedBox(height: 24),

            // Text Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                onChanged: (value) {
                  // Update UI to show/hide clear button
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText: 'e.g., High CO₂ detected!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.notifications_active),
                  suffixIcon: _messageController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _messageController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                maxLength: 100,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Message',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom padding
            SizedBox(
              height: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 24,
            ),
          ],
        ),
      ),
    );
  }
}
