import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CovidSwitch extends StatefulWidget {
    const CovidSwitch({Key? key}) : super(key: key);

  @override
  _CovidSwitchState createState() => _CovidSwitchState();
}

class _CovidSwitchState extends State<CovidSwitch> {

  bool isCovidPositive = false;

  @override
  void initState() {
    super.initState();
    fetchData(); // Call the API when the widget is initialized
  }

  Future<void> fetchData() async {
    String udid = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      udid = androidInfo.androidId; // Android ID can serve as UDID
    }
    final response = await http.get(Uri.parse('http://192.168.11.102:8080/user/getUser/$udid'));

    if (response.statusCode == 200) {
      // Parse the response data
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        isCovidPositive = data['flag'];
      });
      print(data['flag']);
    } else {
      // Handle errors
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  Future<void> toggleSwitch(bool value) async {
     String udid = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      udid = androidInfo.androidId; // Android ID can serve as UDID
    }
    final response = await http.get(Uri.parse('http://192.168.11.102:8080/user/changeFlag/$udid'));
    fetchData(); 

    // Add your API call logic here
    // For example, you might want to send the switch value to the server
    // using a POST request or perform any other desired action
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Covid App',
            style: TextStyle(color: Colors.white),
          ),
          
          centerTitle: true,
          backgroundColor: const Color(0xFF375E97),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
                // Add logic for the "Home" button here
              },
            ),
          ],
          
        ),
        
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Are you COVID positive?',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: isCovidPositive,
                    onChanged: (value) {
                      setState(() {
                        isCovidPositive = value;
                      });
                      toggleSwitch(value); // Call the API when the switch is toggled
                    },
                    activeTrackColor: const Color(0xFF375E97),
                    activeColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                // Other widgets in your page
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(CovidSwitch());
}
