import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:flutter/material.dart';

class SolutionWidget extends StatelessWidget {
  const SolutionWidget({required this.item, super.key});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.externalUrl != null) context.tryLaunchUrl(item.externalUrl!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset(
              item.iconAsset,
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              item.title,
              style: context.textTheme.bodyMedium,
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
