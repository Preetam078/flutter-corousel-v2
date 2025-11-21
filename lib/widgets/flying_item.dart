import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';
import 'carousel_card.dart';

class FlyingItem extends StatefulWidget {
  final CarouselItem item;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onAnimationComplete;

  const FlyingItem({
    super.key,
    required this.item,
    required this.startPosition,
    required this.endPosition,
    required this.onAnimationComplete,
  });

  @override
  State<FlyingItem> createState() => _FlyingItemState();
}

class _FlyingItemState extends State<FlyingItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

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
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7, // Approx height of card
              child: CarouselCard(item: widget.item),
            ),
          ),
        );
      },
    );
  }
}
