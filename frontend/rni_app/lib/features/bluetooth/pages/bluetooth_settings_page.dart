import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/bluetooth/dialog/show_error_dialog.dart';
import 'package:rni_app/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:rni_app/features/bluetooth/widgets/device_list_view.dart';

class BluetoothSettingsPage extends StatefulWidget {
  const BluetoothSettingsPage({super.key});

  @override
  State<BluetoothSettingsPage> createState() => _BluetoothSettingsPageState();
}

class _BluetoothSettingsPageState extends State<BluetoothSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize Bluetooth when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetooth, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bluetooth Scanner'),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Row(children: [const SizedBox(width: 8)])),
              ),
            ],
          ),
          body: Column(
            children: [
              // Scanning status
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    if (bluetooth.isScanning)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                    if (bluetooth.isScanning) const SizedBox(width: 8),
                    Text(
                      bluetooth.isScanning
                          ? 'Scanning... (${bluetooth.scanResults.length} devices)'
                          : 'Found ${bluetooth.scanResults.length} devices',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: DeviceListView()),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final bluetoothProvider = context.read<BluetoothProvider>();

              if (bluetoothProvider.bluetoothAdapterState ==
                  BluetoothAdapterState.on) {
                bluetooth.isScanning
                    ? bluetooth.stopScan()
                    : bluetooth.startScan();
              } else {
                showAlert(
                  context,
                  title: "Bluetooth Disabled",
                  message: "Please enable bluetooth",
                );
              }
            },
            child: bluetooth.isScanning ? Icon(Icons.stop) : Icon(Icons.start),
          ),
        );
      },
    );
  }
}
