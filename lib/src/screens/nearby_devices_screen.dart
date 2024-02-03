import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class NearbyDevicesScreen extends StatefulWidget {
  @override
  _NearbyDevicesScreenState createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  // Establish a connection with the specified BluetoothDevice
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  // Send a static message to the specified BluetoothDevice
  Future<void> sendStaticMessage(BluetoothDevice device) async {
    // Establish a connection if not already connected
    if (device.state != BluetoothDeviceState.connected) {
      await connectToDevice(device);
    }

    String staticMessage = 'Hello, this is a static message!';
    await sendMessage(device, staticMessage);
  }

  // Discover services and read a characteristic from the specified BluetoothDevice
  Future<void> readCharacteristic(BluetoothDevice device) async {
    try {
      // Establish a connection if not already connected
      if (device.state != BluetoothDeviceState.connected) {
        await connectToDevice(device);
      }

      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Replace with the UUID of the characteristic you want to read
          if (characteristic.uuid.toString() == 'your_characteristic_uuid') {
            List<int> value = await characteristic.read();
            String message = utf8.decode(value);

            // Handle the received message (e.g., show it in a dialog)
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Received Message'),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Send a message to the specified BluetoothDevice
  Future<void> sendMessage(BluetoothDevice device, String message) async {
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // Replace with the UUID of the characteristic you want to write
        if (characteristic.uuid.toString() == 'your_characteristic_uuid') {
          List<int> value = utf8.encode(message);
          await characteristic.write(value);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  void startScanning() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Devices'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].name ?? 'Unknown Device'),
            subtitle: Text(devices[index].id.toString()),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await sendStaticMessage(devices[index]);
                  },
                  child: Text('Send Static Message'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await readCharacteristic(devices[index]);
                  },
                  child: Text('Receive Message'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NearbyDevicesScreen(),
  ));
}
