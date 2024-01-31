// small_container_widget.dart
import 'package:flutter/material.dart';
import '../screens/last_encounters_page.dart';

class SmallContainerWidget extends StatelessWidget {
  final String label;
  final VoidCallback onSmallContainerPressed;

  SmallContainerWidget({required this.label, required this.onSmallContainerPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Call the callback function to handle navigation
        onSmallContainerPressed();
       
      },
      child: Container(
        width: 150,
        height: 150,
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
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
