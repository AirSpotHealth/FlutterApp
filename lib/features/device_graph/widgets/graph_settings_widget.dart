import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:airspothealth/features/device_graph/providers/graph_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GraphSettingsWidget extends ConsumerStatefulWidget {
  const GraphSettingsWidget({
    super.key,
  });

  @override
  ConsumerState<GraphSettingsWidget> createState() =>
      _GraphSettingsWidgetState();
}

class _GraphSettingsWidgetState extends ConsumerState<GraphSettingsWidget> {
  void _showMenu() async {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    // Adjust position - move down by 40px and slightly left
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition + const Offset(-8, 40),
        buttonPosition +
            button.size.bottomRight(Offset.zero) +
            const Offset(-8, 40),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<void>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: _buildMenuItems(),
      // This prevents the menu from closing when tapped
      popUpAnimationStyle: AnimationStyle.noAnimation,
    );
  }

  List<PopupMenuEntry<void>> _buildMenuItems() {
    return [
      // _buildPopupMenuItem(
      //   'Zoom Slider',
      //   () => ref.read(graphSettingsProvider).showZoomSlider,
      //   () => ref.read(graphSettingsProvider.notifier).setSettings(
      //       ref.read(graphSettingsProvider).copyWith(showZoomSlider: !ref.read(graphSettingsProvider).showZoomSlider)),
      // ),
      _buildPopupMenuItem(
        'Area Fill',
        () => ref.read(graphSettingsProvider).showAreaFill,
        () {
          final settings = ref.read(graphSettingsProvider);
          ref.read(graphSettingsProvider.notifier).setSettings(
              settings.copyWith(showAreaFill: !settings.showAreaFill));
        },
      ),
      _buildPopupMenuItem(
        'Mark Lines',
        () => ref.read(graphSettingsProvider).showMarkLines,
        () {
          final settings = ref.read(graphSettingsProvider);
          ref.read(graphSettingsProvider.notifier).setSettings(
              settings.copyWith(showMarkLines: !settings.showMarkLines));
        },
      ),
      _buildPopupMenuItem(
        'Breath Percentage',
        () {
          final settings = ref.read(graphSettingsProvider);
          return settings.breathPercentageDisplayMode ==
                  BreathPercentageDisplayMode.percentage ||
              settings.breathPercentageDisplayMode ==
                  BreathPercentageDisplayMode.both;
        },
        () {
          final settings = ref.read(graphSettingsProvider);
          _toggleBreathPercentageMode(
              settings, ref, BreathPercentageDisplayMode.percentage);
        },
      ),
      _buildPopupMenuItem(
        'Breath 1 in X',
        () {
          final settings = ref.read(graphSettingsProvider);
          return settings.breathPercentageDisplayMode ==
                  BreathPercentageDisplayMode.oneInX ||
              settings.breathPercentageDisplayMode ==
                  BreathPercentageDisplayMode.both;
        },
        () {
          final settings = ref.read(graphSettingsProvider);
          _toggleBreathPercentageMode(
              settings, ref, BreathPercentageDisplayMode.oneInX);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMenu,
      child: _buildMenuIcon(),
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

  PopupMenuEntry<void> _buildPopupMenuItem(
      String title, bool Function() valueGetter, VoidCallback onTap) {
    return _PersistentPopupMenuItem(
      title: title,
      valueGetter: valueGetter,
      onTap: onTap,
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

class _PersistentPopupMenuItem extends PopupMenuEntry<void> {
  const _PersistentPopupMenuItem({
    required this.title,
    required this.valueGetter,
    required this.onTap,
  });

  final String title;
  final bool Function() valueGetter;
  final VoidCallback onTap;

  @override
  double get height => 48;

  @override
  bool represents(void value) => false;

  @override
  State<_PersistentPopupMenuItem> createState() =>
      _PersistentPopupMenuItemState();
}

class _PersistentPopupMenuItemState extends State<_PersistentPopupMenuItem> {
  @override
  Widget build(BuildContext context) {
    // Get the current value each time we build
    final bool currentValue = widget.valueGetter();

    return InkWell(
      onTap: () {
        widget.onTap();
        // Force a rebuild to update the UI immediately
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              currentValue ? Icons.check_box : Icons.check_box_outline_blank,
              color: currentValue ? AppColors.primaryColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
