import 'dart:math' as math;
import 'package:corousel_fe/models/onboard_card.dart';
import 'package:corousel_fe/widgets/onboard_card.dart';
import 'package:flutter/material.dart';

class FlyingOnboardItem extends StatefulWidget {
  final OnboardCardData data;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onAnimationComplete;
  final double targetRotation; // Rotation in radians

  const FlyingOnboardItem({
    super.key,
    required this.data,
    required this.startPosition,
    required this.endPosition,
    required this.onAnimationComplete,
    this.targetRotation = 0.0, // Default to no rotation
  });

  @override
  State<FlyingOnboardItem> createState() => FlyingOnboardItemState();
}

class FlyingOnboardItemState extends State<FlyingOnboardItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bounceController;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.endPosition,
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

    // Bounce animation - moves up and down
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 20.0) // Move up 10 pixels
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 20.0, end: 0.0) // Move back down
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  // Public method to trigger bounce animation
  void triggerBounce() {
    _bounceController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _bounceController]),
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy + _bounceAnimation.value, // Add bounce offset
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 360, // Approx height of card
                child: OnboardCard(data: widget.data),
              ),
            ),
          ),
        );
      },
    );
  }
}
