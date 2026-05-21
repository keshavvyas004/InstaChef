import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_collection, size: 100, color: Colors.red),
          Text('Reels Screen', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}