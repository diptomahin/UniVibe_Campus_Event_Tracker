import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Settings sections can be added here
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Notifications'),
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                  ListTile(
                    title: const Text('Maintenance Mode'),
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
