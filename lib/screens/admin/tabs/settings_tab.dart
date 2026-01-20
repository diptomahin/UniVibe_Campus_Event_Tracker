import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          // Broadcast Announcement Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Communications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(
                      Icons.announcement,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Broadcast Announcement'),
                    subtitle: const Text('Send notifications to all users'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/broadcast-announcement'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // System Settings Card
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
