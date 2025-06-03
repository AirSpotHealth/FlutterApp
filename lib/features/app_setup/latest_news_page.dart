import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class LatestNewsPage extends StatelessWidget {
  const LatestNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appSetup.latestNews),
      ),
      body: Center(child: Text(t.appSetup.latestNews)),
    );
  }
}
