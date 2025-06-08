import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constant/text_constants.dart';

class DeviceDetailsScreen extends StatefulWidget {

  final DiscoveredDevice device;

  DeviceDetailsScreen({required this.device});

  @override
  DeviceDetailsPageState createState() => DeviceDetailsPageState();
}

class DeviceDetailsPageState extends State<DeviceDetailsScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<ConnectionStateUpdate> connection;
  bool isConnecting = true;
  QualifiedCharacteristic? writeChar;
  List<int> rssiHistory = [];
  List<FlSpot> rssiSpots = [];
  List<DiscoveredService> services = [];
  DateTime startTime = DateTime.now();
  Timer? rssiTimer;
  int latestRssi = 0;
  late DiscoveredDevice connectedDevice;
  final Map<String, String> charValues = {};

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  void connectToDevice() {
    setState(() {
      isConnecting = true;
    });

    connection = flutterReactiveBle.connectToDevice(
      id: widget.device.id,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((connectionState) async {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        debugPrint("Connected to ${widget.device.name}");

        services = await flutterReactiveBle.discoverServices(widget.device.id);
        readAllReadableCharacteristics();

        // Start RSSI polling
        startRssiUpdates();

        setState(() {
          isConnecting = false;
        });
      }
    }, onError: (error) {
      debugPrint("Failed to connect: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $error")),
      );
      Navigator.pop(context);
    });
  }

  void readAllReadableCharacteristics() async {
    for (final service in services) {
      for (final char in service.characteristics) {
        if (char.isReadable) {
          final qChar = QualifiedCharacteristic(
            characteristicId: char.characteristicId,
            serviceId: service.serviceId,
            deviceId: widget.device.id,
          );

          try {
            final value = await flutterReactiveBle.readCharacteristic(qChar);
            final stringValue = utf8.decode(value);
            setState(() {
              charValues[char.characteristicId.toString()] = stringValue;
            });
          } catch (e) {
            debugPrint("Error reading ${char.characteristicId}: $e");
            setState(() {
              charValues[char.characteristicId.toString()] = char.characteristicId.toString();
            });
          }
        }
      }
    }
  }

  void startRssiUpdates() {
    rssiTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      final rssi = await flutterReactiveBle.readRssi(widget.device.id);
      latestRssi = rssi;
      updateRssi(rssi);
    });
  }

  void updateRssi(int rssi) {
    final now = DateTime.now();
    final secondsSinceStart = now.difference(startTime).inMilliseconds / 1000;

    setState(() {
      rssiSpots.add(FlSpot(secondsSinceStart, rssi.toDouble()));

      // Keep only the last 10 seconds of data
      rssiSpots = rssiSpots.where((spot) => secondsSinceStart - spot.x <= 10).toList();
    });
  }

  void disconnect() {
    rssiTimer?.cancel();
    connection.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    rssiTimer?.cancel();
    connection.cancel();
    super.dispose();
  }

  String getFriendlyName(Uuid uuid, {required bool isService}) {
    final full = uuid.toString().toLowerCase();
    final baseSuffix = '-0000-1000-8000-00805f9b34fb';

    String? shortUuid;

    // If matches standard base format, extract 16-bit UUID
    if (full.length == 36 && full.endsWith(baseSuffix)) {
      shortUuid = full.substring(4, 8).toUpperCase();
    }

    if (isService) {
      return (shortUuid != null && bleUuidNames.containsKey(shortUuid))
          ? bleUuidNames[shortUuid]!
          : uuid.toString();
    } else {
      return (shortUuid != null && bleUuidNames.containsKey(shortUuid))
          ? bleUuidNames[shortUuid]!
          : uuid.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxX = rssiSpots.isNotEmpty ? rssiSpots.last.x : 10;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name.isNotEmpty ? widget.device.name : "Connected Device"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: disconnect),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Device ID: ${widget.device.id}"),
                SizedBox(height: 10),
                Text("Current RSSI: $latestRssi"),
                SizedBox(height: 20),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minX: maxX - 10,
                      maxX: maxX,
                      minY: -100,
                      maxY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: rssiSpots,
                          isCurved: true,
                          color: Colors.blue,
                          belowBarData: BarAreaData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
                Expanded(
                  child:
                  ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final serviceName = getFriendlyName(service.serviceId, isService: true);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          title: Text(
                            serviceName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          leading: Icon(Icons.bluetooth, color: Colors.blueAccent),
                          children: service.characteristics.map((char) {
                            final charName = getFriendlyName(char.characteristicId, isService: false);
                            final canRead = char.isReadable;
                            final canWrite = char.isWritableWithResponse || char.isWritableWithoutResponse;
                            final canNotify = char.isNotifiable;

                            final valueText = charValues[char.characteristicId.toString()];

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              leading: Icon(Icons.memory, color: Colors.green),
                              title: Text(charName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (canRead && valueText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text("$valueText"),
                                    )
                                  else
                                    Text(char.characteristicId.toString()),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (canRead) Chip(label: Text("Read"), backgroundColor: Colors.lightBlue.shade100),
                                      if (canWrite) Chip(label: Text("Write"), backgroundColor: Colors.orange.shade100),
                                      if (canNotify) Chip(label: Text("Notify"), backgroundColor: Colors.purple.shade100),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isConnecting)
            Container(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}