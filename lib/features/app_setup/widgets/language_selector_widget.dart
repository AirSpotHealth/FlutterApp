import 'package:airspothealth/core/providers/language_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final currentLanguageName = _getLanguageName(currentLocale);

    return SettingItemWidget(
      onTap: () => _showLanguageSelector(context, ref),
      item: SettingItem(
        title: t.appSetup.language,
        leadingWidget: const Icon(Icons.language, size: 24),
        suffixWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguageName,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(AppLocale locale) {
    switch (locale) {
      case AppLocale.en:
        return t.appSetup.english;
      case AppLocale.zhCn:
        return t.appSetup.chinese;
    }
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.appSetup.selectLanguage,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              context,
              ref,
              AppLocale.en,
              t.appSetup.english,
              '🇺🇸',
            ),
            _buildLanguageOption(
              context,
              ref,
              AppLocale.zhCn,
              t.appSetup.chinese,
              '🇨🇳',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    AppLocale locale,
    String languageName,
    String flag,
  ) {
    final currentLocale = ref.watch(languageProvider);
    final isSelected = currentLocale == locale;

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        languageName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        if (!isSelected) {
          ref.read(languageProvider.notifier).setLanguage(locale);
          context.showSnackBar(
            t.appSetup.languageChanged(language: languageName),
          );
        }
        Navigator.of(context).pop();
      },
    );
  }
}
