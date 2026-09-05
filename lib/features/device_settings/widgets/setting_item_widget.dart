import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingItemWidget extends StatelessWidget {
  const SettingItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SettingItem item;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        color: Colors.white,
        child: Row(
          children: [
            item.leadingWidget ??
                Image.asset(
                  item.assetIcon!,
                  width: 32,
                  opacity: AlwaysStoppedAnimation(item.enabled ? 1.0 : 0.5),
                ),
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
                        Expanded(
                          flex: 8,
                          child: Text(
                            item.title,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: item.enabled ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!item.enabled)
                          const FaIcon(
                            FontAwesomeIcons.ban,
                            size: 16,
                            color: Colors.grey,
                          )
                        else
                          item.suffixWidget ??
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
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
