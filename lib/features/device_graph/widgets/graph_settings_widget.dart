import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:airspothealth/features/device_graph/providers/graph_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GraphSettingsWidget extends ConsumerWidget {
  const GraphSettingsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: _buildMenuIcon(),
      color: Colors.white,
      offset: const Offset(-8, 48),
      itemBuilder: (context) {
        final GraphSettings settings = ref.read(graphSettingsProvider);

        return [
          _buildPopupMenuItem(
              'Zoom Slider',
              settings.showZoomSlider,
              () => ref.read(graphSettingsProvider.notifier).setSettings(
                  settings.copyWith(showZoomSlider: !settings.showZoomSlider))),
          _buildPopupMenuItem(
              'Area Fill',
              settings.showAreaFill,
              () => ref.read(graphSettingsProvider.notifier).setSettings(
                  settings.copyWith(showAreaFill: !settings.showAreaFill))),
          _buildPopupMenuItem(
              'Mark Lines',
              settings.showMarkLines,
              () => ref.read(graphSettingsProvider.notifier).setSettings(
                  settings.copyWith(showMarkLines: !settings.showMarkLines))),
        ];
      },
    );
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, bool value, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            color: value ? AppColors.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildMenuIcon() {
    return const Icon(
      Icons.tune,
      color: Colors.white,
      size: 24,
    );
  }
}
