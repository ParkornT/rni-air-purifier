import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rni_app/features/bluetooth/pages/bluetooth_settings_page.dart';
import 'package:rni_app/features/main/pages/settings_page.dart';
import 'package:rni_app/features/main/widgets/adapter_state.dart';
import 'package:rni_app/features/main/widgets/device_connection_state.dart';
import 'package:rni_app/features/main/pages/dashboard_page.dart';

class SideNavigation extends StatefulWidget {
  const SideNavigation({super.key});
  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  int _selectedIndex = 0;
  Widget _buildPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const BluetoothSettingsPage();
      case 2:
        return const SettingsPage();
      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              "Rni Air Purifier",
              style: TextStyle(letterSpacing: -1, fontSize: 24),
            ),
            Spacer(), // Gap to the end of Appbar
            DeviceAdapterState(),
            Gap(15),
            DeviceConnectionState(),
          ],
        ),
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Close drawer after selection
        },
        children: const [
          Gap(40),
          NavigationDrawerDestination(
            icon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.bluetooth),
            label: Text('Bluetooth Settings'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.miscellaneous_services),
            label: Text('Settings'),
          ),
        ],
      ),
      body: _buildPage(_selectedIndex),
    );
  }
}
