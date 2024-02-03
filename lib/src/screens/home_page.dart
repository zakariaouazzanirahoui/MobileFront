// app_bar_example.dart
import 'package:flutter/material.dart';
import 'package:mobile_front_end/src/screens/scan_page.dart';
import 'package:mobile_front_end/src/screens/test_near_devices.dart';
import 'package:mobile_front_end/src/widgets/covid_switch.dart';
import '../widgets/welcome_widget.dart';
import '../widgets/large_container_widget.dart';
import '../widgets/small_container_widget.dart';
import '../screens/last_encounters_page.dart'; // Import the LastEncountersPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  // Callback function to navigate to the Last Encounters page
  void navigateToLastEncountersPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LastEncountersPage()),
    );
  }
   void navigateToScanPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
  }
 void navigateToTestNearDevices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp ()),
    );
  }

 void navigateToCovidStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CovidSwitch()),
    );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            WelcomeWidget(),
            LargeContainerWidget(
              onLargeContainerPressed: () => navigateToScanPage(context),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SmallContainerWidget(
                  label: 'Last Encounters',
                  onSmallContainerPressed: () {
                    navigateToLastEncountersPage(context);
                  },
                ),
                SmallContainerWidget(
                  label: 'Test near devices',
                  onSmallContainerPressed: () {
                    navigateToTestNearDevices(context);
                  },
                ),
              ],
            ),
            // Add the CovidSwitch widget here
            SizedBox(height: 10),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SmallContainerWidget(
                  label: 'Covid Status',
                  onSmallContainerPressed: () {
                    navigateToCovidStatus(context);
                    },
                ),
                SmallContainerWidget(
                  label: 'NearBy People',
                  onSmallContainerPressed: () {
                    // Add logic for Container 4 pressed
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
