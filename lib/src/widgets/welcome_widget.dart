import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomeWidget extends StatefulWidget {
  @override
  _WelcomeWidgetState createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  String welcomeMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchData(); // Call the API when the widget is initialized
  }

  Future<void> fetchData() async {
    try {
       String udid = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      udid = androidInfo.androidId; // Android ID can serve as UDID
    }
      // Replace the URL with your actual API endpoint
      final response = await http.get(Uri.parse('http://192.168.11.102:8080/user/getUser/$udid'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          welcomeMessage = 'Welcome, ${data['first_name']}';
        });
      } else {
        // Handle errors
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during API call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          welcomeMessage,
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
