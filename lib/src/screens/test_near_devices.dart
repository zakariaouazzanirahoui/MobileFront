import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'advertiser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.advertiser));
    case 'browser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.browser));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'advertiser');
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Center(
                child: Text(
                  'ADVERTISE',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'browser');
              },
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: Center(
                child: Text(
                  'BROWSE',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({required this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    receivedDataSubscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.deviceType.toString().substring(11).toUpperCase()),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: getItemCount(),
        itemBuilder: (context, index) {
          final device = widget.deviceType == DeviceType.advertiser
              ? connectedDevices[index]
              : devices[index];
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabItemListener(device),
                        child: Column(
                          children: [
                            Text(device.deviceName),
                            Text(
                              getStateName(device.state),
                              style: TextStyle(
                                  color: getStateColor(device.state)),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onButtonClicked(device),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        padding: EdgeInsets.all(8.0),
                        height: 35,
                        width: 100,
                        color: getButtonColor(device.state),
                        child: Center(
                          child: Text(
                            getButtonStateName(device.state),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final myController = TextEditingController();
          return AlertDialog(
            title: Text("Send message"),
            content: TextField(controller: myController),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Send"),
                onPressed: () async {
                  String udid = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      udid = androidInfo.androidId; // Android ID can serve as UDID
    }
                  nearbyService.sendMessage(device.deviceId, udid);
                  myController.text = '';
                },
              )
            ],
          );
        },
      );
    }
  }

  int getItemCount() {
    if (widget.deviceType == DeviceType.advertiser) {
      return connectedDevices.length;
    } else {
      return devices.length;
    }
  }

  _onButtonClicked(Device device) async {
    switch (device.state) {
      case SessionState.notConnected:
      

         nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );

        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void init() async {
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
    }
    await nearbyService.init(
      serviceType: 'mpconn',
      deviceName: devInfo,
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) async {
        if (isRunning) {
          if (widget.deviceType == DeviceType.browser) {
            await nearbyService.stopBrowsingForPeers();
            await Future.delayed(Duration(milliseconds: 200));
            await nearbyService.startBrowsingForPeers();
          } else {
            await nearbyService.stopAdvertisingPeer();
            await nearbyService.stopBrowsingForPeers();
            await Future.delayed(Duration(milliseconds: 200));
            await nearbyService.startAdvertisingPeer();
            await nearbyService.startBrowsingForPeers();
          }
        }
      },
    );
    subscription = nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");
        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      });
      setState(() {
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });
    receivedDataSubscription = nearbyService.dataReceivedSubscription(callback: (data) {

      print("dataReceivedSubscription: ${jsonEncode(data['message'])}");
      //ici appel apai pour enregistrer l'interaction
      saveInteraction(data['message']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonEncode(data)),
          duration: Duration(seconds: 5),
        ),

      );

    });
  }
Future<void> saveInteraction( String interaction_device_udid ) async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Replace 'your_api_endpoint' with the actual endpoint to save user data
  final Uri uri = Uri.parse('http://192.168.11.102:8080/interaction/save');
  AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

  var udid = androidInfo.androidId;
  try {
    // Make a POST request to the API endpoint with the appropriate headers
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded', // Adjust based on server requirements
      },
      body: {
        'device_udid' : udid ,
        'interaction_device_udid': interaction_device_udid ,
      
      },
    );
  
}catch (e) {
    print("Error: $e");
    // Handle the error appropriately, e.g., show an error message to the user
  }
}

}
