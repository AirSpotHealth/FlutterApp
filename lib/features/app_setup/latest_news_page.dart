import 'package:flutter/material.dart';

class LatestNewsPage extends StatelessWidget {
  const LatestNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Airspot Health'),
            Text('Please wait while we set up your app'),
          ],
        ),
      ),
    );
  }
}
