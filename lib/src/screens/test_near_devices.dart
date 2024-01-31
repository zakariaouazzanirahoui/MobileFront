
import 'package:flutter/material.dart';

class TestNearDevices extends StatelessWidget {

  
 
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
        child: Text('Test Near devices '),
      ),
    );
  }
}
