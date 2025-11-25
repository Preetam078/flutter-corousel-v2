import 'package:flutter/material.dart';

class CarouselCartInfo extends StatefulWidget {
  final int itemCount;
  final VoidCallback? onViewCart;
  final Color? backgroundColor;
  final Color? textColor;
  final List<String>? itemImages;

  const CarouselCartInfo({
    super.key,
    this.itemCount = 0,
    this.onViewCart,
    this.backgroundColor,
    this.textColor,
    this.itemImages,
  });

  @override
  State<CarouselCartInfo> createState() => _CarouselCartInfoState();
}

class _CarouselCartInfoState extends State<CarouselCartInfo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _dropController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _dropAnimation;
  bool _hasAnimated = false;
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _dropAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start from above
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeInOut,
    ));

    if (widget.itemCount > 0) {
      _controller.value = 1.0;
      _dropController.value = 1.0;
      _hasAnimated = true;
    }
    
    _lastItemCount = widget.itemCount;
  }

  @override
  void didUpdateWidget(CarouselCartInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only animate on the FIRST item addition (0 -> 1)
    if (widget.itemCount > 0 && oldWidget.itemCount == 0 && !_hasAnimated) {
      _hasAnimated = true;
      _controller.forward();
      _dropController.forward(from: 0.0);
    } else if (widget.itemCount == 0 && oldWidget.itemCount > 0) {
      // Reset when all items are removed
      _hasAnimated = false;
      _controller.reverse();
    } else if (widget.itemCount > _lastItemCount && widget.itemCount > 0) {
      // New item added - trigger drop animation
      _dropController.forward(from: 0.0);
    } else if (widget.itemCount > 0 && _hasAnimated) {
      // Keep at end position
      _controller.value = 1.0;
    }
    
    _lastItemCount = widget.itemCount;
  }

  @override
  void dispose() {
    _controller.dispose();
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.itemCount > 0;

    return Positioned(
      left: 70,
      right: 70,
      bottom: 50,
      child: GestureDetector(
        onTap: widget.onViewCart,
        child: Container(
          height: 45,
          padding: EdgeInsets.only(left: 5, right: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.backgroundColor ?? const Color(0xFFFFFFFF), // #FFFFFF
                const Color(0xFFE0E0E0), // #E0E0E0
                const Color(0xFFD2D2D2), // #D2D2D2
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: hasItems
              ? Row(
                  children: [
                    // Animated circular overlapping images
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SizedBox(
                          height: 32,
                          width: _calculateImageStackWidth(),
                          child: Stack(
                            children: List.generate(
                              widget.itemCount > 3 ? 3 : widget.itemCount,
                              (index) {
                                final displayCount = widget.itemCount > 3 ? 3 : widget.itemCount;
                                final isLastItem = index == displayCount - 1;
                                
                                return Positioned(
                                  left: index * 20.0,
                                  child: isLastItem
                                      ? // Animate only the last (newest) item
                                      SlideTransition(
                                          position: _dropAnimation,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                              color: Colors.white,
                                              image: DecorationImage(
                                                image: AssetImage(
                                                  widget.itemImages != null &&
                                                          index < widget.itemImages!.length
                                                      ? widget.itemImages![index]
                                                      : 'lib/image/sample.png',
                                                ),
                                                fit: BoxFit.fitHeight,
                                              ),
                                            ),
                                          ),
                                        )
                                      : // Static for other items
                                      Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: AssetImage(
                                                widget.itemImages != null &&
                                                        index < widget.itemImages!.length
                                                    ? widget.itemImages![index]
                                                    : 'lib/image/sample.png',
                                              ),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const SizedBox(width: 12),
                    ),

                    // Item count text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          '${widget.itemCount} ${widget.itemCount == 1 ? 'ITEM' : 'ITEMS'}',
                          style: TextStyle(
                            color: widget.textColor ?? Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // VIEW CART text (slides in from right)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VIEW CART',
                            style: TextStyle(
                              color: widget.textColor ?? Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: widget.textColor ?? Colors.black87,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'YOUR CART',
                    style: TextStyle(
                      color: widget.textColor ?? Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  double _calculateImageStackWidth() {
    if (widget.itemCount == 0) return 0;
    if (widget.itemCount == 1) return 32;
    if (widget.itemCount == 2) return 52;
    return 72;
  }
}
