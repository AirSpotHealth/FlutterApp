import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceAliasEditor extends ConsumerStatefulWidget {
  final String deviceId;
  final String? currentAlias;

  const DeviceAliasEditor({
    super.key,
    required this.deviceId,
    this.currentAlias,
  });

  @override
  ConsumerState<DeviceAliasEditor> createState() => _DeviceAliasEditorState();
}

class _DeviceAliasEditorState extends ConsumerState<DeviceAliasEditor> {
  late TextEditingController _aliasController;
  late FocusNode _focusNode;
  late Color _primaryColor;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.currentAlias ?? '');
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
    _aliasController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final alias = _aliasController.text.trim();

    if (alias.isEmpty) {
      context.showSnackBar('Please enter a nickname');
      return;
    }

    ref
        .read(bleSavedDevicesProvider.notifier)
        .updateDeviceAlias(widget.deviceId, alias);

    if (mounted) {
      Navigator.pop(context);
      context.showSnackBar('Nickname updated successfully');
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
                'Change Device Nickname',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Give your device a memorable name',
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
                controller: _aliasController,
                focusNode: _focusNode,
                onChanged: (value) {
                  // Update UI to show/hide clear button
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'e.g., Living Room, Office',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                  suffixIcon: _aliasController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _aliasController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
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
                        'Save Nickname',
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
