import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const AppLogo(),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            dense: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            tileColor: Colors.white,
            title:
                Text('Devices', style: context.textTheme.labelLarge?.weight600),
            subtitle: const Text('Manage your devices'),
            leading: Image.asset(Assets.icDevice, width: 24),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
