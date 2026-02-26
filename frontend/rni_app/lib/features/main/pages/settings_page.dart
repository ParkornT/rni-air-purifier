import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/main/widgets/settings_switch.dart';
import 'package:rni_app/features/main/providers/theme_provider.dart';

/*
Index 3: App Settings
  1) Dark Theme Toggle
  2) ...
*/
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: SettingsSwitch(
              text: 'Dark Theme',
              value: context.watch<ThemeProvider>().darkMode,
              onChanged: (_) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
