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
          // _buildPopupMenuItem(
          //     'Zoom Slider',
          //     settings.showZoomSlider,
          //     () => ref.read(graphSettingsProvider.notifier).setSettings(
          //         settings.copyWith(showZoomSlider: !settings.showZoomSlider))),
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
          _buildPopupMenuItem(
            'Breath Percentage',
            settings.breathPercentageDisplayMode ==
                    BreathPercentageDisplayMode.percentage ||
                settings.breathPercentageDisplayMode ==
                    BreathPercentageDisplayMode.both,
            () => _toggleBreathPercentageMode(
                settings, ref, BreathPercentageDisplayMode.percentage),
          ),
          _buildPopupMenuItem(
            'Breath 1 in X',
            settings.breathPercentageDisplayMode ==
                    BreathPercentageDisplayMode.oneInX ||
                settings.breathPercentageDisplayMode ==
                    BreathPercentageDisplayMode.both,
            () => _toggleBreathPercentageMode(
                settings, ref, BreathPercentageDisplayMode.oneInX),
          ),
        ];
      },
    );
  }

  void _toggleBreathPercentageMode(
      GraphSettings settings, WidgetRef ref, BreathPercentageDisplayMode mode) {
    BreathPercentageDisplayMode newMode;

    if (mode == BreathPercentageDisplayMode.percentage) {
      if (settings.breathPercentageDisplayMode ==
          BreathPercentageDisplayMode.percentage) {
        newMode = BreathPercentageDisplayMode.none;
      } else if (settings.breathPercentageDisplayMode ==
          BreathPercentageDisplayMode.oneInX) {
        newMode = BreathPercentageDisplayMode.both;
      } else if (settings.breathPercentageDisplayMode ==
          BreathPercentageDisplayMode.both) {
        newMode = BreathPercentageDisplayMode.oneInX;
      } else {
        newMode = BreathPercentageDisplayMode.percentage;
      }
    } else {
      // oneInX
      if (settings.breathPercentageDisplayMode ==
          BreathPercentageDisplayMode.oneInX) {
        newMode = BreathPercentageDisplayMode.none;
      } else if (settings.breathPercentageDisplayMode ==
          BreathPercentageDisplayMode.percentage) {
        newMode = BreathPercentageDisplayMode.both;
      } else if (settings.breathPercentageDisplayMode ==
          BreathPercentageDisplayMode.both) {
        newMode = BreathPercentageDisplayMode.percentage;
      } else {
        newMode = BreathPercentageDisplayMode.oneInX;
      }
    }

    ref.read(graphSettingsProvider.notifier).setSettings(
          settings.copyWith(breathPercentageDisplayMode: newMode),
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
