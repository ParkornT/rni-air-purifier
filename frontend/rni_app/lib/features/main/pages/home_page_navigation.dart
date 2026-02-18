import 'package:flutter/material.dart';
import 'package:rni_app/features/main/pages/bluetooth_settings_page.dart';
import 'package:rni_app/features/main/pages/settings_page.dart';
import 'home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Widget _buildPage(int index) {
    switch (_selectedIndex) {
      case 0:
        return MainPage(title: widget.title);
      case 1:
        return BluetoothSettingsPage();
      case 2:
        return SettingsPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              minWidth: 100,
              extended: false, //Turn on if you want wider rail
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text("Home"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bluetooth),
                  label: Text("Bluetooth Settings"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.miscellaneous_services),
                  label: Text("Settings"),
                ),
              ],
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildPage(_selectedIndex)),
        ],
      ),
    );
  }
}
