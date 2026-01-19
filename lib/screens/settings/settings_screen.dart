import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _reminderTime = '24h';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSection('Display', [
                  ListTile(
                    title: const Text('Theme'),
                    subtitle: Text(
                      _getThemeModeText(settingsProvider.themeMode),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Choose Theme'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile(
                                title: const Text('Light'),
                                value: ThemeMode.light,
                                groupValue: settingsProvider.themeMode,
                                onChanged: (value) {
                                  if (value != null) {
                                    settingsProvider.setThemeMode(value);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              RadioListTile(
                                title: const Text('Dark'),
                                value: ThemeMode.dark,
                                groupValue: settingsProvider.themeMode,
                                onChanged: (value) {
                                  if (value != null) {
                                    settingsProvider.setThemeMode(value);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              RadioListTile(
                                title: const Text('System'),
                                value: ThemeMode.system,
                                groupValue: settingsProvider.themeMode,
                                onChanged: (value) {
                                  if (value != null) {
                                    settingsProvider.setThemeMode(value);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ]),
                _buildSection('Notifications', [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      settingsProvider.setNotificationsEnabled(value);
                    },
                  ),
                  if (settingsProvider.notificationsEnabled)
                    ListTile(
                      title: const Text('Reminder Time'),
                      subtitle: Text(_reminderTime),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reminder Time'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile(
                                  title: const Text('1 hour before'),
                                  value: '1h',
                                  groupValue: _reminderTime,
                                  onChanged: (value) {
                                    setState(
                                      () => _reminderTime = value ?? '24h',
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  title: const Text('24 hours before'),
                                  value: '24h',
                                  groupValue: _reminderTime,
                                  onChanged: (value) {
                                    setState(
                                      () => _reminderTime = value ?? '24h',
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ]),
                _buildSection('About', [
                  ListTile(
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                    trailing: const Icon(Icons.info_outline, size: 16),
                  ),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
