// last_encounters_page.dart
import 'package:flutter/material.dart';

class LastEncountersPage extends StatelessWidget {
  const LastEncountersPage({Key? key}) : super(key: key);

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
                padding: const EdgeInsets.all(8.0),
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
          ListTile(
            title: const Text('John Doe'),
          ),
          ListTile(
            title: const Text('Jane Doe'),
          ),
          // Add more list items as needed
        ],
      ),
    );
  }
}
