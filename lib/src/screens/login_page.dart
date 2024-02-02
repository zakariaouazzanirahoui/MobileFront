import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile_front_end/src/screens/home_page.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
void navigateToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
  
  @override
  void initState() {
    super.initState();
    checkUDIDExistence();
  }

Future<void> checkUDIDExistence() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String udid = '';

  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      udid = androidInfo.androidId; // Android ID can serve as UDID
      print(udid);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      udid = iosInfo.identifierForVendor; // IDFV can serve as UDID
    } else if ((Theme.of(context).platform == TargetPlatform.windows)){
      udid = Uuid().v1();
      print(udid);
    }
  } catch (e) {
    print('Error getting device info: $e');
    // Handle the error accordingly
  }

  // Replace 'your_api_endpoint' with the actual endpoint to check UDID existence
  final response = await http.get(Uri.parse('http://192.168.11.102:8080/user/check-udid/$udid') );
  if (response.statusCode == 200) {
    // UDID exists, navigate to home page
    print(udid);
    navigateToHomePage(context);
  }
}



Future<void> saveUserData() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Replace 'your_api_endpoint' with the actual endpoint to save user data
  final Uri uri = Uri.parse('http://192.168.11.102:8080/user/save');
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
        'udid' : udid ,
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'email': emailController.text,
      },
    );



    // Check the status code
    if (response.statusCode == 200) {
      // Data saved successfully, navigate to home page
    navigateToHomePage(context)   ;
   } else {
      print("Error: ${response.statusCode}");
      print("Response body: ${response.body}");
      // Handle the error appropriately, e.g., show an error message to the user
    }
  } catch (e) {
    print("Error: $e");
    // Handle the error appropriately, e.g., show an error message to the user
  }
}@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Covid App', style: TextStyle(color: Colors.white)),
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
      body: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Welcome',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This is your first time using this app',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    saveUserData();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF375E97), // Set button color
                    padding: EdgeInsets.symmetric(vertical: 16), // Set padding
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white), // Set text color to white

                    
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
