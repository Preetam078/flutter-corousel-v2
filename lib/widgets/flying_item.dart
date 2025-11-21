import 'dart:math' as math;
import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';
import 'carousel_card.dart';

class FlyingItem extends StatefulWidget {
  final CarouselItem item;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onAnimationComplete;
  final double targetRotation; // Rotation in radians

  const FlyingItem({
    super.key,
    required this.item,
    required this.startPosition,
    required this.endPosition,
    required this.onAnimationComplete,
    this.targetRotation = 0.0, // Default to no rotation
  });

  @override
  State<FlyingItem> createState() => _FlyingItemState();
}

class _FlyingItemState extends State<FlyingItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // No shrinking
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // 2D Rotation animation that activates when item reaches bottom
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.targetRotation, // Use the rotation passed from parent
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut), // Starts at 60% of animation
    ));

    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 360, // Approx height of card
                child: CarouselCard(item: widget.item),
              ),
            ),
          ),
        );
      },
    );
  }
}
