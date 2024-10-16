import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingItemWidget extends StatelessWidget {
  const SettingItemWidget({
    super.key,
    required this.item,
  });

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.suffixWidget != null) return;

        if (item.route != null) {
          context.pushNamed(item.route!);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        color: Colors.white,
        child: Row(
          children: [
            Image.asset(item.assetIcon, width: 32),
            const SizedBox(width: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 8, child: Text(item.title)),
                        const SizedBox(width: 8),
                        item.suffixWidget ??
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
