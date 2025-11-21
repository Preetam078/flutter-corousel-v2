import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class DodCardFront extends StatefulWidget {
  final bool isCartHandleMove;
  final ValueChanged<bool> onCartHandleMove;
  final Color? cartColor;

  const DodCardFront({
    super.key,
    required this.onCartHandleMove,
    required this.isCartHandleMove,
    this.cartColor,
  });

  @override
  State<DodCardFront> createState() => DodCardFrontState();
}

class DodCardFrontState extends State<DodCardFront>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bounceController;
  late Animation<double> _wobble;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Front wobble: about 10 degrees
    _wobble = Tween(
      begin: -pi / 18,
      end: pi / 9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Bounce animation - moves up and down
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 10.0) // Move up 10 pixels
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: 0.0) // Move back down
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);
  }

  // Public method to trigger bounce animation
  void triggerBounce() {
    _bounceController.forward(from: 0.0);
  }

  Future<void> _playSmallWobble(int count) async {
    for (int i = 0; i < count; i++) {
      if (!mounted) return;
      await _controller.forward(from: 0);
      if (!mounted) return;
      await _controller.reverse();
    }
    setState(() {
      widget.onCartHandleMove(false);
    });
  }

  @override
  void didUpdateWidget(covariant DodCardFront oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCartHandleMove) {
      // FIRST wobble animation: forward then reverse
      _controller.forward(from: 0).then((_) {
        if (!mounted) return;
        _controller.reverse().then((_) async {
          if (!mounted) return;

          // SECOND wobble: smaller and faster, 3 times
          _controller.duration = const Duration(milliseconds: 70);
          _wobble = Tween(begin: -pi / 36, end: pi / 36).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );

          await _playSmallWobble(3);

          if (!mounted) return;
          _controller.reset();
          // Reset duration and wobble for next time
          _controller.duration = const Duration(milliseconds: 350);
          _wobble = Tween(begin: -pi / 18, end: pi / 9).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
        });
      });
    } else {
      _controller.stop();
      _controller.reset();
    }
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
      animation: _bounceController,
      builder: (context, child) {
        return Positioned(
          bottom: 0 - _bounceAnimation.value, // Apply bounce offset (negative because bottom positioning)
          left: 0,
          right: 0,
          child: SizedBox(
            height: 210,
            width: 150,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cart body (no rotation)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    'lib/image/cart_front.svg',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    // colorFilter: ColorFilter.mode(Color(0xFF004F8C), BlendMode.srcIn),
                    // colorFilter: widget.cartColor != null
                    //     ? ColorFilter.mode(
                    //         widget.cartColor!,
                    //         BlendMode.srcIn,
                    //       )
                    //     : null,
                  ),
                ),

                // LEFT HANDLE (hinge at right)
                Positioned(
                  top: 16,
                  left:40,
                  height: 100,
                  width: 125,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform(
                        alignment: Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..rotateZ(widget.isCartHandleMove ? _wobble.value : 0),
                        child: child,
                      );
                    },
                    child: SvgPicture.asset(
                      'lib/image/handle_front_lhs.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // RIGHT HANDLE (hinge at left)
                Positioned(
                  top: 16,
                  right:40,
                  height: 100,
                  width: 125,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..rotateZ(widget.isCartHandleMove ? -_wobble.value : 0),
                        child: child,
                      );
                    },
                    child: SvgPicture.asset(
                      'lib/image/handle_front_rhs.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}