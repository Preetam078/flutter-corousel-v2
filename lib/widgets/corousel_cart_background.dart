import 'package:flutter/material.dart';

class CarouselCartBackground extends StatefulWidget {
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;

  const CarouselCartBackground({
    super.key,
    this.height = 1000,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<CarouselCartBackground> createState() => _CarouselCartBackgroundState();
}

class _CarouselCartBackgroundState extends State<CarouselCartBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start animation when widget is built
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    widget.primaryColor ?? const Color(0xFF8B3A3A), // Dark red at bottom
                    widget.secondaryColor ?? const Color(0xFF4A1F1F), // Darker red
                    Colors.transparent, // Fade to transparent at top
                  ],
                  stops: const [0.0, 0.2, 0.6],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
