import 'package:flutter/material.dart';

class LatestNewsPage extends StatelessWidget {
  const LatestNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800),
                    onPressed: () {},
                    child: const Text('Latest News')),
              ),
              const SizedBox(width: 24),
              Switch(
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
