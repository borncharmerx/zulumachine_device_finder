import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'DeviceDetails.dart';

class DeviceScannerScreen extends StatefulWidget {

  @override
  DeviceScannerState createState() => DeviceScannerState();
}

class DeviceScannerState extends State<DeviceScannerScreen> {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  final Map<String, DiscoveredDevice> devices = {};

  Stream<DiscoveredDevice>? scanStream;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  Future<void> startScan() async {
    // Request permissions
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    devices.clear();

    scanStream = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    );

    scanStream?.listen((device) {
      setState(() {
        devices[device.id] = device;
      });
    });
  }

  @override
  void dispose() {
    flutterReactiveBle.deinitialize();
    super.dispose();
  }

  // RSSI to signal bars: 0-1-2-3-4
  int rssiToBars(int rssi) {
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    if (rssi >= -90) return 1;
    return 0;
  }

  Icon signalIcon(int bars) {
    return Icon(
      [
        Icons.signal_cellular_0_bar,
        Icons.signal_cellular_alt_1_bar,
        Icons.signal_cellular_alt_2_bar,
        Icons.signal_cellular_alt,
        Icons.signal_cellular_4_bar
      ][bars],
      color: bars >= 3 ? Colors.green : (bars >= 2 ? Colors.orange : bars == 0 ? Colors.grey : Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDevices = devices.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Devices"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: startScan,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedDevices.length,
        itemBuilder: (context, index) {
          final device = sortedDevices[index];
          final name = device.name.isNotEmpty ? device.name : "Unknown";
          final rssi = device.rssi;
          final bars = rssiToBars(rssi);
          final isConnectable = device.connectable == Connectable.available;

          return ListTile(
            onTap:  !isConnectable ? null : () {
              flutterReactiveBle.deinitialize();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailsScreen(device: device),
                ),
              );
            },
            title: Text(name),
            subtitle: Text("ID: ${device.id}"),
            leading: signalIcon(bars),
            enabled: isConnectable,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("RSSI: $rssi"),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
