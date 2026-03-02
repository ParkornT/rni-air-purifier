import 'dart:async' show StreamSubscription;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rni_app/features/bluetooth/services/bluetooth_service.dart';
import 'package:rni_app/features/main/providers/live_chart_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// [BluetoothProvider]
///
/// Manages all Bluetooth Low Energy (BLE) states, including:
/// - Connection handling
/// - Data transmission
/// - Adapter state management
/// - Calling BlueService methods
///
/// Acts as the bridge between the UI layer and [BlueService]
/// - UI → Listens and reacts to state changes via [Consumer] or `context.watch`
/// - [BlueService] → Handles BLE logic and raw `flutter_blue_plus` operations
///
/// ---------------------------------------------------------------------------
/// Responsibilities
/// ---------------------------------------------------------------------------
///
/// - Listening to Bluetooth adapter state (on/off/unavailable)
/// - Listening to and parsing incoming data from the ESP32
/// - Sending data to the connected ESP32 device (/TODO)
/// - Forwarding parsed data points to [ChartProvider]
/// - Calling [BlueService] to scan for nearby BLE devices
///   (default filter: `ESP32_BT`)
/// - Calling [BlueService] to connect and disconnect from a BLE device
///
/// ---------------------------------------------------------------------------
/// Provider Registered at main.dart
/// ---------------------------------------------------------------------------
///
/// ```dart
/// ChangeNotifierProxyProvider<ChartProvider, BluetoothProvider>(
///   create: (context) => BluetoothProvider(context.read<ChartProvider>()),
///   update: (context, chart, previous) =>
///     previous ?? BluetoothProvider(chart),
/// )
/// ```
///
/// ---------------------------------------------------------------------------
/// Dependencies
/// ---------------------------------------------------------------------------
///
/// - [BlueService] → Handles raw `flutter_blue_plus` operations
/// - [ChartProvider] → Receives parsed data points for visualization
///

class BluetoothProvider with ChangeNotifier {
  final BlueService _bluetoothService = BlueService();

  // Connection State
  BluetoothAdapterState _bluetoothAdapterState = BluetoothAdapterState.unknown;
  BluetoothDevice? _connectedDevice;

  // Device State
  List<ScanResult> _scanResults = [];
  String _receivedData = "";
  bool _isScanning = false;
  Stream<String>? _deviceDataStream; // Listening device
  StreamSubscription<String>? _deviceDataSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  String? _errorMessage;

  // Consumer
  final ChartProvider _chartProvider; //For ChartProvider.addPoint()

  BluetoothProvider(this._chartProvider);

  // Conncection Getters
  BluetoothAdapterState get bluetoothAdapterState => _bluetoothAdapterState;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Device state Getters
  List<ScanResult> get scanResults => _scanResults;
  String get receivedData => _receivedData;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;

  // Provider state

  bool _initialized = false; // True if already initialized Listeners

  bool _deviceDisconnecting = false; // Don't log Error if intended

  void init() async {
    if (_initialized) return; // Only initialize once
    _initialized = true;

    await _bluetoothService.init();
    _listenToScanResults();
    _listenToScanningState();
    _listenToAdapter();
  }

  // Call BluetoothService to start scanning for bluetooth devices
  Future<void> startScan() async {
    try {
      // Check the Adapter state before scanning
      if (_bluetoothAdapterState == BluetoothAdapterState.on) {
        _scanResults.clear();
        await _bluetoothService.startScan();
        notifyListeners();
      } else {
        print("Bluetooth is not enabled");
      }
    } catch (e) {
      throw "Failed to start scan: $e";
    }
  }

  // Call BluetoothService to stop scanning for bluetooth devices
  Future<void> stopScan() async {
    try {
      await _bluetoothService.stopScan();
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to stop scan: $e");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await _bluetoothService.stopScan();
      await _bluetoothService.connectToDevice(device); // Connect once

      _connectedDevice = device;

      // Listen for unexpected disconnections (power off, out of range)
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = connectionState(device).listen((state) {
        print("Connection state changed: $state");
        if (state == BluetoothConnectionState.disconnected &&
            _deviceDisconnecting == false) {
          _setError(
            "Device disconnected! Please check your device's connection.",
          );
          disconnectDevice();
        }
      });

      // Discover services
      await _bluetoothService.discoverServices(device);

      // Listen to incoming data
      _deviceDataStream = _bluetoothService.listenToDevice(device);
      if (_deviceDataStream == null) {
        print("characteristics not found!");
        return;
      }

      await _deviceDataSubscription?.cancel();
      _deviceDataSubscription = _deviceDataStream!.listen((data) {
        _receivedData = data;
        final parsed = double.tryParse(data.trim());
        _chartProvider.addData(parsed);
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      print("Failed to connect: $e");
      notifyListeners();
    }
  }

  // Disconnect from device
  Future<void> disconnectDevice() async {
    try {
      _deviceDisconnecting = true;
      if (_connectedDevice != null) {
        await _bluetoothService.disconnectDevice(_connectedDevice!);
        print("Disconnected!");
      } else {
        print("Already disconnected!");
      }

      await _deviceDataSubscription?.cancel();
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = null;

      _connectedDevice = null;
      _receivedData = "";
      _deviceDisconnecting = false;
      notifyListeners();
    } catch (e) {
      print("Failed to disconnect: $e");
    }
  }

  // Send data to ESP32
  Future<void> sendData(String message) async {
    try {
      await _bluetoothService.sendData(message);
    } catch (e) {
      print("Send error: $e");
    }
  }

  Future<bool> sendDataWithAck(String message) async {
    try {
      return await _bluetoothService.sendDataWithAck(message);
    } catch (e) {
      rethrow;
    }
  }

  // Listen to BluetoothService and notify Comsumers on scan state changed
  void _listenToScanningState() async {
    _bluetoothService.isScanning.listen((scanning) {
      print(scanning);
      _isScanning = scanning;
      notifyListeners();
    });
  }

  // Listen to BluetoothService and notify Comsumers on scan results
  void _listenToScanResults() async {
    _bluetoothService.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });
  }

  void _listenToAdapter() {
    _bluetoothService.adapterState.listen((state) {
      print(state);
      _bluetoothAdapterState = state;
      if (state != BluetoothAdapterState.on) {
        _isScanning = false;
        _scanResults.clear();
        _connectedDevice = null;
      }
      notifyListeners();
    });
  }

  Future<void> requestPermissions() async {
    //TODO: add permission handler for IOS
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      //Permission.location,
    ].request();
  }

  bool deviceIsConnected() {
    if (_connectedDevice != null) {
      return true;
    }
    return false;
  }

  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) {
    return device.connectionState;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
