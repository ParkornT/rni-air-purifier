import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/main/dialog/show_error_dialog.dart';
import 'package:rni_app/features/bluetooth/providers/bluetooth_provider.dart';

/*
Green - ESP32 Device connected
Red - ESP32 Device not found/connected
*/
class DeviceConnectionState extends StatelessWidget {
  const DeviceConnectionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetooth, _) {
        final isConnected = bluetooth.deviceIsConnected();

        return GestureDetector(
          onTap: () {
            showAlert(
              context,
              title: "Device State",
              message: isConnected
                  ? "The device is currently connected."
                  : "The device is not connected. Ensure that ESP32 is connected correctly.",
            );
          },
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
