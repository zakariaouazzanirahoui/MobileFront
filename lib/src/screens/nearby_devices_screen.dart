import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class NearbyDevicesScreen extends StatefulWidget {
  @override
  _NearbyDevicesScreenState createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

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
            title: Text(devices[index].name),
            subtitle: Text(devices[index].id.toString()),
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
