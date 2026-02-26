import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/main/dialog/show_error_dialog.dart';
import 'package:rni_app/features/bluetooth/providers/bluetooth_provider.dart';

/*
Green - Bluetooth Adapter is On
Red - Bluetooth Adapter is Off
*/
class DeviceAdapterState extends StatelessWidget {
  const DeviceAdapterState({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetooth, _) {
        final adapterState = bluetooth.bluetoothAdapterState;
        Color getAdapterStateColor() {
          switch (adapterState) {
            case BluetoothAdapterState.on:
              return Colors.green;
            case BluetoothAdapterState.off:
              return Colors.red;
            case BluetoothAdapterState.unavailable: //TODO
              return Colors.grey;
            case BluetoothAdapterState.unauthorized: //TODO
              return Colors.orange;
            default:
              return Colors.grey;
          }
        }

        return GestureDetector(
          onTap: () {
            showAlert(
              context,
              title: "Adapter State",
              message: adapterState == BluetoothAdapterState.on
                  ? "Adapter is On."
                  : "Adapter is not On. Please ensure Bluetooth is turned on in your device.",
            );
          },
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getAdapterStateColor(),
            ),
          ),
        );
      },
    );
  }
}
