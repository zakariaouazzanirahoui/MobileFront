import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

void main() {
  runApp(MyApp());
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
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
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'CONNECT',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen();

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  List<Device> devices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;

  bool isInit = false;
  Device? connectedDevice;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CONNECTED DEVICES'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Connected to ${connectedDevice!.deviceName}'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
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
                          // Request connect
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
          ),
        ],
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
    // No message feature, just update the connectedDevice
    setState(() {
      connectedDevice = device;
    });
  }

  _onButtonClicked(Device device) {
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
            await nearbyService.stopBrowsingForPeers();
            await nearbyService.stopAdvertisingPeer();
            await Future.delayed(Duration(microseconds: 200));
            await nearbyService.startBrowsingForPeers();
            await nearbyService.startAdvertisingPeer();
          }
        });
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");
      });

      setState(() {
        devices.clear();
        devices.addAll(devicesList);
      });
    });
  }
}
