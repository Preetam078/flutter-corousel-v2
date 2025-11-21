
import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class DodCardBack extends StatefulWidget {
  final bool isCartHandleMove;   // <-- wobble trigger
  final List<CarouselItem> cartItems;


  const DodCardBack({
    super.key,
    required this.isCartHandleMove,
    required this.cartItems,
  });

  @override
  State<DodCardBack> createState() => _DodCardBackState();
}

class _DodCardBackState extends State<DodCardBack>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _wobble;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // 10° wobble animation
    _wobble = Tween<double>(begin: -pi / 22, end: pi / 11).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _playSmallWobble(int count) async {
    for (int i = 0; i < count; i++) {
      if (!mounted) return;
      await _controller.forward(from: 0);
      if (!mounted) return;
      await _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant DodCardBack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCartHandleMove) {
      // FIRST wobble animation: forward then reverse
      _controller.forward(from: 0).then((_) {
        if (!mounted) return;
        _controller.reverse().then((_) async {
          if (!mounted) return;
          
          // SECOND wobble: smaller and faster, 3 times
          _controller.duration = const Duration(milliseconds: 70);
          _wobble = Tween<double>(begin: -pi / 44, end: pi / 44).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
          
          await _playSmallWobble(3);
          
          if (!mounted) return;
          _controller.reset();
          // Reset duration and wobble for next time
          _controller.duration = const Duration(milliseconds: 350);
          _wobble = Tween<double>(begin: -pi / 22, end: pi / 11).animate(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cart body
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'lib/image/cart_back.svg',
              width: 158,
              height: 158,
              fit: BoxFit.contain,
            ),
          ),

          // LEFT HANDLE — hinge at RIGHT side
          Positioned(
            top: 0,
            left: 45,
            height: 100,
            width: 130,
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
                'lib/image/handle_back_lhs.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // RIGHT HANDLE — hinge at LEFT side
          Positioned(
            top: 0,
            right: 45,
            height: 100,
            width: 130,
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
                'lib/image/handle_back_rhs.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // CartItems(
          //   cartItems: widget.cartItems
          // )
        ],
      ),
    );
  }
}