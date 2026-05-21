import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeImageItem extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final bool isLiked;

  const RecipeImageItem({
    super.key,
    required this.imageUrl,
    required this.onTap,
    required this.onDoubleTap,
    required this.isLiked,
  });

  @override
  State<RecipeImageItem> createState() => _RecipeImageItemState();
}

class _RecipeImageItemState extends State<RecipeImageItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        if (mounted) setState(() => _isAnimating = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    widget.onDoubleTap();
    if (mounted) {
      setState(() => _isAnimating = true);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: 300,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          if (_isAnimating)
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 80,
              ),
            ),
        ],
      ),
    );
  }
}
