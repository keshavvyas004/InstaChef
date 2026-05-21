import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Small reusable widget to display stat info
class ProfileStat extends StatelessWidget {
  final int count;
  final String label;

  const ProfileStat({
    super.key,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    ).animate().scale(duration: 300.ms, curve: Curves.easeInOut);
  }
}

// Main header widget
class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profileImageUrl;
  final int postCount;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.postCount,
  });

  // Method to show fullscreen image viewer with zoom functionality
  void _showImageZoom(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _ImageZoomViewer(imageUrl: profileImageUrl),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showImageZoom(context),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
            const SizedBox(width: 40),
            ProfileStat(count: postCount, label: 'Posts'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}

// Simple image viewer like Instagram
class _ImageZoomViewer extends StatefulWidget {
  final String imageUrl;

  const _ImageZoomViewer({required this.imageUrl});

  @override
  State<_ImageZoomViewer> createState() => _ImageZoomViewerState();
}

class _ImageZoomViewerState extends State<_ImageZoomViewer> {
  double _verticalDragOffset = 0.0;
  double _opacity = 1.0;

  // Handle vertical drag to dismiss
  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _verticalDragOffset += details.delta.dy;
      _opacity = (1.0 - (_verticalDragOffset.abs() / 300)).clamp(0.0, 1.0);
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_verticalDragOffset.abs() > 100) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _verticalDragOffset = 0.0;
        _opacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: _opacity),
        body: Stack(
          children: [
            // Centered larger image
            Center(
              child: Transform.translate(
                offset: Offset(0, _verticalDragOffset),
                child: Hero(
                  tag: 'profile_image',
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
