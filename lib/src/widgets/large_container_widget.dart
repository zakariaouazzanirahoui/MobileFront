// large_container_widget.dart
import 'package:flutter/material.dart';
import '../screens/last_encounters_page.dart';

class LargeContainerWidget extends StatelessWidget {
  final VoidCallback onLargeContainerPressed;

  LargeContainerWidget({required this.onLargeContainerPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          // Call the callback function to handle navigation
          onLargeContainerPressed();
        },
        child: Container(
          width: 300,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Scan Covid Test Certification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
