import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';
import 'draggable_carousel_card.dart';

class CurvedCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final Function(CarouselItem, double) onPullDown;
  final PageController pageController;
  final Set<String> hiddenItems;
  final Animation<double>? gapAnimation;
  final int removedIndex;
  final int totalCountBeforeRemoval;

  const CurvedCarousel({
    super.key,
    required this.items,
    required this.onPullDown,
    required this.pageController,
    this.hiddenItems = const {},
    this.gapAnimation,
    this.removedIndex = -1,
    this.totalCountBeforeRemoval = 0,
  });

  @override
  State<CurvedCarousel> createState() => _CurvedCarouselState();
}

class _CurvedCarouselState extends State<CurvedCarousel> {
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      setState(() {
        _currentPage = widget.pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    // widget.pageController.dispose(); // Don't dispose passed controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      itemCount: widget.items.length,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        
        if (widget.hiddenItems.contains(item.id)) {
          return const SizedBox(); // Render empty space for hidden items
        }
        
        // Calculate offset for curved effect
        double relativePosition = index - _currentPage;
        // User requested "just 5% below", assuming card height ~400, 5% is 20.
        double verticalOffset = (relativePosition.abs() * 10).clamp(0.0, 50.0);
        
        // Calculate tilt (rotation)
        // User requested "slightly tilted".
        // We'll rotate around the Z axis.
        // Left card (negative relativePosition) -> tilt left? or right?
        // Usually side cards tilt outwards.
        // Let's try a small angle proportional to distance.
        // When only one item is left, rotation should be 0
        double rotationAngle = widget.items.length == 1 ? 0.0 : relativePosition * 0.10; // approx 3 degrees per unit

        // When only one item is left, it should always be draggable
        bool isCurrent = widget.items.length == 1 || index == _currentPage.round();
        
        Widget child = DraggableCarouselCard(
            key: ValueKey(item.id),
            item: item,
            isCurrent: isCurrent,
            onPulledDown: (offset) => widget.onPullDown(item, offset),
          );
          
        // Apply rotation
        child = Transform.rotate(
          angle: rotationAngle,
          child: child,
        );

        // Apply gap closing animation
        // Logic:
        // - If removing the LAST item: items before it slide backward (left to right)
        // - If removing a MIDDLE item (excluding first and last): no animation
        // - If removing the FIRST item: items after it slide forward (right to left)
        if (widget.gapAnimation != null && widget.removedIndex != -1) {
          return AnimatedBuilder(
            animation: widget.gapAnimation!,
            builder: (context, child) {
              // Use same gap width for both forward and backward animations
              double width = MediaQuery.of(context).size.width * 0.55;
              
              // Apply easing curve for smoother animation
              final curvedValue = Curves.easeOutCubic.transform(widget.gapAnimation!.value);
              double offset = 0.0;
              
              // Check if we removed the last item
              bool removedLastItem = widget.totalCountBeforeRemoval > 0 && 
                                     widget.removedIndex == widget.totalCountBeforeRemoval - 1;
              
              // Check if we removed the first item
              bool removedFirstItem = widget.removedIndex == 0;
              
              if (removedLastItem && index < widget.removedIndex) {
                // Removed the last item: items before it slide backward (left to right)
                // Animation goes from 0.0 -> 1.0, offset goes from -width -> 0
                offset = -width * (1.0 - curvedValue);
              } else if ((removedFirstItem || (!removedLastItem && index >= widget.removedIndex))) {
                // Removed first item OR middle item: items after it slide forward (right to left)
                // Animation goes from 0.0 -> 1.0, offset goes from +width -> 0
                offset = width * (1.0 - curvedValue);
              }
              // Items before removed index (when removing middle item): no animation (offset stays 0)
              
              return Transform.translate(
                offset: Offset(offset, verticalOffset),
                child: child,
              );
            },
            child: child,
          );
        }

        return Transform.translate(
          offset: Offset(0, verticalOffset),
          child: child,
        );
      },
    );
  }
}
