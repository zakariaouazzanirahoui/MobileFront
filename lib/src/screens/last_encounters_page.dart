import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class LastEncountersPage extends StatefulWidget {
  const LastEncountersPage({Key? key}) : super(key: key);

  @override
  _LastEncountersPageState createState() => _LastEncountersPageState();
}

class _LastEncountersPageState extends State<LastEncountersPage> {
  List<dynamic> interactions = [];

  @override
  void initState() {
    super.initState();
    fetchInteractions();
  }

  Future<void> fetchInteractions() async {
    final response = await fetchInteractionsFromAPI();

    if (response != null && response.statusCode == 200) {
      List<dynamic> fetchedInteractions = parseInteractions(response.body);
      setState(() {
        interactions = fetchedInteractions;
      });
    } else {
      print("Error fetching interactions from the API");
    }
  }

  Future<http.Response?> fetchInteractionsFromAPI() async {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      String udid = androidInfo.androidId; 
    return await http.get(Uri.parse('http://192.168.11.102:8080/interaction/list/$udid'));
  }

  List<dynamic> parseInteractions(String responseBody) {
    return json.decode(responseBody);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Last Encounters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add logic for "Last Week" button
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF375E97),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(150, 50),
                ),
                child: Text('Last Week'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add logic for "Last 2 Weeks" button
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(150, 50),
                ),
                child: Text('Last 2 Weeks'),
              ),
            ],
          ),
          for (var interaction in interactions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: EncounteredPersonTile(
           message: 'Interaction ${interaction['safe'] ? "Safe" : "Not Safe"} at ${formatDateTime(interaction['interaction_date'])}',
              ),
            ),
        ],
      ),
    );
  }
}

String formatDateTime(String dateTimeString) {
  DateTime originalDateTime = DateTime.parse(dateTimeString);
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDateTime);
}

class EncounteredPersonTile extends StatelessWidget {
  final String message;

  const EncounteredPersonTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF375E97),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
